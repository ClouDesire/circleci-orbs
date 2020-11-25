#!/usr/bin/env bash
SONAR_VERSION=${SONAR_VERSION:-3.7.0.1746}
CWD=$(pwd)
SONAR_OPTS="${SONAR_OPTS} -Dsonar.host.url=${SONAR_HOST_URL} \
-Dsonar.login=${SONAR_USERNAME} \
-Dsonar.password=${SONAR_PASS}"

echo "SONAR_OPTS: ${SONAR_OPTS}"

function run_sonar {
  if [ -z "${NO_SONAR}" ]; then
    detect_maven
    # Preview mode when running in a Pull Request
    if [ -n  "${CI_PULL_REQUEST}" ]; then
      PR_NUMBER=${CI_PULL_REQUEST##*/}
      PROJECT_NAME="${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
      GIT_BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
  
      echo ">> Configuring sonar for PR $PR_NUMBER"
      echo ">> PR Base branch is ${GIT_BASE_BRANCH}"
      
      SONAR_OPTS="$SONAR_OPTS -Dsonar.pullrequest.key=${PR_NUMBER} \
      -Dsonar.pullrequest.branch=${CIRCLE_BRANCH} \
      -Dsonar.pullrequest.base=${GIT_BASE_BRANCH}"
    else
        unset SONAR_GITHUB_TOKEN
    fi
    
    # Run
    echo "Running sonar-scanner"
    echo "SONAR_OPTS: ${SONAR_OPTS}"
    ${SONAR_BIN} ${SONAR_OPTS}
  else
      echo "Skipping sonar as requested"
  fi
}

function detect_maven {
  if [[ -x "./mvnw" ]]; then
    SONAR_BIN="./mvnw sonar:sonar"
    return
  fi
  
  if hash mvn 2>/dev/null; then
    SONAR_BIN="mvn sonar:sonar"
    return
  fi
  
  echo ">> Not mvn detected, running standalone sonar-scanner"
  SONAR_OPTS="${SONAR_OPTS} -Dsonar.projectKey=${CIRCLE_PROJECT_REPONAME}"
  if [[ "${SONAR_OPTS}" != *"-Dsonar.sources"* ]]; then
    echo "ERROR: '-Dsonar.sources' must be set in SONAR_OPTS when running standalone"
    exit 3
  fi
   
  echo ">> Installing standalone sonar-scanner"
  install_sonar
  echo ">> Installed standalone sonar-scanner"
}

function install_sonar() {
  mkdir -p $SONAR_DIR
  echo "  >> Downloading sonar-scanner-cli sonar-scanner-cli-${SONAR_VERSION}-linux.zip"
  wget -q "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/ sonar-scanner-cli-${SONAR_VERSION}-linux.zip"
  unzip -q sonar-scanner-cli-"${SONAR_VERSION}"-linux.zip
  mv sonar-scanner-"${SONAR_VERSION}"-linux $SONAR_DIR
  SONAR_BIN="$SONAR_DIR/bin/sonar-scanner"
  echo "  >> Sonar available at ${SONAR_BIN}"
}

run_sonar
