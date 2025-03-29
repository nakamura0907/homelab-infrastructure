ARG VARIANT=bookworm-slim
FROM debian:${VARIANT}

ARG TERRAFORM_VERSION=1.11.3
ARG KUBECTL_VERSION=1.32.0

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    ansible \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/* \
    # Install terraform
    && curl -fsSL -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip \
    # Install kubectl
    && curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    # Install Flux CLI
    && curl -s https://fluxcd.io/install.sh | FLUX_VERSION=2.0.0 bash -s /usr/local/bin \
    # Install Taskfile
    && sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

CMD ["/bin/bash"]
