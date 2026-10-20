# Portfolio reorganization and bilingual (EN/PT) design

Date: 2026-10-20
Repo: KarolinaSchmitt.github.io (static HTML/CSS, GitHub Pages)
Branch: `modificaçoes`

## 1. Goal and understanding

Karolina's game-design portfolio has strong content but a long, run-on home page that is hard to scan. The goal is to **reorganize** it so a recruiter or studio can quickly find who she is, her projects, her experience and her contact, without scrolling one long page.

Reference: https://www.viniciusbustamanti.space/pt/ . What is borrowed: floating icon menu, clearly separated sections, standardized project cards, direct contact buttons, EN/PT switch.

**Stated by Karolina:** the problem is organization (not visual style). She wants "Sobre" in the menu, Pet Shop Fever as one large card, and a bilingual site (EN + PT) using separate folders.

**Assumptions:** audience is recruiters/studios (she is seeking a role in mechanics/systems for narrative-driven games); English remains the primary language; the existing visual identity is kept.

**Success criteria:**
- Every home section is reachable in one click from a fixed menu.
- All nine games share one scannable card format (image, studio · platform, sentence, role chips).
- Every page exists in EN and PT, and the language switch lands on the equivalent page.
- Nothing is published without Karolina's approval.

## 2. Out of scope

