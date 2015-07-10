#!/bin/bash

# Delete directory where CodeDeploy will copy files because it can only fail if files exist!
rm -rf /tmp/deploy-files
