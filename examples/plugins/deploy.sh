#!/bin/bash

bosh deploy -d jenkins ../../deployment/jenkins.yml \
  -o ../../deployment/operations/use-config-repo.yml \
  -o ../../deployment/operations/install-plugins.yml \
  -o ../../deployment/operations/master-only.yml \
  -v deployment_name=jenkins \
  -v repo_url=https://github.com/ebrusseau/jenkins-bootstrap-boshrelease.git \
  -v repo_branch=testing \
  -v repo_path=examples/plugins/config-repo \
  --var-file install_plugins=plugins.txt
