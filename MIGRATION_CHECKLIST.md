# Godot Migration Checklist

Last refreshed: 2026-03-22

Status legend:
- `[done]` already matches or has a solid Godot replacement
- `[in progress]` started in Godot but still needs follow-through
- `[pending]` identified gap that can be migrated safely later
- `[blocked]` should wait for a larger foundation or repo decision

## Launcher

- `[done]` Godot launcher home with two game cards, floating glyph ambience, and mobile browser guidance. Notes: hanziHero uses a launcher homepage with portal cards; Godot now preserves the same top-level game-selection role.
- `[done]` About overlay upgraded to a richer story/article layout with two game summaries and migration notes. Notes: hanziHero's launcher has an about portal with story paragraphs, game cards, and note cards; Godot now carries that structure in-code.
- `[pending]` Theme toggle parity for launcher and about surface. Notes: hanziHero supports a paper-ink theme switch; Godot is still fixed to one dark-ink presentation.
- `[pending]` Bilingual launcher copy and runtime language toggle. Notes: hanziHero ships zh/en launcher strings; Godot still shows placeholder `EN` pills without behavior.
- `[pending]` Cangjie portal follow-through. Notes: hanziHero can open the deckbuilder prototype directly; Godot still stops at a non-interactive "后续接入" button.

## Menus

- `[done]` Zihai second-layer menu with hero selection and archive overlays. Notes: Godot has dedicated overlays for 人物志、合字图谱、怪物图鉴、本地排行榜, matching the source menu depth.
- `[done]` Character selection flow with scholar / xia split and direct battle entry. Notes: source menu moved to "start -> choose hero -> battle"; Godot keeps that same hierarchy.
- `[done]` Quick-start wave shortcuts for menu-side test entry. Notes: hanziHero keeps dedicated test starts for wave 10 / 20; Godot now exposes equivalent menu buttons and treats those shortcut runs as non-ranked checks.
- `[pending]` Character reaction flavor on selection. Notes: hanziHero role cards trigger short personality lines and staging feedback; Godot selection is currently silent.
- `[pending]` Theme / language parity inside the menu layer. Notes: source launcher/menu surfaces share theme and language toggles; Godot menu copy is still single-language.
- `[pending]` More menu-side build and progression surfacing. Notes: source menu surfaces richer descriptive cards and front-end polish; Godot menu remains more utilitarian.

## Battle HUD

- `[done]` Pause overlay, restart / return actions, and local leaderboard access. Notes: hanziHero exposes pause plus result-side leaderboard views; Godot already supports pause and post-run naming/editing for local records.
- `[done]` Map modal with fog-of-war, drag, zoom, legend, and exploration summary. Notes: source has a modal map with zoom/drag/legend; Godot now has a close equivalent.
- `[done]` Mobile joystick, touch interact, pause button, and landscape guard. Notes: hanziHero mobile battle flow depends on these protections; Godot already has matching control coverage.
- `[pending]` Runtime settings / LOD panel. Notes: hanziHero exposes performance, effects, ambient, and enemy-detail toggles; Godot presentation is still hardcoded.
- `[pending]` Music track toast and soundtrack UI. Notes: hanziHero shows the active procedural track name and mood; Godot has no soundtrack or track notification surface yet.
- `[pending]` Phrase / event log panel. Notes: hanziHero records discovered sentence events in a dedicated log; Godot battle UI does not yet surface event history.
- `[pending]` Bilingual HUD copy. Notes: source battle UI can switch zh/en; Godot HUD remains Chinese-only.

## Combat Systems

- `[done]` Auto-attack survival loop with radical draft, recipe formation, and inkstone word grinding. Notes: source progression is "偏旁 -> 成字 -> 词技"; Godot already preserves that core loop.
- `[done]` Two-role hero split between ranged scholar and melee xia. Notes: hanziHero gives xia a close-range sword identity; Godot mirrors that distinction.
- `[done]` Enemy roster baseline with clear telegraphs. Notes: Godot already includes basic, swift, tank, archer, assassin, cavalry, ritualist, elite, and boss enemies with warning zones.
- `[done]` World-prop baseline for trees, bushes, inkstones, chests, stelae, scroll racks, and ink pools. Notes: the source battlefield is no longer an empty field; Godot already supports a comparable landmark layer.
- `[pending]` Phrase / idiom guardian encounters. Notes: hanziHero uses discovered sentences guarded by elites and tied rewards; Godot still uses static landmarks instead of guarded phrase events.
- `[pending]` Relic / artifact system. Notes: hanziHero treats relics as a second growth lane parallel to radicals; Godot chests currently drop only direct pickups.
- `[pending]` Stage phase-shift themes. Notes: hanziHero rotates battlefield atmosphere through 字境 themes like 碑林 / 墨潮 / 雷纹 / 残卷; Godot battle ambience is static.
- `[pending]` Wider radical / recipe / word pool. Notes: hanziHero already has a broader content set; Godot currently centers on 明 / 休 / 海 plus blade growth.
- `[pending]` Source pickup taxonomy parity. Notes: hanziHero includes pickups like 聚墨符 and 疾书令; Godot currently ships a smaller supply set.

