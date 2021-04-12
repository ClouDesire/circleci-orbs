#!/bin/bash -e
echo ">> Autodetect if sudo is required"
if [ "$EUID" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=
fi

echo ">> Download and install chef-dk if needed"
set +e
hash chef &>/dev/null
RET=$?
set -e
if [ ${RET} -eq 1 ]; then
    CHEF_URL=${CHEF_URL:-https://packages.chef.io/files/stable/chefdk/1.6.11/ubuntu/14.04/chefdk_1.6.11-1_amd64.deb}
    mkdir -p ~/downloads
    wget -P ~/downloads -c -nv "$CHEF_URL"
    $SUDO dpkg -i ~/downloads/chefdk_*_amd64.deb
fi

echo ">> Common requirements (especially for chef/chefdk docker image)"
$SUDO sed -i 's/archive.ubuntu.com/us.archive.ubuntu.com/g' /etc/apt/sources.list
$SUDO apt-get update -q
$SUDO apt-get install -qy build-essential libffi-dev git



echo ">> Place ssh key for deploys"
if [ -n "$KITCHEN_SSH_KEY" ]; then
    if [ -z $KITCHEN_SSH_KEY_PATH ]; then
        KITCHEN_SSH_KEY_PATH="${HOME}/.ssh/kitchen_rsa"
        echo "export KITCHEN_SSH_KEY_PATH=${KITCHEN_SSH_KEY_PATH}" >> "${BASH_ENV}"
    fi

    echo "$KITCHEN_SSH_KEY" | base64 --decode > "${KITCHEN_SSH_KEY_PATH}"
    chmod 400 "${KITCHEN_SSH_KEY_PATH}"
fi

echo ">> Place google api service key"
if [ -n "$GCLOUD_SERVICE_KEY" ]; then
    mkdir -p "$HOME/.config/gcloud"
    echo "$GCLOUD_SERVICE_KEY" | base64 --decode >~/.config/gcloud/application_default_credentials.json
fi

echo ">> Do things inside this script directory"
cd "${0%/*}"
CWD=$(eval echo "$CIRCLE_WORKING_DIRECTORY")

echo ">> Configure test-kitchen"
mkdir -p "$HOME/.kitchen"
cp "${GIT_CI_CONF_DIR}/cookbooks/kitchen.yml" "$HOME/.kitchen/config.yml"

echo ">> Configure credentials for test-kitchen"
sed -i "s/cloudesire_openstack_username/$OS_USERNAME/" "$HOME/.kitchen/config.yml"
sed -i "s/cloudesire_openstack_api_key/$OS_PASSWORD/" "$HOME/.kitchen/config.yml"

echo ">> Use default chefignore"
cp "${GIT_CI_CONF_DIR}/cookbooks/chefignore" "$CWD"

echo ">> Use default Berksfile with upstream dependencies"
cp "${GIT_CI_CONF_DIR}/cookbooks/Berksfile" "$CWD"

echo ">> Copy array of cookbooks to manage"
cp "${GIT_CI_CONF_DIR}/cookbooks/cookbooks.rb" "$CWD"

echo ">> Go back to project directory"
cd "$CWD"

echo ">> Install retry utility"
$SUDO sh -c "curl https://raw.githubusercontent.com/kadwanev/retry/master/retry -o /usr/local/bin/retry && chmod +x /usr/local/bin/retry"

echo ">> Grab Berkshelf dependencies"
retry chef exec berks install
