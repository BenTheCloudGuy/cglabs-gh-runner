#!/bin/bash
REPOSITORY=$REPO
ACCESS_TOKEN=$TOKEN

echo "TARGET REPO ${REPOSITORY}"
echo ""
echo ""
echo "BenTheBuilder GitHub Action Runner: "
echo "==================================================="
echo "Configure SSH Directory"

# Set SSH Permissions
chown -R docker /home/docker/.ssh
chmod 600 /home/docker/.ssh/authorized_keys
chmod 600 /home/docker/.ssh/config
chmod 700 /home/docker/.ssh

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