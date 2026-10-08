# Flow Map and Test Cases

This document contains the test cases used to check the weekly rewards settlement. The data is synthetic and only used for this assessment.

**Test run:** Tuesday, October 6, 2026 at 09:00 UTC  
**Settlement window:** September 28, 2026 00:00 UTC to October 5, 2026 00:00 UTC  
The end time is not included in the window.

## Flow

The settlement process follows these steps:

1. Load completed tasks.
2. Convert task times to UTC.
3. Check whether each task is inside the settlement window.
4. Remove duplicate task IDs for the same user.
5. Check whether this user and settlement window have already been paid.
6. Add the reward credits.
7. Send the notification.
8. Mark the notification as sent.

## Assumptions

- **A1:** Timestamps without a timezone are rejected.
- **A2:** The settlement is expected to run on Tuesday. The run time can be provided in a different timezone as long as it represents the correct UTC time.
- **A3:** Each user should receive one payout for each settlement window. Account deletion, account changes, and admin overrides are outside the scope of this assessment.
- **A4:** If a notification fails, a retry can send the notification again. If the notification was already successful, it should not be sent again.

## Test Cases

| TC | Scenario | Input | Expected Result | Faulty | Fixed |
|---|---|---|---|---|---|
| 01 | Happy path | 3 completed tasks for user u1 | 30 credits and 1 notification | Pass | Pass |
| 02 | Lower boundary | One task exactly at the window start and one just before it | Only the task at the start is counted: 10 credits | Pass | Pass |
| 03 | Upper boundary | One task just before the window end and one exactly at the end | Only the task before the end is counted: 10 credits | Pass | Pass |
| 04 | Timezone conversion | Tasks provided with a `-05:00` offset | UTC conversion correctly decides which tasks are inside the window | Pass | Pass |
| 05 | Duplicate task | The same task ID appears twice | The task is counted once: 10 credits | Pass | Pass |
| 06 | Retry | The same settlement is run twice | Total reward stays at 10 credits with one ledger entry | **FAIL — 20 credits** | Pass |
| 07 | Notification failure | Notification fails after the payout | The 10-credit payout remains; the failure is reported | Pass | Pass |
| 08 | Failure followed by retry | Notification fails, then the settlement is retried | Total reward stays at 10 credits and notification is delivered once | **FAIL — 20 credits** | Pass |
| 09 | Duplicate notification | Settlement succeeds, then is run again | Only 1 notification is sent | **FAIL — 2 sent** | Pass |
| 10 | No payout at upper boundary | Only a task exactly at the window end | No payout and no notification | Pass | Pass |
| 11 | Task status | Tasks are failed or pending | No payout | Pass | Pass |
| 12 | Multiple users | Notification fails for u1 but succeeds for u2 | Both users receive their payouts; only u2 is notified | Pass | Pass |
| 13 | Invalid timestamp | Timestamp has no timezone | `ValueError` is raised | Pass | Pass |
| 14 | Invalid run day | Settlement is run on Wednesday | `ValueError` is raised | Pass | Pass |
| 15 | Different timezone for run time | Run at `2026-10-06T19:00+10:00` | Same UTC settlement window and correct payout | Pass | Pass |

## Test Results

The faulty implementation produced **12 passing and 3 failing tests**. The three failures were related to duplicate payouts and duplicate notifications during retries.

The fixed implementation passed **all 15 tests**.

These results were obtained by running the project tests locally. No production or real financial data was used.