#!/bin/bash

YarnRelease() {
  
  cd "$PROJECT_DIR"

  echo "Setting up .npmrc"
  npm config set "@cloudesire:registry" "$NPM_REGISTRY"
  
  NPM_REGISTRY_HOSTNAME="${NPM_REGISTRY##*://}"
  NPM_REGISTRY_HOSTNAME="${NPM_REGISTRY_HOSTNAME%'/'}"
  npm config set //$NPM_REGISTRY_HOSTNAME/:_authToken=$NPM_TOKEN
  
  echo "Releasing $RELEASE_VERSION"
  npm publish --registry $NPM_REGISTRY

  echo "Tagging commit"
  git tag "v${RELEASE_VERSION}"

  echo "Calculating next version"
  IFS='.' read -a semver <<< "$RELEASE_VERSION"
  NEW_VERSION="${semver[0]}.${semver[1]}.$((${semver[2]} + 1))"
  NEW_VERSION="${NEW_VERSION}-beta"
  
  yarn config set version-git-tag false
  yarn config set version-commit-hooks false

  echo "Updating package.json version to ${NEW_VERSION}"
  yarn version --new-version "${NEW_VERSION}"

  find ./ -name package.json -not -path "./node_modules/*" -exec git add {} \;
  git commit -m "Preparing for next iteration - version set to ${NEW_VERSION}"
  
  git push --set-upstream origin "${CIRCLE_BRANCH}" --tags

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  YarnRelease
fi
