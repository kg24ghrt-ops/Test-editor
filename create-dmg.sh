#!/bin/bash
# create-dmg.sh - Build and package PythonRunner.app

set -e

APP_NAME="PythonRunner"
VERSION="1.0.0"
BUILD_DIR=".build/release"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
DMG_PATH="$APP_NAME $VERSION.dmg"

echo "🔨 Building $APP_NAME for macOS 10.15+..."
swift build -c release --arch x86_64  # 2013 MBA is Intel x86_64

echo "📦 Creating DMG with create-dmg..."
create-dmg \
  --volname "$APP_NAME" \
  --volicon "assets/AppIcon.icns" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 175 120 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 425 120 \
  --no-code-sign \
  "$DMG_PATH" \
  "$APP_PATH"

echo "✅ Done! DMG created: $DMG_PATH"
echo "💡 Tip: Set HF_TOKEN before running:"
echo "   export HF_TOKEN='your_token_here' && open '$APP_PATH'"