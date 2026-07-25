# Agent version MUST match the Bamboo server (forge-lab runs 12.1.8).
FROM atlassian/bamboo-agent-base:12.1.8

USER root

# CI/build capabilities only. NO terraform/ansible/multipass — those stay on
# the host-local agent. kubectl is needed to launch and observe kaniko Jobs.
# Arch comes from the rootfs being built (dpkg), so this is correct under both
# `docker buildx` and the in-cluster kaniko build, on amd64 or arm64 nodes.
ARG KUBECTL_VERSION=v1.30.5
RUN apt-get update \
    && apt-get install -y --no-install-recommends git jq maven ca-certificates curl socat \
    && arch="$(dpkg --print-architecture)" \
    && curl -fsSL -o /usr/local/bin/kubectl \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${arch}/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# The custom capability (agent.role=ci) is seeded at deploy time by the Helm
# chart's init container using the image's own /bamboo-update-capability.sh,
# so nothing to bake here.

# Deliberately do NOT set `USER bamboo`: the base entrypoint expects to start as
# root, chown the agent home to the bamboo user (uid 2005), then drop privileges
# itself. Pinning USER bamboo here skips that and the agent can't write bin/wrapper.
USER root
