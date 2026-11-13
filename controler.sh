#!/bin/sh
# Lanceur unique des contrôles Graker (fonder § 6.5).
set -eu
cd "$(dirname "$0")"
SOPHOS="${SOPHOS_ROOT:-/agent/repos/sophos}"
python3 scripts/check-foundation.py 2>/dev/null || python3 Scripts/check-foundation.py
node "$SOPHOS/outils/jetons.mjs" Resources/Brand/tokens.json --verifier
node "$SOPHOS/outils/carte.mjs" --verifier
swift test
