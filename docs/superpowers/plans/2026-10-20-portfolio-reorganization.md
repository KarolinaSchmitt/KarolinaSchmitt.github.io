# Portfolio Reorganization and Bilingual Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the portfolio into a menu-driven home with standardized project cards, and ship a full Portuguese version in `/pt/`.

**Architecture:** Static HTML/CSS (no framework, no build). One shared `assets/site.css` and a small `assets/site.js` for menu highlight, theme toggle and nothing else. Each language has its own HTML files; the EN/PT switch is a plain link. A PowerShell checker (`tools/check-site.ps1`) plays the role of the automated test suite.

**Tech Stack:** HTML, CSS, vanilla JS, PowerShell 5.1 (checker; Node and Python are not installed), browser pane for visual checks.

**Spec:** `docs/superpowers/specs/2026-10-20-portfolio-reorganization-design.md`

## Global Constraints

- Branch `modificaçoes` only. Never touch `main`. Never `git push` without Karolina's explicit go-ahead.
- No new fonts or colors: reuse CSS variables in `assets/site.css` (`--primary`, `--accent`, `--surface`, `--line`, `--feature-bg`, …). Fonts: Bricolage Grotesque / Hanken Grotesk / IBM Plex Mono.
- Light/dark theme must keep working (system preference by default, `data-theme` attribute override).
- No new case-study content. Home card descriptions = the **first sentence** of the existing paragraph; everything else is existing text moved or translated.
- The site must be navigable with JavaScript disabled (anchor links, `<details>`).
- EN stays at the existing URLs (`/index.html`, `/games/*.html`); PT lives in `/pt/` and `/pt/games/`. CSS, images and videos are shared, never copied.
- Section ids on the home (both languages): `home`, `work`, `prototypes`, `about`, `experience`, `contact`.
- Every page: `<html lang="en">` or `<html lang="pt-BR">`, plus reciprocal `<link rel="alternate" hreflang="en|pt-BR" href="…">` to its counterpart.
- Game names, job titles, and terms like LiveOps, A/B testing, F2P stay untranslated.
- Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **JavaScript disabled or `localStorage` blocked:** menu links still jump to sections, "See more +" still opens, theme follows the system, no exception thrown. (Task 2 tests it.)
2. **Sticky menu covering the section heading after an anchor jump:** headings must remain visible. (Task 2: `scroll-margin-top`, checked in browser.)
3. **320px-wide phone:** menu fits (icons only), no horizontal scrollbar on any page. (Checked on every page in Tasks 3–7 with `scrollWidth <= innerWidth`.)
4. **Missing or one-way EN/PT counterpart, broken internal link or image:** language switch 404s. (Task 1 checker.)
5. **Long Portuguese strings** overflowing chips, cards or the menu. (Task 6 and 7 browser checks at 320 and 1280px.)

---

## File Structure

| File | Responsibility |
|---|---|
| `tools/check-site.ps1` | Automated checks: links, hreflang pairs, lang attributes, menu ids |
| `assets/site.css` | Existing styles + new menu, featured/compact cards, chips, `details.more` |
| `assets/site.js` | `initMenu()` highlight, `initTheme()` toggle |
| `index.html`, `games/*.html` | EN home and case studies |
| `pt/index.html`, `pt/games/*.html` | PT home and case studies |

Pages: `pet-shop-fever`, `evolution-galaxy`, `vlogger-go-viral`, `my-boo` under `games/`.

---

### Task 1: Site checker (test first)

**Files:**
- Create: `tools/check-site.ps1`

**Interfaces:**
- Produces: `powershell -File tools/check-site.ps1` → prints one `FAIL: <page>: <reason>` line per problem, then `OK` (exit 0) or `FAILED n` (exit 1). Later tasks run it as their pass/fail gate.

- [ ] **Step 1: Write the checker.** It scans every `*.html` under the repo root (skip `docs/`, `tools/`) and reports:
  - `lang` attribute missing, or not `en` for non-`pt/` pages / `pt-BR` for `pt/` pages.
  - Missing `hreflang` alternate link, or the target file does not exist, or the target does not link back.
  - Local `href`/`src`/`poster` (not starting with `http`, `mailto:`, `#`) pointing to a file that does not exist (strip `#fragment`; resolve relative to the page).
  - For `index.html` and `pt/index.html` only: each of the six section ids from Global Constraints exists as `id="…"`.
