#!/bin/bash

CONFIG_NAME=hosts
CONFIG_PATH=/etc/
CUR_HASH=$(sha256sum "$CONFIG_PATH$CONFIG_NAME" | head -c 64)
NEW_HASH=$(sha256sum "$SOURCES$CONFIG_PATH$CONFIG_NAME" | head -c 64)

if [[ $CUR_HASH != $NEW_HASH ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Files changed. Updating."
  cp -a "$SOURCES$CONFIG_PATH$CONFIG_NAME" "$CONFIG_PATH"
  chown ubuntu:ubuntu "$CONFIG_PATH$CONFIG_NAME"
else
  echo "$(date "+%Y-%m-%d %T"): DEBUG: No files changed."
fi

unset CUR_HASH NEW_HASH CONFIG_NAME CONFIG_PATH
