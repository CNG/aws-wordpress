# Server access

To gain access to the servers, your public key needs to end up in `/home/ubuntu/.ssh/authorized_keys` on the server in question. That file is managed by the deployment process, so instead of editing the server directly (which you couldn't do without access, anyway):

1. Check out `develop` or a feature branch of this repository.
1. Add your key to [authorized_keys](../../../configs/home/ubuntu/.ssh/authorized_keys).
1. Commit the change and push to Github.
1. Note the commit ID and [deploy to the server group in question](../../deployment/deploy_from_github).
1. After successful deployment, you should be able to SSH to the server using the account `ubuntu`, such as `ssh ubuntu@dev.domain.com`.

Note adding many users' keys to the `ubuntu` account is not intended to be a long term solution. If we will require many people to access the servers, we should implement separate user accounts, perhaps using Ansible as we did on the Movable Type architecture.
