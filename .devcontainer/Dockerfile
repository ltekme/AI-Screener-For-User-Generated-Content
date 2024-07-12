FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Turn off install dialogue
ENV DEBIAN_FRONTEND=noninteractive

# Install python
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip

# Install nodejs
RUN apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh \
    && sudo -E bash /tmp/nodesource_setup.sh \
    && sudo apt-get update \
    && sudo apt-get install -y nodejs \
    && rm /tmp/nodesource_setup.sh

# Turn on install dialogue
ENV DEBIAN_FRONTEND=dialog

# Install AWS Typescript and aws-cdk
RUN npm install -g typescript aws-cdk
