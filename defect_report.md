# Defect Report DR-001 — Settlement Retry Pays Twice

**Status:** Reproduced in the faulty implementation  
**Severity:** Critical for a real rewards system  
**Data:** Synthetic test data only

## Problem

If the weekly settlement runs again for the same user and settlement window, the faulty implementation creates another payout instead of recognizing that the user has already been paid.

This can give the user double rewards and can also send the same notification more than once.

> The system in this assessment is fictional, so this severity rating is a QA judgement. No real production incident is being claimed.

## Steps to Reproduce

Run the faulty implementation:

```bash
IMPL=faulty python -m pytest -q
```

On Windows PowerShell:

```powershell
$env:IMPL="faulty"
python -m pytest -q
```

The same behavior can also be reproduced by calling the settlement twice with the same tasks and run time.

## Expected Result

For user `u1`:

- The user should receive **10 credits only once**.
- The ledger should contain **one payout entry**.
- The notification should be sent **once**.

## Actual Result

The faulty implementation:

- Creates **two payout entries**.
- Gives the user **20 credits instead of 10**.
- Sends the notification **twice**.

## Root Cause

The faulty implementation calls `ledger.credit()` without first checking whether the payout for the same user and settlement window already exists.

The intended idempotency key is:

```text
user|window_start
```

The notification logic also does not check whether a notification was already sent successfully.

## Why This Could Happen

A scheduler or worker may retry the settlement after an error, such as a notification/provider failure. If the whole settlement runs again without an idempotency check, the same payout can be created again.

This is a realistic failure scenario, but **no production incident is being claimed or presented as evidence**.

## Evidence

The faulty implementation produced:

- **12 tests passing**
- **3 tests failing**

The failing tests were:

- **TC06:** Retry creates a second payout.
- **TC08:** Partial failure followed by retry creates a second payout.
- **TC09:** Retry sends a duplicate notification.

After applying the reference fix, **all 15 tests passed**.

## Proposed Fix

Before creating a payout, check whether the idempotency key already exists:

```text
ledger.has(key)
```

If the payout already exists, do not create another one.

For notifications, track whether the notification for that payout was already successfully sent. A failed notification can be retried, but a successful notification should not be sent again.

The reference implementation for this behavior is in `rewards/fixed.py`.

## Release Checks

For a real system, this defect should not be considered fully fixed until:

- TC06, TC08, and TC09 pass in CI.
- A database-level unique constraint protects the idempotency key.
- Concurrent settlement runs have been tested.
- Duplicate payout attempts can be monitored or alerted.

The database constraint and concurrency testing are **recommended next steps and were not implemented in this synthetic fixture**.