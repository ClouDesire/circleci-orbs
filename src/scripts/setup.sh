#!/usr/bin/env bash

function install_jq() {
  if [ -z "${JQ_VERSION}" ]; then
    JQ_VERSION="1.6"
  fi

  jq_url="https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64"
  jq_installation_path='/usr/local/bin/jq'


  if command -v 'wget' &> /dev/null; then
    DOWNLOAD_CMD="wget ${jq_url} -O ${jq_installation_path}"
  fi

  if command -v 'curl' &> /dev/null; then
    DOWNLOAD_CMD="curl ${jq_url} -o ${jq_installation_path}"
  fi

  if [ -z "${DOWNLOAD_CMD}" ]; then
    echo "ERROR: impossibile to find either curl or wget. Exiting..."
    exit 1
  fi
  
  ${DOWNLOAD_CMD}
  if [ $? -eq 0 ] ; then
    chmod +x '/usr/local/bin/jq'
    echo "jq version: $(jq --version)"
  else
    echo "ERROR: jq installation failed"
    exit 1
  fi
}

if ! command -v 'jq' &> /dev/null; then
  echo "jq not installed. Installing it..."
  install_jq
  echo "jq installed"
fi
