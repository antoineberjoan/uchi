#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "La construction de Graker Local nécessite macOS 15 ou plus et Xcode 16 ou plus." >&2
  exit 1
fi
python3 Scripts/check-foundation.py
swift test
swift build -c release
graker_binary_directory="$(swift build -c release --show-bin-path)"
graker_application="$(pwd)/dist/Graker Local.app"
mkdir -p "$graker_application/Contents/MacOS"
cp "$graker_binary_directory/GrakerLocal" "$graker_application/Contents/MacOS/GrakerLocal"
cat > "$graker_application/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>GrakerLocal</string>
  <key>CFBundleIdentifier</key><string>local.graker.personnel</string>
  <key>CFBundleName</key><string>Graker Local</string>
  <key>CFBundleDisplayName</key><string>Graker Local</string>
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
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$graker_application/Contents/Info.plist"
codesign --force --sign - "$graker_application"
codesign --verify --strict "$graker_application"
ditto -c -k --keepParent "$graker_application" "dist/Graker-Local-macOS.zip"
echo "Application construite : $graker_application"
