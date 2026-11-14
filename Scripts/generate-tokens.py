#!/usr/bin/env python3
"""Lit les rôles CSS et produit les valeurs SwiftUI. Bibliothèque standard seule."""
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Design/tokens.css"
TARGET = ROOT / "Sources/ImiDesign/Tokens.swift"


def read_tokens():
    text = SOURCE.read_text()
    declarations = re.findall(r"/\*\s*([^*]+)\*/\s*--([\w-]+):\s*([^;]+);", text)
    tokens = {name: value.strip() for usage, name, value in declarations if usage.strip()}
    names = re.findall(r"--([\w-]+):", text)
    if len(tokens) != len(names) or len(set(names)) != len(names):
        raise ValueError("Token sans usage écrit ou nom en double.")
    return tokens


def resolve(tokens, name, seen=()):
    if name in seen:
        raise ValueError("Boucle de tokens : " + name)
    value = tokens[name]
    ref = re.fullmatch(r"var\(--([\w-]+)\)", value)
    return resolve(tokens, ref[1], (*seen, name)) if ref else value


def convert_color(value):
    match = re.fullmatch(r"oklch\(([\d.]+) ([\d.]+) ([\d.]+)\)", value)
    if not match:
        raise ValueError("Couleur OKLCH attendue : " + value)
    lightness, chroma, hue = map(float, match.groups())
    a, b = chroma * math.cos(math.radians(hue)), chroma * math.sin(math.radians(hue))
    l = (lightness + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (lightness - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (lightness - 0.0894841775 * a - 1.2914855480 * b) ** 3
    linear = (4.0767416621*l - 3.3077115913*m + 0.2309699292*s,
              -1.2684380046*l + 2.6097574011*m - 0.3413193965*s,
              -0.0041960863*l - 0.7034186147*m + 1.7076147010*s)
    def encode(c):
        c = max(0, min(1, c))
        return 12.92*c if c <= 0.0031308 else 1.055*c**(1/2.4)-0.055
    return tuple(encode(c) for c in linear)


def camel(name):
    first, *parts = name.split("-")
    return first + "".join(p.title() for p in parts)


def render():
    tokens = read_tokens()
    result = ["// Généré depuis Design/tokens.css ; ne pas modifier.", "#if os(macOS)",
              "import SwiftUI", "import AppKit", "", "enum Tokens {"]
    for name in tokens:
        if not name.startswith("role-"):
            continue
        short = name.removeprefix("role-")
        if short.endswith("-dark"):
            continue
        if short.endswith("-light"):
            role = short.removesuffix("-light")
            light = convert_color(resolve(tokens, name))
            dark = convert_color(resolve(tokens, "role-" + role + "-dark"))
            values = lambda cs: ", ".join(f"{c:.8f}" for c in cs)
            result.append(f"    static let {camel(role)} = makeColor(light: ({values(light)}), dark: ({values(dark)}))")
        else:
            value = resolve(tokens, name)
            if short.startswith("weight-"):
                weights = {"100": "ultraLight", "200": "thin", "300": "light", "400": "regular", "500": "medium",
                           "600": "semibold", "700": "bold", "800": "heavy", "900": "black"}
                result.append(f"    static let {camel(short)}: Font.Weight = .{weights[value]}")
                continue
            if short == "family-body":
                designs = {"system-ui": "default", "serif": "serif", "monospace": "monospaced", "rounded": "rounded"}
                result.append(f"    static let familyBody: Font.Design = .{designs[value]}")
                continue
            number = re.fullmatch(r"([\d.]+)(px|s)?", value)
            if number:
                result.append(f"    static let {camel(short)}: CGFloat = {number[1]}")
    for role in ["body", "label", "caption", "title", "heading"]:
        weight = "weightTitle" if role in ["title", "heading"] else "weightBody"
        result.append(f"    static let font{role.title()} = Font.system(size: size{role.title()}, weight: {weight}, design: familyBody)")
    result.extend(["", "    private static func makeColor(light: (Double, Double, Double), dark: (Double, Double, Double)) -> Color {",
                   "        Color(nsColor: NSColor(name: nil) { appearance in",
                   "            let value = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light",
                   "            return NSColor(srgbRed: value.0, green: value.1, blue: value.2, alpha: 1)",
                   "        })", "    }", "}", "#endif", ""])
    return "\n".join(result)


if __name__ == "__main__":
    content = render()
    if "--check" in sys.argv:
        if not TARGET.exists() or TARGET.read_text() != content:
            sys.exit("Tokens.swift est à régénérer : python3 Scripts/generate-tokens.py")
        print("Tokens Swift à jour.")
    else:
        TARGET.parent.mkdir(parents=True, exist_ok=True)
        TARGET.write_text(content)
        print("Tokens Swift générés.")
