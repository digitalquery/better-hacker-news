#!/bin/bash
# Build distributable extension packages in ./dist
set -euo pipefail
cd "$(dirname "$0")"

VERSION=$(python3 -c "import json; print(json.load(open('manifest.json'))['version'])")
SLUG=$(python3 -c "import json,re; n=json.load(open('manifest.json'))['name']; print(re.sub(r'[^a-z0-9]+', '-', n.lower()).strip('-'))")
mkdir -p dist
rm -f "dist/$SLUG-firefox-$VERSION.zip" "dist/$SLUG-chrome-$VERSION.zip"

# Firefox / addons.mozilla.org: manifest.json must be at the root of the zip.
zip -r -X "dist/$SLUG-firefox-$VERSION.zip" . \
  -x '.git/*' '.gitignore' 'AGENTS.md' 'dist/*' 'screenshots/*' 'notes' 'zip.sh' 'js/jquery-3.2.1.js' '.DS_Store' '*/.DS_Store'

# Chrome web store. Chrome ignores browser_specific_settings, so the same
# package contents work for both stores.
cp "dist/$SLUG-firefox-$VERSION.zip" "dist/$SLUG-chrome-$VERSION.zip"

echo "Built:"
ls -lh dist/*.zip
