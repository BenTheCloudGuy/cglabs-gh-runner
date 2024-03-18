# Custom GitHub Runner Docker Image

This repository contains a custom GitHub Runner packaged as a Docker image. GitHub Actions allows you to automate your workflow, and using custom runners can extend the capabilities of your actions. This Docker image provides a way to run GitHub Actions workflows on your own infrastructure. Image is based on ubuntu:20.04

Details on this Docker Image can be found at: [GitHub | BenTheCloudGuy](https://github.com/BenTheCloudGuy/cglabs-gh-runner)

## Features

- **Customizable**: Easily configure the runner to suit your specific needs and environment.
- **Docker-based**: Utilizes Docker to encapsulate the runner environment, ensuring consistency and portability.
- **Scalable**: Can be scaled horizontally by spinning up multiple instances to handle parallel jobs.
- **Self-hosted**: Enables you to run workflows on your own servers or cloud infrastructure.
- **Flexible**: Supports running workflows for both public and private repositories.

## Installed Applications

- Ansible
- Hashicorp Packer
- Hashicorp Terraform
- Azure CLI
- Powershell Core
   - Az Module
   - AzureAD Module
   - Microsoft.Graph Module


## Prerequisites

Before using this Docker image, ensure you have the following prerequisites installed:

- Docker Engine: [Installation Guide](https://docs.docker.com/get-docker/)
- GitHub Repository: Set up a repository on GitHub where you want to use the custom runner.

## Usage

### 1. Pull the Docker Image

Pull the latest version of the custom GitHub Runner Docker image from Docker Hub:

```bash
docker pull benthebuilder/cglabs-gh-runner
```

### 2. Configure Runner

Set up the runner by providing necessary configuration options such as GitHub registration token, runner name, etc. These configurations are typically provided through environment variables.

### 3. Run Docker Container

Start the Docker container using the pulled image:

```bash
docker run -d benthebuilder/cglabs-gh-runner
```

### 4. Register Runner

Once the container is running, register the runner with your GitHub repository. Follow the instructions provided by GitHub for runner registration.

### 5. Run Workflows

After registering the runner, you can now use it to run workflows in your GitHub repository. Configure your workflows to use this runner as needed.

## Configuration

You can configure the custom GitHub Runner by providing environment variables to the Docker container. Refer to the [GitHub Actions documentation](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners#self-hosted-runner-groups) for a list of available configuration options.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgements

- This Docker image is inspired by the official GitHub Actions Runner.
- Special thanks to the GitHub Actions community for their contributions and support.

## Support

For any questions, issues, or feedback, please [open an issue](https://github.com/BenTheCloudGuy/cglabs-gh-runner/issues/new) on GitHub.
