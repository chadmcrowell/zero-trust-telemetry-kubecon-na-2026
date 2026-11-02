# Validation Plan (not a test report)

**Status: NOT RUN against a live cluster.** Use this as a reproducible staging checklist; attach real evidence before claiming that a control works.

| Control | Suggested staging test | Expected observation | Evidence to retain |
|---|---|---|---|
| Manifest preflight | Validate YAML schema and Collector config with the **chosen** Collector release | No validation errors | tool versions and command output |
| PKI issuance | Inspect `Certificate`, Secret and issuer status | Issued certificate with expected SANs and key usages | sanitized `kubectl describe certificate`, certificate metadata (never private key) |
| Receiver mTLS | Connect with valid trusted client certificate; then untrusted/no client certificate | Trusted connection accepted; untrusted handshake rejected | sanitized client/server logs |
| Exporter mTLS | Verify backend server SAN/CA and required client certificate | Valid identity succeeds; invalid CA/name fails | sanitized handshake results |
| Key rotation | Trigger controlled reissuance in staging and compare public-key fingerprints | New key after reissuance under `rotationPolicy: Always` | timestamps, public-key fingerprints (not secrets) |
| Availability during rotation | Generate continuous OTLP traffic while reissuing; check Collector reload or rolling restart | No unplanned ingestion gap **if** reload, trust overlap and availability are correctly configured | time-series of accepted/exported items and error counts |
| Network isolation | Generate one allowed and one denied OTLP connection | Intended forwarded and dropped datapath events | Hubble flows, policy snapshot, pod labels |
| DNS/backend egress | Verify gateway can resolve backend and reach only approved destinations | Required flow succeeds; unauthorized egress blocked | Hubble flows and application logs |
| Runtime detection (optional) | Install and tune explicit Falco rules and audit plugin in separate lab | Expected controlled test events raise alerts | rule version and sanitized alert output |
| Threat model | Walk through T1–T5 with owners and residual risks | Reviewed decisions and follow-up actions | signed-off worksheet |

## Evidence record template

- Cluster type / CNI / versions:
- Kubernetes namespace and test workload labels:
- Collector version and exact config revision:
- cert-manager version and issuer configuration reference:
- Hubble/Cilium versions:
- Test date/time and operator:
- Test performed / expected result / actual result:
- Evidence location:
- Outcome: PASS / FAIL / NOT RUN
- Limitations and remediation owner:

## Safety and accuracy

- Run disruptive tests only in an isolated test environment.
- Do not publish certificates' private keys, bearer tokens, log credentials, or sensitive telemetry as evidence.
- Network-level `FORWARDED`/`DROPPED` observations are not substitutes for TLS authentication tests.
- A rotation claim of **zero downtime** needs measured continuity during the rotation window; do not infer it from cert-manager issuance alone.
