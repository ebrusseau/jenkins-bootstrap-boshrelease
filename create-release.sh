#!/bin/bash

usage() {
  echo "Usage: $(basename $0) <release type> [tarball output filename]" 1>&2
  echo "  release type must be 'dev' or 'final'" 1>&2
  echo "  tarball output filename is optional; defaults to:" 1>&2
  echo "    jenkins-bootstrap-dev.tgz for dev releases" 1>&2
  echo "    jenkins-bootstrap-final.tgz for final releases" 1>&2
  echo
  exit 1
}

get_jenkins_version() {
  local war=blobs/jenkins/jenkins.war
  local version
  if [[ ! -e ${war} ]]; then
    echo "Jenkins blob file missing; use 'download-blobs' to download"
    exit 1
  fi

  version=$(unzip -p "${war}" META-INF/MANIFEST.MF | grep "^Jenkins-Version: " | sed -e 's#^Jenkins-Version: ##')

  if [[ $? -ne 0 ]]; then
    echo "Jenkins blob file damaged; use 'download-blobs -c' to re-download"
    exit 1
  fi

  version=${version%%[[:space:]]}
  echo "${version}"
}

main() {
  if [[ $# -lt 1 ]]; then
    usage "missing arguments"
  fi

  case ${1} in
    dev)
      version_suffix="-dev.$(date '+%Y%m%d.%-H%M.%S+%Z')"
      ;;
    final)
      version_suffix="-$(date '+%Y%m%d.%-H%M.%S+%Z')"
      create_args="--final"
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "ERROR: Invalid release type: ${1}"
      usage
      ;;
  esac


  version="$(get_jenkins_version)${version_suffix}"
  filename=${2:-jenkins-bootstrap-${1}.tgz}
  create_args="${create_args} --force --version=${version} --tarball=${filename}"

  echo "Creating BOSH release with version: ${version}"
  bosh create-release ${create_args}
}

main "$@"
