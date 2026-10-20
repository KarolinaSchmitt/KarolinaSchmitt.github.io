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
- All four projects share one scannable card format.
- Every page exists in EN and PT, and the language switch lands on the equivalent page.
- Nothing is published without Karolina's approval.

## 2. Out of scope

- New content for the short case studies (Evolution Galaxy, Vlogger Go Viral, My Boo). Existing text is only reorganized.
- New fonts, colors or logo. The blue/amber palette, fonts and light/dark theme stay.
- Analytics, a build step, or any framework.
- Changes to `main`.
- The "Concepts & prototyping" section (4 concept pitches) is **removed from the site** (Karolina's decision, 2026-10-20). Its menu item and id `prototypes` go with it. "Earlier games" moves from Experience into Work. Menu has 5 items: Home, Work, About, Experience, Contact.

## 3. File structure

```
/index.html               home (EN) - existing URL stays valid
/games/*.html             4 case studies (EN)
/pt/index.html            home (PT)
/pt/games/*.html          4 case studies (PT)
/assets/                  shared: site.css, site.js, images, videos
/docs/superpowers/specs/  this spec
```

- CSS and media are shared by both languages; only text is duplicated.
- Each page has `<html lang>` and `hreflang` alternate links to its counterpart.
- The EN/PT switch is a plain link to the equivalent page (no JavaScript needed).

## 4. Home structure

A floating pill menu (fixed at top, icons plus labels) with the language switch and the theme toggle at its end.

| Menu item | Section | Content |
|---|---|---|
| Home | Profile | Photo, name, positioning line, buttons "View projects" and "Email" (the 4-stat strip was removed by Karolina, 2026-10-20) |
| Work | Selected work + Earlier games | Pet Shop Fever as one full-width featured card; the other 3 projects in a grid below; then an always-visible "Earlier games" strip (Playmove, 2015-2019, PC & Mobile) with its 5 thumbnails |
| About | How I work + Narrative & impact | Four-step process and the narrative paragraph, merged into one block |
| Experience | Experience | Timeline only |
| Contact | Let's talk | Email, LinkedIn, location |

**Project card format (all four):** cover, genre and platform chip, title, one-sentence description, role chips. The long paragraph moves to the case study (where it already lives). Grid: 3 compact cards in one row on desktop (avoids an orphan card), 1 column on mobile.

## 5. Project pages

- Same layout as today, plus the same fixed menu as the home.
- Pet Shop Fever keeps its rich page (screenshots, videos, features).
- The three shorter case studies are only reorganized, not expanded.
- "Next project" footer stays.

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
