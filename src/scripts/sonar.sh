#!/usr/bin/env bash
SONAR_OPTS="${SONAR_OPTS} -Dsonar.host.url=${SONAR_HOST_URL}"

function run_sonar() {
  export PULL_REQUEST=""

  if [ -n "${CI_PULL_REQUEST}" ]; then
    export PULL_REQUEST="${CI_PULL_REQUEST}"
  elif [ -n "${CIRCLE_PULL_REQUEST}" ]; then
    export PULL_REQUEST="${CIRCLE_PULL_REQUEST}"
  fi
  
  if [ "$CIRCLE_BRANCH" != "master" ] && [ "$CIRCLE_BRANCH" != "main" ] && [ -z "${PULL_REQUEST}" ] && [ -z "${CIRCLE_TAG}" ]; then
    echo "ERROR: not on a PR nor on master/main nor a tagged build, you may want to enable 'Only build pull requests' option in the CircleCI project settings page"
    exit 1
  fi

  detect_maven
  
  if [ -n "${PULL_REQUEST}" ]; then
    PR_NUMBER=${PULL_REQUEST##*/}
    
    GIT_BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

    echo ">> Configuring sonar for PR $PR_NUMBER"
    echo ">> PR Base branch is ${GIT_BASE_BRANCH}"

    SONAR_OPTS="$SONAR_OPTS -Dsonar.pullrequest.key=${PR_NUMBER} \
    -Dsonar.pullrequest.branch=${CIRCLE_BRANCH} \
    -Dsonar.pullrequest.base=${GIT_BASE_BRANCH}"
  fi
  
  PROJECT_NAME="${CIRCLE_PROJECT_USERNAME}_${CIRCLE_PROJECT_REPONAME}"
  SONAR_OPTS="$SONAR_OPTS -Dsonar.projectKey=${PROJECT_NAME}"
  
  # Run
  echo "Running sonar-scanner"
  echo "SONAR_OPTS: ${SONAR_OPTS}"
  ${SONAR_BIN} ${SONAR_OPTS}
}

function detect_maven() {
  # https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/
  if [ "${SONAR_MVN_VERSION}" = "latest" ]; then
    SONAR_MVN_COMMAND="sonar:sonar"
  else
    SONAR_MVN_COMMAND="org.sonarsource.scanner.maven:sonar-maven-plugin:$SONAR_MVN_VERSION:sonar"
  fi

  if [[ -x "./mvnw" ]]; then
    SONAR_BIN="./mvnw $SONAR_MVN_COMMAND"
    return
  fi

  if hash mvn 2>/dev/null && [ -f "pom.xml" ]; then
    SONAR_BIN="mvn $SONAR_MVN_COMMAND"
    return
  fi

  echo ">> Maven not detected, running standalone sonar-scanner"
  SONAR_OPTS="${SONAR_OPTS} -Dsonar.projectKey=${CIRCLE_PROJECT_REPONAME}"
  if [[ "${SONAR_OPTS}" != *"-Dsonar.sources"* ]]; then
    echo "ERROR: '-Dsonar.sources' must be set in SONAR_OPTS when running standalone"
    exit 3
  fi

  if [[ "$(ls -A $SONAR_DIR/sonar-scanner-${SONAR_VERSION}-linux)" ]]; then
    echo ">> sonar-scanner already installed"
  else
    echo ">> Installing standalone sonar-scanner"
    install_sonar
    echo ">> Installed standalone sonar-scanner"
  fi

  SONAR_BIN="$SONAR_DIR/sonar-scanner-${SONAR_VERSION}-linux/bin/sonar-scanner"
  echo "  >> Sonar available at ${SONAR_BIN}"
  $SONAR_BIN --version

}

function install_sonar() {
  mkdir "$SONAR_DIR" -p
  echo "  >> Downloading sonar-scanner-cli sonar-scanner-cli-${SONAR_VERSION}-linux.zip"
  wget -q "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_VERSION}-linux.zip"
  unzip -q "sonar-scanner-cli-${SONAR_VERSION}-linux.zip"
  echo "  >> Moving sonar-scanner-cli to ${SONAR_DIR}"
  mv "sonar-scanner-${SONAR_VERSION}-linux" "${SONAR_DIR}"
}

cd $PROJECT_DIR
if [ -z "${NO_SONAR}" ]; then
  run_sonar
fi
