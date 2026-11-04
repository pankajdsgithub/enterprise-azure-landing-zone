#!/usr/bin/env python3
"""Static wiring check (no Azure / provider download needed).
Verifies for every root: module call args exist, required inputs are supplied,
and module.<name>.<output> references exist. Complements terraform validate; does not replace it."""
import re, sys, pathlib

repo = pathlib.Path(__file__).resolve().parent.parent
errors = []

def blocks(text, kw):
    """yield (header_regex_match, body) for top-level blocks starting with kw."""
    for m in re.finditer(rf'^{kw}\s+"([^"]+)"(?:\s+"([^"]+)")?\s*\{{', text, re.M):
        i, depth = m.end(), 1
        while depth and i < len(text):
            depth += {'{': 1, '}': -1}.get(text[i], 0); i += 1
        yield m, text[m.end():i-1]

def top_level_keys(body):
    keys, depth = [], 0
    for line in body.splitlines():
        s = line.strip()
        if depth == 0:
            m = re.match(r'([A-Za-z_][\w]*)\s*=', s)
            if m: keys.append(m.group(1))
        depth += line.count('{') + line.count('[') + line.count('(') - line.count('}') - line.count(']') - line.count(')')
    return keys

def module_interface(path):
    v = (path / 'variables.tf').read_text()
    req, allv = set(), set()
    for m, body in blocks(v, 'variable'):
        allv.add(m.group(1))
        if not re.search(r'^\s*default\s*=', body, re.M): req.add(m.group(1))
    outs = {m.group(1) for m, _ in blocks((path / 'outputs.tf').read_text(), 'output')}
    return req, allv, outs

roots = [p for p in list((repo/'platform').iterdir()) + [repo/'application'] if (p/'main.tf').exists()]
for root in roots:
    text = "\n".join(f.read_text() for f in root.glob('*.tf'))
    mods = {}
    for m, body in blocks(text, 'module'):
        name = m.group(1)
        src = re.search(r'source\s*=\s*"([^"]+)"', body).group(1)
        target = (root / src).resolve()
        if not target.exists():
            errors.append(f"{root.name}: module.{name} source {src} not found"); continue
        req, allv, outs = module_interface(target)
        mods[name] = outs
        given = set(top_level_keys(body)) - {'source', 'count', 'for_each', 'providers', 'depends_on'}
        for g in given - allv: errors.append(f"{root.name}: module.{name} passes unknown input '{g}' (module {target.name})")
        for r in req - given: errors.append(f"{root.name}: module.{name} missing required input '{r}' (module {target.name})")
    for ref_mod, ref_out in re.findall(r'module\.(\w+)(?:\[[^\]]+\])?\.(\w+)', text):
        if ref_mod in mods and ref_out not in mods[ref_mod]:
            errors.append(f"{root.name}: reference module.{ref_mod}.{ref_out} - no such output")
    # var.* references must be declared
    declared = {m.group(1) for m, _ in blocks(text, 'variable')}
    for v in set(re.findall(r'\bvar\.(\w+)', text)) - declared:
        errors.append(f"{root.name}: var.{v} used but not declared")

# inside modules: var.* declared
for mod in (repo/'modules').iterdir():
    text = "\n".join(f.read_text() for f in mod.glob('*.tf'))
    declared = {m.group(1) for m, _ in blocks(text, 'variable')}
    for v in set(re.findall(r'\bvar\.(\w+)', text)) - declared:
        errors.append(f"modules/{mod.name}: var.{v} used but not declared")

print("\n".join(errors) if errors else "wiring OK: all module calls, outputs and variables resolve")
sys.exit(1 if errors else 0)
