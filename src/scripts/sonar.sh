#!/usr/bin/env bash
SONAR_VERSION=${SONAR_VERSION:-3.0.3.778}
CWD=$(pwd)
SONAR_OPTS="${SONAR_OPTS} -Dsonar.host.url=${SONAR_HOST_URL} \
-Dsonar.login=${SONAR_USERNAME} \
-Dsonar.password=${SONAR_PASS}"

function run_sonar {
    if [ -z "${NO_SONAR}" ]; then
        detect_maven
        # Preview mode when running in a Pull Request
        if [ -n  "${CI_PULL_REQUEST}" ]; then
            PR_NUMBER=${CI_PULL_REQUEST##*/}
            PROJECT_NAME="${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
            
            echo "Configuring sonar for PR $PR_NUMBER"
            SONAR_OPTS="$SONAR_OPTS -Dsonar.pullrequest.key=${PR_NUMBER} \
            -Dsonar.pullrequest.branch=${CIRCLE_BRANCH} \
            -Dsonar.pullrequest.base=master"
        else
            unset SONAR_GITHUB_TOKEN
        fi
        
        # Run
        echo "Running sonar"
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
    
    install_sonar
    
    if [ -n  "${SONAR_SOURCES}" ]; then
        SONAR_OPTS="${SONAR_OPTS} -Dsonar.sources=${SONAR_SOURCES} -Dsonar.projectKey=${CIRCLE_PROJECT_REPONAME}"
    else
        echo "SONAR_SOURCES must be set when running standalone"
        exit 3
    fi
}

function install_sonar() {
    mkdir -p $SONAR_DIR
    wget -q "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/\
    sonar-scanner-cli-${SONAR_VERSION}-linux.zip"
    unzip -q sonar-scanner-cli-"${SONAR_VERSION}"-linux.zip
    mv sonar-scanner-"${SONAR_VERSION}"-linux $SONAR_DIR
    SONAR_BIN="$SONAR_DIR/bin/sonar-scanner"
    echo Sonar available at "${SONAR_BIN}"
}

run_sonar
