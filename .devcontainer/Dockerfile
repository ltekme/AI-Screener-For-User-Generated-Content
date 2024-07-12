FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Turn off install dialogue
ENV DEBIAN_FRONTEND=noninteractive

# Install python
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip

# Install nodejs
# RUN apt-get install -y curl \
#     && curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh \
#     && sudo -E bash /tmp/nodesource_setup.sh \
#     && sudo apt-get update \
#     && sudo apt-get install -y nodejs \
#     && rm /tmp/nodesource_setup.sh

# Install AWS Typescript and aws-cdk
# RUN npm install -g typescript aws-cdk

# Terrafrom setup
RUN wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list \
    && sudo apt update && sudo apt install terraform -y

ENV DEBIAN_FRONTEND=dialog