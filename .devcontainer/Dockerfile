FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# no output
ENV DEBIAN_FRONTEND=noninteractive

# Install Python
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip

# output
ENV DEBIAN_FRONTEND=dialog

# Setup Requirements
COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
   && rm -rf /tmp/pip-tmp