# intent.md — Why I Chose This Problem

## The problem I chose

I chose to work on a **fictional weekly rewards settlement flow** based on the rules in the assessment brief.

The system gives users 10 test credits for each completed task. The main problem I decided to investigate is what happens when the rewards job is **run again or retried**.

The risk is that a user could receive the same payout twice.

This is a fictional project using synthetic data. I am not claiming that this is a real production incident.

## Business rules

Before writing the tests, I defined these rules:

- The settlement runs on Tuesday at 09:00 UTC.
- The reward window starts on Monday at 00:00 UTC and ends on the following Monday at 00:00 UTC.
- The start time is included, but the end time is not included.
- Only completed tasks earn rewards.
- Each unique task ID earns 10 test credits.
- Timestamps are compared in UTC.
- Running the same settlement again must not create another payout for the same user.
- A notification is sent only after the payout is successfully created.
- If notification delivery fails, the payout should not be removed or reversed.

## Problems I considered

I considered five possible problems and compared them using three simple factors:

- **Impact:** How serious would the problem be for the user or business?
- **Likelihood:** How likely do I think the problem is?
- **Effort:** How much work would be needed to fix and test it?

These scores are my own judgement. They are not based on production data or historical incidents.

| # | Possible problem | Impact | Likelihood | Effort | Score |
|---|---|---:|---:|---:|---:|
| 1 | **A retry creates a second payout** | 5 | 4 | 1 | **20** |
| 2 | The upper time boundary is included incorrectly | 4 | 3 | 1 | **12** |
| 3 | The same task ID is counted twice | 4 | 2 | 1 | **8** |
| 4 | A timezone is handled incorrectly | 3 | 4 | 2 | **6** |
| 5 | A notification failure affects the payout | 3 | 2 | 2 | **3** |

**Score = Impact × Likelihood ÷ Effort.**

## Why I chose the retry problem

I chose the retry problem because I think it has the biggest potential impact.

For example, if a user should receive 10 credits and the settlement runs twice, the user could end up with 20 credits. This creates an incorrect balance and could be difficult to correct later.

Retries are also a realistic possibility in scheduled jobs and queue-based systems. A job might run again after a temporary failure.

The problem is also connected to notification failure. For example, the payout might succeed but the notification might fail. If the job is then retried, the system must make sure it does not create another payout.

The other problems are still important, so I included them in the test suite. I chose the retry problem as the main area for deeper investigation.

## Who could be affected?

In a real rewards system, users could receive more credits than they should.

The business might then need to investigate and correct those balances. Support and finance teams could also have to deal with related issues.

The value of this work is a regression test that can catch the problem before release and help prevent it from coming back.

## What I am not testing

This project is intentionally small and fictional.

I am not testing:

- Real money or real payments
- A real database
- A real queue or scheduler
- Two workers running the settlement at the same time
- An admin interface
- Performance or load
- A real notification service

Concurrency and real database behaviour are important follow-up areas, but they are outside the scope of this fixture.

## Evidence

The evidence comes from the automated tests in the project.

When I ran the faulty implementation, **3 of the 15 tests failed**. These failures showed the duplicate payout and notification problems.

After the fix was applied, **all 15 tests passed**.

I did not use production data, user interviews, revenue numbers, or real incident history for this assessment.