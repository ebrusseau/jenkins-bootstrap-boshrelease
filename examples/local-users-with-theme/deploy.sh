#!/bin/bash

bosh deploy -d jenkins ../../deployment/jenkins.yml \
  -o ../../deployment/operations/use-config-repo.yml \
  -o ../../deployment/operations/set-initial-config.yml \
  -o operations/credential-variables.yml \
  -v repo_url=https://github.com/ebrusseau/jenkins-bootstrap-boshrelease.git \
  -v repo_branch=testing \
  -v repo_path=examples/local-users-with-theme/config-repo \
  --var-file initial_config=initial_config.yml
