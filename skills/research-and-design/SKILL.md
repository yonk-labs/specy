---
name: research-and-design
description: Curated, self-contained prior-art and feasibility method bundled with specy. Invoked by the /spec phase engine (phase 5 Compete, alongside market-intel) to survey how the problem is solved today and judge novelty. Not a general-purpose replacement for a full research-and-design skill.
---

# research-and-design (curated for specy)

Understand the problem space before committing to build it. Complements
`market-intel` (which is about *competitors*); this is about *prior art and
feasibility*.

## Method
1. **How it's solved today** — `WebSearch` for the existing OSS projects, commercial tools, and manual workarounds people use right now.
2. **Minimum viable features** — what does the space *expect* any entrant to have? (The table stakes.)
3. **Barriers** — name the hard parts: technical, distribution, data, integration. What stops this from being trivial?
4. **Novelty judgment** — is the idea new enough to be worth building, or is it a thinner copy of something that exists? State the verdict plainly.

Cite every external claim with its URL.

## Output
Write `evidence/research.md`:
- **Prior art:** how the problem is solved today.
- **Table stakes:** the minimum viable feature set.
- **Barriers:** the hard parts.
- **Novelty verdict:** worth building / not, with the reason.

## Done when
Prior art is mapped AND a novelty judgment is recorded.

---
*Slim, bundled method. The fuller version lives in [yonk-labs/yonk-ai-skills](https://github.com/yonk-labs/yonk-ai-skills) — specy prefers it automatically (amplify-first) when installed.*
