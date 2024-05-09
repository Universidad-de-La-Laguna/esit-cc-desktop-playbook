FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common && \
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y --no-install-recommends \
    ansible && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /ansible

CMD ["/bin/bash"]
