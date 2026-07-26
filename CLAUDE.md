# bamboo-agent

Containerized Bamboo CI/image-build remote agent: image sources, build
mechanics, Helm deployment. Companion to forge-lab. See `README.md` for module
layout.

The Bamboo plan that builds this image (`AGENT-BUILD`) lives in forge-lab
(`bamboo-specs/src/main/java/lab/agent/BuildAgentImageSpec.java`) — this repo
holds no Bamboo Specs. Pipeline changes go there; image changes go here.

## Conventions

- Commits use Roj's git identity ONLY — never add Claude as author, co-author,
  or trailer (no `Co-Authored-By`, no "Generated with Claude" footers).
- Image tag is semver from `bamboo-agent-deployment/VERSION`; keep
  `bamboo-agent-helm/values.yaml` `image.tag` in sync when releasing.
- Scripts: bash strict mode, shellcheck-clean. Dockerfile: hadolint-clean.
- Never commit secrets, PATs, or rendered manifests containing credentials.
- Agent base image version MUST match the Bamboo server (and forge-lab's
  `bamboo-specs-parent`).
