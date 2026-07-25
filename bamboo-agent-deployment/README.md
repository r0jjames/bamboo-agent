# bamboo-agent-deployment

Builds the CI/image-build agent image and pushes it to
`docker.io/rojcarranza/bamboo-agent:<git-sha>` via a kaniko Job.

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

```bash
scripts/build-image.sh          # pushes :<git-sha>, prints IMAGE_TAG=<sha>
```

The build runs entirely in a throwaway kaniko Job in namespace `ci`; the shell
that runs the script needs only `kubectl`. The commit being built must be
pushed first — kaniko clones the git context (`KANIKO_CONTEXT`, default the
`main` branch of this repo).
