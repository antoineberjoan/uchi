#!/bin/bash
# Télécharge la dernière application construite par GitHub sur la branche principale.
# Elle est signée en local (ad hoc) et vise les Mac Apple Silicon.
set -euo pipefail
imi_repository="antoineberjoan/uchi"
imi_destination="${1:-$HOME/Downloads/imi}"

if ! command -v gh >/dev/null 2>&1; then
  echo "Installez GitHub CLI avec « brew install gh », puis lancez « gh auth login »." >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "Connectez-vous d'abord avec « gh auth login »." >&2
  exit 1
fi

imi_run="$(gh run list --repo "$imi_repository" --workflow verify.yml --branch main \
  --status success --limit 1 --json databaseId --jq '.[0].databaseId // empty')"
if [[ -z "$imi_run" ]]; then
  echo "Aucune construction réussie sur main. Vérifiez l'onglet Actions du dépôt." >&2
  exit 1
fi

rm -rf "$imi_destination"
mkdir -p "$imi_destination"
gh run download "$imi_run" --repo "$imi_repository" --name imi-macOS --dir "$imi_destination"
ditto -x -k "$imi_destination/imi-macOS.zip" "$imi_destination"
rm "$imi_destination/imi-macOS.zip"
echo "Application prête : $imi_destination/imi.app (construction $imi_run)"
open "$imi_destination"
