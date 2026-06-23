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
  stack: confirmed
  architecture: confirmed
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

| ID | Feature | Critical? | Serves (SC/Job) | Acceptance check | Status |
|----|---------|-----------|-----------------|------------------|--------|
| F1 | Interval reminders | ✅ | SC-1 | reminder fires within ±30s of interval | — |
| F2 | Custom interval | ✅ | SC-1, Job | `sip start --every 45m` schedules at 45m | — |
| F3 | Snooze / dismiss | ✅ | SC-3 | keystroke snoozes 10m or dismisses | — |
| F4 | Unattended run | ✅ | SC-4 | runs 8h with no restart | — |
| F5 | Quiet hours | ⬜ later | — | no reminders 22:00–08:00 | — |
| F6 | Intake tracking/stats | ⬜ won't | — | (out of scope — not a tracker) | — |

## Scope
<!-- phase: features -->
- **In (critical):** F1 interval reminders, F2 custom interval, F3 snooze/dismiss, F4 unattended run.
- **Later (could):** F5 quiet hours.
- **Won't:** F6 intake tracking — this is a nudge, not a logger.

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
