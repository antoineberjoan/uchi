#!/bin/bash
# Télécharge la dernière application construite par GitHub sur la branche principale.
# Elle est signée en local (ad hoc) et vise les Mac Apple Silicon.
set -euo pipefail
graker_repository="antoineberjoan/uchi"
graker_destination="${1:-$HOME/Downloads/Graker Local}"

if ! command -v gh >/dev/null 2>&1; then
  echo "Installez GitHub CLI avec « brew install gh », puis lancez « gh auth login »." >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "Connectez-vous d'abord avec « gh auth login »." >&2
  exit 1
fi

graker_run="$(gh run list --repo "$graker_repository" --workflow verify.yml --branch main \
  --status success --limit 1 --json databaseId --jq '.[0].databaseId // empty')"
if [[ -z "$graker_run" ]]; then
  echo "Aucune construction réussie sur main. Vérifiez l'onglet Actions du dépôt." >&2
  exit 1
fi

rm -rf "$graker_destination"
mkdir -p "$graker_destination"
gh run download "$graker_run" --repo "$graker_repository" --name Graker-Local-macOS --dir "$graker_destination"
ditto -x -k "$graker_destination/Graker-Local-macOS.zip" "$graker_destination"
rm "$graker_destination/Graker-Local-macOS.zip"
echo "Application prête : $graker_destination/Graker Local.app (construction $graker_run)"
open "$graker_destination"
