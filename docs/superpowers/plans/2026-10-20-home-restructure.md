# Home Restructure (Revision 2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the home into profile, a uniform 9-game grid and a contact block with buttons, and move About/Experience to a new About page, in EN and PT.

**Architecture:** Same static site (HTML/CSS, shared `assets/site.css`, `assets/site.js`, checker `tools/check-site.ps1`). New pages `about.html` and `pt/about.html`. Menu shrinks to 4 items; the contact block becomes two buttons and is identical on every page.

**Tech Stack:** HTML, CSS, vanilla JS, PowerShell 5.1 checker, browser pane with a temporary local PowerShell HttpListener server for visual checks (file:// does not load CSS in the pane).

**Spec:** `docs/superpowers/specs/2026-10-20-portfolio-reorganization-design.md` (section 4, "Revision 2"). Supersedes the home layout of `docs/superpowers/plans/2026-10-20-portfolio-reorganization.md`.

## Global Constraints

- Branch `modificaçoes` only. Never touch `main`. Never `git push` without Karolina's explicit go-ahead.
- No new fonts or colors: only existing CSS variables. Light/dark themes keep working; site usable without JavaScript.
- Text is moved, not rewritten: every sentence removed from the home reappears verbatim on the About page (EN) or its existing PT translation (PT). New strings are limited to those in the "New strings" table below.
- Game names, company names, LiveOps, A/B testing, F2P, Unity, GDD, idle, merge, time management stay in English in PT; use the existing PT glossary/translations already in `pt/index.html` and `pt/games/*.html` for recurring terms ("em operação" for live).
- Home ids: `home`, `work`, `contact`. About page id: `contact` (footer). The old ids `about`, `experience` are gone from the home.
- Every page keeps `<html lang>`, `rel="canonical"`, absolute `hreflang` alternates (`en`, `pt-BR`, `x-default`→EN) in canonical form (`https://karolinaschmitt.github.io/about.html`, `/pt/about.html`), unique `<title>`, `<meta name="description">`, the inline theme script in `<head>`, `#theme-toggle` with `aria-pressed`, labels "Dark theme" (EN) / "Tema escuro" (PT).
- Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## New strings

| Place | EN | PT |
|---|---|---|
| Games heading | 10+ years of experience | Mais de 10 anos de experiência |
| Games note | The games I've worked on | Os jogos em que trabalhei |
| Menu labels | Home, Work, About, Contact | Início, Projetos, Sobre, Contato |
| Buttons | E-mail, LinkedIn | E-mail, LinkedIn |
| About h1 | About | Sobre |
| Chips | Tapps Games · Mobile / Playmove · PC & Mobile | Tapps Games · Mobile / Playmove · PC e Mobile |
| Playmove role chips | GDD, Mechanics, Playtesting, Game design, Creative direction, Level design | GDD, Mecânicas, Playtesting, Game design, Direção criativa, Level design |

"Let's talk." / "Vamos conversar." and the existing contact sentence already exist on the pages.

## Review Focus

1. **Playmove cards (no page) must not look or act clickable:** no pointer cursor, no hover lift/zoom, not in the tab order, no "view project" arrow. (Task 2 test.)
2. **Menu links to sections on other pages:** from `about.html` and the case studies, Home/Work/Contact reach the home sections; About is marked `aria-current="page"` on the About page and nothing else is highlighted by JS there. (Task 1 test.)
3. **Nine-card grid at 320, 768, 1280px:** no horizontal overflow, equal card heights per row, long PT chips wrap. (Tasks 2 and 3.)
4. **Contact buttons:** real links with accessible names (visible text; icon `aria-hidden`), the e-mail address is not shown as text anywhere, LinkedIn has `rel="noopener"`, contrast ≥ 4.5:1 on the dark footer in both themes. (Task 2 measures.)
5. **Content preservation:** nothing lost in the move: the Earlier-games lede now sits in the Playmove job entry; the home-hero paragraph is the About intro. (Task 1 text diff.)

---

## Contracts (used by several tasks)

**Menu** (4 items + switch + toggle; copy the SVG icons from the current menu, drop the Experience item):

| Page | Home | Work | About | Contact | other-language link |
|---|---|---|---|---|---|
| `index.html` | `#home` | `#work` | `about.html` | `#contact` | `pt/index.html` |
| `about.html` | `index.html#home` | `index.html#work` | `about.html` (`aria-current="page"`) | `#contact` | `pt/about.html` |
| `games/*.html` | `../index.html#home` | `../index.html#work` | `../about.html` | `../index.html#contact` | `../pt/games/<file>` |
| `pt/index.html` | `#home` | `#work` | `about.html` | `#contact` | `../index.html` |
| `pt/about.html` | `index.html#home` | `index.html#work` | `about.html` (`aria-current="page"`) | `#contact` | `../about.html` |
| `pt/games/*.html` | `../index.html#home` | `../index.html#work` | `../about.html` | `../index.html#contact` | `../../games/<file>` |

**Contact block** (all pages; replaces the current `.links` row):
```html
<footer class="contact band" id="contact">
  <div class="inner">
    <h2>Let's <span class="u">talk</span>.</h2>
    <p>…existing sentence…</p>
    <div class="cta-row">
      <a class="btn btn-primary" href="mailto:karolinafschmitt@gmail.com"><svg aria-hidden="true">…</svg>E-mail</a>
      <a class="btn btn-ghost" href="https://www.linkedin.com/in/karolina-schmitt-a7623390/" target="_blank" rel="noopener"><svg aria-hidden="true">…</svg>LinkedIn</a>
    </div>
    <div class="fine">Blumenau, Brazil · …existing education/languages line…</div>
  </div>
</footer>
```
On the home hero the same two buttons replace "See my work" / "Email me". Case-study footers get `id="contact"` too. `.btn` gets a small icon style; buttons on the dark footer use light borders/text (existing `--feature-*` variables).

**Game card:**
```html
<a class="card" href="games/<file>.html">          <!-- Tapps games -->
<div class="card card-static">                      <!-- Playmove games: no link -->
  <div class="card-media"><img src="…" alt="…"></div>
  <div class="card-body">
    <span class="chip">Studio · Platform</span>
    <h3>Title <span class="go">view project &rarr;</span></h3>   <!-- .go only on links -->
    <p>one sentence</p>
    <div class="tags"><span class="tag">…</span>…</div>
  </div>
</…>
```

| # | Title | Studio · Platform | Sentence (verbatim existing) | Tags | Image / link |
|---|---|---|---|---|---|
| 1 | Pet Shop Fever | Tapps Games · Mobile | A live time-management game where players build and grow a chain of pet shops across several worlds. | Narrative design, Feature design, Economy & balancing | `assets/covers/pet-shop-fever.jpg` / `games/pet-shop-fever.html` |
| 2 | Evolution Galaxy: Mutant Merge | Tapps Games · Mobile | A merge and collection game where players combine species to evolve new life forms and expand across planets. | Systems design, Merge mechanics, Progression pacing | `assets/covers/evolution-galaxy.jpg` / `games/evolution-galaxy.html` |
| 3 | Vlogger Go Viral | Tapps Games · Mobile | An idle game about growing a video channel from a bedroom setup to an automated media operation. | Idle systems, Curve tuning, Prestige | `assets/covers/vlogger-go-viral.jpg` / `games/vlogger-go-viral.html` |
| 4 | My Boo | Tapps Games · Mobile | A long-running virtual-pet game with a daily care loop, minigames and seasonal events. | Daily loop, Customization systems, Seasonal events | `assets/covers/my-boo.jpg` / `games/my-boo.html` |
| 5 | Liga do Tempo | Playmove · PC & Mobile | History timeline card game. | GDD, Mechanics, Playtesting | `assets/thumbs/liga-do-tempo.jpg` / none |
| 6 | Color Shooter | Playmove · PC & Mobile | Co-op motor-skills game, 30 levels. | Game design, Creative direction | `assets/thumbs/color-shooter.jpg` / none |
| 7 | Lab Boom | Playmove · PC & Mobile | Four-player checkers-style game with four modes. | Game design | `assets/thumbs/lab-boom.jpg` / none |
| 8 | Divertron | Playmove · PC & Mobile | Touch adaptation of classic board games. | Game design | `assets/thumbs/divertron.jpg` / none |
| 9 | Guardiões do Mundo | Playmove · PC & Mobile | Challenge-mode level design, 20 levels. | Level design | `assets/thumbs/guardioes-do-mundo.jpg` / none |

Image alts: the current ones ("X key art" for covers; the game name for thumbs). These card texts are placeholders Karolina will rewrite next. PT: translate the sentences from the existing PT thumbs/cards text already in `pt/index.html` and reuse its PT tag wording.

---

### Task 1: About page (EN), 4-item menu, checker

**Files:**
- Create: `about.html`
- Modify: `index.html` (menu; remove `#about` and `#experience` sections), `games/*.html` (menu), `assets/site.js`, `assets/site.css`, `tools/check-site.ps1`

**Interfaces:**
- Produces: the menu contract above on `index.html`, `about.html`, `games/*.html`; `about.html` with header (`detail-hero` pattern: h1 "About" + the verbatim paragraph from the old home hero `.sub`), "How I work" (h2, 4 `.step` as h3), "Narrative & impact" (h2), Experience timeline (h2, four jobs verbatim, Playmove entry gets a second paragraph: the verbatim Earlier-games lede), then the existing contact footer (rebuilt in Task 2). `initMenu()` becomes a no-op unless `document.getElementById('home')` exists.
- Consumes: current `index.html` sections `#about`, `#experience`; the dark `.process` band styles.

- [ ] **Step 1: Failing check.** Update the checker's required ids: `index.html`/`pt/index.html` → `home work contact`; `about.html`/`pt/about.html` → `contact`. Then change the home menu to the 4-item contract (About → `about.html`, Experience item removed) without creating `about.html` yet. Run `powershell -ExecutionPolicy Bypass -File tools/check-site.ps1`. Expected: FAIL with `link not found: about.html` on `index.html`.
- [ ] **Step 2: Create `about.html`** from the old sections (move text verbatim; promote headings to a valid h1→h2→h3 outline and retarget the CSS selectors so the look is unchanged: `.process .sec-head h2` etc.). Head: unique title, description, canonical `https://karolinaschmitt.github.io/about.html`, hreflang (`pt-BR` → `/pt/about.html`), theme script, site.css/js links. Menu per the contract with About `aria-current="page"`.
- [ ] **Step 3: Update `index.html`** (menu → 4 items; delete the `#about` and `#experience` sections; the About link is `about.html`) and `games/*.html` (menu → 4 items; remove the Experience item and its SVG). Remove CSS that becomes dead.
- [ ] **Step 4: `site.js`:** `initMenu()` no-op unless `#home` exists; verify home highlighting still works for Home/Work/Contact and the bottom-of-page rule marks Contact.
- [ ] **Step 5: Verify.** Checker: only PT-counterpart failures (`pt/about.html` missing, about pair). Browser (temp server): home menu highlights Home/Work/Contact; `about.html` shows About as current, no JS-driven highlight; Home/Work/Contact from `about.html` and a case study land on the right home section; text diff: every removed home sentence is present in `about.html` (compare strings by grep); 320px no horizontal scroll on `about.html`.
- [ ] **Step 6: Commit.** `git add -A` for these files; message "Add About page and 4-item menu".

---

### Task 2: Home restructure and contact buttons (EN)

**Files:**
- Modify: `index.html`, `about.html`, `games/*.html` (contact block), `assets/site.css`

**Interfaces:**
- Consumes: menu from Task 1; contracts above.
- Produces: `.card`/`.card-static`/`.chip`/`.tag` styles for the 9-card grid (`.cards` grid: 3 columns ≥1000px, 2 columns 640–999px, 1 column <640px; card is vertical: media on top); `.cta-row .btn` icon style; `.contact .btn` styles on the dark footer.

- [ ] **Step 1: Failing check (visual/assert).** In the browser confirm the current home has `.card-featured` and `.earlier-strip` (they must not exist after this task) and that the footer shows the printed e-mail address (must not).
- [ ] **Step 2: Hero.** Keep the photo, eyebrow, h1 (summary phrase) and location chip; remove the `.sub` paragraph (already on the About page) and replace the two CTA buttons with E-mail (primary) and LinkedIn (ghost) per the contract.
- [ ] **Step 3: Games section** `id="work"`: heading "10+ years of experience", note "The games I've worked on", then the 9 cards from the table (Tapps first). Delete `.card-featured`, `.card-compact`, `.earlier-strip`, `.thumbs`, `.thumb` markup and CSS.
- [ ] **Step 4: Cards CSS:** the three breakpoints above; `.card-static` has no pointer cursor, no hover lift/zoom, no `.go`, and is a `div` (not focusable); links keep hover/focus-visible (radius 20px).
- [ ] **Step 5: Contact block** on `index.html`, `about.html` and the four `games/*.html` per the contract (case-study footers also get `id="contact"`).
- [ ] **Step 6: Verify.** Checker prints only PT-pair failures. Browser at 320/768/1280px, light and dark: grid columns as specified (assert with `getBoundingClientRect`), equal heights per row, `scrollWidth <= innerWidth`; Playmove cards: `cursor` is not pointer, not focusable (`tabIndex === -1` or non-interactive element), no `.go`; buttons: names "E-mail"/"LinkedIn", `grep` shows no printed e-mail address in visible text (it appears only in `href`), LinkedIn has `rel="noopener"`; measure contrast of both buttons in the hero and the footer in both themes (≥ 4.5:1; fix with existing variables if not); screenshots of the home at 1280 and 320.
- [ ] **Step 7: Commit.** "Restructure home: games grid, contact buttons".

---

### Task 3: Portuguese pages

**Files:**
- Create: `pt/about.html`
- Modify: `pt/index.html`, `pt/games/*.html`

**Interfaces:**
- Consumes: finished EN pages as the source; menu and contact contracts (PT rows); the New strings table; existing PT glossary.

- [ ] **Step 1: `pt/about.html`:** copy from `about.html`; `lang="pt-BR"`, `../assets/…` paths, menu per contract, canonical `https://karolinaschmitt.github.io/pt/about.html`, hreflang (`en` and `x-default` → `https://karolinaschmitt.github.io/about.html`), translate every string, reusing the PT text already present in `pt/index.html` for the moved sections (How I work, Narrative, Experience, the intro paragraph, the Playmove lede).
- [ ] **Step 2: `pt/index.html`:** apply the same changes as the EN home (hero buttons, 9 cards with PT strings, 4-item menu, contact block). Remove the PT versions of the deleted sections.
- [ ] **Step 3: `pt/games/*.html`:** 4-item menu and the contact block per contract.
- [ ] **Step 4: Verify.** Checker prints `OK`. Browser at 320 and 1280px for all 6 PT pages: no overflow, long chips/tags wrap, images load, no console errors; language switch from every page lands on the equivalent page (about ↔ pt/about too); menu rows behave as the contract; no English left in `pt/` except the allowed terms (grep).
- [ ] **Step 5: Commit.** "Add Portuguese About page and apply home restructure".

---

### Task 4: SEO, accessibility and final sweep

**Files:**
- Modify: any page or CSS as the checks demand

- [ ] **Step 1: SEO/hreflang** for `about.html`/`pt/about.html` (title, description from the About intro, canonical, hreflang incl. x-default) — checker `OK`.
- [ ] **Step 2: Accessibility:** one h1 per page and a valid heading outline on the home (h1 → h2 games → h3 card titles) and About (h1 → h2 → h3); focus ring visible on menu, buttons, cards, toggle, lang link; Tab skips the Playmove cards; `prefers-reduced-motion` respected; contrast of chips/tags/buttons ≥ 4.5:1 in both themes.
- [ ] **Step 3: Final sweep** over all 12 pages × {320, 768, 1280}px × {light, dark}: no horizontal scroll, no console errors, images load, menu doesn't overlap titles, language switch and Next-project links resolve; record a compact table.
- [ ] **Step 4: Commit.** "Final polish for restructured home".
