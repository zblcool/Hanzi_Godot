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
- `[done]` Theme toggle parity for launcher and about surface. Notes: hanziHero supports a paper-ink theme switch; Godot launcher and about overlay now expose a remembered `夜墨 / 纸墨` toggle while preserving the existing night-ink default.
- `[done]` Launcher-side latest update spotlight. Notes: hanziHero's homepage surfaces a recent version / changelog spotlight; Godot launcher now mirrors that front-page role with an in-launcher migration progress card.
- `[done]` Launcher-side changelog history overlay. Notes: the source launcher can open a dedicated changelog panel; Godot launcher now exposes a matching in-launcher update-history overlay from the latest-update card instead of stopping at a single snapshot.
- `[pending]` Bilingual launcher copy and runtime language toggle. Notes: hanziHero ships zh/en launcher strings; Godot still shows placeholder `EN` pills without behavior.
- `[pending]` Cangjie portal follow-through. Notes: hanziHero can open the deckbuilder prototype directly; Godot still stops at a non-interactive "后续接入" button.

## Menus

- `[done]` Zihai second-layer menu with hero selection and archive overlays. Notes: Godot has dedicated overlays for 人物志、合字图谱、怪物图鉴、本地排行榜, matching the source menu depth.
- `[done]` Character selection flow with scholar / xia split and direct battle entry. Notes: source menu moved to "start -> choose hero -> battle"; Godot keeps that same hierarchy.
- `[done]` Quick-start wave shortcuts for menu-side test entry. Notes: hanziHero keeps dedicated test starts for wave 10 / 20; Godot now exposes equivalent menu buttons and routes those shortcut runs into a separate local test board.
- `[done]` Character reaction flavor on selection. Notes: hanziHero role cards trigger short personality lines; Godot now rotates short in-character response quotes in the detail panel whenever a hero is picked.
- `[done]` Player Sigil default-name flow in launcher and menu. Notes: hanziHero lets the launcher / portal maintain a device signature reused by leaderboard entries; Godot now mirrors that with a persistent `玩家名帖` overlay backed by `user://leaderboard_identity.json`.
- `[done]` Theme toggle parity inside the menu layer. Notes: source launcher/menu surfaces share the remembered paper-ink theme; Godot Zihai menu and its overlays now inherit the same `夜墨 / 纸墨` preference and expose a matching top-bar toggle.
- `[pending]` Language toggle parity inside the menu layer. Notes: source menu can switch zh/en on the front portal; Godot menu still keeps the placeholder `EN` pill without runtime behavior.
- `[done]` Menu-side leaderboard build snapshots. Notes: hanziHero's menu leaderboard cards surface build lanes and kill mix; Godot menu leaderboard now appends `偏旁 / 成字 / 词技 / 击倒` 摘要 under each entry instead of stopping at flat score lines.
- `[pending]` More menu-side build and progression surfacing beyond leaderboard snapshots. Notes: source menu still carries broader descriptive cards and front-end polish; Godot menu remains more utilitarian outside the richer leaderboard view.

## Battle HUD

- `[done]` Pause overlay, restart / return actions, and local leaderboard access. Notes: hanziHero exposes pause plus result-side leaderboard views; Godot already supports pause and post-run naming/editing for local records.
- `[done]` Map modal with fog-of-war, drag, zoom, legend, and exploration summary. Notes: source has a modal map with zoom/drag/legend; Godot now has a close equivalent.
- `[done]` Mobile joystick, touch interact, pause button, and landscape guard. Notes: hanziHero mobile battle flow depends on these protections; Godot already has matching control coverage.
- `[done]` First runtime settings / LOD panel slice. Notes: Godot pause overlay now exposes a low-risk `战场布置` panel with remembered performance preset, enemy health bar toggle, and ambient glyph density controls, covering the first practical slice of hanziHero's settings modal.
- `[done]` Runtime settings follow-through for effect/detail parity. Notes: Godot pause overlay now remembers separate `视觉字效` and `远敌细节` toggles alongside the original preset slice, so decorative glyph bursts can be trimmed independently and distant enemy badges / health bars collapse back to a near-only read when detail is lowered.
- `[done]` Music track toast and soundtrack UI. Notes: hanziHero shows the active procedural track name and mood; Godot battle HUD now carries a matching `战场乐题` card plus a top-right `配乐提示` toast that reuses the source track names and mood text on key battle beats.
- `[done]` Phrase / event log panel. Notes: Godot battle HUD now keeps a dedicated `战报` panel that records wave pushes, realm shifts, boss beats, recipe/word upgrades, and pickup highlights, with a compact mobile-safe variant for smaller screens.
- `[pending]` Bilingual HUD copy. Notes: source battle UI can switch zh/en; Godot HUD remains Chinese-only.

## Combat Systems

