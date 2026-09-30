#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "  Abstrakt DevOps: Pre-Commit Verification"
echo "=========================================="

staged_files=$(git diff --cached --name-only || true)

if [ -n "$staged_files" ]; then
    # 1. Check for unresolved merge conflict markers in staged files
    if echo "$staged_files" | xargs grep -E "^(<<<<<<<|=======|>>>>>>>)" 2>/dev/null; then
        echo "❌ Error: Unresolved merge conflict markers found in staged files."
        exit 1
    fi

    # 2. Check for private signing secrets or temporary local overrides accidentally staged
    if echo "$staged_files" | grep -E "Signing\.local\.xcconfig|\.env$" >/dev/null 2>&1; then
        echo "⚠️ Warning: Local signing or secret config file is staged for commit."
        exit 1
    fi
fi

# 3. If SwiftLint is installed, run it
if command -v swiftlint >/dev/null 2>&1; then
    echo "🔍 Running SwiftLint..."
    swiftlint lint --strict --quiet
    echo "✅ SwiftLint passed."
else
    echo "ℹ️ SwiftLint not installed locally; skipping local lint (will run in CI)."
fi

echo "✅ All pre-commit checks passed successfully."
