#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)" || exit 1
exec /bin/bash "$SCRIPT_DIR/start.command" --status
