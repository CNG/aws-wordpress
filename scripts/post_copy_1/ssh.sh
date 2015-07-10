#!/bin/bash

CONFIG_NAME=ssh
CONFIG_PATH=/home/ubuntu/
CUR_HASH=$({ export LC_ALL=C;
  find "$CONFIG_PATH.$CONFIG_NAME" -type f -exec wc -c {} \; | sort; echo;
  find "$CONFIG_PATH.$CONFIG_NAME" -type f -exec sha256sum {} + | sort; echo;
  find "$CONFIG_PATH.$CONFIG_NAME" -type d | sort;
  find "$CONFIG_PATH.$CONFIG_NAME" -type d | sort | sha256sum;
  } | sha256sum)
NEW_HASH=$({ export LC_ALL=C;
  find "$SOURCES$CONFIG_PATH.$CONFIG_NAME" -type f -exec wc -c {} \; | sed "s|$SOURCES||" | sort; echo;
  find "$SOURCES$CONFIG_PATH.$CONFIG_NAME" -type f -exec sha256sum {} + | sed "s|$SOURCES||" | sort; echo;
  find "$SOURCES$CONFIG_PATH.$CONFIG_NAME" -type d | sed "s|$SOURCES||" | sort;
  find "$SOURCES$CONFIG_PATH.$CONFIG_NAME" -type d | sed "s|$SOURCES||" | sort | sha256sum;
  } | sha256sum)

if [[ $CUR_HASH != $NEW_HASH ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Files changed. Updating."
  cp -a "$SOURCES$CONFIG_PATH.$CONFIG_NAME" "$CONFIG_PATH"
  chmod -R 700 "$CONFIG_PATH.$CONFIG_NAME"
  chown -R ubuntu:ubuntu "$CONFIG_PATH.$CONFIG_NAME"
  chmod 644 "$CONFIG_PATH.$CONFIG_NAME/authorized_keys"
  chmod 600 "$CONFIG_PATH.$CONFIG_NAME/id_rsa"
  service ssh reload
else
  echo "$(date "+%Y-%m-%d %T"): DEBUG: No files changed."
fi

unset CUR_HASH NEW_HASH CONFIG_NAME CONFIG_PATH
