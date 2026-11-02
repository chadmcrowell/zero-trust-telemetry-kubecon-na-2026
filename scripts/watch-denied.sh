#!/usr/bin/env bash
set -euo pipefail
command -v hubble >/dev/null || { echo 'hubble CLI required' >&2; exit 2; }
DEST="${DEST:-telemetry-secure/otel-gateway}"
echo "Watching denied connections to $DEST; Ctrl-C to stop"
hubble observe --to-pod "$DEST" --verdict DROPPED --follow
