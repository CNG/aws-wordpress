# Production

Ideally we will later create a Cloud Formation script to set up the architecture, but here is the command log for now.

Starting with m4.large:

    sudo sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
    echo 'app-d-1.domain.com' | sudo tee /etc/hostname
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

    sudo add-apt-repository -y ppa:gluster/glusterfs-3.5
    sudo apt-get update
    sudo apt-get -y install glusterfs-server xfsprogs
    # attach new storage at /dev/xvdf
    sudo mkfs.xfs -i size=512 /dev/xvdf
    sudo mkdir /gluster-storage
    sudo sh -c 'echo "/dev/xvdf\t/gluster-storage\txfs\tdefaults\t0\t1" >> /etc/fstab'
    sudo mount /gluster-storage
    #### We didn't run codedeploy yet, so manually make sure private IPs are in /etc/hosts and mapped to prod-a-1-int, etc.

    # ORIGINAL PROCESS

    # run next only on one server
    sudo gluster peer probe prod-c-1-int
    # run next only on other server 
    sudo gluster peer probe prod-a-1-int
    # run next three only on one server
    sudo gluster volume create webs replica 2 transport tcp prod-a-1-int:/gluster-storage/brick prod-c-1-int:/gluster-storage/brick
    sudo gluster volume start webs
    sudo gluster volume set webs auth.allow '*'

    # ADDING SERVER TO EXISTING PROCESS

    # run from existing server
    sudo gluster peer probe prod-e-1-int
    sudo gluster volume add-brick webs replica 4 prod-e-1-int:/gluster-storage/brick

    sudo mkdir -p /var/www.gluster
    sudo sh -c 'echo "localhost:/webs\t/var/www.gluster\tglusterfs\tdefaults,nobootwait,_netdev,direct-io-mode=disable\t0\t0" >> /etc/fstab'
    sudo mount /var/www.gluster
    sudo mkdir -p /var/www.nfs
    sudo sh -c 'echo "localhost:/webs\t/var/www.nfs\tnfs\tdefaults,nobootwait,_netdev\t0\t0" >> /etc/fstab'
    sudo mount /var/www.nfs
    cd /var; sudo ln -s www.nfs www

    sudo reboot

Next need to:
* trigger CodeDeploy
