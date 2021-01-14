#!/usr/bin/env bash
SONAR_OPTS="${SONAR_OPTS} -Dsonar.host.url=${SONAR_HOST_URL} \
-Dsonar.login=${SONAR_USERNAME} \
-Dsonar.password=${SONAR_PASS}"

function run_sonar() {
  if [ -z "${NO_SONAR}" ]; then
    detect_maven
    if [ -n "${CI_PULL_REQUEST}" ]; then
      PR_NUMBER=${CI_PULL_REQUEST##*/}
      PROJECT_NAME="${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
      GIT_BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

      echo ">> Configuring sonar for PR $PR_NUMBER"
      echo ">> PR Base branch is ${GIT_BASE_BRANCH}"

      SONAR_OPTS="$SONAR_OPTS -Dsonar.pullrequest.key=${PR_NUMBER} \
      -Dsonar.pullrequest.branch=${CIRCLE_BRANCH} \
      -Dsonar.pullrequest.base=${GIT_BASE_BRANCH}"
    fi

    # Run
    echo "Running sonar-scanner"
    echo "SONAR_OPTS: ${SONAR_OPTS}"
    ${SONAR_BIN} ${SONAR_OPTS}
  fi
}

function detect_maven() {
  if [[ -x "./mvnw" ]]; then
    SONAR_BIN="./mvnw sonar:sonar"
    return
  fi

  if hash mvn 2>/dev/null && [ -f "pom.xml" ]; then
    SONAR_BIN="mvn sonar:sonar"
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
run_sonar
