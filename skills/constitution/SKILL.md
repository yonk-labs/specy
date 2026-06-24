---
name: constitution
description: Curated, self-contained non-negotiables method bundled with specy. Invoked by the /spec phase engine (phase 6 Vision) to formalize principles and constraints. Not a general-purpose replacement for a full constitution skill.
---

# constitution (curated for specy)

Capture what the project stands for and refuses to compromise on.

## Method
1. **Principles** — the governing ideas. What does this project value above convenience? (e.g. "privacy over analytics", "boring tech over clever tech".)
2. **Non-negotiables in three tiers** — classify every constraint:
   - **ALWAYS** — expected, no approval needed (e.g. "always validate input at trust boundaries").
   - **ASK FIRST** — requires explicit approval before doing (e.g. "adding a runtime dependency").
   - **NEVER** — absolute, no exception (e.g. "never phone home with user data").
3. **Review gates** (optional) — any check a change must pass before it ships.

Push for at least one real NEVER — a project with no hard limits hasn't decided what it is.

## Output
Write `evidence/constitution.md`:
- **Principles:** bulleted.
- **ALWAYS / ASK FIRST / NEVER:** three lists.
- **Review gates:** if any.

## Done when
≥1 explicit non-negotiable (an ASK-FIRST or NEVER item) is recorded.

---
*Slim, bundled method. The fuller version lives in [yonk-labs/yonk-ai-skills](https://github.com/yonk-labs/yonk-ai-skills) — specy prefers it automatically (amplify-first) when installed.*
