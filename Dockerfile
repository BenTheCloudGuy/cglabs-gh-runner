FROM ubuntu:20.04

# Set the Arguments for the Dockerfile
ARG RUNNER_VERSION="2.314.1"        # Use this to set the Download Version for the Runner
ARG OS_VERSION="20.04"              # Use this to set the Download Version for the Microsoft Repo

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

# Update apt and add docker user
RUN apt update -y && apt upgrade -y && useradd -m docker

# install dependencies
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip software-properties-common openssh-client wget apt-transport-https

# Install Powershell Core
RUN wget -q https://packages.microsoft.com/config/ubuntu/${OS_VERSION}/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt update -y \
    && apt install -y powershell 

# Install Ansbile on Image
RUN apt-add-repository -y --update ppa:ansible/ansible \
    && apt update -y \
    && pip3 install pywinrm pyvmomi ansible 

# Install the runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Grant docker access to runner script
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# Copy start.sh to the image
COPY start.sh start.sh

# make start.sh executable
RUN chmod +x start.sh

# set the user to "docker" and set the entrypoint to start.sh
USER docker
ENTRYPOINT ["./start.sh"]