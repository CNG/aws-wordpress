#!/bin/bash

SCRIPT=/opt/backup.sh
RUN_TYPE=deployment
if [[ -f $SCRIPT ]]; then
  source "$SCRIPT"
fi
