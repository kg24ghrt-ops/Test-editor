#!/bin/bash
# generate_project_report.sh - macOS compatible project structure exporter

OUTPUT_FILE="${1:-project_structure.txt}"
PROJECT_ROOT="$(pwd)"

echo "🔍 Generating project structure report..."
echo "📁 Root: $PROJECT_ROOT"
echo "📄 Output: $OUTPUT_FILE"
echo ""

{
  echo "=== PROJECT STRUCTURE REPORT ==="
  echo "Generated: $(date)"
  echo "Root: $PROJECT_ROOT"
  echo "macOS: $(sw_vers -productVersion)"
  echo ""
  
  echo "=== DIRECTORY TREE (Source Files Only) ==="
  if command -v tree &> /dev/null; then
    tree -I '.git|DerivedData|build|Pods|Carthage|.swiftpm|node_modules|*.xcuserdatad|*.o|*.a|*.dylib|*.framework|*.dSYM' \
         --dirsfirst -L 5 -h -s -N -f \
         -P '*.swift|*.h|*.m|*.mm|*.storyboard|*.xib|*.xcassets|Podfile|Podfile.lock|Package.swift|Package.resolved|Info.plist|*.json|*.md|README*|Makefile|CMakeLists.txt|*.py|*.js|*.ts|*.graphql|*.proto' \
         . 2>/dev/null || echo "⚠️ tree command failed"
  else
    echo "⚠️ 'tree' not installed. Install with: brew install tree"
    echo "Falling back to find command..."
    find . -type f \( \
      -name "*.swift" -o -name "*.h" -o -name "*.m" -o -name "*.mm" -o \
      -name "*.storyboard" -o -name "*.xib" -o -name "*.xcassets" -o \
      -name "Podfile" -o -name "Package.swift" -o -name "Info.plist" -o \
      -name "*.json" -o -name "*.md" -o -name "Makefile" -o -name "*.py" -o \
      -name "*.js" -o -name "*.ts" \) \
      ! -path "*/.git/*" ! -path "*/DerivedData/*" ! -path "*/build/*" \
      ! -path "*/Pods/*" ! -path "*/Carthage/*" ! -path "*/.swiftpm/*" \
      ! -path "*/node_modules/*" ! -path "*/__pycache__/*" \
      | sed 's|^\./||' | sort
  fi
  
  echo ""
  echo "=== FILE COUNTS BY TYPE ==="
  find . -type f \( \
    -name "*.swift" -o -name "*.h" -o -name "*.m" -o -name "*.mm" -o \
    -name "*.storyboard" -o -name "*.xib" -o -name "*.xcassets" -o \
    -name "Podfile" -o -name "Package.swift" -o -name "Info.plist" -o \
    -name "*.json" -o -name "*.md" -o -name "Makefile" -o -name "*.py" -o \
    -name "*.js" -o -name "*.ts" \) \
    ! -path "*/.git/*" ! -path "*/DerivedData/*" ! -path "*/build/*" \
    ! -path "*/Pods/*" ! -path "*/Carthage/*" ! -path "*/.swiftpm/*" \
    ! -path "*/node_modules/*" \
    | sed 's|^\./||' | \
    awk -F. '{print $NF}' | sort | uniq -c | sort -rn
  
  echo ""
  echo "=== LARGEST SOURCE FILES (>100KB) ==="
  find . -type f \( -name "*.swift" -o -name "*.h" -o -name "*.m" -o -name "*.mm" \) \
    -size +100k \
    ! -path "*/.git/*" ! -path "*/Pods/*" ! -path "*/Carthage/*" \
    -exec ls -lh {} \; 2>/dev/null | awk '{print $9, "(", $5, ")"}' | sed 's|^\./||'
  
  echo ""
  echo "=== END OF REPORT ==="
} > "$OUTPUT_FILE"

echo "✅ Done! File saved to: $OUTPUT_FILE"
echo "📊 Total lines: $(wc -l < "$OUTPUT_FILE")"
echo ""
echo "📎 To share with Qwen:"
echo "1. Open $OUTPUT_FILE in TextEdit or VS Code"
echo "2. Copy all content (Cmd+A, Cmd+C)"
echo "3. Paste in your next message"