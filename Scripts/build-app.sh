#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "La construction de imi nécessite macOS 15 ou plus et Xcode 16 ou plus." >&2
  exit 1
fi
python3 scripts/check-foundation.py
swift test
swift build -c release
imi_binary_directory="$(swift build -c release --product Imi --show-bin-path)"
imi_application="$(pwd)/dist/imi.app"
mkdir -p "$imi_application/Contents/MacOS"
cp "$imi_binary_directory/Imi" "$imi_application/Contents/MacOS/Imi"
cat > "$imi_application/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>Imi</string>
  <key>CFBundleIdentifier</key><string>local.imi.personnel</string>
  <key>CFBundleName</key><string>imi</string>
  <key>CFBundleDisplayName</key><string>imi</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>15.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>NSAppTransportSecurity</key><dict><key>NSAllowsLocalNetworking</key><true/></dict>
</dict></plist>
PLIST
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$imi_application/Contents/Info.plist"
codesign --force --sign - "$imi_application"
codesign --verify --strict "$imi_application"
ditto -c -k --keepParent "$imi_application" "dist/imi-macOS.zip"
echo "Application construite : $imi_application"