- [ ] **Step 2: Run it.** Run: `powershell -ExecutionPolicy Bypass -File tools/check-site.ps1`. Expected: `FAILED n` — every page lacks hreflang and the home lacks most ids; no "file not found" failures on current EN links (proves the link check isn't a false alarm).
- [ ] **Step 3: Commit.** `git add tools/check-site.ps1 && git commit -m "Add site checker"`

---

### Task 2: Menu, base CSS and JS (EN home shell)

**Files:**
- Modify: `assets/site.css` (append new sections before `/* ---------------- responsive ---------------- */`; add rules inside the existing media queries)
- Create: `assets/site.js`
- Modify: `index.html` (add menu, ids, hreflang, script tag)

**Interfaces:**
- Produces markup contract used by every page:
  ```html
  <nav class="menu" aria-label="Main">
    <a href="#home">…icon…<span>Home</span></a> … work, prototypes, about, experience, contact
    <span class="menu-sep"></span>
    <a class="lang" href="pt/index.html" hreflang="pt-BR" lang="pt-BR">PT</a>
    <button type="button" id="theme-toggle" aria-label="Toggle theme">…icon…</button>
  </nav>
  ```
  Menu links on EN case studies use `../index.html#work` etc.; on PT case studies `../index.html#work` too (relative to `pt/games/`, that is `pt/index.html`); on `pt/index.html` they are plain `#work`. The current page's language is shown as plain text (`<span class="lang current">EN</span>`), the other as a link.
- Produces JS: `initMenu(): void` sets `aria-current="true"` on the menu link whose target section is most visible (IntersectionObserver); does nothing if the browser lacks it. `initTheme(): void` wires `#theme-toggle` to flip `document.documentElement.dataset.theme` between `light`/`dark` and persists it under localStorage key `theme`; every localStorage access is inside try/catch. Both run on `DOMContentLoaded`.

- [ ] **Step 1: Failing checks.** Run the checker; confirm `index.html` fails for hreflang and missing ids `home work prototypes about experience contact`. (`work` already exists.)
- [ ] **Step 2: Markup.** In `index.html` add `<html lang="en">` hreflang links in `<head>` (`en` → `index.html`, `pt-BR` → `pt/index.html`), the `<nav class="menu">` as the first child of `.doc`, `id="home"` on the hero `<header>`, and `<script src="assets/site.js" defer></script>` before `</body>`. Icons: small inline SVGs (one per item, `aria-hidden="true"`); labels live in `<span>`.
- [ ] **Step 3: CSS.** `.menu`: `position: fixed; top: 0.9rem; left: 50%; transform: translateX(-50%)`, pill shape, `--surface` background, `--line` border, `var(--shadow)`, `z-index: 50`, horizontal flex, `max-width: calc(100vw - 1.5rem)`. `.menu a[aria-current="true"]` uses `--primary` background with white text. Below 640px hide `.menu a span` (icons only) and keep the lang link and toggle. `section[id], header[id], footer[id] { scroll-margin-top: 5.5rem; }`. Respect `prefers-reduced-motion` (no transitions).
- [ ] **Step 4: JS** as specified in Interfaces. No other behavior.
- [ ] **Step 5: Verify.** Run the checker: only the missing ids `prototypes about experience contact` may remain (added in Task 4). Open the pages in the browser pane via `file:///C:/Users/karol/Git/KarolinaSchmitt.github.io/index.html` (Node and Python are not installed, and the site is static, so no server is needed). In the browser pane: click each menu item, confirm the heading is visible below the menu (focus item 2); toggle theme and reload (persists); disable JS via `javascript_exec` is not possible, so instead read the page and confirm every menu `href` is a plain `#id` (focus item 1); check `document.documentElement.scrollWidth <= innerWidth` at 320px (focus item 3).
- [ ] **Step 6: Commit.** `git commit -am "Add fixed menu, theme toggle and base styles"` (include `assets/site.js`).

---

### Task 3: Home work cards (featured + compact)

**Files:**
- Modify: `index.html` (the `#work` section), `assets/site.css`

**Interfaces:**
- Consumes: menu and base styles from Task 2.
- Produces classes: `.card-featured` (full width, existing horizontal layout: media left 58%, body right) and `.card-compact` (vertical: media on top, body below); `.chip` (platform/genre chip, same look as `.eyebrow` but smaller). The container stays `.cards`, now a CSS grid.

- [ ] **Step 1: Restructure markup.** Pet Shop Fever → `<a class="card card-featured">`; other three → `<a class="card card-compact">`. Each card body, in order: `.chip` (genre; plus `Mobile`), `<h3>` title with `.go`, one sentence (first sentence of the current paragraph, verbatim), then `.tags` role chips (existing tags; keep all for Pet Shop Fever, first 3 for the others). Full paragraphs stay only in the case study pages (they are already there).
- [ ] **Step 2: CSS.** `.cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: clamp(1.25rem, 3vw, 2rem); }`; `.card-featured { grid-column: 1 / -1; }` keeps the 2-column internal layout; remove the `:nth-child(even)` alternation rules (and their mobile counterparts). Below 900px: `.cards` is one column.
- [ ] **Step 3: Update the spec** line "Grid: 2 columns desktop" to "3 compact cards in one row on desktop (avoids an orphan card), 1 column on mobile". Run the checker (no new failures).
- [ ] **Step 4: Verify in browser** at 1280, 768 and 320px: featured card spans the row, three compact cards share one row on desktop and stack below 900px, no horizontal scroll, hover state intact.
- [ ] **Step 5: Commit.** `git commit -am "Standardize project cards with featured Pet Shop Fever"`

---

### Task 4: Home remaining sections (EN)

**Files:**
- Modify: `index.html`, `assets/site.css`

**Interfaces:**
- Consumes: section id contract; `.sec-head`, `.feature-card`, `.step`, `.job`, `.thumb` classes (existing).
- Produces: `details.more` (with `summary` styled as a ghost button reading "See more +", changing to "See less −" when open via `details[open] summary`).

- [ ] **Step 1: Failing check.** Run the checker; expect only the ids `prototypes about experience contact` missing.
- [ ] **Step 2: Reorder and id the sections** to match the spec order: hero (`#home`) → stats → work (`#work`) → concepts (`id="prototypes"`, rename existing `id="prototyping"`) → **About** (`id="about"`: wrap the dark "How I work" block and the "Narrative & impact" text in one `<section id="about">`, heading `About`, keep both sub-blocks' text unchanged) → Experience (`id="experience"`, timeline unchanged) with the "Earlier games" content moved inside a `<details class="more"><summary>See more +</summary>…</details>` directly under the jobs → footer (`id="contact"`).
- [ ] **Step 3: CSS** for `details.more` (reuse `.btn-ghost` look; hide the default marker) and the About wrapper (keep the dark `.process` band; the narrative text follows it on the normal background).
- [ ] **Step 4: Verify.** Checker prints `OK` for EN pages except the missing `pt/` counterpart (Task 6). Browser: every menu item lands on its section; the `<details>` opens and closes by mouse and by keyboard (Enter/Space); 320px has no horizontal scroll.
- [ ] **Step 5: Commit.** `git commit -am "Reorganize home sections: About, Experience with collapsible earlier games"`

---

### Task 5: English case studies share the menu

**Files:**
- Modify: `games/pet-shop-fever.html`, `games/evolution-galaxy.html`, `games/vlogger-go-viral.html`, `games/my-boo.html`

**Interfaces:**
- Consumes: menu markup contract (Task 2) with links `../index.html#work` etc.; the lang link points to `../pt/games/<same-file>.html`.

- [ ] **Step 1: Per page:** replace the `.topbar`/`.crumb` block with the shared `<nav class="menu">` (active highlight not needed; `aria-current` is only set by JS on the home), add hreflang links (`en` → itself, `pt-BR` → `../pt/games/<file>`), `<script src="../assets/site.js" defer></script>`. Add `padding-top` to `.detail-hero` equal to the menu height so the menu never overlaps the title. Keep everything else untouched.
- [ ] **Step 2: Verify.** Checker reports only the missing PT counterparts. Browser: each page at 320 and 1280px shows no overlap and no horizontal scroll; "Next project" link works; each menu item opens the matching home section.
- [ ] **Step 3: Commit.** `git commit -am "Share fixed menu on English case studies"`

---

### Task 6: Portuguese home

**Files:**
- Create: `pt/index.html`

**Interfaces:**
- Consumes: finished EN `index.html` as the source; asset paths become `../assets/…`; menu links are `#home`… ; the lang switch points to `../index.html`; hreflang `pt-BR` → `index.html`, `en` → `../index.html`; case-study links point to `games/<file>.html`.

- [ ] **Step 1: Copy `index.html` to `pt/index.html`**, fix paths and `lang="pt-BR"`, and translate every visible string, `alt` text, `<title>` and meta description to natural Brazilian Portuguese. Keep terms listed in Global Constraints in English. Menu labels: Início, Projetos, Protótipos, Sobre, Experiência, Contato. Buttons: "Ver projetos", "Enviar e-mail", "Ver mais +".
- [ ] **Step 2: Verify.** Checker: `pt/index.html` passes; EN↔PT home pair is reciprocal. Browser at 320 and 1280px: no menu, chip or card text overflows (focus item 5); no horizontal scroll.
- [ ] **Step 3: Review gate.** Tell Karolina the PT text is ready to read in `pt/index.html` and wait for her corrections before Task 7 reuses the vocabulary. Apply her edits.
- [ ] **Step 4: Commit.** `git add pt && git commit -m "Add Portuguese home"`

---

### Task 7: Portuguese case studies

**Files:**
- Create: `pt/games/pet-shop-fever.html`, `pt/games/evolution-galaxy.html`, `pt/games/vlogger-go-viral.html`, `pt/games/my-boo.html`

**Interfaces:**
- Consumes: EN case studies as sources; paths become `../../assets/…`; menu links `../index.html#work`…; lang switch → `../../games/<file>.html`; "Next project" links stay within `pt/games/`.

- [ ] **Step 1: Copy, fix paths, translate** each page (including `alt`, captions, `<title>`, video `aria` labels) using the vocabulary approved in Task 6.
- [ ] **Step 2: Verify.** Run the checker: expect `OK` with zero failures (all pairs reciprocal, all links and images resolve). Browser at 320 and 1280px for all four pages: video and gallery load, no overflow.
- [ ] **Step 3: Review gate.** Ask Karolina to read the four PT pages; apply her edits.
- [ ] **Step 4: Commit.** `git add pt && git commit -m "Add Portuguese case studies"`

---

### Task 8: Polish and final verification

**Files:**
- Modify: any page or `assets/site.css` as the checks demand

- [ ] **Step 1: Accessibility pass.** Keyboard: Tab order starts with the menu; focus ring visible on menu, cards, toggle, `summary`; `aria-current` set; images have meaningful `alt`; `prefers-reduced-motion` disables the menu and card transitions. Contrast of the active menu item and chips ≥ 4.5:1 in both themes.
- [ ] **Step 2: SEO tags.** Each page has a unique `<title>`, `<meta name="description">`, and `<link rel="canonical">` (use `https://karolinaschmitt.github.io/…`, with `/pt/…` for Portuguese).
- [ ] **Step 3: Final run.** `powershell -File tools/check-site.ps1` prints `OK`. Browser sweep: all 10 pages × {320, 768, 1280}px × {light, dark}: no overlap, no horizontal scroll, switch EN↔PT lands on the equivalent page, menu anchors correct.
- [ ] **Step 4: Report** results to Karolina, including anything not covered. Ask whether to push the branch `modificaçoes` and how she wants to publish; do not push on your own.
- [ ] **Step 5: Commit.** `git commit -am "Accessibility, SEO and final polish"`
