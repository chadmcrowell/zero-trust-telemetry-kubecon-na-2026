# Zero-Trust Telemetry: Reference Blueprints

Conference companion resources for evaluating and adapting security controls around OpenTelemetry and Kubernetes telemetry pipelines.

**Status:** Educational blueprints with example YAML and runnable inspection scripts. **Not** audited, production-certified, or end-to-end cluster-tested. They are not a turnkey deployment. Treat all labels, names, endpoints, trust roots, versions, and policy selectors as environment-specific.

## Three deliverables

1. **Kubernetes Security Blueprint** (`manifests/`): an illustrative OTel gateway, cert-manager Certificate, default-deny NetworkPolicies, and narrow OTLP ingress/egress. See [deployment assumptions](manifests/README.md).
2. **eBPF Flow Verification Blueprint** (`scripts/`): read-only Hubble-based collection and policy inspection scripts. See [verification guide](scripts/README.md).
3. **Zero-Trust Telemetry Threat Model Template** (`threat-model/TEMPLATE.md`): five threat scenarios mapped to preventive, detective, and validation controls.

See [VALIDATION.md](VALIDATION.md) for the proposed test plan and evidence checklist. **No passing integration-test results are included.**

## Before attempting deployment

- Use a **disposable or staging cluster** with a NetworkPolicy-enforcing CNI; Cilium/Hubble are required only for the Hubble scripts.
- Install cert-manager and configure a **trusted** `ClusterIssuer` named `telemetry-ca` using your own PKI. This bundle deliberately does not create a CA.
- Provision the `telemetry-trust-bundle` ConfigMap with `ca.crt` in `telemetry-secure` through a trusted distribution mechanism. The trust root must not be accepted from an untrusted telemetry sender.
- Provide an `otel-backend` workload in `telemetry-secure` with the `app: otel-backend` label and an OTLP/gRPC mTLS endpoint on 4317; its server certificate must match `otel-backend.telemetry-secure.svc.cluster.local`. **The backend is not provided here.**
- Review Collector version and config fields, resource limits, cert reload behavior, namespace labels, DNS selectors, and source namespace egress policies. Some settings may require adaptation for the Collector release you choose.
- Only after review: `kubectl apply -f manifests/00-foundation.yaml`, then `01-certificates.yaml`, then `02-networkpolicies.yaml`. **Applying default-deny can interrupt workloads.**

## What these blueprints demonstrate (and do not)

- mTLS can authenticate peers and protect transport; it does not establish that the telemetry content itself is truthful.
- cert-manager can renew/reissue certificates and rotate private keys; **zero-downtime rotation is conditional** on certificate/key reload (or safe rolling replacement), CA overlap, and successful connection tests. Two replicas alone are insufficient.
- NetworkPolicy limits selected L3/L4 flows; it is not application-layer authorization or a substitute for credential hygiene.
- Hubble provides observed datapath verdicts from eBPF-backed telemetry. It **does not verify TLS identities, cryptographic integrity, or kernel isolation in full**.
- The threat model includes Prometheus federation, logs, Falco, storage integrity, and AIOps; **those systems are not deployed** by this example.

## Adaptation checklist

- [ ] Substitute real workload/service/namespace identities and validate selectors.
- [ ] Review PKI trust, certificate SANs, secret access, rotation and reload.
- [ ] Ensure ingress **and** egress allow rules on both ends of each connection.
- [ ] Confirm DNS reachability and backend authentication.
- [ ] Generate controlled allowed and denied flows; save evidence.
- [ ] Complete threat-model owners, likelihood, impacts, and residual risks.
- [ ] Perform security review before any production use.

## Primary documentation

- https://opentelemetry.io/docs/collector/configuration/
- https://cert-manager.io/docs/usage/certificate/
- https://kubernetes.io/docs/concepts/services-networking/network-policies/
- https://docs.cilium.io/en/stable/observability/hubble/hubble-cli/
- https://prometheus.io/docs/operating/security/
- https://falco.org/docs/concepts/event-sources/plugins/kubernetes-audit/
