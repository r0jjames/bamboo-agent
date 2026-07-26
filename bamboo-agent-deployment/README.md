# bamboo-agent-deployment

Builds the CI/image-build agent image and pushes it to
`docker.io/rojcarranza/bamboo-agent:<semver>` via a kaniko Job.

The Bamboo plan that runs this build (`AGENT-BUILD`) is defined in
[forge-lab](https://github.com/r0jjames/forge-lab) —
`bamboo-specs/src/main/java/lab/agent/BuildAgentImageSpec.java` — and published
from there with `make specs-publish`. This module holds only the image sources
and the build mechanics the plan invokes.

## One-time: Docker Hub push secret

Create a Docker Hub PAT (Account Settings > Security), then:

```bash
kubectl -n ci create secret docker-registry dockerhub-push \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=rojcarranza \
  --docker-password=<DOCKERHUB_PAT>
```

The PAT never lands in git.

## Build

The image tag is a semver read from the `VERSION` file (source of truth).

```bash
scripts/build-image.sh          # pushes :<VERSION>, prints IMAGE_TAG=<x.y.z>
IMAGE_TAG=0.2.0 scripts/build-image.sh   # override the version ad hoc
```

To cut a release: bump `VERSION`, bump `bamboo-agent-helm/values.yaml`
`image.tag` to match, commit, push, then run the build.

The build runs entirely in a throwaway kaniko Job in namespace `ci`; the shell
that runs the script needs only `kubectl`. The commit being built must be
pushed first — kaniko clones the git context (`KANIKO_CONTEXT`, default the
`main` branch of this repo).
