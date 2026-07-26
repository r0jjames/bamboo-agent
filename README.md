# bamboo-agent

Containerized Bamboo remote agent for CI / image-build jobs: its image sources,
build mechanics, and Helm deployment. Companion to the
[forge-lab](https://github.com/r0jjames/forge-lab) CI/CD lab; coexists with
forge-lab's host-local agent (which keeps the multipass provisioning jobs).

The Bamboo plan that drives the build (`AGENT-BUILD`) lives in forge-lab with
the rest of the lab's plans-as-code —
`bamboo-specs/src/main/java/lab/agent/BuildAgentImageSpec.java`. It checks this
repo out and runs `bamboo-agent-deployment/scripts/build-image.sh`.

## Modules

- `bamboo-agent-deployment/` — agent Dockerfile, `agent.role=ci` capability,
  and the kaniko build script that pushes the image to
  `docker.io/rojcarranza/bamboo-agent:<semver>` (from `VERSION`).
- `bamboo-agent-helm/` — Helm chart deploying the image into the local k8s
  Bamboo (namespace `ci`) as a remote agent.

## Prerequisites

- forge-lab's Bamboo running in namespace `ci` (server version 12.1.8).
- Secret `bamboo-agent-token` present in `ci` (created by forge-lab's `make bamboo-secrets`).
- Secret `dockerhub-push` in `ci` — see `bamboo-agent-deployment/README.md`.

## Quick start

```bash
# 1. Build + push the image (host agent or any kubectl-capable shell)
bamboo-agent-deployment/scripts/build-image.sh

# 2. Deploy the agent (image.tag defaults to the semver in values.yaml)
helm upgrade --install bamboo-agent ./bamboo-agent-helm -n ci

# 3. Approve the agent once: Bamboo > Administration > Agents
```

To run the build as a Bamboo plan instead of by hand, publish the specs from
forge-lab (`make specs-publish`) and run `AGENT-BUILD`.
