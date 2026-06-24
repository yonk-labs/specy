---
slug: example-idea
input: "a tiny CLI that reminds you to drink water"
intensity: standard
updated: 2026-06-23
phases:
  frame: confirmed
  why: confirmed
  users: confirmed
  success: confirmed
  compete: confirmed
  vision: confirmed
  features: confirmed
  design: confirmed
  stack: confirmed
  architecture: confirmed
  personas: confirmed
  synthesize: confirmed
---

# SPEC — sip

> The authoritative spec. A coding agent should be able to build from this file
> alone; `evidence/` holds the supporting research and consults.

## Overview / Current State
<!-- phase: frame -->
`sip` is a single-binary CLI that sits in the background and nudges you to drink
water on an interval you set. Idea mode — no prior code.

## Problem & Why
<!-- phase: why -->
Desk workers forget to drink water for hours; existing reminders are heavyweight
phone apps that pull you out of the terminal. **Why this:** the terminal is
where the target user already lives all day. **Why now:** the author keeps
ending the day dehydrated and no terminal-native tool exists. **Why it must
exist:** without it, the nudge happens on a device you're trying to ignore.

## Users & Use Cases
<!-- phase: users -->
A remote software developer who lives in a terminal 8+ hours a day. Today they
either use a phone app (ignored, on the wrong device) or nothing. They want a
nudge in the context they're already in, that costs them no attention to set up.

## Success Criteria
<!-- phase: success -->
- **SC-1:** A reminder fires within ±30s of each scheduled interval.
- **SC-2:** First-run setup to first reminder takes under 60 seconds.
- **SC-3:** A reminder can be snoozed or dismissed without leaving the terminal.
- **SC-4:** Runs unattended for an 8-hour session without manual restart.

## Competitive Landscape
<!-- phase: compete -->
- **Phone hydration apps** (WaterMinder, Plant Nanny): rich tracking, but on the wrong device for this user and attention-heavy.
- **`cron` + `notify-send`**: free and native, but no snooze, no interval UX, manual to wire up.
- **Pomodoro CLIs**: adjacent (timed nudges) but framed around focus, not hydration, and rarely support recurring all-day intervals with snooze.

## Differentiation
<!-- phase: compete -->
Terminal-native, zero-config, snooze-aware. The wedge is *context*: it nudges
where the user already is. Survived the counter-argument "isn't this just cron?"
— cron has no snooze, no first-run UX, and no graceful quiet-hours; those are the
load-bearing differences, not polish.

## Product Vision & Principles
<!-- phase: vision -->
A tool so small you forget it's running until it taps you on the shoulder.
**Non-negotiables:**
- ALWAYS single binary, no daemon to manage by hand.
- ALWAYS dismissable in one keystroke.
- NEVER phone home or track personal data.

## Features & Requirements
<!-- phase: features -->
Critical = at least one Success Criterion or Job fails without it.

| ID | Feature | How (sketch) | Critical? | Serves (SC/Job) | Acceptance check | Status |
|----|---------|--------------|-----------|-----------------|------------------|--------|
| F1 | Interval reminders | scheduler computes next-fire, sleeps, calls notifier | ✅ | SC-1 | reminder fires within ±30s of interval | — |
| F2 | Custom interval | `--every <dur>` sets the scheduler period | ✅ | SC-1, Job | `sip start --every 45m` schedules at 45m | — |
| F3 | Snooze / dismiss | keystroke pushes next-fire +10m, or cancels | ✅ | SC-3 | keystroke snoozes 10m or dismisses | — |
| F4 | Unattended run | long-lived process; suspend → one catch-up max `→ Design` | ✅ | SC-4 | runs 8h with no restart | — |
| F5 | Quiet hours | suppress fires inside a time window | ⬜ later | — | no reminders 22:00–08:00 | — |
| F6 | Intake tracking/stats | — | ⬜ won't | — | (out of scope — not a tracker) | — |

## Scope
<!-- phase: features -->
- **In (critical):** F1 interval reminders, F2 custom interval, F3 snooze/dismiss, F4 unattended run.
- **Later (could):** F5 quiet hours.
- **Won't:** F6 intake tracking — this is a nudge, not a logger.

## Design — How It Works
<!-- phase: design -->
**Reminder delivery (your vision).** The scheduler holds the next-fire timestamp;
on each tick it calls the platform notifier (OS notification, terminal-bell
fallback). A snooze keystroke advances next-fire by 10m. *Why:* the process *is*
the scheduler — no daemon, matching the single-binary non-negotiable.
*Alternatives weighed:* cron+notify-send (no snooze/quiet-hours), TUI popup
(misses you when the terminal isn't focused). *Open questions:* none.

**Suspend/resume behaviour (specy proposed — you said "decide for me").** What
happens to reminders missed while the laptop slept? specy offered: **(A)** fire a
single catch-up on wake, then resume schedule — *recommended, serves SC-4 without
a notification storm*; (B) silently skip missed, resume next interval; (C) fire
all missed (storm — rejected). You delegated → **A**. ⚑ *specy proposal — revisit
if users find the catch-up nag annoying.* This is the rule behind F4's tightened
acceptance check.

## Tech Stack
<!-- phase: stack -->
**Recommendation:** Go, compiled to a single static binary, using the OS
notifier (`notify-send` / `osascript` / Windows toast) plus a terminal bell
fallback. Serves the "single binary, no runtime" non-negotiable and SC-2
(fast install: `go install` or a downloaded binary).

### Decision log
- **Go vs Python:** Python needs an interpreter + venv → violates single-binary non-negotiable and slows SC-2. Go ships one file.
- **Go vs Rust:** both compile static binaries; Go chosen for faster build/iteration on a tool this small. Rust reconsidered only if a daemon-grade scheduler is needed (it isn't).
- **OS notifier vs TUI popup:** OS notifier reaches the user even when the terminal isn't focused; terminal bell is the fallback when no notifier exists.

## Architecture
<!-- phase: architecture -->
Three small pieces:
- **scheduler** — holds the interval, computes next fire time, sleeps until then. State: in-memory; the process is the daemon.
- **notifier** — platform adapter: `notify-send` (Linux), `osascript` (macOS), toast (Windows), bell fallback. Interface: `Notify(title, body) error`.
- **cli** — `sip start --every <dur> [--quiet 22:00-08:00]`, `sip stop`. Parses flags, owns the snooze keybinding loop.

Data flow: `cli` → configures `scheduler` → on tick calls `notifier`; snooze
keystroke pushes the next fire time forward 10m.

## Persona Feedback
<!-- phase: personas -->
Three voices reacted to the spec above (full reactions in
`evidence/persona-feedback.md`).

- **The target user — terminal-bound remote dev.** Wins: nudges where they already
  are, zero-config. **Objection:** "What happens when my laptop sleeps for lunch —
  does it fire 6 reminders at once when it wakes?" **Verdict:** would use, if wake
  behavior is sane. → *Resolved:* added to F4's acceptance check (no reminder storm
  after suspend; catch-up is capped at one).
- **The skeptical builder — senior engineer.** **Objection:** "Three OS notifier
  adapters is most of the maintenance surface for a toy — keep them thin or this
  rots." **Verdict:** would build it, with that caveat. → *Resolved:* notifier
  interface is one method (`Notify(title, body) error`); documented as a hard line.
- **The first-timer — non-technical, hitting it cold.** **Objection:** "After I
  run `sip start`, how do I know it's actually running?" **Verdict:** would try it,
  but felt blind. → *Deferred:* surfaced a real gap — there's no `sip status`
  command. Logged as a Later-scope feature (F7); not promoted to Critical because
  the OS notification itself is the running signal.
