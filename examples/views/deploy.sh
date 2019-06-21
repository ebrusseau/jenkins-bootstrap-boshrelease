#!/bin/bash
flags=$*

bosh deploy -n -d jenkins ../../deployment/jenkins.yml \
  -o ../../deployment/operations/set-initial-config.yml \
  -o ../../deployment/operations/set-install-plugins.yml \
  -o ../../deployment/operations/master-only.yml \
  -v deployment_name=jenkins \
  --var-file install_plugins=plugins.txt \
  --var-file initial_config=initial_config.yml
