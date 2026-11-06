# Database migration

Baseline and risks: [ARCHITECTURE_AUDIT.md](ARCHITECTURE_AUDIT.md). Requirements: specification §14.

Planned schema 2 adds typed entity tables and operation/cash ledgers. Existing six tables and financial JSON payloads are retained byte-for-byte during upgrade. Fresh databases and upgrades must produce equivalent schemas. No SQL table recreation or mass customer-name linking. Explicit FK-backed relationship records link old sales only when the user selects a customer. Baseline v1 snapshot stays frozen.

Verification pending: representative schema-1 fixture reopening, rollback, all legacy fixtures, backup v1/v2 and new format round trips. Do not mark migration complete before tests execute.
