#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(dirname $0)
SCRIPT_NAME=$(basename $0)
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
NORMAL="\033[0m"
BLOBS=()
FAILURES=0

usage() {
  echo "Usage: ${SCRIPT_NAME} [OPTIONS]" 1>&2
  echo "  Available Options:"
  echo "    -c, --clean         Cleans out existing blob files and re-downloads them"
  echo "    -v, --version       Download a specific Jenkins LTS version (\"latest\" will be used by default)"
  echo
  echo "  Example usage: ${SCRIPT_NAME} --clean --version 2.150.1"
  echo
  exit 1
}

fail() {
  echo -e "${RED}ERROR${NORMAL}: $*" 1>&2
  exit 1
}

get_github_release_url() {
  local owner=${1}
  local repo=${2}
  local binary_type=${3:-linux}
  local version=${4:-latest}

  if [[ -z ${owner} ]] || [[ -z ${repo} ]]; then
    fail "GitHub owner and repo must be supplied"
  fi

  curl -s https://api.github.com/repos/${owner}/${repo}/releases/${version} \
  | grep browser_download_url \
  | grep ${binary_type} \
  | cut -d '"' -f 4
}

get_github_archive_url() {
  local owner=${1}
  local repo=${2}
  local tag

  if [[ -z ${owner} ]] || [[ -z ${repo} ]]; then
    fail "GitHub owner and repo must be supplied"
  fi

  tag=$(git ls-remote --tags https://github.com/${owner}/${repo} | sort -Vk2 | tail -n1 | sed 's/.*\///; s/\^{}//')
  echo "https://github.com/${owner}/${repo}/archive/${tag}.tar.gz"
}

get_plugin_url() {
  local plugin=${1}
  local baseurl version

  baseurl="https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/${plugin}"
  version=$(curl -s ${baseurl}/maven-metadata.xml \
  | grep -o '<latest>.*</latest>' \
  | sed 's/<latest>\(.*\)<\/latest>/\1/g')
  echo "${baseurl}/${version}/${plugin}-${version}.jar"
}

# Usage: download_blob <path and name of blob in blobstore> <url of appropriate source/binary archive>
download_blob() {
  local blob_name=${1}
  local blob_url=${2}
  local blob_dir=$(dirname ${blob_name})
  local blob_file="${SCRIPT_DIR}/blobs/${blob_name}"
  shift; shift

  BLOBS+=("${blob_name}")
  printf " > ${BLUE}${BOLD}%-40s${NORMAL}" "${blob_name}"
  if [[ -e ${blob_file} ]]; then
    echo -e "${YELLOW}Skipping; file exists${NORMAL}"
  else
    mkdir -p ${SCRIPT_DIR}/blobs/${blob_dir}
    wget "$@" -q -O ${blob_file} ${blob_url}
    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}Done${NORMAL}"
    else
      [[ -e ${blob_file} ]] && rm -f ${blob_file}
      echo -e "${RED}FAILED${NORMAL}"
      FAILURES=$((FAILURES+1))
    fi
  fi
}

add_blob() {
  local blob_name=${1}
  local blob_file=${SCRIPT_DIR}/blobs/${blob_name}

  if [[ -e ${blob_file} ]]; then
    bosh add-blob ${blob_file} ${blob_name}
    return $?
  else
    FAILURE+=("File missing for blob: ${blob_name}")
    return 1
  fi
}

clean_blobs() {
  echo "Cleaning out existing blobs..."
  [[ -d ${SCRIPT_DIR}/blobs ]] && rm -rf ${SCRIPT_DIR}/blobs
  echo "--- {}" > ${SCRIPT_DIR}/config/blobs.yml
}

main() {
  local jenkins_version="latest"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--clean)
        clean_blobs
        ;;
      -v|--version)
        shift
        jenkins_version="${1}"
        ;;
      -h|--help)
        usage
        ;;
      -*)
        echo "${SCRIPT_NAME}: bad argument: $1"
        usage
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  echo "Downloading Jenkins package blob (${jenkins_version}):"
  download_blob jenkins/jenkins.war "http://mirrors.jenkins.io/war-stable/${jenkins_version}/jenkins.war"

  echo
  echo "Downloading supporting package blobs:"
  download_blob oracle-jdk/oracle-jdk.tar.gz "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz" --header "Cookie: oraclelicense=accept-securebackup-cookie"
  download_blob cf-cli/cf-cli-binary.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github"
  download_blob git-client/git-client-source.tar.gz $(get_github_archive_url git git)
  download_blob swarm-client/swarm-client.jar $(get_plugin_url swarm-client)
  download_blob spruce/spruce-binary $(get_github_release_url geofffranks spruce)

  if [ ${#BLOBS} -ne 0 ]; then
    echo
    echo "Adding blobs to BOSH release: "
    for blob_name in ${BLOBS[@]}; do
      printf " > ${BLUE}${BOLD}%-40s${NORMAL}" "${blob_name}"
      add_blob ${blob_name} > /dev/null 2>&1
      if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Success${NORMAL}"
      else
        echo -e "${RED}FAILED${NORMAL}"
        FAILURES=$((FAILURES+1))
      fi
    done
  fi

  if [ ${FAILURES} -gt 0 ]; then
    echo
    fail "One or more failures occured"
  fi
}

main "$@"
