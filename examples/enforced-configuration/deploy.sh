#!/bin/bash
flags="$@"

bosh deploy ${flags} --deployment jenkins ../../deployment/jenkins.yml \
  --ops-file ../../deployment/operations/set-initial-config.yml \
  --ops-file ../../deployment/operations/set-enforced-config.yml \
  --ops-file ../../deployment/operations/master-only.yml \
  --var-file initial_config=initial_config.yml \
  --var-file enforced_config=enforced_config.yml \
  --var deployment_name=jenkins
