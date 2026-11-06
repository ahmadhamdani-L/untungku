# Financial rules

Existing rules: audit; target acceptance: specification §§8–10 and 14.

- Integer Rupiah and basis points; keep original sale snapshots unchanged.
- Payment collection affects cash/receivable, not revenue or stock. Account metadata missing historically stays explicitly unallocated, with no claimed known account balance.
- Supplier inventory acquisitions are assets, not operating expenses; supplier payment reduces cash/payable separately.
- Owner contributions/withdrawals and transfers are not operating income/expense. Transfer legs must balance.
- New inventory receipts use deterministic integer weighted-average cost. Preserve historical sales costs; negative-stock policy needs explicit treatment and tests.
- Returns allocate original sale discount/fee proportionally using cumulative integer allocation so partial returns sum exactly to full reversal. Restock only resellable units. Refund paid amount or record explicit liability; never refund twice.
- Every posting must be atomic and use a stable unique operation reference. Conflicting reuse must fail, not silently overwrite.

Implementation and reconciliation evidence pending in TASKS.md.
