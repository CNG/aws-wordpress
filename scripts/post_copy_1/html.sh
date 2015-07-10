#!/bin/bash

chmod -R 775 "$DEPLOYMENT_FILES/html"
chown -R www-data:www-data "$DEPLOYMENT_FILES/html"
rsync -rlpgo --delete \
  --exclude /html/wp-content/uploads \ # add excludes for client specific files
"$DEPLOYMENT_FILES/html" /var/www

# put in place proper W3TotalCache settings folder
cd /var/www/html/wp-content
mkdir -p w3tc-config
mv w3tc-config-$DEPLOYMENT_GROUP_NAME/* w3tc-config
chown -R www-data:www-data w3tc-config
rm -rf w3tc-config-*
