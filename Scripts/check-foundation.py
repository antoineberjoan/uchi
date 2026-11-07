#!/usr/bin/env python3
"""Cliquets Sophos : usages, contrastes, rôles, frontières et génération."""
import re
import runpy
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
model = runpy.run_path(str(ROOT / "Scripts/generate-tokens.py"))
tokens = model["read_tokens"]()
resolve, convert = model["resolve"], model["convert_color"]
errors = []

for name in tokens:
    try:
        resolve(tokens, name)
    except (KeyError, ValueError) as error:
        errors.append(f"{name} : {error}")


def luminance(color):
    linear = [v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4 for v in color]
    return sum(a*b for a, b in zip(linear, (.2126, .7152, .0722)))


def contrast(a, b):
    low, high = sorted((luminance(a), luminance(b)))
    return (high + .05) / (low + .05)


count = 0
for theme in ("light", "dark"):
    for foreground in ("text", "text-muted", "danger", "success", "focus"):
        for background in ("background", "surface", "input"):
            ratio = contrast(convert(resolve(tokens, f"role-{foreground}-{theme}")),
                             convert(resolve(tokens, f"role-{background}-{theme}")))
            minimum = 3 if foreground == "focus" else 4.5
            count += 1
            if ratio < minimum:
                errors.append(f"Contraste {foreground}/{background}/{theme} : {ratio:.2f} < {minimum}")
    ratio = contrast(convert(resolve(tokens, f"role-on-accent-{theme}")),
                     convert(resolve(tokens, f"role-accent-{theme}")))
    count += 1
    if ratio < 4.5:
        errors.append(f"Contraste du bouton en {theme} : {ratio:.2f} < 4.5")
    ratio = contrast(convert(resolve(tokens, f"role-variant-explanation-text-{theme}")),
                     convert(resolve(tokens, f"role-variant-explanation-background-{theme}")))
    count += 1
    if ratio < 4.5:
        errors.append(f"Contraste de la carte d’explication en {theme} : {ratio:.2f} < 4.5")

target = ROOT / "Sources/GrakerLocal/Presentation/Tokens.swift"
if not target.exists() or target.read_text() != model["render"]():
    errors.append("Tokens.swift absent ou périmé.")
roles = set(re.findall(r"static (?:let|var) (\w+)", model["render"]()))

for path in (ROOT / "Sources").rglob("*.swift"):
    text = path.read_text()
    relative = path.relative_to(ROOT)
    for role in re.findall(r"Tokens\.(\w+)", text):
        if role not in roles:
            errors.append(f"Rôle inconnu ou primitive interdite : {relative} → {role}")
    imports = re.findall(r"^import (\w+)", text, re.M)
    if "GrakerCore" in path.parts and set(imports) - {"Foundation"}:
        errors.append(f"Frontière du noyau : {relative} importe {imports}")
    if "Presentation" in path.parts and path.name != "Tokens.swift":
        if re.search(r"Color\((?:red:|white:)|NSColor\(|#[0-9a-fA-F]{6}\b|--(?:gray|blue|space)-", text):
            errors.append(f"Valeur visuelle brute : {relative}")
        if re.search(r"(?:Color\.|foregroundStyle\(\.|tint\(\.)(?:red|blue|green|gray|white|black)\b", text):
            errors.append(f"Couleur hors rôles : {relative}")
        if re.search(r"\.(?:padding|cornerRadius|opacity)\(\s*\d|\.system\(size:\s*\d|(?:width|height):\s*\d", text):
            errors.append(f"Dimension hors tokens : {relative}")
    if re.search(r"\bprint\(|\bdebugPrint\(|\bNSLog\(", text):
        errors.append(f"Log non autorisé : {relative}")

if errors:
    sys.exit("\n".join(errors))
print(f"Fondation vérifiée : {len(tokens)} tokens documentés, {count} contrastes, génération et frontières.")
