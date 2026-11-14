#!/bin/bash
# Double-click entry point; it does not import the database or stop unrelated services.
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)" || exit 1
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)" || exit 1
cd -- "$PROJECT_DIR" || exit 1
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif [ -x /Library/Frameworks/Python.framework/Versions/3.10/bin/python3 ]; then
  PYTHON_BIN=/Library/Frameworks/Python.framework/Versions/3.10/bin/python3
else
  echo "未找到 Python 3，请先检查本机 Python 环境。"
  exit 1
fi
"$PYTHON_BIN" "$PROJECT_DIR/scripts/project_runtime.py" "$@"
PROJECT_RESULT=$?
if [ -t 0 ]; then
  echo
  read -r -p "按回车关闭此窗口……" _PROJECT_REPLY
fi
exit "$PROJECT_RESULT"
