#!/usr/bin/env bash
set -euo pipefail
# Build and push the bamboo-agent image via a throwaway kaniko Job in ns ci.
# Kaniko must run in its own pod (it unpacks the base image over the container
# root fs), so we template a Job per build, wait, and tail its logs. The
# orchestrating shell needs only kubectl — the host agent already has it.
#
# The image tag is a semver read from the VERSION file (override with IMAGE_TAG).
# Bump VERSION (and the Helm image.tag) to cut a new release.
NS="${NS:-ci}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${IMAGE_TAG:-$(tr -d '[:space:]' < "$SCRIPT_DIR/../VERSION")}"
CONTEXT="${KANIKO_CONTEXT:-git://github.com/r0jjames/bamboo-agent.git#refs/heads/main}"
TMPL="$SCRIPT_DIR/../kaniko/kaniko-job.yaml.tmpl"

command -v kubectl >/dev/null || { echo "kubectl not found"; exit 1; }
kubectl -n "$NS" get secret dockerhub-push >/dev/null 2>&1 \
  || { echo "secret 'dockerhub-push' missing in ns $NS — see bamboo-agent-deployment/README.md"; exit 1; }

# k8s object names are RFC1123 labels (no dots), so sanitize the semver for the
# Job name; the image tag keeps the dotted semver.
JOB="kaniko-build-$(echo "$VERSION" | tr '.' '-')"
# Idempotent: clear a prior Job of the same version before re-applying.
kubectl -n "$NS" delete job "$JOB" --ignore-not-found

MANIFEST="$(mktemp)"
trap 'rm -f "$MANIFEST"' EXIT
sed -e "s|__JOBNAME__|${JOB}|g" -e "s|__TAG__|${VERSION}|g" -e "s|__CONTEXT__|${CONTEXT}|g" "$TMPL" > "$MANIFEST"
kubectl -n "$NS" apply -f "$MANIFEST"

echo "Waiting for $JOB (timeout 600s)..."
deadline=$(( SECONDS + 600 ))
status=""
while [ "$SECONDS" -lt "$deadline" ]; do
  if [ "$(kubectl -n "$NS" get job "$JOB" -o jsonpath='{.status.succeeded}' 2>/dev/null)" = "1" ]; then
    status="succeeded"; break
  fi
  if [ "$(kubectl -n "$NS" get job "$JOB" -o jsonpath='{.status.failed}' 2>/dev/null)" = "1" ]; then
    status="failed"; break
  fi
  sleep 5
done

kubectl -n "$NS" logs "job/$JOB" --tail=40 || true

case "$status" in
  succeeded)
    echo "IMAGE_TAG=${VERSION}"
    echo "Pushed docker.io/rojcarranza/bamboo-agent:${VERSION}"
    ;;
  failed)  echo "kaniko build failed"; exit 1 ;;
  *)       echo "kaniko build timed out"; exit 1 ;;
esac
