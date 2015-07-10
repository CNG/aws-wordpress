# Development 

Note I made some refinements to this for the production server scripts. Ideally we will later create a Cloud Formation script to set up the architecture, but here is the command log for now.

Starting with m4.large:

    sudo sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
    echo 'dev.clientname.press' | sudo tee /etc/hostname
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

    # To install Java/Solr, followed https://www.digitalocean.com/community/tutorials/how-to-install-solr-5-2-1-on-ubuntu-14-04
    # JAVA FOR SOLR
    sudo apt-get -y install python-software-properties
    sudo add-apt-repository -y ppa:webupd8team/java
    sudo apt-get update
    echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
    sudo apt-get -y install oracle-java8-installer
    # SOLR
    cd ~
    wget http://apache.mirrors.pair.com/lucene/solr/5.2.1/solr-5.2.1.tgz
    tar xzf solr-5.2.1.tgz solr-5.2.1/bin/install_solr_service.sh --strip-components=2
    sudo bash ./install_solr_service.sh solr-5.2.1.tgz
    
    sudo reboot

Next need to:
* trigger CodeDeploy