## Progression

- `[done]` Local leaderboard persistence with player naming, hero, bosses, kills, radicals, recipes, words, and enemy counts. Notes: hanziHero already records local runs; Godot mirrors that in `user://local_leaderboard.json`.
- `[done]` Word-grind gating at the inkstone rather than passive auto-unlock. Notes: the source moved word skills behind an explicit station interaction; Godot follows that rule.
- `[pending]` Dedicated test-run leaderboard view. Notes: shortcut starts now stay out of the ranked local board, but Godot still lacks the source repo's explicit manual / test separation.
- `[pending]` Cloud leaderboard sync. Notes: hanziHero has online leaderboard plumbing; Godot only keeps local records today.
- `[pending]` Relic-aware build summary. Notes: source pause / result views include owned relic context; Godot cannot yet show that lane because relics are not ported.
- `[pending]` More map-event reward routing. Notes: source sentence discoveries can branch into different reward types; Godot progression currently stays in the core combat loop.

## Content

- `[done]` Character archive, recipe atlas, and enemy codex text live in shared session data. Notes: source uses compendium-style front panels; Godot already ships equivalent text-driven overlays.
- `[pending]` More hero flavor text, taunts, and reactive presentation. Notes: hanziHero has more voiced/written character reactions on the front end and battlefield.
- `[pending]` More narrative and educational copy parity from the launcher / about surface. Notes: source continues to frame the cultural motivation and bilingual-learning angle more broadly than Godot elsewhere.
- `[blocked]` Full `仓颉之路` Godot port. Notes: the web prototype is playable, but the Godot repo does not yet have the deckbuilder combat/map foundation needed for a safe direct migration.

## Polish

- `[done]` Tree fade-through, bush anti-abuse lockout, banners, and strong telegraph readability. Notes: Godot already carries several of the source combat-polish beats into 3D.
- `[pending]` Procedural music playback and current-track feedback. Notes: source already rotates multiple tracks and announces them; Godot is still silent on that front.
- `[pending]` Higher-end hit/audio differentiation. Notes: hanziHero has more layered weapon/skill sound identity and lingering glyph afterimages; Godot feedback can be pushed further.
- `[pending]` Themeable launcher/menu presentation. Notes: source supports stronger visual mode switching; Godot keeps one locked art direction so far.
- `[pending]` More stage spectacle for big unlocks and transitions. Notes: source leans harder into large character/word reveal moments and evolving battlefield mood.

## Export

- `[done]` Godot Web export script, export presets, and Vercel deployment path. Notes: the Godot repo already has a direct replacement for the web repo's static hosting flow.
- `[done]` Root README documentation for export overrides and deployment expectations. Notes: recent README maintenance now matches the current `scripts/export_web.sh` behavior.
- `[pending]` Automated scene smoke checks in repo scripts. Notes: export validation is currently command-driven and manual rather than wrapped in a repeatable local check command.

## Technical Debt

- `[in progress]` Long-lived migration tracking in repo root. Notes: this checklist is now the shared source of truth; keep updating it instead of scattering parity state across README prose and issues.
- `[pending]` Shared localization layer for launcher, menu, and battle UI. Notes: hanziHero already centralizes zh/en strings; Godot will need a similar data layer before toggles are practical.
- `[pending]` Break up `scripts/battle/zihai_battle.gd` into smaller systems. Notes: source JS has already started splitting combat/rendering/data concerns; Godot battle logic is still concentrated in one large script.
- `[pending]` Move launcher / menu content into data-driven definitions. Notes: current Godot UI is built inline in GDScript; data-backed cards would make future theme and language parity safer.
