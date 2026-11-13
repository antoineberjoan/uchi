#!/bin/sh
# Lanceur unique des contrôles imi (fonder § 6.5).
set -eu
cd "$(dirname "$0")"
SOPHOS="${SOPHOS_ROOT:-${SOPHOS:-/agent/repos/sophos}}"
export SOPHOS_ROOT="$SOPHOS"
if [ ! -f "$SOPHOS/outils/jetons.mjs" ]; then
  echo "Sophos absent : cloner antoineberjoan/sophos et définir SOPHOS_ROOT." >&2
  exit 1
fi
python3 scripts/check-foundation.py
node "$SOPHOS/outils/jetons.mjs" Resources/Brand/tokens.json --verifier
node "$SOPHOS/outils/carte.mjs" --verifier
if command -v swift >/dev/null 2>&1; then
  swift test
else
  echo "Swift absent sur ce runner. Les tests et la construction native restent au workflow macOS."
fi
