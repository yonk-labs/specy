# Stack — evidence

Candidate languages weighed for a single-binary, cross-platform CLI:

| Option | Single binary | Notifier path | Iteration speed | Verdict |
|--------|---------------|---------------|-----------------|---------|
| Go | ✅ static | shell out to OS notifier | fast | **chosen** |
| Rust | ✅ static | crates exist | slower build | overkill here |
| Python | ❌ needs interpreter | easy | fast | violates non-negotiable |
| Bash | ✅-ish | native | fast | fragile cross-platform |

- `abe` second opinion (simulated): agreed Go for a tool this small; flagged that
  if quiet-hours grows into a full scheduler, revisit. Logged as a future risk,
  not a v1 blocker.
- Notifier reach: OS notifier preferred over TUI popup because it surfaces even
  when the terminal isn't focused; terminal bell is the fallback.

UNVERIFIED: notifier command availability per-distro not exhaustively tested —
confirm `notify-send` presence at runtime and fall back to the bell.
