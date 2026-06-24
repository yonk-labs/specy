# Design — evidence (phase 8)

Two items needed real "how" work; the rest were obvious from their acceptance checks.

## Reminder delivery — vision-driven
User had a clear picture. Drawn out and pressure-tested:
- Mechanism: scheduler owns next-fire timestamp → tick → notifier; snooze advances +10m.
- Pressure test: serves SC-1 (timing) and SC-3 (snooze)? yes. Simplest that works? yes — the process is the scheduler, no daemon. What breaks it? laptop suspend (→ next item).

## Suspend/resume — propose mode ("decide for me")
User had no picture and delegated. specy generated options:
- **A — single catch-up on wake, then resume.** Trade-off: one nudge after a long sleep; signals missed hydration without spamming. Serves SC-4. ← recommended, chosen.
- **B — silently skip, resume next interval.** Trade-off: zero noise, but a 3-hour lunch passes with no signal.
- **C — fire all missed.** Trade-off: notification storm on wake. Rejected.

Decision: A, delegated by the user → flagged in the spec as a specy proposal to revisit.
Fed back into F4's acceptance check (no reminder storm after suspend; catch-up capped at one).
