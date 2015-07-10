#!/bin/bash

HOST_NAME=$(cat /etc/hostname)

if [[ $RUN_TYPE = deployment ]]; then
  # faster deploy: don't spend time purging old snapshots
  SNAPSHOT_ARGS="-n -h    -k 6 -u"
elif [[ $RUN_TYPE = scheduled ]]; then
  SNAPSHOT_ARGS="-n -h -p -k 6 -u"
fi

# DATABASE BACKUP
# we don't strictly need this since we're using AWS RDS, which has point in time restores

PHP_INCLUDE="\$_SERVER['HTTP_HOST'] = '$HOST_NAME'; include '/var/www/html/wp-config.php';"
DB_NAME=$(php -r "$PHP_INCLUDE echo DB_NAME;")
DB_USER=$(php -r "$PHP_INCLUDE echo DB_USER;")
DB_PASS=$(php -r "$PHP_INCLUDE echo DB_PASSWORD;")
DB_HOST=$(php -r "$PHP_INCLUDE echo DB_HOST;")
if [[ ! -d /var/www/backups/$HOST_NAME/$RUN_TYPE ]]; then
  mkdir -p "/var/www/backups/$HOST_NAME/$RUN_TYPE"
fi
DB_FILE="/var/www/backups/$HOST_NAME/$RUN_TYPE/wpdb-$(date +%Y-%m-%d-%H.%M.%S).sql.gz"
echo "$(date "+%Y-%m-%d %T"): DEBUG: Dumping MySQL database $DB_NAME to $DB_FILE"
mysqldump -a -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME | gzip -c | cat > "$DB_FILE"

# VOLUME SNAPSHOT

# look up tags to use as command arguments
case $HOST_NAME in
  app-a-1.domain.com )
    SNAPSHOT_TAGS="Group,Values=WordPress-Prod-A-1"
    ;;
  app-c-1.domain.com )
    # "Name" intentionally not "Group" to avoid snapshot of multiple Gluster volumes
    SNAPSHOT_TAGS="Name,Values=WordPress-Prod-C-1"
    ;;
  stage.domain.com   )
    SNAPSHOT_TAGS="Group,Values=WordPress-Stage-D-1"
    ;;
  dev.domain.com     )
    SNAPSHOT_TAGS="Group,Values=WordPress-Dev-E-1"
    ;;
esac
# download and use EC2 snapshot rotating script
EC2_SCRIPT=ec2-automate-backup-awscli.sh
if [[ ! -f /opt/$EC2_SCRIPT ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Downloading $EC2_SCRIPT"
  wget -O "/opt/$EC2_SCRIPT" https://raw.githubusercontent.com/colinbjohnson/aws-missing-tools/master/ec2-automate-backup/$EC2_SCRIPT
  chmod 755 "/opt/$EC2_SCRIPT"
fi
if [[ -f /opt/$EC2_SCRIPT ]]; then
  echo "$(date "+%Y-%m-%d %T"): DEBUG: Executing: /opt/$EC2_SCRIPT -r 'us-east-1' -s tag -t '$SNAPSHOT_TAGS' $SNAPSHOT_ARGS"
  "/opt/$EC2_SCRIPT" -r "us-east-1" -s tag -t "$SNAPSHOT_TAGS" $SNAPSHOT_ARGS
fi
