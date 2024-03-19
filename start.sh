#!/bin/bash
REPOSITORY=$REPO
ACCESS_TOKEN=$TOKEN
SSH_TMP_DIR=$SSH_TMP_DIR #  /home/docker/tmp/
 
echo ""
echo ""
echo "${REPOSITORY}: GitHub Action Runner"
echo "==================================================="
echo "===CHECKING ENVIRONMENT VARIABLES==="
echo "==================================================="
echo ""
echo ""
echo "SSH_TMP_DIR: ${SSH_TMP_DIR}"

if [ -d "$SSH_TMP_DIR"]; then
    echo "SSH_TMP_DIR Found: ${SSH_TMP_DIR}"
    echo "Copying SSH Files from ${SSH_TMP_DIR}"
    cp -a ${SSH_TMP_DIR}. /home/docker/.ssh
    cd /home/docker/.ssh
    for key in *; do
        if [!"authorized_keys"]; then
            echo "Setting Permissions for ${key}"
            chmod 600 ${key}
        fi
    done
fi

echo "Collecting Registration Token from GitHub"
REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/${REPOSITORY} --token ${REG_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!