# Content synchronization

## Development > Production

    #!/bin/bash

    CONFIG_NAME=sync
    HOST_NAME=$(cat /etc/hostname)
    if [[ $HOST_NAME == ip-0-0-0-0 ]]; then
        PHP_HTTP_HOST="'www.domain.com'"
        SNAPSHOT_TAGS="Group,Values=WordPress-Prod-A-1"
    fi
    if [[ $HOST_NAME == ip-0-0-0-0 ]]; then
        PHP_HTTP_HOST="'www.domain.com'"
        # "Name" intentionally not "Group" to avoid snapshot of multiple Gluster volumes
        SNAPSHOT_TAGS="Name,Values=WordPress-Prod-C-1"
    fi
    if [[ $HOST_NAME == ip-0-0-0-0 ]]; then
        PHP_HTTP_HOST="'stage.domain.com'"
        SNAPSHOT_TAGS="Group,Values=WordPress-Stage-D-1"
    fi
    if [[ $HOST_NAME == ip-0-0-0-0 ]]; then
        PHP_HTTP_HOST="'dev.domain.com'"
        SNAPSHOT_TAGS="Group,Values=WordPress-Dev-E-1"
    fi
    PHP_INCLUDE="\$_SERVER['SERVER_NAME'] = $PHP_HTTP_HOST; include '/var/www/html/wp-config.php';"
    DB_NAME=$(php -r "$PHP_INCLUDE echo DB_NAME;")
    DB_USER=$(php -r "$PHP_INCLUDE echo DB_USER;")
    DB_PASS=$(php -r "$PHP_INCLUDE echo DB_PASSWORD;")
    DB_HOST=$(php -r "$PHP_INCLUDE echo DB_HOST;")
    DEV_DB_NAME="clientname-wp-dev"
    DEV_DB_USER="clientname-wp-dev"
    DEV_DB_PASS="XXPASSWORDXX"
    DEV_DB_HOST="clientname-mysql.XXXX.us-east-1.rds.amazonaws.com"
    EC2_SCRIPT="ec2-automate-backup-awscli.sh"


    # BACK UP PROD DB AND FILESYSTEM

    sudo mkdir -p /var/www/$CONFIG_NAME/$HOST_NAME
    sudo chown -R ubuntu:ubuntu /var/www/$CONFIG_NAME/$HOST_NAME
    mysqldump -a -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME | gzip -c | cat > /var/www/$CONFIG_NAME/$HOST_NAME/wpdb-$(date +%Y-%m-%d-%H.%M.%S).sql.gz;

    if [[ ! -f /opt/$EC2_SCRIPT ]]; then
        wget -O /opt/$EC2_SCRIPT https://raw.githubusercontent.com/colinbjohnson/aws-missing-tools/master/ec2-automate-backup/$EC2_SCRIPT
        chmod 755 /opt/$EC2_SCRIPT
    fi

    if [[ -f /opt/$EC2_SCRIPT ]]; then
        /opt/$EC2_SCRIPT -r "us-east-1" -s tag -t "$SNAPSHOT_TAGS" -n -h -p -k 6 -u
    fi


    # DROP CURRENT PROD DATABASE
    mysql -h$DB_HOST -u$DB_USER -p$DB_PASS -e "DROP DATABASE \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\`;";
    # COPY CURRENT DEV DATABASE TO PROD DATABASE
    mysqldump -a -h$DEV_DB_HOST -u$DEV_DB_USER -p$DEV_DB_PASS $DEV_DB_NAME | sed 's|17:\\"/solr/development\\"|16:\\"/solr/production\\"|' | mysql -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME 
    # COPY DEV FILES TO PROD
    sudo rsync -az -e "ssh -l ubuntu -i /home/ubuntu/.ssh/id_rsa" --delete dev:/var/www/html/ /var/www/html

## Production > Staging

    #!/bin/bash

    CONFIG_NAME="sync"
    HOST_NAME=$(cat /etc/hostname)
    if [[ $HOST_NAME == ip-0-0-0-0 ]]; then
        PHP_HTTP_HOST="'www.domain.com'"
        SNAPSHOT_TAGS="Group,Values=WordPress-Prod-A-1"
    fi
    if [[ $HOST_NAME == ip-0-0-0-0 ]]; then
        PHP_HTTP_HOST="'www.domain.com'"
        # "Name" intentionally not "Group" to avoid snapshot of multiple Gluster volumes
        SNAPSHOT_TAGS="Name,Values=WordPress-Prod-C-1"
    fi
    if [[ $HOST_NAME == ip-0-0-0-0 ]]; then
        PHP_HTTP_HOST="'stage.domain.com'"
        SNAPSHOT_TAGS="Group,Values=WordPress-Stage-D-1"
    fi
    if [[ $HOST_NAME == ip-0-0-0-0 ]]; then
        PHP_HTTP_HOST="'dev.domain.com'"
        SNAPSHOT_TAGS="Group,Values=WordPress-Dev-E-1"
    fi
    PHP_INCLUDE="\$_SERVER['HTTP_HOST'] = $PHP_HTTP_HOST; include '/var/www/html/wp-config.php';"
    DB_NAME=$(php -r "$PHP_INCLUDE echo DB_NAME;")
    DB_USER=$(php -r "$PHP_INCLUDE echo DB_USER;")
    DB_PASS=$(php -r "$PHP_INCLUDE echo DB_PASSWORD;")
    DB_HOST=$(php -r "$PHP_INCLUDE echo DB_HOST;")
    PROD_DB_NAME="clientname-wp-prod"
    PROD_DB_USER="clientname-wp-prod"
    PROD_DB_PASS="XXPASSWORDXX"
    PROD_DB_HOST="clientname-mysql.XXXX.us-east-1.rds.amazonaws.com"
    EC2_SCRIPT="ec2-automate-backup-awscli.sh"


    # BACK UP DB AND FILESYSTEM

    sudo mkdir -p /var/www/$CONFIG_NAME/$HOST_NAME
    sudo chown -R ubuntu:ubuntu /var/www/$CONFIG_NAME/$HOST_NAME
    mysqldump -a -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME | gzip -c | cat > /var/www/$CONFIG_NAME/$HOST_NAME/wpdb-$(date +%Y-%m-%d-%H.%M.%S).sql.gz;

    if [[ ! -f /opt/$EC2_SCRIPT ]]; then
        wget -O /opt/$EC2_SCRIPT https://raw.githubusercontent.com/colinbjohnson/aws-missing-tools/master/ec2-automate-backup/$EC2_SCRIPT
        chmod 755 /opt/$EC2_SCRIPT
    fi

    if [[ -f /opt/$EC2_SCRIPT ]]; then
        /opt/$EC2_SCRIPT -r "us-east-1" -s tag -t "$SNAPSHOT_TAGS" -n -h -p -k 6 -u
    fi


    # DROP CURRENT DATABASE
    mysql -h$DB_HOST -u$DB_USER -p$DB_PASS -e "DROP DATABASE \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\`;";
    # COPY PROD DATABASE TO CURRENT DATABASE
    mysqldump -a -h$PROD_DB_HOST -u$PROD_DB_USER -p$PROD_DB_PASS $PROD_DB_NAME | sed 's|16:\\"/solr/production\\"|13:\\"/solr/staging\\"|' | mysql -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME 
    # COPY PROD FILES TO PROD
    sudo rsync -az -e "ssh -l ubuntu -i /home/ubuntu/.ssh/id_rsa" --delete prod-a-1:/var/www/html/ /var/www/html
