#!/usr/bin/env python3
"""Cliquets Sophos : jetons, frontières de couches et absence de valeurs visuelles brutes."""
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOPHOS = Path(os.environ.get("SOPHOS_ROOT", "/agent/repos/sophos"))
errors = []

jetons = SOPHOS / "outils/jetons.mjs"
if jetons.exists():
    result = subprocess.run(["node", str(jetons), "Resources/Brand/tokens.json", "--verifier"],
                            cwd=ROOT, capture_output=True, text=True)
    if result.returncode != 0:
        errors.append(result.stderr.strip() or result.stdout.strip())
else:
    errors.append("jetons.mjs introuvable.")

for path in (ROOT / "Sources/GrakerCore").rglob("*.swift"):
    imports = re.findall(r"^import (\w+)", path.read_text(), re.M)
    allowed = {"Foundation", "CoreGraphics"} if path.name == "PanelPlacement.swift" else {"Foundation"}
    extra = set(imports) - allowed
    if extra:
        errors.append(f"Frontière du noyau : {path.relative_to(ROOT)} importe {sorted(extra)}")

for path in (ROOT / "Sources/GrakerUI").rglob("*.swift"):
    if re.search(r"^import (AppKit|UIKit)", path.read_text(), re.M):
        errors.append(f"Frontière GrakerUI : {path.relative_to(ROOT)} importe AppKit ou UIKit")

for path in (ROOT / "Sources/GrakerUI").rglob("*.swift"):
    text = path.read_text()
    relative = path.relative_to(ROOT)
    if not re.findall(r"Tokens\.\w+", text):
        continue
    if re.search(r"Color\((?:red:|white:)|NSColor\(|#[0-9a-fA-F]{6}\b", text):
        errors.append(f"Valeur visuelle brute : {relative}")
    if re.search(r"\.(?:padding|cornerRadius|opacity)\(\s*\d", text):
        errors.append(f"Dimension hors tokens : {relative}")

if not (ROOT / "Sources/GrakerDesign/Tokens.swift").exists():
    errors.append("Sources/GrakerDesign/Tokens.swift manque.")

if errors:
    sys.exit("\n".join(errors))
print("Fondation vérifiée : jetons, frontières et rôles de l’interface.")
