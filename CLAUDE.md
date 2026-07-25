# bamboo-agent

Containerized Bamboo CI/image-build remote agent + its build pipeline and Helm
deployment. Companion to forge-lab. See `README.md` for module layout.

## Conventions

- Commits use Roj's git identity ONLY — never add Claude as author, co-author,
  or trailer (no `Co-Authored-By`, no "Generated with Claude" footers).
- Image tag is semver from `bamboo-agent-deployment/VERSION`; keep
  `bamboo-agent-helm/values.yaml` `image.tag` in sync when releasing.
- Scripts: bash strict mode, shellcheck-clean. Dockerfile: hadolint-clean.
- Never commit secrets, PATs, or rendered manifests containing credentials.
- Agent version (base image, bamboo-specs-parent) MUST match the Bamboo server.
