---
name: persona
description: Curated, self-contained persona-voicing method bundled with specy. Invoked by the /spec phase engine (phase 11 Persona Review) to construct stakeholder voices and have them react to the drafted spec. Not a general-purpose replacement for a full persona skill.
---

# persona (curated for specy)

Construct a named stakeholder voice and have it react to the spec — fast, no
full voice-profile build.

## Method
1. **Pick candidates from the spec** — derive the personas who matter from what's
   already written:
   - the primary **User** (phase 3) — would they actually use this?
   - a skeptical **builder** (a senior engineer who'd implement or fork it)
   - a **buyer / decision-maker** if there's money or adoption at stake (phase 5)
   - a **first-timer** (non-expert hitting it cold)
   - a **competitor** who'd try to crush it (phase 5)
   Recommend 3-4 that fit *this* spec; don't voice all of them by reflex.
2. **One-line profile each** — who they are, what they care about, what they're
   suspicious of.
3. **Voice the reaction** — in that persona's words, reacting to the spec:
   - what wins them over
   - what they push back on (the objection — be specific, not polite)
   - what's missing for them
   - verdict: would they use / buy / build it, yes or no, and why

Keep each voice distinct — different priorities, not the same note in different
hats.

## Output
Used by phase 11; write `evidence/persona-feedback.md` — one block per persona
(profile + reaction + top objection + verdict).

## Done when
Each chosen persona has a profile and a concrete reaction with at least one real
objection.

---
*Slim, bundled method. The fuller version lives in [yonk-labs/yonk-ai-skills](https://github.com/yonk-labs/yonk-ai-skills) — specy prefers it automatically (amplify-first) when installed.*
