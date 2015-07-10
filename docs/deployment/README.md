# Deployment

## Overview

All code changes are managed via this repository and a deployment process that makes the changes on the servers. This is handled by the Amazon Web Services product [CodeDeploy](https://aws.amazon.com/codedeploy), which follows the instructions in the [`appspec.yml`](../../../appspec.yml) file ([documentation](http://docs.aws.amazon.com/codedeploy/latest/userguide/app-spec-ref.html)).

Commits to this repository's default branch `develop` automatically trigger a deployment to the `dev.domain.com` server, while other servers must be manually deployed to through the CodeDeploy interface. The automatic deployment groups are configured under “Environments” in the [GitHub Auto-Deployment](#) service hook.

We should never need to make configuration changes directly to any of the servers. Generally, changes are made in this repository to the file in [configs](configs) that corresponds to the file you want to modifiy in `/etc/` on the server. Generally, changes are detected and the appropriate software is reloaded if the configuration was changed.

If you need to troubleshoot this, you can look in [`appspec.yml`](appspec.yml) to see the order the scripts are run, and then look at the scripts themselves in the [scripts](scripts) folder. Those scripts are copied to the local filesystem by CodeDeploy and are then run one by one, and later deleted. Most of the scripts log to `/var/log/aws/codedeploy-scripts/output.log` to help determine which scripts were run.

## Deploying

See [Deploy a specific commit to a server or group](deploy_from_github).

## Setup

See [CodeDeploy configuration](codedeploy_configuration).

## Details and logging

`codedeploy-agent` runs in the background on all servers. This checks for deployments triggered by AWS CodeDeploy and executes them per instructions in the [`appspec.yml`](../../../appspec.yml) file ([documentation](http://docs.aws.amazon.com/codedeploy/latest/userguide/app-spec-ref.html)). 

The `codedeploy-agent` process logs to `/var/log/aws/codedeploy-agent/codedeploy-agent.log`. If a deployment fails due to file copy or other issues, there might be an error message near the end of this file. It does not give insight into specific actions of the scripts, though.

As you can see in [`appspec.yml`](../../../appspec.yml), we attach a script to four hooks: BeforeInstall, AfterInstall, ApplicationStart and ValidateService. For convenience of logging, these all point to the same [`master.sh`](../../../scripts/master.sh), which itself triggers other scripts:

* BeforeInstall:  [`pre_deploy/*.sh`](../../../scripts/pre_deploy)
* AfterInstall:  [`post_copy_1/*.sh`](../../../scripts/post_copy_1)
* ApplicationStart:  [`post_copy_2/*.sh`](../../../scripts/post_copy_2)
* ValidateService:  [`post_copy_3/*.sh`](../../../scripts/post_copy_3)

Most of the scripts we run are in [`post_copy_1`](../../../scripts/post_copy_1) since the execution order isn't important, but if that changes, scripts could be strategically moved to the other two folders to control order. If we ever need more fine grained control, we probably need to go back to an explicit list of scripts and get rid of the automatic folder based process we have now.

Specific scripts can be disabled by removing the execute bit on the script, since this is checked for in the `for SCRIPT in $SCRIPTS/*` block of [`master.sh`](../../../scripts/master.sh).

Each script has built in explicit logging to `/var/log/aws/codedeploy-scripts/output.log`.

Each time  is run, for each "lifecycle event", a new line will appear in the log specifying:

    $(date "+%Y-%m-%d %T"): $APPLICATION_NAME: $DEPLOYMENT_GROUP_NAME: $DEPLOYMENT_ID: $LIFECYCLE_EVENT

The output of a typical deployment might look like this:

	2015-11-09 21:02:39: DEPLOYMENT SCRIPTS STARTING
	2015-11-09 21:02:39: wordpress: develop: d-MXZVOTQAC: BeforeInstall
	2015-11-09 21:02:39: DEBUG: Looking for scripts in /opt/codedeploy-agent/deployment-root/30312b88-d375-4a5f-9065-098cdcafdaf5/d-MXZVOTQAC/deployment-archive/scripts/pre_deploy
	2015-11-09 21:02:39: DEBUG: Executing /opt/codedeploy-agent/deployment-root/30312b88-d375-4a5f-9065-098cdcafdaf5/d-MXZVOTQAC/deployment-archive/scripts/pre_deploy/backup.sh
	2015-11-09 21:02:40: DEBUG: Dumping MySQL database clientname-wp-dev to /var/www/backups/dev.domain.com/deployment/wpdb-2015-11-09-21.02.40.sql.gz
	2015-11-09 21:02:42: DEBUG: Executing: /opt/ec2-automate-backup-awscli.sh -r 'us-east-1' -s tag -t 'Group,Values=WordPress-Dev-E-1' -n -h    -k 6 -u
	Snapshots taken by ec2-automate-backup-awscli.sh will be eligible for purging after the following date (the purge after date given in seconds from epoch): 1447621362.
	2015-11-09 21:02:42: DEBUG: Executing /opt/codedeploy-agent/deployment-root/30312b88-d375-4a5f-9065-098cdcafa0f5/d-MXZVOTQAC/deployment-archive/scripts/pre_deploy/prepare.sh
	2015-11-09 21:02:52: wordpress: develop: d-MXZVOTQAC: AfterInstall
	2015-11-09 21:02:52: DEBUG: Looking for scripts in /tmp/deploy-files/scripts/post_copy_1
	2015-11-09 21:02:52: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/hosts.sh
	2015-11-09 21:02:52: DEBUG: No files changed.
	2015-11-09 21:02:52: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/html.sh
	2015-11-09 21:02:52: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/log.sh
	2015-11-09 21:02:52: DEBUG: No files changed.
	2015-11-09 21:02:52: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/nginx.sh
	2015-11-09 21:02:52: DEBUG: No files changed.
	2015-11-09 21:02:52: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/php.sh
	2015-11-09 21:02:52: DEBUG: No files changed.
	2015-11-09 21:02:52: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/scripts.sh
	2015-11-09 21:02:52: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/solr.sh
	2015-11-09 21:02:53: DEBUG: No files changed.
	2015-11-09 21:02:53: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/ssh.sh
	2015-11-09 21:02:53: DEBUG: Files changed. Updating.
	2015-11-09 21:02:53: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_1/varnish.sh
	2015-11-09 21:02:53: DEBUG: Checking /etc/varnish
	2015-11-09 21:02:53: DEBUG: No files changed.
	2015-11-09 21:02:53: DEBUG: Checking /etc/default/varnish
	2015-11-09 21:02:53: DEBUG: No files changed.
	2015-11-09 21:02:53: DEBUG: Checking /etc/default/varnishlog
	2015-11-09 21:02:53: DEBUG: No files changed.
	2015-11-09 21:02:53: DEBUG: Checking /etc/default/varnishncsa
	2015-11-09 21:02:53: DEBUG: No files changed.
	2015-11-09 21:02:54: wordpress: develop: d-MXZVOTQAC: ApplicationStart
	2015-11-09 21:02:54: DEBUG: Looking for scripts in /tmp/deploy-files/scripts/post_copy_2
	2015-11-09 21:02:54: DEBUG: Skipping /tmp/deploy-files/scripts/post_copy_2/placeholder.sh since execute bit off
	2015-11-09 21:02:56: wordpress: develop: d-MXZVOTQAC: ValidateService
	2015-11-09 21:02:56: DEBUG: Looking for scripts in /tmp/deploy-files/scripts/post_copy_3
	2015-11-09 21:02:56: DEBUG: Executing /tmp/deploy-files/scripts/post_copy_3/cleanup.sh
	2015-11-09 21:02:56: DEPLOYMENT SCRIPTS FINISHED
