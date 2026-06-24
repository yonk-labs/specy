# Persona Feedback — evidence (specy:persona orchestration)

Personas chosen from the spec: the target **User** (phase 3), a skeptical
**builder**, and a **first-timer**. A buyer/competitor persona was offered but
skipped — `sip` is a free OSS tool with no purchase decision.

## Target user — terminal-bound remote dev
- **Profile:** lives in tmux 8h/day, hates context switches, already ignores their phone.
- **Wins:** terminal-native, zero-config, snooze without leaving the shell.
- **Objection:** suspend/resume — "if my laptop sleeps over lunch, does it dump a backlog of reminders when it wakes?"
- **Verdict:** would use, conditional on sane wake behavior.

## Skeptical builder — senior engineer
- **Profile:** would fork it before installing it; allergic to maintenance debt.
- **Wins:** small surface, single binary, obvious code.
- **Objection:** three OS notifier adapters are the bulk of the maintenance surface for a toy — keep the interface trivial or it rots.
- **Verdict:** would build it, with the thin-adapter caveat.

## First-timer — non-technical, cold start
- **Profile:** copy-pastes the install command, no mental model of background processes.
- **Wins:** "drink water" is self-explanatory.
- **Objection:** after `sip start` there's no feedback that it's running — felt blind.
- **Verdict:** would try it, but wanted reassurance.

## Fed into synthesis
- User objection → tightened F4 acceptance (no reminder storm after suspend).
- Builder objection → notifier interface pinned to one method, documented as a hard line.
- First-timer objection → real gap (no `sip status`); logged as Later-scope F7, not Critical (the OS notification is itself the running signal).