- `[done]` Auto-attack survival loop with radical draft, recipe formation, and inkstone word grinding. Notes: source progression is "偏旁 -> 成字 -> 词技"; Godot already preserves that core loop.
- `[done]` Two-role hero split between ranged scholar and melee xia. Notes: hanziHero gives xia a close-range sword identity; Godot mirrors that distinction.
- `[done]` Enemy roster baseline with clear telegraphs. Notes: Godot already includes basic, swift, tank, archer, assassin, cavalry, ritualist, elite, and boss enemies with warning zones.
- `[done]` World-prop baseline for trees, bushes, inkstones, chests, stelae, scroll racks, and ink pools. Notes: the source battlefield is no longer an empty field; Godot already supports a comparable landmark layer.
- `[pending]` Phrase / idiom guardian encounters. Notes: hanziHero uses discovered sentences guarded by elites and tied rewards; Godot still uses static landmarks instead of guarded phrase events.
- `[pending]` Relic / artifact system. Notes: hanziHero treats relics as a second growth lane parallel to radicals; Godot chests currently drop only direct pickups.
- `[done]` Stage phase-shift themes. Notes: Godot now rotates every 4 waves through `碑林 / 墨潮 / 雷纹 / 残卷`, blends fog/ground/backdrop mood, and stamps giant lingering hanzi near the player when the realm shifts.
- `[pending]` Wider radical / recipe / word pool. Notes: hanziHero already has a broader content set; Godot currently centers on 明 / 休 / 海 plus blade growth.
- `[done]` Static `聚墨符 / 疾书令` battlefield pickups. Notes: hanziHero ships one-shot utility pickups for full-map ink recall and burst haste; Godot now has fixed battlefield placements with matching core effects.
- `[done]` Enemy-dropped utility pickup routing and `回春丹` parity. Notes: Godot elites / bosses can now seed `聚墨符 / 疾书令`, regular enemies can occasionally route those pickups back into the field, and a `回春丹` drop meter restores the source-style max-health recovery pickup instead of relying on static-only utility spawns.

## Progression

- `[done]` Local leaderboard persistence with player naming, hero, bosses, kills, radicals, recipes, words, and enemy counts. Notes: hanziHero already records local runs; Godot mirrors that in `user://local_leaderboard.json`.
- `[done]` Word-grind gating at the inkstone rather than passive auto-unlock. Notes: the source moved word skills behind an explicit station interaction; Godot follows that rule.
- `[done]` Dedicated test-run leaderboard view. Notes: hanziHero keeps separate main/test boards; Godot now records wave 10 / 20 shortcuts into a dedicated `试阵榜` while keeping wave 1 runs on the main board.
- `[pending]` Cloud leaderboard sync. Notes: hanziHero has online leaderboard plumbing; Godot only keeps local records today.
- `[pending]` Relic-aware build summary. Notes: source pause / result views include owned relic context; Godot cannot yet show that lane because relics are not ported.
- `[pending]` More map-event reward routing. Notes: source sentence discoveries can branch into different reward types; Godot progression currently stays in the core combat loop.

## Content

- `[done]` Character archive, recipe atlas, and enemy codex text live in shared session data. Notes: source uses compendium-style front panels; Godot already ships equivalent text-driven overlays.
- `[done]` Battlefield hero callouts and elite/boss taunt beats. Notes: hanziHero surfaces reactive frontline lines and enemy taunts in battle; Godot now mirrors that with a dedicated `战场呼应` card plus event-log entries for hero intro / recovery / milestone quotes and elite / boss entrance taunts.
- `[pending]` More menu/archive hero flavor follow-through. Notes: source still has denser character flavor and front-end reactions across the portal and compendium surfaces than Godot's current menu/archive panels.
- `[pending]` More narrative and educational copy parity from the launcher / about surface. Notes: source continues to frame the cultural motivation and bilingual-learning angle more broadly than Godot elsewhere.
- `[blocked]` Full `仓颉之路` Godot port. Notes: the web prototype is playable, but the Godot repo does not yet have the deckbuilder combat/map foundation needed for a safe direct migration.

## Polish

- `[done]` Tree fade-through, bush anti-abuse lockout, banners, and strong telegraph readability. Notes: Godot already carries several of the source combat-polish beats into 3D.
- `[pending]` Procedural music playback and current-track feedback. Notes: Godot now has the HUD-side track card and toast, but actual procedural playback / loop rotation is still missing.
- `[pending]` Higher-end hit/audio differentiation. Notes: hanziHero has more layered weapon/skill sound identity and lingering glyph afterimages; Godot feedback can be pushed further.
- `[done]` Themeable launcher/menu presentation. Notes: Godot launcher, about overlay, and Zihai menu now share the remembered `夜墨 / 纸墨` presentation; battle/HUD localization and broader downstream parity remain tracked separately.
- `[pending]` More stage spectacle for big unlocks and transitions. Notes: source leans harder into large character/word reveal moments and evolving battlefield mood.

## Export

- `[done]` Godot Web export script, export presets, and Vercel deployment path. Notes: the Godot repo already has a direct replacement for the web repo's static hosting flow.
- `[done]` Root README documentation for export overrides and deployment expectations. Notes: recent README maintenance now matches the current `scripts/export_web.sh` behavior.
- `[done]` Automated scene smoke checks in repo scripts. Notes: `scripts/smoke_test_scenes.sh` now imports assets, runs every `scenes/*.tscn` headlessly with an isolated temp runtime/log path, and catches startup-time errors before export.

## Technical Debt

- `[done]` Long-lived migration tracking in repo root. Notes: `MIGRATION_CHECKLIST.md` remains the source of truth and now has a matching long-lived GitHub tracker issue for checklist/body sync instead of one-off progress issues.
- `[pending]` Shared localization layer for launcher, menu, and battle UI. Notes: hanziHero already centralizes zh/en strings; Godot will need a similar data layer before toggles are practical.
- `[pending]` Break up `scripts/battle/zihai_battle.gd` into smaller systems. Notes: source JS has already started splitting combat/rendering/data concerns; Godot battle logic is still concentrated in one large script.
- `[pending]` Move launcher / menu content into data-driven definitions. Notes: current Godot UI is built inline in GDScript; data-backed cards would make future theme and language parity safer.
