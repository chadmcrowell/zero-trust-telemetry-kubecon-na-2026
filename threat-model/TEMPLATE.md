# Zero-Trust Telemetry: Threat Model Template

**System / owner / review date:** [fill in]
**Scope:** [applications, instrumentation, collectors, exporters, federation, query services, storage, AIOps]
**Assumptions:** [cluster/CNI, trust roots, threat actor access, data classification]

## 1. Data-flow inventory
| Source | Destination | Protocol/port | Identity/authentication | Sensitive data | Trust boundary |
|---|---|---|---|---|---|
| Application | OTel gateway | OTLP/gRPC 4317 | Client cert + trusted CA | [classify] | Workload -> telemetry |
| OTel gateway | Backend | OTLP/gRPC 4317 | Mutual TLS | [classify] | Telemetry -> storage |
| Exporter | Prometheus | HTTP(S) | [fill in] | Labels/metrics | Scrape target -> server |
| Prometheus | Federation | /federate | [fill in] | Selected series | Upstream -> federation |
| Query API | AIOps agent | [fill in] | RBAC/service identity | Logs, traces | Backend -> automation |

## 2. Assets and attacker objectives
- Assets: telemetry integrity, credentials, service identity, evidence retention, query permissions, backend availability.
- Objectives: suppress incident evidence, impersonate metrics, pivot into internal endpoints, extract sensitive logs, influence automated remediation.

## 3. Threat scenarios
| ID | Entry / prerequisite | Manipulation | Observable consequence | Prevent | Detect | Residual risk |
|---|---|---|---|---|---|---|
| T1 | Attacker controls telemetry before tail sampling | Alter trace attributes/status or flood traces | Important traces under-retained | Authenticated ingestion, trusted instrumentation, policy design | Retention-rate drift, sampling-policy audits | Trusted but compromised emitters |
| T2 | Compromised scrape target or exporter configuration | Impersonated labels, parameterized destination pivot | Misleading metrics / unexpected outbound access | Target allowlists, egress policies, scrape authentication | Hubble flow drops, config-change alerts | Misconfigured federation |
| T3 | Access to logs or query endpoint | Credential-bearing log queries | Secret disclosure to unauthorized actor/agent | Redaction, least-privilege RBAC, query controls | Query audits, unusual query patterns | Previously stored secrets |
| T4 | Compromised workload or Kubernetes API credentials | Change Collector ConfigMap / exporter destinations | Redirected or tampered telemetry | RBAC, admission controls, GitOps | Falco runtime/K8s audit rules | Privileged insiders |
| T5 | Compromised telemetry storage | Alter or delete historical evidence | Misleading forensics/AIOps | Immutable retention and integrity checks where supported | Independent audit and hash verification | Trusted key compromise |

## 4. Abuse-case walkthrough (one per scenario)
- Initial access and required permissions: [fill in]
- Boundary crossed: [fill in]
- Evidence expected before and after: [fill in]
- What an AIOps agent could wrongly conclude: [fill in]
- Containment and recovery steps: [fill in]
- Validation test (non-production): [fill in]

## 5. Control verification checklist
- [ ] Receiver authenticates client certificates; exporter verifies backend identity.
- [ ] CA distribution, renewal, key rotation and certificate reload tested.
- [ ] Default-deny ingress AND egress enforced by cluster CNI.
- [ ] Only approved source -> Collector -> backend paths permitted.
- [ ] Hubble captures both a legitimate FORWARDED flow and a controlled DROPPED flow.
- [ ] Prometheus federation label provenance and exporter target restrictions reviewed.
- [ ] Sensitive log fields redacted before export and query RBAC validated.
- [ ] Falco runtime and audit rules installed, enabled and tuned explicitly.
- [ ] AIOps tools require authorization for mutating actions; no auto-deploy on untrusted telemetry alone.
- [ ] Incident evidence retained independently of the telemetry pipeline.

## 6. Risk acceptance
| Threat | Likelihood | Impact | Owner | Action | Deadline | Evidence link |
|---|---|---|---|---|---|---|
| [fill in] | [L/M/H] | [L/M/H] | [fill in] | [mitigate/accept] | [date] | [link] |

## 7. Blueprint-to-threat mapping

| Threat | Relevant blueprint control | Required validation beyond the blueprint |
|---|---|---|
| T1 Tail-sampling manipulation | Authenticated Collector ingestion (example mTLS) | Verify telemetry provenance, sampling policy and retained-trace behavior under controlled altered input |
| T2 Federation/exporter pivot | NetworkPolicy egress isolation pattern; Hubble flow observations | Review Prometheus scrape/federation configuration, `honor_labels`, exporter target restrictions and authentication |
| T3 Credential-stuffed logs | Threat-model access boundary inventory | Validate redaction before storage and backend query RBAC; not deployed here |
| T4 Collector configuration tampering | Workload hardening and restricted connectivity pattern | Test Kubernetes RBAC/admission policy and configured Falco audit detections; not deployed here |
| T5 Storage tampering | Independent evidence/retention requirement | Validate immutable retention, signing/hashing and independent audit access; not deployed here |

**Blueprint maturity:** map each proposed control to an actual owner, implementation status (`planned`, `configured`, `tested`, `monitored`) and evidence link. Do not label a control verified until the relevant validation has been performed.
