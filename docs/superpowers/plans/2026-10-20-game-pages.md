# Game Pages Template (Revision 3) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give all 9 games a case-study page with one template (company + name, platform · style, functions, media, Overview, My role, Design challenges, Results), in EN and PT, with clearly marked provisional text where content does not exist yet.

**Architecture:** Static HTML/CSS (shared `assets/site.css`). Four existing Tapps pages are restructured; five Playmove pages are new, EN and PT. `tools/check-site.ps1` learns the template (required section ids, provisional-text counting, `-Publish` gate).

**Tech Stack:** HTML, CSS, PowerShell 5.1 checker, browser pane with a temporary local PowerShell HttpListener server (file:// does not load CSS in the pane).

**Spec:** `docs/superpowers/specs/2026-10-20-portfolio-reorganization-design.md` section 5 (Revision 3).

## Global Constraints

- Branch `modificaçoes` only. Never touch `main`. Never `git push` without Karolina's explicit go-ahead.
- No new fonts or colors (existing CSS variables only). Light/dark themes keep working; no JavaScript required.
- No invented content: facts come only from existing site text. Everything else is a provisional block (instructions, never facts, numbers or results).
- Text moved verbatim; PT reuses the existing PT text of the same blocks (see PT strings).
- Every page keeps `<html lang>`, inline theme script, unique title/description, canonical + absolute hreflang (`en`, `pt-BR`, `x-default`→EN), the 4-item menu per the existing contract, the contact block, `aria-label` conventions. Game page URLs: `games/<slug>.html` and `pt/games/<slug>.html`.
- One h1 per page; h2 for the four template sections; no skipped heading levels.
- Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Contracts

**Page markup (template):**
```html
<header class="detail-hero band"><div class="inner-narrow">
  <span class="eyebrow">COMPANY</span>
  <h1>GAME</h1>
  <div class="detail-meta">PLATFORM · STYLE</div>
  <p class="sub">…existing one-liner (Tapps pages only)…</p>
  <div class="detail-tags"><span class="tag">…</span>…</div>
</div></header>
<div class="cover-banner">…existing cover markup…</div>   <!-- Pet Shop Fever: followed by its "In action" section -->
<section class="detail-section band" id="overview"><div class="inner-narrow"><h2>Overview</h2>…</div></section>
<section class="detail-section band" id="role"><div class="inner-narrow"><h2>My role</h2>…</div></section>
<section class="detail-section band" id="challenges"><div class="inner-narrow"><h2>Design challenges</h2><div class="placeholder" data-placeholder>…</div></div></section>
<section class="detail-section band" id="results"><div class="inner-narrow"><h2>Results</h2><div class="placeholder" data-placeholder>…</div></div></section>
```
**Provisional block:** `<div class="placeholder" data-placeholder><span class="ph-badge">Provisional text</span><p>…instruction…</p></div>` (PT badge "Texto provisório"): dashed border (`--line`/`--ink-faint`), transparent or `--surface-2` background, italic text in `--ink-soft`, badge in mono uppercase; contrast ≥ 4.5:1 in both themes.

**Media:** `.game-media` rules: images whose natural width is under 800px (all covers/thumbnails are 440px) render at natural size (`max-width: 100%; width: auto`, not stretched to the column), framed like the current cover banner (radius, border, soft shadow, `--surface-2` background); Pet Shop Fever's 1400px `shot-title.jpg` keeps the full banner.

**Provisional strings:**

| Slot | EN | PT |
|---|---|---|
| Design challenges | Describe here the main design challenge on this game and how you approached it. | Descreva aqui o principal desafio de design deste jogo e como você o abordou. |
| Results | Describe here what this work achieved: metrics, retention, revenue or player feedback you can share. | Descreva aqui o que esse trabalho alcançou: métricas, retenção, receita ou feedback dos jogadores que você possa compartilhar. |
| My role (Playmove) | Describe here your role on this game and what you were responsible for. | Descreva aqui o seu papel neste jogo e o que ficou sob sua responsabilidade. |
| Overview extra (Playmove) | Add here a short overview of the game: concept, audience and how it plays. | Adicione aqui uma visão geral curta do jogo: conceito, público e como se joga. |
| Headings | Overview, My role, Design challenges, Results | Visão geral, Meu papel, Desafios de design, Resultados |

**Tapps pages (restructure; existing content moves, nothing is rewritten):** Overview = first paragraph of the old Overview; My role = its second paragraph; `.sub` and `.detail-tags` unchanged. New `.detail-meta` = `Mobile · <genre>`: Pet Shop Fever "Mobile · Time management"; Evolution Galaxy "Mobile · Merge / idle / collection"; Vlogger Go Viral "Mobile · Idle / simulation"; My Boo "Mobile · Virtual pet / simulation" (PT: same wording as the existing PT genre text). The old "focus" part of the meta line (e.g. "Narrative, features, systems") is dropped (the chips cover it). **Pet Shop Fever extra:** Narrative, Features I designed and Economy & progression become h3 subsections inside My role (feature grids unchanged, same look); "In action" (clips + gallery) becomes an h2 section directly after the cover banner.

**Playmove pages (new):** eyebrow `Playmove · 2015-2019`; media = the 440px thumbnail; Overview = the existing sentence plus the "Overview extra" provisional block; My role, Design challenges, Results = provisional blocks; no `.sub`.

| Slug | Game | Meta | Overview sentence (existing) | Tags | Image |
|---|---|---|---|---|---|
| `liga-do-tempo` | Liga do Tempo | PC & Mobile · Card game | History timeline card game. | GDD, Mechanics, Playtesting | `assets/thumbs/liga-do-tempo.jpg` |
| `color-shooter` | Color Shooter | PC & Mobile · Co-op motor-skills game | Co-op motor-skills game, 30 levels. | Game design, Creative direction | `assets/thumbs/color-shooter.jpg` |
| `lab-boom` | Lab Boom | PC & Mobile · Checkers-style game | Four-player checkers-style game with four modes. | Game design | `assets/thumbs/lab-boom.jpg` |
| `divertron` | Divertron | PC & Mobile · Board games | Touch adaptation of classic board games. | Game design | `assets/thumbs/divertron.jpg` |
| `guardioes-do-mundo` | Guardiões do Mundo | PC & Mobile · Challenge mode | Challenge-mode level design, 20 levels. | Level design | `assets/thumbs/guardioes-do-mundo.jpg` |

PT meta/tags/sentences: reuse the PT wording already on `pt/index.html` cards (sentences, tags "Mecânicas", "Direção criativa", …) and "PC e Mobile"; style words in PT keep the same style as EN where the PT home has no translation (the implementer reports each choice for Karolina's review).

**Next-project chain** (every game page, EN and PT, with the "Next project"/"Próximo projeto" nav): pet-shop-fever → evolution-galaxy → vlogger-go-viral → my-boo → liga-do-tempo → color-shooter → lab-boom → divertron → guardioes-do-mundo → pet-shop-fever.

**Home cards:** the 5 Playmove `div.card.card-static` become `<a class="card" href="games/<slug>.html">` (EN) / same in `pt/index.html`, same markup as the Tapps cards; delete the dead `.card-static` CSS.

## Review Focus

1. **Provisional text cannot ship silently:** the checker prints a count and fails with `-Publish`; the badge is visible and readable in both themes. (Task 1 test.)
2. **Playmove pages invent nothing:** every non-provisional string is traceable to existing site text; thumbnails are not stretched; layout holds when the image is narrower than the text column. (Task 2.)
3. **Next-project chain is complete and cyclic in EN and PT** with no dead links. (Checker + Task 4 sweep.)
4. **Pet Shop Fever keeps all its content and look** after the h2→h3 demotion (feature grids, clips, gallery). (Task 1.)
5. **Home Playmove cards behave like the Tapps cards** (link, hover border, keyboard focus), no leftover `.card-static`. (Task 2.)

---

### Task 1: Checker, shared CSS and the four Tapps pages (EN)

**Files:**
- Modify: `tools/check-site.ps1`, `assets/site.css`, `games/pet-shop-fever.html`, `games/evolution-galaxy.html`, `games/vlogger-go-viral.html`, `games/my-boo.html`

**Interfaces:**
- Produces: checker rules (below) used by every later task; `.placeholder`, `.ph-badge`, `.game-media` CSS; the template markup on the 4 EN Tapps pages.

- [ ] **Step 1: Failing checks first.** Extend the checker: for every page under `games/` and `pt/games/`, require `id="overview"`, `id="role"`, `id="challenges"`, `id="results"` in that order, exactly one `<h1>`, and count `data-placeholder` occurrences; print `NOTE: <page>: <n> provisional text block(s)` per page and a total; add a `-Publish` switch that turns every remaining provisional block into a `FAIL: <page>: provisional text` line. Run it: expected FAIL listing the four missing ids on each existing game page (EN and PT).
- [ ] **Step 2: Shared CSS** (`.placeholder`, `.ph-badge`, `.game-media`) per Contracts; reuse existing variables; light/dark parity.
- [ ] **Step 3: Restructure the four EN Tapps pages** per Contracts (Pet Shop Fever: In action section after the cover; Narrative/Features/Economy become h3 inside My role). Preserve all existing text, links and media. The My Boo next link stays `pet-shop-fever.html` until Task 2.
- [ ] **Step 4: Verify.** Checker: EN Tapps pages pass the structure rules; remaining failures only for the not-yet-restructured PT game pages. Browser: each page at 320/768/1280px, light and dark: no horizontal scroll, heading outline h1 → h2 (→ h3 on Pet Shop Fever), provisional blocks readable (contrast ≥ 4.5:1), cover images not stretched past natural width when under 800px, Pet Shop Fever clips and gallery still load and look the same; text diff: every removed sentence is present on the page.
- [ ] **Step 5: Commit.** "Add game page template to Tapps case studies".

### Task 2: Playmove pages (EN) and home links

**Files:**
- Create: `games/liga-do-tempo.html`, `games/color-shooter.html`, `games/lab-boom.html`, `games/divertron.html`, `games/guardioes-do-mundo.html`
- Modify: `index.html` (5 cards), `games/my-boo.html` (next link), `assets/site.css` (remove `.card-static`)

**Interfaces:**
- Consumes: template, placeholder and media CSS from Task 1; the Playmove table in Contracts.

- [ ] **Step 1: Failing check.** Change the 5 home cards to links first; run the checker: expected `link not found` for the five pages.
- [ ] **Step 2: Create the five pages** from a Tapps page as the structural source (menu, head, footer, canonical/hreflang `…/games/<slug>.html` and `…/pt/games/<slug>.html`, unique title "<Game> Case Study", description = the Overview sentence), content per the Playmove table and provisional strings.
- [ ] **Step 3: Next-project chain** across all 9 EN game pages per Contracts (My Boo → Liga do Tempo, … Guardiões do Mundo → Pet Shop Fever).
- [ ] **Step 4: Home cards + dead CSS:** the 5 Playmove cards become `<a class="card" href="games/<slug>.html">` with the same markup as Tapps cards; delete `.card-static` rules.
- [ ] **Step 5: Verify.** Checker: only PT-pair failures (pt pages not built yet). Browser: the 5 new pages and the home at 320/768/1280px, light and dark: layout holds with the 440px thumbnail, no overflow, provisional blocks visible, cards open the right page, keyboard Tab reaches all 9 cards, hover/focus border as on the Tapps cards, chain links resolve; every non-provisional string traceable to existing text (list the sources in the report).
- [ ] **Step 6: Commit.** "Add Playmove case study pages".

### Task 3: Portuguese pages

**Files:**
- Modify: `pt/games/pet-shop-fever.html`, `pt/games/evolution-galaxy.html`, `pt/games/vlogger-go-viral.html`, `pt/games/my-boo.html`, `pt/index.html`
- Create: `pt/games/liga-do-tempo.html`, `pt/games/color-shooter.html`, `pt/games/lab-boom.html`, `pt/games/divertron.html`, `pt/games/guardioes-do-mundo.html`

**Interfaces:**
- Consumes: finished EN pages as the source; PT strings and rows in Contracts; PT menu/contact contracts already in use.

- [ ] **Step 1:** restructure the 4 PT Tapps pages exactly like their EN versions (same ids/classes/structure); reuse the existing PT text for the moved blocks verbatim.
- [ ] **Step 2:** create the 5 PT Playmove pages from the EN ones (paths `../../assets/…`, PT menu per contract, canonical `…/pt/games/<slug>.html`, hreflang `pt-BR` self, `en`/`x-default` → `…/games/<slug>.html`, "Próximo projeto" chain, PT strings).
- [ ] **Step 3:** `pt/index.html`: 5 Playmove cards become links `games/<slug>.html`.
- [ ] **Step 4: Verify.** Checker `OK` (exit 0) with only `NOTE` lines for provisional blocks; EN↔PT structure parity for all 9 pairs (tag/class/id sequence); browser at 320 and 1280px for the 9 PT pages: no overflow, long strings wrap, images load; language switch from each page lands on its pair; no English left in `pt/` except allowed terms.
- [ ] **Step 5: Commit.** "Add Portuguese game pages".

### Task 4: Polish and final sweep

- [ ] **Step 1:** SEO metadata for the 5 new page pairs (unique title/description/canonical/hreflang) — checker `OK`.
- [ ] **Step 2:** accessibility: heading outline per page, focus rings, provisional badge contrast in both themes, reduced motion; chip/tag/eyebrow contrast on the new pages.
- [ ] **Step 3:** final sweep over all 21 pages × {320, 768, 1280}px × {light, dark} and a table of results; run `powershell -ExecutionPolicy Bypass -File tools/check-site.ps1 -Publish` and confirm it FAILS only because of provisional blocks and report the total count.
- [ ] **Step 4: Commit.** "Final polish for game pages".
