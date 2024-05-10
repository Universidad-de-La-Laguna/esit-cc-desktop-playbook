FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y ansible && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /ansible

CMD ["/bin/bash"]
