#!/usr/bin/env python3
"""Checks every profile file against the contract and the SKILL.md catalogue."""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ROLES = {"api", "web", "mobile", "db", "infra", "any"}
CHECK_ROOT = {"node", "python", "posix", "per-variant"}
STATUS = {"proven", "written"}
REQUIRED_FIELDS = ("profile", "role", "check-root", "status")

errors: list[str] = []


def front_matter(text: str, path: Path) -> dict[str, str]:
    match = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not match:
        errors.append(f"{path.name}: missing front matter")
        return {}
    fields = {}
    for line in match.group(1).splitlines():
        key, _, value = line.partition(":")
        fields[key.strip()] = value.split("#")[0].strip()
    return fields


profiles: dict[str, dict[str, str]] = {}
for path in sorted((ROOT / "profiles").glob("*.md")):
    if path.name == "README.md":
        continue
    text = path.read_text(encoding="utf-8")
    fields = front_matter(text, path)
    for key in REQUIRED_FIELDS:
        if key not in fields:
            errors.append(f"{path.name}: front matter lacks '{key}'")
    name = fields.get("profile", "")
    if name != path.stem:
        errors.append(f"{path.name}: profile '{name}' does not match file name")
    if fields.get("role") not in ROLES:
        errors.append(f"{path.name}: role '{fields.get('role')}' not in {sorted(ROLES)}")
    if fields.get("check-root") not in CHECK_ROOT:
        errors.append(f"{path.name}: check-root '{fields.get('check-root')}' invalid")
    if fields.get("status") not in STATUS:
        errors.append(f"{path.name}: status '{fields.get('status')}' invalid")
    if f"# `{path.stem}`" not in text:
        errors.append(f"{path.name}: missing '# `{path.stem}`' heading")
    if "**Verify**" not in text and "| Verify |" not in text and "Verify:" not in text:
        errors.append(f"{path.name}: no Verify item")
    profiles[path.stem] = fields

skill = (ROOT / "SKILL.md").read_text(encoding="utf-8")
catalogue = dict(
    (name, (role, status))
    for role, name, status in re.findall(
        r"^\| (\w+) \| \[`([a-z0-9-]+)`\]\(profiles/[a-z0-9-]+\.md\) \| [^|]+ \| (\w+) \|",
        skill,
        re.M,
    )
)
for name, fields in profiles.items():
    if name not in catalogue:
        errors.append(f"{name}: not listed in the SKILL.md catalogue")
        continue
    role, status = catalogue[name]
    if role != fields.get("role"):
        errors.append(f"{name}: catalogue role '{role}' != front matter '{fields.get('role')}'")
    if status != fields.get("status"):
        errors.append(f"{name}: catalogue status '{status}' != front matter '{fields.get('status')}'")
for name in catalogue:
    if name not in profiles:
        errors.append(f"{name}: in the catalogue but profiles/{name}.md is missing")

for link in re.findall(r"\]\(((?:profiles|reference|templates)/[^)#]*)\)", skill):
    if not (ROOT / link).exists():
        errors.append(f"SKILL.md links to missing {link}")

if errors:
    print("\n".join(f"FAIL {e}" for e in errors))
    sys.exit(1)
print(f"profiles ok ({len(profiles)} profiles, catalogue and links consistent)")
