#!/bin/bash
REPOSITORY="$REPO"
ACCESS_TOKEN="$TOKEN"
SSH_TMP_DIR="$SSH_TMP_DIR" #  /home/docker/tmp/
 
echo ""
echo ""
echo "${REPOSITORY}: GitHub Action Runner"
echo "==================================================="
echo "===|      CHECKING ENVIRONMENT VARIABLES       |==="
echo "==================================================="
echo "SSH_TMP_DIR: ${SSH_TMP_DIR}"
echo "REPOSITORY: ${REPOSITORY}"
echo "RUNNER_VERSION: ${RUNNER_VERSION}"     
echo "OS_VERSION: ${OS_VERSION}"
echo "ACCESS_TOKEN: ${ACCESS_TOKEN}"      
echo ""

# If SSH_TMP_DIR is set, copy the SSH files to the .ssh directory
if [ -d $SSH_TMP_DIR ]; then
    echo "Copying SSH Files from ${SSH_TMP_DIR}"
    cp -a "${SSH_TMP_DIR}". /home/docker/.ssh
    cd /home/docker/.ssh
    for key in *; 
    do
        if [ $key != "authorized_keys" ]; then
            chmod 600 "${key}"
        fi
    done
fi

echo "Collecting Registration Token from GitHub"
REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

echo "${REG_TOKEN}"
cd /home/docker/actions-runner

./config.sh --url https://github.com/${REPOSITORY} --token ${REG_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!