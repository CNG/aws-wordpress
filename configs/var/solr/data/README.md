# CodeDeploy management

There are three environments that all point to SOLR servers hosted on the development
server, but since they all have the same configuration, the files are represented in 
this repo just once. This folder, `development`, gets copied to folders `staging` and 
`production` alongside `development` on the development server. None of the other servers
host SOLR installations.

The `core.properties` file and the `conf` directory within this directory are
version controlled and must be modified via committing to this repo. On the
server, there is a `data` directory contained within this `development` directory.
That `data` directory contains information derived from other data in the CMS, and
therefore the `data` directory is not under version control.

Upon committing changes to either the `core.properties` file or modifying anything within
the `conf` directory, the script `/scripts/solr.sh` overwrites that file or directory
on the server and restarts SOLR.
