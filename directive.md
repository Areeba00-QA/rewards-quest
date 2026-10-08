# directive.md — Final

## Objective

The goal of this project is to find and prevent duplicate payouts when a fictional weekly rewards settlement is run again.

I created a small test fixture that can reproduce the problem on the faulty implementation and verify that the corrected implementation no longer has the problem.

## What I tested

The project covers:

- The weekly rewards window and its time boundaries
- UTC time conversion
- Completed tasks
- Duplicate task IDs
- Payouts being created only once per user and settlement window
- Retry behaviour
- Notification behaviour
- Notification failure and retry
- Faulty and fixed implementations
- Automated regression tests
- Defect reporting
- Release readiness

The project does not cover real money, a live system, a real database, concurrent workers, or a user interface.

## Requirements

The system should follow these rules:

1. The reward window starts on Monday at 00:00 UTC and ends on the following Monday at 00:00 UTC. The end time is not included.
2. Each unique completed task earns 10 test credits.
3. A user should receive only one payout for the same settlement window, even if the job is retried.
4. A notification is sent only after a payout has been created.
5. If notification delivery fails, the payout should not be removed or reversed.
6. A successful notification should not be sent again when the same settlement is retried.
7. The faulty implementation should fail the relevant regression tests.
8. The fixed implementation should pass all 15 tests.

## Completion criteria

I considered the work complete when:

- The faulty implementation reproduced the selected bug.
- The fixed implementation passed all 15 automated tests.
- The test cases and assumptions were documented.
- The defect report explained the problem, root cause and proposed fix.
- The release checklist identified remaining risks.
- The final results and handoff instructions were documented.

---

# Results and Handoff

## Project files

The project contains:

- `rewards/` — the reward settlement code
- `tests/test_settlement.py` — the automated tests
- `test_cases.md` — the flow and test cases
- `defect_report.md` — the bug report and root cause
- `release_checklist.md` — the release decision and remaining risks
- `intent.md` — why I chose this problem

**Loom video:** `<ADD YOUR LOOM LINK>`

**Project / repository:** `<ADD YOUR REVIEWER-ACCESSIBLE PROJECT LINK>`

## How to run the tests

Install the dependencies first:

```text id="f7x4ha"
pip install -r requirements.txt
```

For the faulty implementation, in Windows PowerShell:

```text id="k6q8vm"
$env:IMPL="faulty"
python -m pytest -q
```

Expected result:

```text id="e6n1qv"
3 failed, 12 passed
```

For the fixed implementation:

```text id="h3w7pz"
$env:IMPL="fixed"
python -m pytest -q
```

Expected result:

```text id="r2c5nx"
15 passed
```

The project also includes `run_demo.sh` for Bash-compatible environments.

## Actual results

I ran both implementations.

- **Faulty:** 3 failed, 12 passed
- **Fixed:** 15 passed

The three failures on the faulty version were related to retry and notification behaviour.

## How AI was used

I used AI (Claude) to help me draft the test fixture, automated tests and documentation.

I then ran the tests myself and reviewed the results.

I also reviewed the test cases, checked the faulty and fixed behaviour, selected the main problem to investigate, and considered the remaining risks before deciding whether the fixture was ready.

No production data or confidential information was used. All data in this project is synthetic.

## Limitations

This is a small fictional test fixture with an in-memory ledger and a mock notification service.

I did not test:

- Two workers running the settlement at the same time
- A real database or database-level uniqueness
- Real distributed scheduler behaviour
- A crash between creating the payout and recording notification delivery
- All daylight-saving-time edge cases

The likelihood scores in `intent.md` are my judgement and are not based on production measurements.

## Release decision

I consider the **fictional reference implementation ready** because the faulty behaviour was reproduced and the corrected implementation passes all 15 tests.

I would **not treat this as ready for a real production system yet**.

Before a real release, I would add a database-level uniqueness guarantee for the payout key, test concurrent settlement runs, test durable notification behaviour, and make the critical regression tests part of the CI release gate.

## Next steps

1. Add a database-level unique constraint for the payout idempotency key.
2. Test two settlement workers running at the same time.
3. Test crash and recovery around notification tracking.
4. Add relevant DST edge cases.
5. Make the retry regression tests blocking checks in CI.