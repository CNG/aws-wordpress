#!/bin/bash

CONFIG_NAME=nginx
CONFIG_PATH=/etc/
CONFIG_FILE="$SOURCES$CONFIG_PATH$CONFIG_NAME/sites-available/default"

if [[ $DEPLOYMENT_GROUP_NAME = develop ]]; then
  sed -i -e 's/DOMAIN_NAME/dev.domain.com/g' "$CONFIG_FILE"
elif [[ $DEPLOYMENT_GROUP_NAME = staging ]]; then
  sed -i -e 's/DOMAIN_NAME/stage.domain.com/g' "$CONFIG_FILE"
elif [[ $DEPLOYMENT_GROUP_NAME = prod ]]; then
  sed -i -e 's/DOMAIN_NAME/www.domain.com ~^app-.-.\\.domain\\.com$/g' "$CONFIG_FILE"
fi

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

if [[ $CUR_HASH != $NEW_HASH ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Files changed. Updating."
  rm -rf "$CONFIG_PATH$CONFIG_NAME"
  mv "$SOURCES$CONFIG_PATH$CONFIG_NAME" "$CONFIG_PATH"
  service "$CONFIG_NAME" reload
else
  echo "$(date "+%Y-%m-%d %T"): DEBUG: No files changed."
fi

unset CUR_HASH NEW_HASH CONFIG_NAME CONFIG_PATH CONFIG_FILE
