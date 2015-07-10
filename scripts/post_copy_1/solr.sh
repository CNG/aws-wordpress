#!/bin/bash

if [[ $DEPLOYMENT_GROUP_NAME == develop ]]; then

  CONFIG_NAME=solr
  CONFIG_PATH="/var/$CONFIG_NAME/data"
  CONFIG_PATH_D="$CONFIG_PATH/development"
  CONFIG_PATH_S="$CONFIG_PATH/staging"
  CONFIG_PATH_P="$CONFIG_PATH/production"
  CUR_HASH=$({ export LC_ALL=C;
    sha256sum "$CONFIG_PATH_D/core.properties" | head -c 64;
    find "$CONFIG_PATH_D/conf" -type f -exec wc -c {} \; | sort; echo;
    find "$CONFIG_PATH_D/conf" -type f -exec sha256sum {} + | sort; echo;
    find "$CONFIG_PATH_D/conf" -type d | sort;
    find "$CONFIG_PATH_D/conf" -type d | sort | sha256sum;
    } | sha256sum)
  NEW_HASH=$({ export LC_ALL=C;
    sha256sum $SOURCES$CONFIG_PATH_D/core.properties | head -c 64;
    find "$SOURCES$CONFIG_PATH_D/conf" -type f -exec wc -c {} \; | sed "s|$SOURCES||" | sort; echo;
    find "$SOURCES$CONFIG_PATH_D/conf" -type f -exec sha256sum {} + | sed "s|$SOURCES||" | sort; echo;
    find "$SOURCES$CONFIG_PATH_D/conf" -type d | sed "s|$SOURCES||" | sort;
    find "$SOURCES$CONFIG_PATH_D/conf" -type d | sed "s|$SOURCES||" | sort | sha256sum;
    } | sha256sum)

  if [[ $CUR_HASH != $NEW_HASH ]]; then
    echo "$(date "+%Y-%m-%d %T"): DEBUG: Files changed. Updating."
    rm -rf "$CONFIG_PATH_D/conf" "$CONFIG_PATH_S/conf" "$CONFIG_PATH_P/conf"
    mkdir -p "$CONFIG_PATH_D" "$CONFIG_PATH_S" "$CONFIG_PATH_P"
    cp -a "$SOURCES$CONFIG_PATH_D"/* "$CONFIG_PATH_D"
    cp -a "$SOURCES$CONFIG_PATH_D"/* "$CONFIG_PATH_S"
    cp -a "$SOURCES$CONFIG_PATH_D"/* "$CONFIG_PATH_P"
    sed -i 's/development/staging/' "$CONFIG_PATH_S/core.properties"
    sed -i 's/development/production/' "$CONFIG_PATH_P/core.properties"
    chown -R $CONFIG_NAME:$CONFIG_NAME "$CONFIG_PATH"
    service $CONFIG_NAME restart
  else
    echo "$(date "+%Y-%m-%d %T"): DEBUG: No files changed."
  fi

  unset CUR_HASH NEW_HASH CONFIG_NAME CONFIG_PATH

fi
