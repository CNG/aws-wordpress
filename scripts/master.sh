#!/bin/bash

LOG_DIR=/var/log/aws/codedeploy-scripts
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/output.log"

if [[ $LIFECYCLE_EVENT = BeforeInstall ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEPLOYMENT SCRIPTS STARTING" >> "$LOG_FILE"
fi

cat << EOF >> "$LOG_FILE"
$(date "+%Y-%m-%d %T"): $APPLICATION_NAME: $DEPLOYMENT_GROUP_NAME: $DEPLOYMENT_ID: $LIFECYCLE_EVENT
EOF

DEPLOYMENT_FILES=/tmp/deploy-files
SOURCES="$DEPLOYMENT_FILES/configs"
case $LIFECYCLE_EVENT in
  BeforeInstall )

    # next line not required, but if deploy fails, these might not get deleted, leading to further failures
    # rm -rf /tmp/deploy-files

    # Find where CodeDeploy puts the files after downloading
    DEPLOYMENT_GROUP_ID=$(ls -I 'deployment-instructions' -t /opt/codedeploy-agent/deployment-root | head -1)
    DEPLOYMENT_FILES_TMP="/opt/codedeploy-agent/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive"
    
    cp "$DEPLOYMENT_FILES_TMP/scripts/backup.sh" /opt
    chmod +x /opt/backup.sh

    SCRIPTS="$DEPLOYMENT_FILES_TMP/scripts/pre_deploy"

    unset DEPLOYMENT_GROUP_ID DEPLOYMENT_FILES_TMP

    ;;
  AfterInstall )
    SCRIPTS="$DEPLOYMENT_FILES/scripts/post_copy_1"
    ;;
  ApplicationStart )
    SCRIPTS="$DEPLOYMENT_FILES/scripts/post_copy_2"
    ;;
  ValidateService )
    SCRIPTS="$DEPLOYMENT_FILES/scripts/post_copy_3"
    ;;
esac

echo "$(date "+%Y-%m-%d %T"): DEBUG: Looking for scripts in $SCRIPTS" >> "$LOG_FILE"
for SCRIPT in "$SCRIPTS"/*; do
  # Strictly, we don't need execute bit set because we are sourcing
  # but we will use the convention for convenience in disabling.
  if [[ -f $SCRIPT && -x $SCRIPT ]]; then
    echo "$(date "+%Y-%m-%d %T"): DEBUG: Executing $SCRIPT" >> "$LOG_FILE"
    source "$SCRIPT" >> "$LOG_FILE" 2>&1
  else
    echo "$(date "+%Y-%m-%d %T"): DEBUG: Skipping $SCRIPT since execute bit off" >> "$LOG_FILE"
  fi
done

if [[ $LIFECYCLE_EVENT = ValidateService ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEPLOYMENT SCRIPTS FINISHED" >> "$LOG_FILE"
fi

unset LOG_DIR LOG_FILE DEPLOYMENT_FILES SOURCES
