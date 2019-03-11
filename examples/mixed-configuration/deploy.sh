#!/bin/bash

bosh deploy -d jenkins ../../deployment/jenkins.yml \
  -o ../../deployment/operations/use-config-repo.yml \
  -o ../../deployment/operations/set-initial-config.yml \
  -o ../../deployment/operations/master-only.yml \
  -v deployment_name=jenkins \
  -v config_repo_url=https://github.com/ebrusseau/jenkins-bootstrap-boshrelease.git \
  -v config_repo_branch=testing \
  -v config_repo_path=examples/mixed-configuration/config-repo \
  --var-file initial_config=initial_config.yml
