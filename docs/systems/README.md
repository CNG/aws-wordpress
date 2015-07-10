# Systems overview

This repository deploys code to all servers as outline in [Deployment](../deployment). All servers currently have same `~/.ssh/authorized_keys` file. See [Server access](server_access).

## Development ([setup](development.md))

* `ssh ubuntu@dev.domain.com`
* `dev.domain.com` runs Nginx + Varnish
* `dev.domain.com` runs Solr servers for the integration with the WPSOLR plugin
* points to remote database defined in [`/var/www/html/wp-config.php`](../../html/wp-config.php)

## Staging ([setup](stage.md))

* `ssh ubuntu@stage.domain.com`
* `stage.domain.com` runs Nginx + Varnish
* points to remote MySQL database defined in [`/var/www/html/wp-config.php`](../../html/wp-config.php)
* points to remote Solr database on `dev.domain.com`

## Test (setup identical to [stage](stage.md))

* `ssh ubuntu@test.domain.com`
* `test.domain.com` runs Nginx + Varnish
* points to remote MySQL database defined in [`/var/www/html/wp-config.php`](../../html/wp-config.php)
* points to remote Solr database on `dev.domain.com`

## Production ([setup](production.md))

`app-a-1.domain.com` and `app-c-1.domain.com`

* `ssh ubuntu@app-a-1.domain.com`
* `ssh ubuntu@app-c-1.domain.com`
* `/var/www` shared via GlusterFS and mounted by `/etc/fstab` and `/etc/rc.local`
* runs Nginx + Varnish
* points to remote MySQL database defined in [`/var/www/html/wp-config.php`](../../html/wp-config.php)
* points to remote Solr database on `dev.domain.com`
* W3TC settings point to ElastiCache cluster `wp-prod` with 2 nodes spread across zones

`www.domain.com` is a load balancer that points to `app-a-1.domain.com` and `app-c-1.domain.com`.

## Backups

### On Deployment

Upon each CodeDeploy deployment, the server in question will run [`backup.sh`](../../scripts/backup.sh), which dumps the MySQL database to `/var/www/backups` and then send a snapshot command to AWS, resulting in a snapshot of the complete filesystem, also containing the latest database. Since the databases are all hosted on AWS RDS, we can also do point in time restores there through the AWS admin panel.

The production servers have an OS volume and a Gluster volume, so both of those are imaged upon deployment. (Since the Gluster volumes are identical, only the one attached to `app-a-1.domain.com` is imaged. This is configured in [`backup.sh`](../../scripts/backup.sh) through the `SNAPSHOT_TAGS` environment variable.)

### Scheduled

Additionally, the above backups and snapshots are created daily by a script in [`/etc/cron.daily`](../../configs/etc/cron.daily).

## DNS and IPs

If needed, IP addresses for the servers are located in this repo at [`configs/etc/hosts`](../../configs/etc/hosts), and the internal IPs used by Gluster should not change due to VPC settings. The other IPs are all elastic IPs and also should not change.

The `domain.com` zone is managed in Route53.
