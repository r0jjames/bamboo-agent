#!/usr/bin/env bash
set -euo pipefail
# Publish the BuildAgentImageSpec plan to the Bamboo server.
# Needs: a `.credentials` file here (token=<bamboo PAT>, gitignored) and the
# server reachable at http://localhost:8085 (run forge-lab's `make ui`).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
[ -f .credentials ] || { echo ".credentials missing (needs 'token=<bamboo PAT>')"; exit 1; }
mvn -q compile exec:java \
  -Dexec.mainClass=lab.agent.BuildAgentImageSpec \
  -Dexec.cleanupDaemonThreads=false
