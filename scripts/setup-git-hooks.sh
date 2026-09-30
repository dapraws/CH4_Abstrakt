#!/usr/bin/env bash
set -euo pipefail

HOOKS_DIR=".git/hooks"
PRE_COMMIT="$HOOKS_DIR/pre-commit"

echo "Setting up Git pre-commit hook..."

mkdir -p "$HOOKS_DIR"

cat << 'EOF' > "$PRE_COMMIT"
#!/usr/bin/env bash
./scripts/verify.sh
EOF

chmod +x "$PRE_COMMIT"
chmod +x scripts/verify.sh

echo "✅ Git pre-commit hook successfully installed at $PRE_COMMIT."
