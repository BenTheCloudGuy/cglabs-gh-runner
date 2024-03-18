#!/bin/bash
REPOSITORY=$REPO
ACCESS_TOKEN=$TOKEN

# Example for getting .SSH keys via mapped volume | /mnt/user/appdata/sshFolder/tmp/.ssh/  ==>  /home/docker/tmp 


echo ""
echo ""
echo "BenTheBuilder GitHub Action Runner: "
echo "==================================================="
echo "Configure SSH Directory"
echo "TARGET REPO ${REPOSITORY}"
echo ""
echo "Copy SSH Keys from tmp to .ssh"
cp -RT /home/docker/tmp/. /home/docker/.ssh/

echo "Setting .ssh permissions"
chmod 600 /home/docker/.ssh

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