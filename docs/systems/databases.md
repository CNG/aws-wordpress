# Databases 

* Region: N.Virgina (`us-east-1`)
* DB Instance Identifier: `clientname-mysql`
* Master Username: `username`
* Master Password: `password`
* Database Name: `clientname_prod`
* Address: `clientname-mysql.XXXX.us-east-1.rds.amazonaws.com`

Create the three databases on remote RDS server:

    CREATE DATABASE `clientname-wp-prod`;
    CREATE DATABASE `clientname-wp-staging`;
    CREATE DATABASE `clientname-wp-dev`;
    CREATE USER `clientname-wp-prod`@'%' IDENTIFIED BY 'XXPASSWORDXX';
    CREATE USER `clientname-wp-staging`@'%' IDENTIFIED BY 'XXPASSWORDXX';
    CREATE USER `clientname-wp-dev`@'%' IDENTIFIED BY 'XXPASSWORDXX';
    GRANT ALL PRIVILEGES ON `clientname-wp-prod`.* TO `clientname-wp-prod`@'%';
    GRANT ALL PRIVILEGES ON `clientname-wp-staging`.* TO `clientname-wp-staging`@'%';
    GRANT ALL PRIVILEGES ON `clientname-wp-dev`.* TO `clientname-wp-dev`@'%';
    FLUSH PRIVILEGES;

Create extra database for migration testing:

    CREATE DATABASE `clientname-wp-test`;
    CREATE USER `clientname-wp-test`@'%' IDENTIFIED BY 'XXPASSWORDXX';
    GRANT ALL PRIVILEGES ON `clientname-wp-test`.* TO `clientname-wp-test`@'%';
    FLUSH PRIVILEGES;

Copy local MySQL to remote (this might need updating):

    PHP_SERVER_NAME="'dev.clientname.press'"
    PHP_INCLUDE="\$_SERVER['SERVER_NAME'] = $PHP_SERVER_NAME; include '/var/www/html/wp-config.php';"
    LOCAL_DB_NAME=$(php -r "$PHP_INCLUDE echo DB_NAME;")
    LOCAL_DB_USER=$(php -r "$PHP_INCLUDE echo DB_USER;")
    LOCAL_DB_PASS=$(php -r "$PHP_INCLUDE echo DB_PASSWORD;")
    LOCAL_DB_HOST=$(php -r "$PHP_INCLUDE echo DB_HOST;")

    REMOTE_DB_NAME="clientname-wp-dev"
    REMOTE_DB_USER="clientname-wp-dev"
    REMOTE_DB_PASS="XXPASSWORDXX"
    REMOTE_DB_HOST="clientname-mysql.XXXX.us-east-1.rds.amazonaws.com"

    mysqldump -a -h$LOCAL_DB_HOST -u$LOCAL_DB_USER -p$LOCAL_DB_PASS $LOCAL_DB_NAME | mysql -h$REMOTE_DB_HOST -u$REMOTE_DB_USER -p$REMOTE_DB_PASS $REMOTE_DB_NAME
