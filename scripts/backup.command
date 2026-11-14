#!/bin/zsh
cd -- "${0:A:h:h}" || exit 1
/usr/bin/env python3 scripts/backup_project.py
result=$?
if [[ -t 0 ]]; then
  read "?按回车关闭窗口……"
fi
exit $result
