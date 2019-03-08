#!/bin/bash

set -eo pipefail

SCRIPT_DIR=$(dirname $0)
BLOBS_DIR=${SCRIPT_DIR}/blobs

# Usage: download_blob <path and name of blob in blobstore> <url of appropriate source/binary archive>
download_blob() {
  local blob_name=${1}
  local blob_url=${2}
  local blob_dir=$(dirname ${blob_name})
  shift; shift

  echo Downloading ${blob_name} from ${blob_url}...
  mkdir -p ${BLOBS_DIR}/${blob_dir}
  wget "$@" -O ${BLOBS_DIR}/${blob_name} ${blob_url}
  bosh add-blob ${BLOBS_DIR}/${blob_name} ${blob_name}
}

download_oracle_jdk_blob() {
  echo "Downloading Oracle JDK from $1..."
  mkdir -p ${BLOBS_DIR}/oracle-jdk
  wget \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    -O ${BLOBS_DIR}/oracle-jdk/oracle-jdk.tar.gz $1

  [[ $? -eq 0 ]] && bosh add-blob ${BLOBS_DIR}/oracle-jdk/oracle-jdk.tar.gz oracle-jdk/oracle-jdk.tar.gz
}

rm -rf blobs
echo "--- {}" > config/blobs.yml

download_blob oracle-jdk/oracle-jdk.tar.gz "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz" --header "Cookie: oraclelicense=accept-securebackup-cookie"
download_blob apache-groovy/apache-groovy-binary.zip "https://dl.bintray.com/groovy/maven/apache-groovy-binary-2.5.6.zip"
download_blob apache-groovy/snakeyaml.jar "http://central.maven.org/maven2/org/yaml/snakeyaml/1.24/snakeyaml-1.24.jar"
download_blob apache-maven/apache-maven-binary.tar.gz "http://ftp.wayne.edu/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz"
download_blob cf-cli/cf-cli-binary.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github"
download_blob git-client/git-client-source.tar.gz "https://github.com/git/git/archive/v2.21.0.tar.gz"
download_blob golang/go-binary.tar.gz "https://dl.google.com/go/go1.12.linux-amd64.tar.gz"
download_blob jenkins/jenkins.war "http://mirrors.jenkins.io/war-stable/latest/jenkins.war"
download_blob swarm-client/swarm-client.jar "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.9/swarm-client-3.9.jar"
download_blob spruce/spruce-binary "https://github.com/geofffranks/spruce/releases/download/v1.19.2/spruce-linux-amd64"
