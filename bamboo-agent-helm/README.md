# bamboo-agent-helm

Deploys the containerized Bamboo CI agent into the local k8s Bamboo (ns `ci`)
as a remote agent.

## Prerequisites

- forge-lab Bamboo running in ns `ci`; secret `bamboo-agent-token` present.
- An image pushed by `bamboo-agent-deployment/scripts/build-image.sh`
  (note the `IMAGE_TAG=<sha>` it prints).

## Install

```bash
helm upgrade --install bamboo-agent ./bamboo-agent-helm -n ci \
  --set image.tag=<git-sha>
```

Then approve the agent once: **Bamboo > Administration > Agents**.

## Why no broker workaround

The host-local agent needs a localhost broker override and a port-forward
because it runs off-cluster. This agent runs **in** the cluster, so the broker
URL the server advertises (`bamboo-0.bamboo.ci.svc.cluster.local:54663`) is
reachable directly — no override needed.

## Upgrade to a new image

Rebuild (new sha), then re-run the install with the new `--set image.tag`.
