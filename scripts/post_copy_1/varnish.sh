#!/bin/bash

CONFIG_NAME=varnish
CONFIG_PATH=/etc/
CUR_HASH=$({ export LC_ALL=C;
  find "$CONFIG_PATH$CONFIG_NAME" -type f -exec wc -c {} \; | sort; echo;
  find "$CONFIG_PATH$CONFIG_NAME" -type f -exec sha256sum {} + | sort; echo;
  find "$CONFIG_PATH$CONFIG_NAME" -type d | sort;
  find "$CONFIG_PATH$CONFIG_NAME" -type d | sort | sha256sum;
  } | sha256sum)
NEW_HASH=$({ export LC_ALL=C;
  find "$SOURCES$CONFIG_PATH$CONFIG_NAME" -type f -exec wc -c {} \; | sed "s|$SOURCES||" | sort; echo;
  find "$SOURCES$CONFIG_PATH$CONFIG_NAME" -type f -exec sha256sum {} + | sed "s|$SOURCES||" | sort; echo;
  find "$SOURCES$CONFIG_PATH$CONFIG_NAME" -type d | sed "s|$SOURCES||" | sort;
  find "$SOURCES$CONFIG_PATH$CONFIG_NAME" -type d | sed "s|$SOURCES||" | sort | sha256sum;
  } | sha256sum)

echo "$(date "+%Y-%m-%d %T"): DEBUG: Checking $CONFIG_PATH$CONFIG_NAME"
if [[ $CUR_HASH != $NEW_HASH ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Files changed. Updating."
  rm -rf "$CONFIG_PATH$CONFIG_NAME"
  mv "$SOURCES$CONFIG_PATH$CONFIG_NAME" "$CONFIG_PATH"
  service $CONFIG_NAME reload
else
  echo "$(date "+%Y-%m-%d %T"): DEBUG: No files changed."
fi

CONFIG_PATH=/etc/default/

CUR_HASH=$(sha256sum "$CONFIG_PATH$CONFIG_NAME" | head -c 64)
NEW_HASH=$(sha256sum "$SOURCES$CONFIG_PATH$CONFIG_NAME" | head -c 64)
echo "$(date "+%Y-%m-%d %T"): DEBUG: Checking $CONFIG_PATH$CONFIG_NAME"
if [[ $CUR_HASH != $NEW_HASH ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Files changed. Updating."
  cp -a "$SOURCES$CONFIG_PATH$CONFIG_NAME" "$CONFIG_PATH"
  service $CONFIG_NAME reload
else
  echo "$(date "+%Y-%m-%d %T"): DEBUG: No files changed."
fi

echo "$(date "+%Y-%m-%d %T"): DEBUG: Checking $CONFIG_PATH$(echo $CONFIG_NAME)log"
CUR_HASH=$(sha256sum "$CONFIG_PATH$(echo $CONFIG_NAME)log" | head -c 64$)
NEW_HASH=$(sha256sum "$SOURCES$CONFIG_PATH$(echo $CONFIG_NAME)log" | head -c 64$)
if [[ $CUR_HASH != $NEW_HASH ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Files changed. Updating."
  cp -a "$SOURCES$CONFIG_PATH$(echo $CONFIG_NAME)log" "$CONFIG_PATH"
  service $CONFIG_NAME reload
else
  echo "$(date "+%Y-%m-%d %T"): DEBUG: No files changed."
fi

echo "$(date "+%Y-%m-%d %T"): DEBUG: Checking $CONFIG_PATH$(echo $CONFIG_NAME)ncsa"
CUR_HASH=$(sha256sum $CONFIG_PATH$(echo $CONFIG_NAME)ncsa | head -c 64$)
NEW_HASH=$(sha256sum $SOURCES$CONFIG_PATH$(echo $CONFIG_NAME)ncsa | head -c 64$)
if [[ $CUR_HASH != $NEW_HASH ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Files changed. Updating."
  cp -a "$SOURCES$CONFIG_PATH$(echo $CONFIG_NAME)ncsa" "$CONFIG_PATH"
  service $CONFIG_NAME reload
else
  echo "$(date "+%Y-%m-%d %T"): DEBUG: No files changed."
fi

unset CUR_HASH NEW_HASH CONFIG_NAME CONFIG_PATH
