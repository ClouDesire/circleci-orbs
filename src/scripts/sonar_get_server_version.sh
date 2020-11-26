#!/usr/bin/env bash
SONAR_API_ENDOINT="${SONAR_HOST_URL}/api/server/version"
SONAR_SERVER_VERSION=$(curl "$SONAR_API_ENDOINT")
echo "Sonar Server Version: ${SONAR_SERVER_VERSION}"
echo "export SONAR_SERVER_VERSION='$SONAR_SERVER_VERSION'" > sonar_version.txt
echo "export SONAR_SERVER_VERSION='$SONAR_SERVER_VERSION'" >> $BASH_ENV
source $BASH_ENV
