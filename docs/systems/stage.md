# Stage 

Starting with m4.large:

    sudo sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
    echo 'stage.domain.com' | sudo tee /etc/hostname
    sudo curl http://repo.varnish-cache.org/debian/GPG-key.txt | sudo apt-key add -
    sudo sh -c 'echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list'
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
    sudo apt-get -y install imagemagick mysql-client-5.6 nginx varnish unzip git ruby2.0 python3-pip memcached
    sudo apt-get -y install php5-fpm php5-cli php5-dev php5-mysql php5-curl php5-gd php5-imagick php5-memcache php-apc php-pear build-essential php5-tidy

    sudo pip3 install awscli
    printf '\n\nus-east-1\njson\n\n' | sudo aws configure
    cd /home/ubuntu
    sudo aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
    sudo chmod +x ./install
    sudo ./install auto
    sudo rm -f install
    sudo service codedeploy-agent status
    # The AWS CodeDeploy agent is running as PID 5777

    sudo reboot

Next need to:

copy contents from production:

    cat /dev/zero | ssh-keygen -q -N ""
    cat .ssh/id_rsa.pub
    # append key to ubuntu@app-a-1.domain.com:~/.ssh/authorized_keys
    # echo "KEY_HERE" >> .ssh/authorized_keys
    sudo ssh app-a-1.domain.com
    # accept fingerprint, and should get "Permission denied" and return to prompt
    # if for some reason the SSH command works, exit to return to test.domain.com prompt
    sudo rsync -az -e "ssh -l ubuntu -i /home/ubuntu/.ssh/id_rsa" --delete app-a-1.domain.com:/var/www/html /var/www

* trigger CodeDeploy
