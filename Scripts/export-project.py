#!/usr/bin/env python3
"""Exporte les sources enregistrées et l'historique Git, sans l'état de session."""
import argparse
import shlex
import subprocess
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run_git(*arguments):
    return subprocess.check_output(["git", "-C", str(ROOT), *arguments])


def export_project(destination):
    if run_git("status", "--porcelain=v1").strip():
        raise SystemExit("Enregistrez les changements dans Git avant l'export.")
    head = run_git("rev-parse", "HEAD").decode().strip()
    branch = run_git("rev-parse", "--abbrev-ref", "HEAD").decode().strip()
    files = [name for name in run_git("ls-files", "-z").decode().split("\0") if name]
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="graker-export-") as directory:
        bundle = Path(directory) / "history.bundle"
        run_git("bundle", "create", str(bundle), "--all", "HEAD")
        run_git("bundle", "verify", str(bundle))
        temporary_archive = Path(directory) / "sources.zip"
        with zipfile.ZipFile(temporary_archive, "w", zipfile.ZIP_DEFLATED) as archive:
            for name in files:
                archive.write(ROOT / name, "graker-local/" + name)
            archive.write(bundle, "graker-local/history.bundle")
            archive.writestr("graker-local/EXPORT.txt", (
                "Graker Local — export des sources et de l'historique Git\n"
                f"Commit des sources : {head}\n"
                f"Branche des sources : {branch}\n"
                "Lisez README.md et AGENTS.md avant toute reprise.\n"
                "history.bundle contient les références Git ; restaurez-le avec git clone.\n"
                + (f"git clone --branch {shlex.quote(branch)} /chemin/history.bundle graker-local-review\n"
                   if branch != "HEAD" else
                   f"git clone /chemin/history.bundle graker-local-review\ngit -C graker-local-review checkout --detach {head}\n")
                +
                "Aucune transcription complète du chat, clé API ou application compilée.\n"
            ))
        destination.write_bytes(temporary_archive.read_bytes())
    print(f"Archive créée : {destination}")
    print(f"Commit : {head} ; fichiers enregistrés : {len(files)} ; historique Git inclus.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "dist/Graker-Local-sources.zip")
    arguments = parser.parse_args()
    export_project(arguments.output.resolve())
