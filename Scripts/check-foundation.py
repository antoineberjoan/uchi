#!/usr/bin/env python3
"""Ancien chemin : délègue à scripts/check-foundation.py."""
import runpy
runpy.run_path(__import__("pathlib").Path(__file__).resolve().parents[1] / "scripts/check-foundation.py")
