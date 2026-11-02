#!/usr/bin/env bash
set -euo pipefail
# Preflight inspection, not a comprehensive security audit.
NAMESPACE="${NAMESPACE:-telemetry-secure}"
command -v kubectl >/dev/null || exit 2
kubectl -n "$NAMESPACE" get networkpolicies
kubectl -n "$NAMESPACE" get certificate otel-gateway 2>/dev/null || echo 'Certificate not yet provisioned'
kubectl -n "$NAMESPACE" get deploy otel-gateway 2>/dev/null || echo 'Collector not yet deployed'
echo 'Review: CNI enforcement, both directions, DNS, namespace labels, TLS reload, and real allow/deny tests.'
