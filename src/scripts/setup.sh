#!/usr/bin/env bash

function install_jq() {
  if [ -z "${JQ_VERSION}" ]; then
    JQ_VERSION="1.6"
  fi

  jq_url="https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64"
  jq_installation_path='/usr/local/bin/jq'

  if ! command -v 'wget' &> /dev/null; then
    echo "ERROR: impossible to find command wget. Trying with curl..."
    if ! command -v 'curl' &> /dev/null; then
      echo "ERROR: impossibile to find command curl. Exiting..."
      exit 1
    else
      DOWNLOAD_CMD="curl ${jq_url} -o ${jq_installation_path}"
    fi
  else
    DOWNLOAD_CMD="wget ${jq_url} -O ${jq_installation_path}"
  fi

  if ! command -v 'jq' &> /dev/null && [ -n "${DOWNLOAD_CMD}" ]; then
    ${DOWNLOAD_CMD}
    chmod +x '/usr/local/bin/jq'
  fi

  echo "jq version: $(jq --version)"
}

install_jq