- New content for the short case studies (Evolution Galaxy, Vlogger Go Viral, My Boo). Existing text is only reorganized.
- New fonts, colors or logo. The blue/amber palette, fonts and light/dark theme stay.
- Analytics, a build step, or any framework.
- Changes to `main`.
- The "Concepts & prototyping" section (4 concept pitches) is **removed from the site** (Karolina's decision, 2026-10-20). Its menu item and id `prototypes` go with it. "Earlier games" moves from Experience into Work. (Superseded by Revision 2: the menu now has 4 items.)

## 3. File structure

> **Revision 2 (2026-10-20, Karolina):** the home is restructured into three blocks (profile, games grid, contact) and the About/Experience content moves to a separate About page. Section 4 below is the current design; the older home layout (featured Pet Shop Fever card, Earlier games strip inside Work, About and Experience on the home, 5-item menu) is superseded.

```
/index.html               home (EN) - existing URL stays valid
/about.html               About page (EN): intro paragraph, How I work, Narrative & impact, Experience timeline
/games/*.html             4 case studies (EN)
/pt/index.html            home (PT)
/pt/about.html            About page (PT)
/pt/games/*.html          4 case studies (PT)
/assets/                  shared: site.css, site.js, images, videos
/docs/superpowers/specs/  this spec
```

- CSS and media are shared by both languages; only text is duplicated.
- Each page has `<html lang>` and `hreflang` alternate links to its counterpart.
- The EN/PT switch is a plain link to the equivalent page (no JavaScript needed).

## 4. Home structure

A floating pill menu (fixed at top, icons plus labels) with the language switch and the theme toggle at its end.

**Menu (4 items):** Home (`#home`), Work (`#work`), About (page `about.html`), Contact (`#contact`), then the language switch and theme toggle. On `about.html` and the case studies the first two and Contact point back to the home sections (`index.html#home`, …); on `about.html` the About item is marked `aria-current="page"`.

**Home** (3 blocks):

| Block | Id | Content |
|---|---|---|
| Profile | `home` | Photo (kept), eyebrow "Game Designer — Mechanics, Systems & Player Experience" (title and skills), the summary phrase as h1 ("I design the mechanics and systems that give a game its intended emotional experience."), location chip, and two buttons: **E-mail** and **LinkedIn** (icon buttons, address not shown as text); below the photo and the title/buttons row, in full width (a readable measure of about 72 characters, aligned with the left edge of the title), an intro text of three paragraphs (EN verbatim with the wording "multiple titles" in paragraph 3 from Karolina, PT translation to be reviewed by her). EN: (1) "Games have always been a part of my life – they’ve marked me, inspired me, and, in a way, shaped who I am. Today, my goal is to create experiences that have the same impact on others." (2) "I work on creating engaging gameplay experiences, balanced monetization systems, and Live Ops that keep players engaged for the long haul. I believe that creativity and strategy should go hand in hand, ensuring that every design decision has purpose and impact." (3) "Throughout my career, I’ve had the opportunity to contribute to the design and growth of multiple titles and learn from every challenge I’ve faced. I want to keep improving my skills, reach new milestones, and collaborate with the industry." PT: (1) "Os jogos sempre fizeram parte da minha vida – eles me marcaram, me inspiraram e, de certa forma, moldaram quem eu sou. Hoje, meu objetivo é criar experiências que causem o mesmo impacto em outras pessoas." (2) "Trabalho criando experiências de gameplay envolventes, sistemas de monetização equilibrados e Live Ops que mantêm os jogadores engajados a longo prazo. Acredito que criatividade e estratégia devem andar juntas, para que cada decisão de design tenha propósito e impacto." (3) "Ao longo da minha carreira, tive a oportunidade de contribuir para o design e o crescimento de vários títulos e de aprender com cada desafio que enfrentei. Quero continuar aprimorando minhas habilidades, alcançar novos marcos e colaborar com a indústria." |
| Games | `work` | Heading "10+ years of experience", note "The games I've worked on", then a uniform grid of 9 game cards (below) |
| Contact | `contact` | "Let's talk." heading, the existing "I'm looking for a role…" sentence, the same **E-mail** and **LinkedIn** buttons, location, the education/languages line |

**Game card (all 9, same size):** image; chip "Studio · Platform" (Tapps Games · Mobile; Playmove · PC & Mobile); title; one sentence; role chips. Grid: 3 columns on desktop, 2 on tablet, 1 on mobile. Order: Pet Shop Fever, Evolution Galaxy: Mutant Merge, Vlogger Go Viral, My Boo, then the five Playmove games (Liga do Tempo, Color Shooter, Lab Boom, Divertron, Guardiões do Mundo).
- The 4 Tapps cards are links to their case study. The 5 Playmove cards have no page and are not links (no invented content).
- Card text and role chips use existing wording (the first sentence of the existing text; role chips from the existing tags). For Lab Boom and Divertron the site states no role, so the chip is "Game design". **These card texts are placeholders: Karolina will rewrite them in the next step.**

**About page:** h1 "About"; the intro paragraph formerly in the home hero ("Eleven years in game design, 10+ shipped titles…"); "How I work" (4 steps); "Narrative & impact"; Experience timeline (four jobs). The sentence formerly introducing Earlier games ("The first place I designed around an explicit learning and emotional goal…") moves, verbatim, to the Playmove job entry. Ends with the same contact block.

**Contact block** appears on the home, About and every case study, identical, with buttons instead of a printed e-mail address.

## 5. Project pages (Revision 3, 2026-10-20)

Every one of the **9 games** gets a case-study page (4 Tapps pages exist; 5 Playmove pages are new), in EN and PT, all with the same template. Playmove cards on the home become links.

Template, in order:
1. **Company + game name:** eyebrow with the company ("Tapps Games · Live since 2022", "Tapps Games · Live", "Playmove · 2015-2019") and the game name as h1.
2. **Platform · style:** one line, e.g. "Mobile · Time management" (Playmove: "PC & Mobile · …").
3. **My functions:** the role chips (existing `.detail-tags`).
4. **Media:** the cover image (Pet Shop Fever also keeps its "In action" clips and gallery directly below). Images narrower than 800px are shown at natural size, not stretched (all covers and thumbnails are only 440px wide; better images or gameplay videos should replace them later).
5. **Overview** (id `overview`), 6. **My role** (id `role`), 7. **Design challenges** (id `challenges`), 8. **Results** (id `results`), each an h2.

Content mapping (no invented content): Overview = first existing paragraph; My role = second existing paragraph (Pet Shop Fever: plus Narrative, Features I designed and Economy & progression as h3 subsections); the short sentence under the title (`.sub`) stays for the Tapps pages. The Playmove pages use their one existing sentence as Overview text and the existing role chips.

**Provisional text (Karolina's choice):** Design challenges and Results on all 9 pages, plus My role/extra Overview on the Playmove pages, hold clearly marked provisional blocks (`<div class="placeholder" data-placeholder>` with a visible "Provisional text" / "Texto provisório" badge and a dashed border). They contain instructions, never facts. `tools/check-site.ps1` counts them and prints a warning; `-Publish` makes the checker fail while any remain, so nothing is published unfilled by accident.

"Next project" chain: Pet Shop Fever → Evolution Galaxy → Vlogger Go Viral → My Boo → Liga do Tempo → Color Shooter → Lab Boom → Divertron → Guardiões do Mundo → Pet Shop Fever. The contact block stays at the bottom.

## 6. Behavior (assets/site.js)

Small vanilla JS file: highlight the menu item for the section in view, remember the chosen theme. The site must remain fully readable and navigable with JS disabled (anchor links).

## 7. Translation

English text is the source. Claude drafts the Portuguese naturally (not word for word); Karolina reviews before anything is published. Game names, job titles and industry terms (LiveOps, A/B testing, F2P) are kept as they are.

## 8. Work order

1. Base: fixed menu, new CSS, language switch, applied to the EN home.
2. Full EN home (profile, cards with earlier games, About, Experience, Contact).
3. EN case studies with the shared menu.
4. PT home and case studies, with translation for Karolina's review.
5. Polish: accessibility, SEO tags, final check.

## 9. Verification

- Serve locally and check every page in the browser at desktop, tablet and mobile widths, in light and dark themes.
- All links, images and videos load; menu items reach the correct section; EN/PT switch lands on the equivalent page.
- Keyboard navigation (Tab) works, contrast is adequate, `prefers-reduced-motion` is respected.

## 10. Publishing safety

- Work on branch `modificaçoes`; do not touch `main` (the live site).
- Small commits, one per slice, so any step can be reverted.
- Nothing is pushed until Karolina says so.
