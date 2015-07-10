#!/bin/bash

cp -a "$SOURCES"/etc/cron.* /etc

if [[ $DEPLOYMENT_GROUP_NAME = prod ]]; then
  cp -a "$SOURCES"/etc/rc.local.prod /etc/rc.local
fi
