FROM ubuntu:20.04

# Set the version of the runner to install (https://github.com/actions/runner/releases) 
ARG RUNNER_VERSION="2.314.1"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

# Update apt and add docker user
RUN apt update -y && apt upgrade -y && useradd -m docker

# install dependencies
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# Install Ansbile on Image
run apt-add-repository --yes --update ppa:ansible/ansible \
    && apt update --yes \
    && pip3 install pywinrm \
    && pip3 install pyvmomi \
    && pip3 install ansible 

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