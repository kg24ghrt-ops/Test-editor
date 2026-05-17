#!/bin/bash
# Smart snapshot for PythonRunner project
set -e

NAME="PythonRunner_$(date +%Y%m%d_%H%M)"
echo "📸 Creating snapshot: $NAME"

# Create temp dir
mkdir -p "$NAME"

# Copy essential files only
find . -maxdepth 3 -type f \( \
  -name "*.swift" -o \
  -name "Package.swift" -o \
  -name "Info.plist" -o \
  -name "*.icns" -o \
  -name "*.yml" -o \
  -name "*.md" -o \
  -name "server.py" \
\) ! -path "./.build/*" \
  ! -path "./.git/*" \
  ! -name ".DS_Store" \
  -exec cp --parents {} "$NAME/" \; 2>/dev/null || true

# Add manifest
cat > "$NAME/PROJECT_INFO.txt" << MANIFEST
PythonRunner Snapshot
Generated: $(date)
macOS: $(sw_vers -productVersion)
Swift: $(swift --version | head -n1)
Architecture: $(uname -m)

Files included:
$(find "$NAME" -type f | wc -l | xargs) files
MANIFEST

# Compress
zip -rq "$NAME.zip" "$NAME"
rm -rf "$NAME"

echo "✅ Snapshot ready: $(pwd)/$NAME.zip"
echo "💡 Share this .zip with your next AI session!"
