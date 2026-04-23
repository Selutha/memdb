#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh: Install memdb (mem-cli binary, skills, hooks) into ~/.claude/
#
# Thin wrapper over src/install.sh — gives a consistent top-level entry point
# across the claude/ and memdb/ repos. src/install.sh remains the canonical
# installer.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/src/install.sh" "$@"
