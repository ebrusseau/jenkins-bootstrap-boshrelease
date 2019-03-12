#!/bin/bash

bosh deploy -n -d jenkins ../../deployment/jenkins.yml \
  -o ../../deployment/operations/use-config-repo.yml \
  -o ../../deployment/operations/master-only.yml \
  -v deployment_name=jenkins \
  -v config_repo_url=https://github.com/ebrusseau/jenkins-bootstrap-boshrelease.git \
  -v config_repo_branch=testing \
  -v config_repo_path=examples/script-approval/config-repo
