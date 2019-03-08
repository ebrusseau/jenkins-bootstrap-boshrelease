#!/bin/bash

bosh deploy -d jenkins ../../deployment/jenkins.yml \
  -o ../../deployment/operations/set-initial-config.yml \
  -o ../../deployment/operations/set-enforced-config.yml \
  -o ../../deployment/operations/master-only.yml \
  -v deployment_name=jenkins \
  --var-file initial_config=initial_config.yml \
  --var-file enforced_config=enforced_config.yml
