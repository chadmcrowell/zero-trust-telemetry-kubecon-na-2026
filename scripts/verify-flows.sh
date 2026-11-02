#!/usr/bin/env bash
set -euo pipefail
# Read-only verifier: uses Hubble's eBPF-backed flow telemetry; does not inspect kernel programs directly.
command -v hubble >/dev/null || { echo 'Install hubble CLI and configure Hubble Relay access' >&2; exit 2; }
command -v kubectl >/dev/null || { echo 'kubectl required' >&2; exit 2; }
NAMESPACE="${NAMESPACE:-telemetry-secure}"
DEST="${DEST:-${NAMESPACE}/otel-gateway}"
OUT="${OUT:-./evidence}"
mkdir -p "$OUT"
kubectl -n "$NAMESPACE" get networkpolicy -o yaml > "$OUT/networkpolicies.yaml"
kubectl -n "$NAMESPACE" get pods -o wide > "$OUT/pods.txt"
hubble status > "$OUT/hubble-status.txt"
echo "Collecting recent Hubble flows to $DEST"
hubble observe --to-pod "$DEST" --last 200 -o json > "$OUT/flows.json"
hubble observe --to-pod "$DEST" --verdict DROPPED --last 200 > "$OUT/dropped.txt"
hubble observe --to-pod "$DEST" --verdict FORWARDED --last 200 > "$OUT/forwarded.txt"
echo "Saved $OUT. Inspect source/destination, verdict and policy context; empty DROPPED output is not proof of enforcement."
