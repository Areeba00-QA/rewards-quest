# Release-readiness checklist

- [x] All 15 tests pass on the fixed implementation (`IMPL=fixed`)
- [x] Regression proven to fail on faulty reference (3 failures)
- [x] Boundary, timezone, duplicate, retry, partial-failure covered
- [x] Assumptions A1–A4 documented
- [ ] Concurrent runs (two workers at once) — NOT tested
- [ ] Real DB unique constraint on idempotency key — NOT built
- [ ] Crash between credit and `mark_notified` with real persistence — in-memory only
- [ ] DST/leap-second edge cases — only fixed UTC offsets tested

**Decision: GO for the fictional reference fix, CONDITIONAL for any real system.** Block release unless TC06/08/09 pass in CI and a DB-level uniqueness guarantee exists; concurrency testing is the next step.
