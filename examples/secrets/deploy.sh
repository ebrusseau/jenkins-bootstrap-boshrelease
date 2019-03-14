#!/bin/bash
flags=$*

bosh deploy ${flags} --deployment jenkins ../../deployment/jenkins.yml \
  --ops-file ../../deployment/operations/master-only.yml \
  --ops-file operations/set-enforced-config.yml \
  --ops-file operations/credential-variables.yml \
  --var deployment_name=jenkins
