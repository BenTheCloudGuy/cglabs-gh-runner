FROM ubuntu:20.04

# Set the Arguments for the Dockerfile
ARG RUNNER_VERSION="2.314.1"        # Use this to set the Download Version for the Runner
ARG OS_VERSION="20.04"              # Use this to set the Download Version for the Microsoft Repo

# Set Envirorment Variables based on the Arguements
ENV RUNNER_VERSION=${RUNNER_VERSION}
ENV OS_VERSION=${OS_VERSION}

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

# Update apt and add docker user
RUN apt update -y && apt upgrade -y && useradd -m docker

# Install Dependencies
RUN apt install -y --no-install-recommends \
    curl jq yq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip software-properties-common openssh-client wget apt-transport-https curl gnupg unzip vim iputils-ping

# Install Powershell Core
RUN wget -q https://packages.microsoft.com/config/ubuntu/${OS_VERSION}/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt update -y \
    && apt install -y powershell 

# Install Azure Powershell Modules
RUN pwsh -c "Install-Module -Name Az -Force" \
    && pwsh -c "Install-Module -Name AzureAD -RequiredVersion 2.0.2.140 -Force" \
    && pwsh -c "Install-Module -Name Microsoft.Graph -Force" \
    && pwsh -c "Install-Module -Name powershell-yaml -Force"

# Install Azure Tools
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash 

# Install Terraform & Packer
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt update \
    && apt install -y terraform packer \
    && terraform --version \
    && packer --version

# Install Ansbile
RUN apt-add-repository -y --update ppa:ansible/ansible \
    && apt update -y \
    && pip3 install pywinrm pyvmomi ansible \
    && ansible --version

# Install GH Runner Agent
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Setup up SSH Folders
RUN mkdir /home/docker/.ssh \
    && chown docker /home/docker/.ssh \
    && chmod 700 /home/docker/.ssh

# Grant docker access to runner script
RUN chown -R docker ~docker \
    && /home/docker/actions-runner/bin/installdependencies.sh

# Copy start.sh to the image
COPY start.sh start.sh

# make start.sh executable
RUN chmod +x start.sh

# set the user to "docker" and set the entrypoint to start.sh
USER docker
ENTRYPOINT ["./start.sh"]