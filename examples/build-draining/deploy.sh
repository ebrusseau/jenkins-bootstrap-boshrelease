#!/bin/bash
flags=$*

bosh deploy ${flags} --deployment jenkins ../../deployment/jenkins.yml \
  --ops-file ../../deployment/operations/set-initial-config.yml \
  --ops-file ../../deployment/operations/set-install-plugins.yml \
  --ops-file ../../deployment/operations/enable-drain.yml \
  --var-file install_plugins=plugins.txt \
  --var-file initial_config=initial_config.yml \
  --var deployment_name=jenkins
