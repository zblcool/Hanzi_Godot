extends RefCounted

const LAUNCHER_TOP_ACTIONS := [
	{"kind": "action", "title": "玩家名帖", "size": Vector2(152.0, 54.0), "action": "show_profile"},
	{"kind": "action", "title": "关于字海", "size": Vector2(136.0, 54.0), "action": "show_about"},
	{"kind": "theme_toggle", "size": Vector2(94.0, 54.0)},
	{"kind": "language_toggle", "size": Vector2(78.0, 54.0)}
]

const LAUNCHER_MOBILE_INFO_PANELS := [
	{
		"title": "微信内打开",
		"lines": [
			"如果是微信内置浏览器，尽量切到系统浏览器再进入。",
			"这样更容易拿到稳定的全屏、音频和触控体验。"
		],
		"accent": Color(0.5, 0.88, 0.66, 1.0)
	},
	{
		"title": "iPhone / iPad",
		"lines": [
			"可以用“分享 -> 添加到主屏幕”把启动器放到桌面。",
			"主屏幕入口会更接近独立应用的打开方式。"
		],
		"accent": Color(0.52, 0.8, 1.0, 1.0)
	}
]

const LAUNCHER_GAME_CARDS := [
	{
		"title": "字海残卷",
		"badge_text": "Action Roguelite",
		"tagline": "在墨阵里活下去，把偏旁一步步磨成成字与词技。",
		"tags": ["3D 自动战斗", "偏旁三选一", "合字 -> 磨词"],
		"accent": Color(0.92, 0.54, 0.28, 1.0),
		"preview_kind": "zihai",
		"button_text": "进入字海残卷",
		"action": "enter_zihai",
		"enabled": true
	},
	{
		"title": "仓颉之路",
		"badge_text": "Deckbuilder Climb",
		"tagline": "把字形拆解、语义路线和出牌构筑压进同一条爬塔曲线。",
		"tags": ["卡牌构筑", "字形拼装", "后续迁移"],
		"accent": Color(0.38, 0.58, 0.9, 1.0),
		"preview_kind": "cangjie",
		"button_text": "进入仓颉入口",
		"action": "show_cangjie_portal",
		"enabled": true
	}
]

const LAUNCHER_ROADMAP_INFO_PANELS := [
	{
		"title": "迁移阶段",
		"lines": [
			"入口 -> 二级菜单 -> 战斗 的层级已经稳定。",
			"字海残卷保持 3D 俯视角，不回退到纯占位原型。",
			"敌人轮廓、字核和 UI 正在向 web 端气质统一。"
		],
		"accent": Color(0.92, 0.68, 0.4, 1.0)
	},
	{
		"title": "当前目标",
		"lines": [
			"把偏旁、合字、词技做成真正的成长主线。",
			"让战斗里的字、墨、纸和敌人轮廓属于同一世界。",
			"把菜单和 HUD 提到可展示、可录像的完成度。"
		],
		"accent": Color(0.38, 0.74, 0.84, 1.0)
	}
]

const LAUNCHER_ABOUT_CONTENT := {
	"tag": "About The Games",
	"title": "关于汉字工坊",
	"summary": "这里先讲清这款游戏为什么会被做出来，再继续介绍当前已经迁进 Godot 的部分，以及还留在 web 原型里的目标。",
	"story_title": "为什么做这两款游戏",
	"story_paragraphs": [
		"作为生活在海外的中国人，多种文化之间的碰撞与交流，让我重新看见自己的母语。汉字像古老而仍然鲜活的图画，从甲骨文到小篆、从繁体到简体，每一次演变都藏着故事，也延续着几千年的文化脉络。",
		"一直以来，我都想做一款和中文有关的游戏。直到孩子出生，这个念头变得更具体了。身处英语环境，我开始更认真地想：能不能用游戏去点燃他，也点燃更多孩子，对汉字与中华文化的兴趣？对我来说，这既是一次实验，也是一个父亲的愿望。",
		"这个项目会持续借助 AI 参与开发，但归根结底，它更像是一封写给汉字、写给中文文化的情书。现在 Godot 主线先把《字海残卷》的启动器、二级菜单和 3D 战斗接牢，再继续把 web 原型里更完整的内容一项项迁回来。"
	],
	"games": [
		{
			"kicker": "Action Roguelite",
			"title": "字海残卷",
			"copy": "自动攻击、生存走位、偏旁合字、词技磨成与字阵地图。像幸存者类，但核心成长来自汉字结构和语义。",
			"points": ["偏旁收集、合字成技、词技进阶", "波次、关键怪、卷主、地图地标", "移动端横屏保护与战斗适配"],
			"accent": Color(0.92, 0.54, 0.28, 1.0),
			"preview_kind": "zihai"
		},
		{
			"kicker": "Deckbuilder Climb",
			"title": "仓颉之路",
			"copy": "类杀戮尖塔的卡牌爬塔原型。每张牌同时是战斗动作与汉字学习卡，字形、语义和组合路线都能进入构筑。",
			"points": ["地图节点、卡牌战斗、奖励选牌", "中英双语辅助，更适合非中文母语玩家", "当前仍在 web 原型，等待 Godot 迁入"],
			"accent": Color(0.38, 0.58, 0.9, 1.0),
			"preview_kind": "cangjie"
		}
	],
	"notes": [
		{"title": "面向谁", "body": "不仅面向中文母语者，也面向中文学习者、教育者，以及想通过游戏认识汉字结构、字义和词感的玩家。", "accent": Color(0.92, 0.68, 0.4, 1.0)},
		{"title": "适合传播", "body": "先保留浏览器可试玩 demo，更适合在中文学习社区、独立游戏圈和语言社群里直接分享与验证。", "accent": Color(0.74, 0.56, 0.94, 1.0)},
		{"title": "迁移重点", "body": "Godot 主线优先补齐启动器、菜单、HUD 和战斗成长链，再追赶 web 端的音乐、设置、双语和仓颉玩法。", "accent": Color(0.38, 0.74, 0.84, 1.0)},
		{"title": "下一步产品化", "body": "先把 Godot 版做成稳定可展示的 vertical slice，验证玩法和学习体验，再决定哪些角色、卡组、塔层与字阵系统进入完整版本。", "accent": Color(0.58, 0.84, 0.62, 1.0)}
	],
	"close_text": "返回启动器"
}

const LAUNCHER_UPDATE_SPOTLIGHT := {
	"eyebrow": "Update History",
	"title": "启动器更新日志入口已补齐",
	"summary": "Godot 启动器首页现在既保留最近更新聚光卡，也能直接打开内置更新历史面板，继续向 web 原型首页的 changelog panel 对齐。",
	"meta": ["2026-03-22", "Godot 启动器", "更新日志"],
	"highlights": [
		"首页“最近更新”卡现在可以直接展开最近几次迁移里程碑，不再只停在单条快照。",
		"前台已补齐主题联动、玩家名帖与场景 smoke 检查，近期推进可以留在同一层里回看。",
		"启动器层剩余更大的缺口仍是双语切换与仓颉入口接入。"
	],
	"footnote": "完整长期追踪仍以仓库根目录的 MIGRATION_CHECKLIST 为准。"
}

const LAUNCHER_CHANGELOG_HISTORY := [
	{
		"date": "2026-03-22",
		"title": "启动器更新日志面板接回首页",
		"summary": "Godot 首页现在既保留最近更新聚光卡，也能展开内置更新历史面板，直接回看最近几次迁移里程碑。",
		"meta": ["Godot 启动器", "迁移前台", "Launcher"],
		"sections": [
			{
				"label": "新增",
				"items": [
					"首页最近更新卡新增“查看更新记录”入口，可以直接展开最近几次 Godot 迁移快照。",
					"启动器内置更新面板会滚动列出近期完成项，让 changelog 入口不再只存在于仓库文件里。"
				]
			},
			{
				"label": "同步",
				"items": [
					"近期的主题联动、玩家名帖、战场乐题提示和 utility 掉落迁移成果都被收进同一条前台历史里。",
					"继续对齐 hanziHero web 启动器里的 changelog panel 角色，但先保留当前 Godot 单语结构。"
				]
			},
			{
				"label": "下一步",
				"items": [
					"启动器剩余更大的缺口仍是双语切换与仓颉入口接入。",
					"如果继续做前台层，小而稳的下一步更适合补菜单侧的 build / progression 展示。"
				]
			}
		]
	},
	{
		"date": "2026-03-21",
		"title": "字海菜单层与排行榜署名链路接稳",
		"summary": "Godot 主线把启动器后的字海二级菜单、局外资料面板和本地排行榜署名链路接成了更完整的一段 vertical slice。",
		"meta": ["菜单层", "排行榜", "Vertical Slice"],
		"sections": [
			{
				"label": "新增",
				"items": [
					"补上人物志、合字图谱、怪物图鉴和本地排行榜这些字海二级菜单 overlays。",
					"启动器和菜单都能维护玩家名帖，后续结算页留空时会自动复用默认署名。"
				]
			},
			{
				"label": "打磨",
				"items": [
					"移动端战斗入口、暂停和小屏 UI 进一步压实，不再只是桌面演示。",
					"场景 smoke 检查、README 与迁移清单开始持续跟着当前主线一起维护。"
				]
			}
		]
	},
	{
		"date": "2026-03-20",
		"title": "首个 Godot 字海可玩切片成型",
		"summary": "Godot 仓库完成了启动器、菜单、3D 战斗、地图、导出与移动端守护的第一轮闭环，字海残卷开始脱离占位原型。",
		"meta": ["3D 战斗", "Web 导出", "移动端"],
		"sections": [
			{
				"label": "新增",
				"items": [
					"搭出 Godot 版启动器、字海战斗原型、地图 modal、暂停层和移动端横屏保护。",
					"接通 Web 导出脚本、Vercel 部署路径，以及基础本地排行榜存档。"
				]
			},
			{
				"label": "系统",
				"items": [
					"敌人谱系、宝箱与场景道具、波次推进和核心偏旁成长链路开始在 Godot 内成型。",
					"Launcher -> 字海菜单 -> 3D 战斗 的仓库主线从这一天开始可持续迭代。"
				]
			}
		]
	}
]

const CANGJIE_PORTAL_SECTIONS := [
	{
		"id": "start_climb",
		"title": {"zh": "起笔登塔", "en": "Start Climb"},
		"eyebrow": "Tower Entry",
		"accent": Color(0.9, 0.68, 0.38, 1.0),
		"summary": {
			"zh": "source portal 不只是一张静态卡片，它会先说明为什么这条线暂不做人物选择、真正的差异来自哪里，以及双语学习辅助要怎么读。",
			"en": "The source portal is more than a static card. It explains why the climb skips hero select for now, where run variety really comes from, and how the bilingual learning assist should be read."
		},
		"points": [
			{
				"zh": "当前 source 先固定一名登塔者，真正的变化更多来自牌组路线、遗物和节点抉择。",
				"en": "The current source fixes one climber first, so most variation comes from deck lines, relics, and node choices."
			},
			{
				"zh": "英文模式会同时保留汉字、拼音和义项，方便非中文母语玩家边打边认字。",
				"en": "English mode keeps hanzi, pinyin, and gloss together so non-native readers can learn while climbing."
			},
			{
				"zh": "Godot 端先把这段入口说明迁回启动器，等卡牌战斗基础成熟后再接真实开局。",
				"en": "The Godot branch brings this entry framing back into the launcher first, then wires a real run start once the card-combat foundation is ready."
			}
		],
		"duel_preview": {
			"title": {"zh": "舞台对峙", "en": "Stage Faceoff"},
			"summary": {
				"zh": "source《仓颉之路》入口不会只停在文案，它还会给一小段可交互的对峙舞台，点按双方就会抖动并吐出一句回应。",
				"en": "The source Cangjie Road portal does not stop at copy alone. It also gives a small interactive faceoff stage where each duelist shakes and answers when tapped."
			},
			"hint": {
				"zh": "点按左右执牌者，预览 source 的开场回应；`3D 特效` 会收束或放开舞台辉光。",
				"en": "Tap either duelist to preview the source opening banter. `3D Effects` tightens or opens the stage glow."
			},
			"fx_button": {"zh": "3D 特效", "en": "3D Effects"},
			"fx_state_on": {"zh": "舞台辉光开启", "en": "Stage glow enabled"},
			"fx_state_off": {"zh": "舞台辉光收束", "en": "Stage glow reduced"},
			"duelists": [
				{
					"id": "hero",
					"glyph": "仓",
					"tone": Color(0.92, 0.68, 0.38, 1.0),
					"kicker": {"zh": "登塔者", "en": "Climber"},
					"title": {"zh": "字路执笔", "en": "Glyph Route"},
					"primary": {
						"zh": "先读塔路，再决定把哪条字线真正推成主牌组。",
						"en": "Read the route first, then decide which character line becomes the real deck."
					},
					"secondary": {
						"zh": "学习辅助要跟着塔路一起露出来，而不是进战后才补一句英文。",
						"en": "Learning assist should surface with the route framing instead of appearing only after battle starts."
					},
					"responses": [
						{
							"zh": "这一层先看节点，不急着把手牌全交出去。",
							"en": "Read the nodes first. No need to cash every card in immediately."
						},
						{
							"zh": "若要走学读线，拼音和义项要跟着一起露出来。",
							"en": "If the run leans into learning assist, pinyin and gloss should stay visible too."
						}
					]
				},
				{
					"id": "enemy",
					"glyph": "妄",
					"tone": Color(0.48, 0.74, 0.96, 1.0),
					"kicker": {"zh": "敌方", "en": "Enemy"},
					"title": {"zh": "残页守望者", "en": "Fragment Sentinel"},
					"primary": {
						"zh": "真正进战后才会亮出敌意与压迫节奏。",
						"en": "Intent and pressure only fully show once the duel actually starts."
					},
					"secondary": {
						"zh": "你若只看字面，不看节点，这层塔会先吞掉你的节奏。",
						"en": "If you read only the glyph and ignore the route, the tower will eat your tempo first."
					},
					"responses": [
						{
							"zh": "这层塔先考你何时定下主线，不只是考伤害。",
							"en": "This floor first tests when you commit to a line, not only how much damage you can deal."
						},
						{
							"zh": "等你真正起笔时，我的敌意才会完整亮出来。",
							"en": "My full intent only lights up once you truly start the climb."
						}
					]
				}
			]
		},
		"sample_groups": [
			{
				"title": {"zh": "入口预览", "en": "Entry Preview"},
				"cards": [
					{
						"glyph": "塔",
						"title": {"zh": "从底层起笔", "en": "Begin At The Base"},
						"subtitle": {"zh": "单角色主线", "en": "One-core climber"},
						"body": {
							"zh": "先不上人物选择，差异先交给路线、遗物和节点。",
							"en": "Hero select stays out for now so route, relic, and node choices define the run first."
						},
						"tags": [
							{"zh": "主线入口", "en": "Main entry"},
							{"zh": "路线差异", "en": "Route variance"}
						]
					},
					{
						"glyph": "文",
						"title": {"zh": "双语学读", "en": "Bilingual Read"},
						"subtitle": {"zh": "汉字 + 拼音 + 义项", "en": "Hanzi + pinyin + gloss"},
						"body": {
							"zh": "入口文案会把学习辅助说清楚，而不只是在战斗里临时出现英文。",
							"en": "The entry copy frames the learning assist up front instead of dropping English in only during battle."
						},
						"tags": [
							{"zh": "学习辅助", "en": "Learning assist"},
							{"zh": "前台说明", "en": "Front-end framing"}
						]
					},
					{
						"glyph": "路",
						"title": {"zh": "路线先行", "en": "Route First"},
						"subtitle": {"zh": "牌组 / 遗物 / 节点", "en": "Deck / relic / nodes"},
						"body": {
							"zh": "先读塔路，再决定把哪条合字线真正推成主牌组。",
							"en": "Read the tower route first, then decide which character line deserves to become the real deck spine."
						},
						"tags": [
							{"zh": "路线判断", "en": "Route read"},
							{"zh": "构筑方向", "en": "Build line"}
						]
					}
				]
			}
		]
	},
	{
		"id": "card_codex",
		"title": {"zh": "卡牌字库", "en": "Card Codex"},
		"eyebrow": "Card Codex",
		"accent": Color(0.46, 0.72, 0.88, 1.0),
		"summary": {
			"zh": "web 原型已经把牌分成偏旁基牌、合字牌和引擎牌三层，不是单一数值卡堆。",
			"en": "The web prototype already splits cards into radical starters, formed-character cards, and engine pieces instead of one flat stack of numbers."
		},
		"points": [
			{
				"zh": "偏旁牌负责起手和过渡，是后续合字路线的材料层。",
				"en": "Radical cards handle the opener and bridge turns, acting as the material layer for later fusions."
			},
			{
				"zh": "合字牌会把结构真正写成战斗效果，让“组字”变成卡组成长的一部分。",
				"en": "Fusion cards turn structure into combat effects, so assembling characters becomes part of deck growth."
			},
			{
				"zh": "引擎牌继续推进抽牌、留牌、墨流或连锁，让 deckbuilder 身份成立。",
				"en": "Engine cards keep draw, retention, Ink flow, or chaining alive so the deckbuilder identity holds."
			}
		],
		"sample_groups": [
			{
				"title": {"zh": "源稿样张", "en": "Source Samples"},
				"cards": [
					{
						"glyph": "日",
						"title": {"zh": "日 · 起手偏旁", "en": "日 · Sun Trace"},
						"subtitle": {"zh": "偏旁起手", "en": "Radical opener"},
						"body": {
							"zh": "先用直白伤害起手，并把「明」这条线写进牌库。",
							"en": "Open with clean damage and seed the 明 line into the deck early."
						},
						"tags": [
							{"zh": "偏旁", "en": "Radical"},
							{"zh": "铺垫", "en": "Setup"}
						]
					},
					{
						"glyph": "明",
						"title": {"zh": "明 · 节奏成字", "en": "明 · Tempo Fusion"},
						"subtitle": {"zh": "日 + 月", "en": "Sun + moon"},
						"body": {
							"zh": "成型后同时补伤害、抽牌和墨流，是很标准的节奏成字。",
							"en": "Once formed it supplies damage, draw, and Ink flow together, making it a classic tempo fusion."
						},
						"tags": [
							{"zh": "成字", "en": "Fusion"},
							{"zh": "节奏", "en": "Tempo"}
						]
					},
					{
						"glyph": "学",
						"title": {"zh": "学 · 抽墨引擎", "en": "学 · Study Thread"},
						"subtitle": {"zh": "引擎牌", "en": "Engine card"},
						"body": {
							"zh": "抽 2 并补 1 墨，提醒这条线不只有合字，还有真正维持牌组运转的引擎牌。",
							"en": "Draw 2 and gain 1 Ink, showing the line needs real engine cards instead of only fusions."
						},
						"tags": [
							{"zh": "引擎", "en": "Engine"},
							{"zh": "抽墨", "en": "Draw + Ink"}
						]
					}
				]
			}
		]
	},
	{
		"id": "fusion_atlas",
		"title": {"zh": "合字图谱", "en": "Fusion Atlas"},
		"eyebrow": "Fusion Atlas",
		"accent": Color(0.74, 0.82, 0.46, 1.0),
		"summary": {
			"zh": "《仓颉之路》不是只把汉字当皮肤，而是把合字路线直接做成牌组构筑图谱。",
			"en": "Cangjie Road does not use hanzi as skin only. It turns fusion routes into a deckbuilding atlas."
		},
		"points": [
			{
				"zh": "不同合字路线会决定你这次爬塔偏向爆发、连锁、续航还是控制。",
				"en": "Different fusion routes decide whether a climb leans into burst, chains, sustain, or control."
			},
			{
				"zh": "图谱层会比字海残卷更强调“先收什么，再往哪条组合线转”。",
				"en": "This atlas layer cares more than Ink-Sea about what you collect first and which combination line you pivot into."
			},
			{
				"zh": "Godot 当前已经有字海的偏旁 -> 合字 -> 词技主线，后面可以把这套图谱思路反向迁回来。",
				"en": "Godot already has the Ink-Sea radical -> glyph -> phrase loop, so this atlas logic can later migrate back in the other direction."
			}
		],
		"sample_groups": [
			{
				"title": {"zh": "路线样例", "en": "Route Samples"},
				"cards": [
					{
						"glyph": "明",
						"title": {"zh": "明 · 节奏线", "en": "Bright · Tempo Line"},
						"subtitle": {"zh": "日 + 月", "en": "Sun + moon"},
						"body": {
							"zh": "补格挡、抽牌和墨流，适合作为标准中速节奏主线。",
							"en": "Adds Block, draw, and Ink flow, making it a clean mid-speed tempo spine."
						},
						"tags": [
							{"zh": "节奏", "en": "Tempo"},
							{"zh": "中速", "en": "Mid-speed"}
						]
					},
					{
						"glyph": "雷",
						"title": {"zh": "雷 · 控爆线", "en": "Thunder · Control Burst"},
						"subtitle": {"zh": "雨 + 田", "en": "Rain + field"},
						"body": {
							"zh": "更偏进攻与控制，适合把易伤和爆发串成一条线。",
							"en": "Leans into attack and control, especially when chaining Vulnerable into burst."
						},
						"tags": [
							{"zh": "控制", "en": "Control"},
							{"zh": "爆发", "en": "Burst"}
						]
					},
					{
						"glyph": "休",
						"title": {"zh": "休 · 稳健线", "en": "Rest · Sustain Line"},
						"subtitle": {"zh": "人 + 木", "en": "Human + wood"},
						"body": {
							"zh": "把抽牌、防御和续航缝在一起，更像能扛中层压力的慢线。",
							"en": "Stitches draw, defense, and sustain together into a steadier line that can absorb mid-floor pressure."
						},
						"tags": [
							{"zh": "续航", "en": "Sustain"},
							{"zh": "稳健", "en": "Steady"}
						]
					}
				]
			}
		]
	},
	{
		"id": "relic_shelf",
		"title": {"zh": "遗物架", "en": "Relic Shelf"},
		"eyebrow": "Relic Shelf",
		"accent": Color(0.88, 0.58, 0.62, 1.0),
		"summary": {
			"zh": "web 原型里《仓颉之路》有独立遗物层，负责给整套牌组和路线额外偏转。",
			"en": "The web prototype gives Cangjie Road an independent relic layer that can bend both the deck and the route."
		},
		"points": [
			{
				"zh": "遗物不会只加一点基础数值，而是会改变抽牌、留牌、字形连锁和节点选择价值。",
				"en": "Relics matter less because they add flat stats and more because they reshape draw, retention, combo value, and node choices."
			},
			{
				"zh": "这条系统也正是 Godot 《字海残卷》当前还缺的第二成长线之一。",
				"en": "This is also one of the big second growth lanes still missing from Godot Ink-Sea."
			},
			{
				"zh": "先把遗物架的说明和样例放回启动器，会更容易衔接后续真正的系统迁移。",
				"en": "Putting the relic shelf framing and examples back into the launcher makes later system migration easier to stage safely."
			}
		],
		"sample_groups": [
			{
				"title": {"zh": "遗物样例", "en": "Relic Samples"},
				"cards": [
					{
						"glyph": "砚",
						"title": {"zh": "砚 · 开局多抽", "en": "Inkstone · Opening Draw"},
						"subtitle": {"zh": "战斗起手", "en": "Battle opener"},
						"body": {
							"zh": "每场战斗开局多抽 1，让慢线更快碰到关键偏旁与成字。",
							"en": "Draw 1 extra card at the start of each battle so slower lines reach key radicals and fusions sooner."
						},
						"tags": [
							{"zh": "起手抽牌", "en": "Opening draw"},
							{"zh": "节奏提速", "en": "Tempo boost"}
						]
					},
					{
						"glyph": "镜",
						"title": {"zh": "镜 · 重复返抽", "en": "Mirror Slip · Repeat Draw"},
						"subtitle": {"zh": "重复偏旁", "en": "Repeated radical"},
						"body": {
							"zh": "每回合第一次打出重复偏旁时抽 1，直接改写你对重复材料的价值判断。",
							"en": "The first repeated radical each turn draws 1, directly changing how valuable duplicate material feels."
						},
						"tags": [
							{"zh": "重复利用", "en": "Repeat use"},
							{"zh": "资源再估值", "en": "Revalue resources"}
						]
					},
					{
						"glyph": "契",
						"title": {"zh": "契 · 商店折扣", "en": "Broker Seal · Shop Cut"},
						"subtitle": {"zh": "牌 / 遗物更便宜", "en": "Cheaper cards / relics"},
						"body": {
							"zh": "让路线能更激进，也更愿意在买牌、买遗物和修薄之间重新分配 Gold。",
							"en": "Makes routes greedier and shifts how willingly you spend Gold on cards, relics, or thinning."
						},
						"tags": [
							{"zh": "商店", "en": "Shop"},
							{"zh": "路线偏转", "en": "Route bend"}
						]
					}
				]
			}
		]
	},
	{
		"id": "post_battle_flow",
		"title": {"zh": "战后抉择", "en": "Post-Battle Flow"},
		"eyebrow": "Reward Route",
		"accent": Color(0.94, 0.74, 0.42, 1.0),
		"summary": {
			"zh": "source《仓颉之路》每场战斗后都会继续给 Gold、选牌和精英 / Boss 遗物，不是打一场就线性前进。",
			"en": "The source Cangjie Road keeps chaining Gold, card rewards, and elite or boss relic follow-through after fights instead of moving forward in a straight line."
		},
		"points": [
			{
				"zh": "普通战斗胜利后会先拿 Gold，再从奖励牌里挑 1 张，或者跳过来保持牌组更薄。",
				"en": "Regular fights pay Gold first, then offer a card reward that can also be skipped to keep the deck leaner."
			},
			{
				"zh": "精英和 Boss 会在选牌之后继续给 2 到 3 件遗物，让战后路线被二次改写。",
				"en": "Elites and bosses continue with 2 to 3 relic choices after the card reward, bending the route a second time."
			},
			{
				"zh": "先把这段战后链路讲清楚，Godot 入口就不只是在展示静态牌样，而是在说明一局怎么越爬越偏向某条字路。",
				"en": "Bringing this reward chain back into the launcher helps the Godot portal explain how a run keeps leaning harder into one character line instead of only showing static card samples."
			}
		],
		"sample_groups": [
			{
				"title": {"zh": "奖励链路", "en": "Reward Loop"},
				"cards": [
					{
						"glyph": "赏",
						"title": {"zh": "战后选牌", "en": "Post-Battle Draft"},
						"subtitle": {"zh": "Gold + 三选一", "en": "Gold + pick one of three"},
						"body": {
							"zh": "每场战斗先结算 Gold，再从三张候选里补 1 张，路线会在这里被慢慢写厚。",
							"en": "Each fight settles Gold first, then adds one card from three choices, slowly thickening the route here."
						},
						"tags": [
							{"zh": "战后收益", "en": "Post-fight gain"},
							{"zh": "路线加厚", "en": "Route growth"}
						]
					},
					{
						"glyph": "简",
						"title": {"zh": "跳过保薄", "en": "Skip To Stay Lean"},
						"subtitle": {"zh": "少拿一张牌", "en": "Take nothing here"},
						"body": {
							"zh": "source 明确允许跳过奖励，让“更干净的抽牌质量”本身成为一个有效选择；算盘类遗物还会把这步转成额外 Gold。",
							"en": "The source explicitly allows reward skips so cleaner draw quality stays a valid choice, and abacus-style relics can even turn that skip into extra Gold."
						},
						"tags": [
							{"zh": "精简", "en": "Lean deck"},
							{"zh": "取舍", "en": "Tradeoff"}
						]
					},
					{
						"glyph": "匣",
						"title": {"zh": "战后遗物", "en": "Post-Battle Relic"},
						"subtitle": {"zh": "精英 / Boss 跟进", "en": "Elite / boss follow-up"},
						"body": {
							"zh": "精英和 Boss 不只掉更多奖励，还会在选牌后补一轮遗物，让后续节点与牌张估值一起偏转。",
							"en": "Elites and bosses do more than drop larger rewards; they add a relic follow-up after the card pick so future nodes and card values bend together."
						},
						"tags": [
							{"zh": "遗物链路", "en": "Relic chain"},
							{"zh": "二次偏转", "en": "Second bend"}
						]
					}
				]
			}
		]
	},
	{
		"id": "tower_guide",
		"title": {"zh": "塔路导览", "en": "Tower Guide"},
		"eyebrow": "Tower Guide",
		"accent": Color(0.66, 0.68, 0.94, 1.0),
		"summary": {
			"zh": "原型里塔路节点和敌人意图已经是独立设计，不只是打完一场接一场的线性战斗。",
			"en": "In the prototype, tower nodes and enemy intents are already their own design layer instead of one linear fight after another."
		},
		"points": [
			{
				"zh": "路线会混合战斗、恢复、事件和构筑节点，逼你在短期强度和长期牌组之间做取舍。",
				"en": "Routes mix battles, rests, events, and build nodes, forcing tradeoffs between short-term power and long-term deck shape."
			},
			{
				"zh": "敌人不是字海那种大群追击，而是更接近回合制对局里的意图压迫和节奏管理。",
				"en": "Enemies do not pressure like Ink-Sea swarms. They lean closer to turn-based intent reading and tempo management."
			},
			{
				"zh": "Godot 端先把路线、节点和敌意图整理清楚，避免第二项目继续只剩一张静态卡片。",
				"en": "The Godot launcher now stages routes, nodes, and enemy intent clearly so the second project stops reading like a single static card."
			}
		],
		"sample_groups": [
			{
				"title": {"zh": "节点类型", "en": "Node Types"},
				"cards": [
					{
						"glyph": "战",
						"title": {"zh": "战斗", "en": "Battle"},
						"subtitle": {"zh": "稳定读牌组", "en": "Read the deck steadily"},
						"body": {
							"zh": "最稳定地拿牌、拿 Gold，也是在前几层读自己主线最直接的地方。",
							"en": "The steadiest place to gain cards and Gold, and to learn what line the deck is really on."
						},
						"tags": [
							{"zh": "拿牌", "en": "Cards"},
							{"zh": "Gold", "en": "Gold"}
						]
					},
					{
						"glyph": "魁",
						"title": {"zh": "精英", "en": "Elite"},
						"subtitle": {"zh": "高风险高定向", "en": "High risk, high direction"},
						"body": {
							"zh": "更危险，但也更容易把构筑真正推向某个方向。",
							"en": "Riskier, but much more likely to push the build into a real direction."
						},
						"tags": [
							{"zh": "方向锁定", "en": "Direction lock"},
							{"zh": "高压", "en": "Pressure"}
						]
					},
					{
						"glyph": "宝",
						"title": {"zh": "遗物", "en": "Treasure"},
						"subtitle": {"zh": "改写后续 pick", "en": "Rewrite future picks"},
						"body": {
							"zh": "真正改变牌张价值判断的节点，经常会让你改写后续奖励顺序。",
							"en": "The node that most often changes how future cards are valued, not just a bigger number room."
						},
						"tags": [
							{"zh": "遗物节点", "en": "Relic node"},
							{"zh": "后续偏转", "en": "Future bend"}
						]
					}
				]
			},
			{
				"title": {"zh": "敌意样本", "en": "Enemy Samples"},
				"cards": [
					{
						"glyph": "妄",
						"title": {"zh": "妄墨徒", "en": "Mad Ink Acolyte"},
						"subtitle": {"zh": "污染 / 基础压血", "en": "Smudge / chip pressure"},
						"body": {
							"zh": "会在普通攻击和污染抽牌之间切换，逼你更认真看前期节奏。",
							"en": "Swaps between regular attacks and dirtying your draws, forcing more careful early tempo reads."
						},
						"tags": [
							{"zh": "战斗层", "en": "Battle floor"},
							{"zh": "前期压力", "en": "Early pressure"}
						]
					},
					{
						"glyph": "劫",
						"title": {"zh": "劫文兽", "en": "Calamity Script Beast"},
						"subtitle": {"zh": "吸血 / 污染 / 爆发", "en": "Drain / smudge / burst"},
						"body": {
							"zh": "半成型回合很难回答它，必须把控制、防御和兑现一起写清楚。",
							"en": "Half-built turns stop being enough, so the deck must answer with cleaner control, defense, and payoff."
						},
						"tags": [
							{"zh": "精英层", "en": "Elite floor"},
							{"zh": "综合试压", "en": "Mixed exam"}
						]
					},
					{
						"glyph": "渊",
						"title": {"zh": "卷渊之主", "en": "Lord Of The Abyssal Scroll"},
						"subtitle": {"zh": "长回合耐压", "en": "Long-form pressure"},
						"body": {
							"zh": "会把蓄势、连击、污染和重击串成塔顶总检验，要求整副牌都站得住。",
							"en": "It chains charges, multi-hits, smudges, and heavy blows into a summit exam for the whole deck."
						},
						"tags": [
							{"zh": "Boss", "en": "Boss"},
							{"zh": "综合检验", "en": "Full build check"}
						]
					}
				]
			}
		]
	}
]

const LAUNCHER_CHANGELOG_CONTENT := {
	"tag": "Update History",
	"title": "更新日志",
	"summary": "首页最近更新卡现在会把近期 Godot 迁移里程碑一并展开，方便直接对照前台推进节奏。",
	"footnote": "完整变更记录仍保留在仓库根目录 CHANGELOG.md；长期迁移状态仍以 MIGRATION_CHECKLIST.md 为准。",
	"close_text": "返回启动器"
}

const LAUNCHER_PROFILE_CONTENT := {
	"tag": "Player Sigil",
	"title": "玩家名帖",
	"summary": "像 web 原型那样，为这台设备保存默认排行榜署名。结算页里留空时，后续战绩会直接复用这里的名字。",
	"preview_title": "当前署名",
	"name_field_title": "默认排行榜署名",
	"save_text": "保存署名",
	"reset_text": "恢复默认",
	"close_text": "返回启动器"
}

const MENU_PAGE_CONTENT := {
	"header_eyebrow": "INK-BORN ROGUELITE",
	"header_title": "字海残卷",
	"header_summary": "先进入残卷，再决定谁来执笔。每名角色都会把同一套偏旁系统，写成完全不同的战斗节奏。",
	"hero_section_title": "可选执笔者",
	"hero_card_title_format": "%s  ·  %s",
	"detail_heading": "当前执笔",
	"detail_title": "执笔者档案",
	"detail_archive_hint": "长说明和 build 路线请看人物志与图谱。",
	"detail_preview_eyebrow": "执笔映像",
	"detail_preview_source_format": "出处 · %s",
	"detail_role_format": "%s  ·  %s",
	"detail_weapon_format": "当前执笔节奏：%s",
	"reaction_title": "执笔回应",
	"opening_title": "起笔落点",
	"source_skill_title": "源稿字技（待迁移）",
	"source_skill_note": "当前只在菜单里保留 hanziHero 的字技预览，Godot 战斗内仍未接入独立主动输入。",
	"progression_title": "残卷路线",
	"progression_summary": "把开卷补笔、中盘续写与砚台磨词顺序先记住，进入战斗后更容易判断本轮 build 该补哪一笔。",
	"progression_note": "当前只先保留 web 原型的 build 顺序与路线提示，Godot 战斗内还没有真正的路线权重修正。",
	"build_route_title": "源稿构筑方向",
	"build_route_summary": "把 web 原型里更偏向的构筑方向先压缩成菜单预览，连同源稿词技 / 遗物搭配一起放在开局前参考。",
	"build_route_note": "当前只负责前台提示：源稿词技 / 遗物搭配还没有接回 Godot 战斗掉落或路线权重。",
	"stats_title": "战斗轮廓",
	"quick_start_title": "快速试阵",
	"quick_start_summary": "对照 web 原型保留第 10 / 20 波捷径，便于快速检查 HUD、混编敌潮与角色 build。试阵入口会单独写入试阵榜，不影响主卷榜。",
	"secondary_access_title": "二级入口与试阵",
	"secondary_access_note": "长说明移到人物志与图谱；这里保留快速进入与测试入口。",
	"selection_note": "选择界面只保留短摘要和关键属性，更长的角色说明移到次级菜单。",
	"secondary_archive_button": "人物志",
	"secondary_atlas_button": "合字图谱",
	"detail_stat_mobility": "机动",
	"detail_stat_vitality": "气血",
	"detail_stat_damage": "伤害",
	"detail_stat_range": "射程",
	"detail_stat_attack_rate": "攻速",
	"detail_stat_pickup": "拾取",
	"detail_stat_move_speed_value_format": "%.1f",
	"detail_stat_max_health_value_format": "%.0f",
	"detail_stat_attack_damage_value_format": "%.0f",
	"detail_stat_attack_range_value_format": "%.1f",
	"detail_stat_attack_rate_value_format": "%.2f /秒",
	"detail_stat_pickup_value_format": "%.1f",
	"reaction_quote_format": "“%s”",
	"theme_label_night": "夜墨",
	"theme_label_paper": "纸墨",
	"theme_tooltip_to_night": "切换到夜墨主题",
	"theme_tooltip_to_paper": "切换到纸墨主题",
	"language_label_en": "EN",
	"language_label_zh": "中",
	"language_tooltip_to_english": "切换到英文",
	"language_tooltip_to_chinese": "切换到中文",
	"detail_preview_fallback_glyph": "书",
	"selected_badge": "已选中",
	"selected_button": "正在展示",
	"select_button": "进入主舞台"
}

const MENU_TOP_ACTIONS := [
	{"kind": "action", "title": "返回启动器", "size": Vector2(168.0, 54.0), "action": "back"},
	{"kind": "action", "title": "人物志", "size": Vector2(148.0, 54.0), "action": "character_archive"},
	{"kind": "action", "title": "合字图谱", "size": Vector2(164.0, 54.0), "action": "recipe_atlas"},
	{"kind": "action", "title": "怪物图鉴", "size": Vector2(164.0, 54.0), "action": "enemy_archive"},
	{"kind": "action", "title": "玩家名帖", "size": Vector2(156.0, 54.0), "action": "profile"},
	{"kind": "action", "title": "查看排行榜", "size": Vector2(172.0, 54.0), "action": "leaderboard"},
	{"kind": "action", "title": "直接开始", "size": Vector2(152.0, 54.0), "action": "start"},
	{"kind": "theme_toggle", "size": Vector2(94.0, 54.0)},
	{"kind": "language_toggle", "size": Vector2(74.0, 54.0)}
]

const MENU_QUICK_START_ACTIONS := [
	{"title": "标准入卷", "accent": Color(0.92, 0.68, 0.42, 1.0), "action": "start"},
	{"title": "试阵 · 第10波", "accent": Color(0.56, 0.84, 1.0, 1.0), "action": "start_wave_10"},
	{"title": "压测 · 第20波", "accent": Color(0.78, 0.52, 1.0, 1.0), "action": "start_wave_20"}
]

const MENU_OVERLAY_CONTENT := {
	"character_archive": {
		"title": "人物志",
		"summary": "把已经接入的执笔者档案收进二级菜单，进入残卷前先确认每名角色的身份与战斗轮廓。",
		"note": "文本直接取自当前 Godot 迁移版的角色数据，不额外编造尚未落地的职业或成长线。",
		"close_text": "收起人物志"
	},
	"recipe_atlas": {
		"title": "合字图谱",
		"summary": "把偏旁、成字与砚台磨词路线收进二级菜单，开局前就能快速确认成长链。",
		"note": "当前先集中展示已经接入的偏旁、合字等级、词技等级与独立武器偏旁。真正的磨词仍然发生在战场砚台旁。",
		"close_text": "收起图谱"
	},
	"enemy_archive": {
		"title": "怪物图鉴",
		"summary": "把已经接入的敌人谱系收进二级菜单，开局前先记住预警和应对重点。",
		"note": "图鉴文本直接对应当前 Godot 迁移版已经写进战斗脚本的敌人行为，不额外虚构未接入兵种。",
		"close_text": "收起图鉴"
	},
	"leaderboard": {
		"title": "残卷战绩",
		"summary": "现在可以在二级菜单里直接查看本地排行榜，并顺手回看每局 build 走向，不必先打到结算页。",
		"sort_note": "当前可以按波次、击破或存活重新排序，更接近 source web 原型里回看不同 build 结果的方式。",
		"close_text": "收起战绩"
	},
	"profile": {
		"title": "玩家名帖",
		"summary": "像 source web 原型一样，先在菜单里维护这台设备的默认排行榜署名。结算页留空时，会自动复用这里的名字。",
		"preview_title": "当前署名",
		"fallback_glyph": "侠",
		"device_default_copy": "设备默认侠名仍在生效；保存自定义署名后，之后的战绩会切到这个名字。",
		"device_default_hint_format": "如果不另外保存自定义署名，系统会继续沿用本机默认侠名：%s",
		"saved_copy": "当前默认署名会自动复用到之后的本地排行榜记录里。",
		"saved_hint_format": "清空或恢复默认后，会重新回退到本机默认侠名：%s",
		"name_field_title": "默认排行榜署名",
		"name_field_placeholder": "输入想显示的名字",
		"random_text": "随机侠名",
		"save_text": "保存署名",
		"status_saved_format": "已保存默认署名：%s",
		"status_restored_format": "已恢复设备默认侠名：%s",
		"reset_text": "恢复默认",
		"close_text": "返回菜单"
	}
}

const MENU_TRANSITION_CONTENT := {
	"glyph": "书",
	"title": "残卷一·入墨",
	"subtitle": "执笔者正落字入卷。",
	"note": "墨线正在收束，字潮即将开启。",
	"runtime_title": "残卷一·入墨",
	"runtime_subtitle_format": "%s 执笔，落字入卷。"
}

const MENU_ARCHIVE_CONTENT := {
	"focus_format": "执笔焦点：%s",
	"summary_title_format": "%s  ·  %s",
	"quote_title": "卷中文字",
	"quote_excerpt_format": "“%s”",
	"record_fallback_title": "人物札记",
	"opening_title": "起笔落点",
	"opening_empty_summary": "当前 Godot 保持无固定起手偏旁，第一批掉落更适合顺势决定这一局往哪条合字线转。",
	"opening_started_summary": "当前 Godot 会带着 %s 入卷，让这名执笔者更早摸到自己的开场路线。",
	"stage_empty_summary": "无固定起手，顺第一批掉落决定路线。",
	"stage_started_summary": "起手自带 %s。",
	"stage_tag_fallback": "无固定起手",
	"trait_format": "角色特性：%s",
	"route_hint_format": "入卷建议：%s",
	"active_skill_title": "源稿字技（待迁移）",
	"active_skill_note": "当前只在人物志里保留对照预览，实际战斗输入仍待迁移。",
	"active_skill_cooldown_format": "%.1f 秒冷却",
	"active_skill_missing_headline": "当前还没有可对照的源稿字技条目。",
	"active_skill_missing_body": "当前这名执笔者还没有额外记录到独立字技说明。",
	"progression_title": "残卷路线",
	"progression_summary": "把这名执笔者的前几步 build 顺序先看清，再入卷会更容易顺着掉落继续写。",
	"progression_note": "当前先保留 web 原型的 build 顺序与路线提示，Godot 战斗内还没有真正的路线权重修正与额外掉落偏向。",
	"build_route_title": "源稿构筑方向",
	"build_route_summary": "对照 web 原型现有的路线选择，把更贴近这名执笔者的构筑方向与词技 / 遗物搭配保留成前台参考。",
	"build_route_note": "这些卡片当前不直接改战斗数值、掉落权重或路线偏向，只帮助对照 web 原型的构筑意图。",
	"build_route_relic_title": "源稿遗物偏向",
	"build_route_word_title": "源稿词技偏向",
	"stats_title": "战斗轮廓",
	"stat_mobility": "机动",
	"stat_vitality": "气血",
	"stat_damage": "伤害",
	"stat_range": "射程",
	"stat_attack_rate": "攻速",
	"stat_pickup": "拾取",
	"stat_attack_rate_value_format": "%.2f /秒"
}

const MENU_RECIPE_CONTENT := {
	"intro_line_1": "偏旁先补齐成字，成字满级后再去砚台磨成词技。",
	"intro_line_2": "进入残卷前先看一眼路线，升级三选一时会更容易判断当前该补哪一笔。",
	"recipe_header_format": "%s  %s",
	"glyph_format": "成字：%s  Lv.%d",
	"description_format": "  %s",
	"phrase_format": "磨词：%s  Lv.%d  砚台消耗 %d",
	"independent_title": "独立偏旁",
	"independent_entry_format": "%s  %s"
}

const MENU_LEADERBOARD_CONTENT := {
	"empty_test": "当前还没有试阵记录。用第 10 / 20 波捷径打一轮后，这里会单独留下试阵榜。",
	"empty_manual": "当前还没有可展示的主卷战绩。下一次从第 1 波真正开卷后，这里会留下你的记录。",
	"intro_test": "试阵榜会单独记录第 10 / 20 波捷径，不与主卷榜混排。",
	"intro_manual": "主卷榜只统计从第 1 波真正开卷的正式战绩。",
	"sorted_format": "当前排序：%s。",
	"identity_hero_fallback": "书生",
	"identity_format": "%s · %s",
	"summary_test": "试阵榜单独收录第 10 / 20 波捷径，方便检查敌潮、build 与 HUD；现在也能在波次 / 击破 / 存活三种排序之间切换，更接近 source 榜单的回看方式。",
	"summary_manual": "主卷榜只收从第 1 波真正开卷的战绩；现在也能在波次 / 击破 / 存活三种排序之间切换，开局前可以从不同角度回看 route 成果。",
	"main_board": "主卷榜",
	"test_board": "试阵榜",
	"view_button_count_format": "%s · %d",
	"sort_wave": "按波次",
	"sort_kills": "按击破",
	"sort_time": "按存活",
	"sort_summary_wave": "按波次优先",
	"sort_summary_kills": "按击破优先",
	"sort_summary_time": "按存活优先",
	"test_run_format": "试阵 W%d",
	"manual_completed": "定卷",
	"manual_scroll": "残卷",
	"bosses_label": "卷主",
	"wave_label": "波次",
	"kills_label": "击破",
	"level_label": "等级",
	"time_label": "存活",
	"entry_format": "%d. %s  %s  %s %d  %s %d  %s %d  %s %d  %s %s",
	"detail_prefix_format": "   %s",
	"detail_radicals": "偏旁 %s",
	"detail_glyphs": "成字 %s",
	"detail_phrases": "词技 %s",
	"detail_count_entry_format": "%s%d",
	"detail_count_joiner": " ",
	"detail_blade_xia": "剑势",
	"detail_blade_scholar": "笔锋",
	"detail_blade_level_format": "%s Lv.%d",
	"detail_takedowns": "击倒 %s",
	"detail_joiner": " | ",
	"time_zone_format": "时区 %s",
	"enemy_kill_entry_format": "%s%d",
	"enemy_kill_joiner": " "
}

const MENU_ENEMY_CONTENT := {
	"intro": "以下条目对应当前残卷里已经接入的敌人谱系、预警方式与最实用的临场处理思路。",
	"entry_format": "%s  %s  ·  %s",
	"summary_format": "  %s",
	"warning_format": "  预警：%s",
	"counter_format": "  应对：%s"
}

const MENU_EN_TEXT := {
	"返回启动器": "Back to Launcher",
	"人物志": "Character Archive",
	"合字图谱": "Fusion Atlas",
	"怪物图鉴": "Enemy Archive",
	"玩家名帖": "Player Sigil",
	"查看排行榜": "Leaderboard",
	"直接开始": "Start Now",
	"字海残卷": "Ink-Sea Remnant Scroll",
	"先进入残卷，再决定谁来执笔。每名角色都会把同一套偏旁系统，写成完全不同的战斗节奏。": "Enter the remnant scroll first, then decide who will write it. The same radical system becomes a different battle rhythm for each hero.",
	"可选执笔者": "Available Scribes",
	"执笔者档案": "Scribe Dossier",
	"执笔回应": "Scribe Response",
	"起笔落点": "Opening Route",
	"源稿字技（待迁移）": "Source Skill (Pending Migration)",
	"当前只在菜单里保留 hanziHero 的字技预览，Godot 战斗内仍未接入独立主动输入。": "This menu currently keeps the hanziHero active-skill preview only as a reference. The Godot battle scene still does not have separate manual skill input.",
	"残卷路线": "Scroll Route",
	"把开卷补笔、中盘续写与砚台磨词顺序先记住，进入战斗后更容易判断本轮 build 该补哪一笔。": "Memorize the opening, midgame, and inkstone phrase order first so it is easier to choose your next build step in battle.",
	"当前只先保留 web 原型的 build 顺序与路线提示，Godot 战斗内还没有真正的路线权重修正。": "The current build only keeps the source route order and hints for reference. Godot battle does not yet restore true route bias.",
	"战斗轮廓": "Combat Outline",
	"快速试阵": "Quick Test Runs",
	"对照 web 原型保留第 10 / 20 波捷径，便于快速检查 HUD、混编敌潮与角色 build。试阵入口会单独写入试阵榜，不影响主卷榜。": "Wave 10 and wave 20 shortcuts remain for quick HUD, mixed-wave, and hero-build checks. Test entries go into a separate leaderboard and never affect the main scroll board.",
	"标准入卷": "Standard Entry",
	"试阵 · 第10波": "Test Run · Wave 10",
	"压测 · 第20波": "Stress Run · Wave 20",
	"把偏旁、成字与砚台磨词路线收进二级菜单，开局前就能快速确认成长链。": "Keep radicals, formed glyphs, and inkstone phrase routes inside the menu so you can review the growth chain before entering battle.",
	"当前先集中展示已经接入的偏旁、合字等级、词技等级与独立武器偏旁。真正的磨词仍然发生在战场砚台旁。": "This screen currently focuses on migrated radicals, glyph levels, phrase levels, and the independent weapon radical. Actual phrase refinement still happens beside the battlefield inkstone.",
	"把已经接入的执笔者档案收进二级菜单，进入残卷前先确认每名角色的身份与战斗轮廓。": "Keep the migrated hero dossiers inside the menu so you can confirm each fighter's identity and combat profile before entering the scroll.",
	"文本直接取自当前 Godot 迁移版的角色数据，不额外编造尚未落地的职业或成长线。": "The text comes directly from the current Godot migration data and does not invent classes or growth lines that are not implemented yet.",
	"残卷战绩": "Run Records",
	"现在可以在二级菜单里直接查看本地排行榜，并顺手回看每局 build 走向，不必先打到结算页。": "You can now inspect the local leaderboard directly from the sub-menu and review each build path without first reaching the result screen.",
	"当前可以按波次、击破或存活重新排序，更接近 source web 原型里回看不同 build 结果的方式。": "You can now resort by wave, kills, or survival time, closer to how the source web prototype reviews different build outcomes.",
	"像 source web 原型一样，先在菜单里维护这台设备的默认排行榜署名。结算页留空时，会自动复用这里的名字。": "Just like the source web prototype, keep the default leaderboard alias for this device inside the menu. Result screens reuse it automatically when left blank.",
	"当前署名": "Current Alias",
	"默认排行榜署名": "Default Leaderboard Alias",
	"输入想显示的名字": "Enter the name you want to show",
	"随机侠名": "Random Wuxia Name",
	"保存署名": "Save Alias",
	"恢复默认": "Restore Default",
	"返回菜单": "Back to Menu",
	"收起战绩": "Close Records",
	"把已经接入的敌人谱系收进二级菜单，开局前先记住预警和应对重点。": "Keep the migrated enemy families inside the sub-menu so you can remember their warnings and counters before battle.",
	"图鉴文本直接对应当前 Godot 迁移版已经写进战斗脚本的敌人行为，不额外虚构未接入兵种。": "Archive text maps directly to behaviors already implemented in the current Godot battle scripts instead of inventing unshipped units.",
	"收起人物志": "Close Archive",
	"收起图谱": "Close Atlas",
	"收起图鉴": "Close Archive",
	"残卷一·入墨": "Scroll I · Into Ink",
	"执笔者正落字入卷。": "The scribe is laying the opening stroke into the scroll.",
	"墨线正在收束，字潮即将开启。": "Ink lines are closing. The glyph tide is about to begin.",
	"卷中文字": "Text Within the Scroll",
	"人物札记": "Scribe Notes",
	"机动": "Mobility",
	"气血": "Vitality",
	"伤害": "Damage",
	"射程": "Range",
	"攻速": "Attack Rate",
	"拾取": "Pickup",
	"夜墨": "Night Ink",
	"纸墨": "Paper Ink",
	"切换到夜墨主题": "Switch to Night Ink theme",
	"切换到纸墨主题": "Switch to Paper Ink theme",
	"切换到英文": "Switch to English",
	"切换到中文": "Switch to Chinese",
	"源稿构筑方向": "Source Build Route",
	"把 web 原型里更偏向的构筑方向先压缩成菜单预览，连同源稿词技 / 遗物搭配一起放在开局前参考。": "Compress the source web build routes into a menu preview and keep their source word and relic pairings visible before the run.",
	"当前只负责前台提示：源稿词技 / 遗物搭配还没有接回 Godot 战斗掉落或路线权重。": "Front-end reference only: source word and relic pairings are not yet wired back into Godot battle drops or route bias.",
	"对照 web 原型现有的路线选择，把更贴近这名执笔者的构筑方向与词技 / 遗物搭配保留成前台参考。": "Mirror the source web route choices by keeping the best-fitting build directions, words, and relic pairings visible for this hero.",
	"这些卡片当前不直接改战斗数值、掉落权重或路线偏向，只帮助对照 web 原型的构筑意图。": "These cards do not yet change combat values, drop weights, or route bias. They only surface the source prototype's build intent.",
	"源稿遗物偏向": "Source Relic Pairing",
	"源稿词技偏向": "Source Word Pairing",
	"当前执笔": "Active Scribe",
	"选择界面只保留短摘要和关键属性，更长的角色说明移到次级菜单。": "The selection screen now keeps only a short summary and core stats. Longer hero write-ups live in the secondary menus.",
	"人物来路、源稿字技与构筑路线": "Origin, source skill, and build route",
	"请打开下方次级入口查看完整人物志与路线参考。": "Open the secondary entries below for the full archive and route reference.",
	"当前执笔节奏：%s": "Current combat rhythm: %s",
	"起笔偏向：%s": "Opening route: %s",
	"人物志里收录完整来路、摘句、源稿字技和 build 顺序。": "The archive keeps the full backstory, excerpts, source skill, and build order.",
	"二级入口": "Secondary Access",
	"二级入口与试阵": "Secondary Access and Test Runs",
	"长说明移到人物志与图谱；这里保留快速进入与测试入口。": "Longer notes live in Archive and Atlas; this panel keeps quick entry and test access.",
	"长说明和 build 路线请看人物志与图谱。": "See Archive and Atlas for the full write-up and build route.",
	"执笔焦点：%s": "Hero focus: %s",
	"角色特性：%s": "Trait: %s",
	"入卷建议：%s": "Entry hint: %s",
	"当前只在人物志里保留对照预览，实际战斗输入仍待迁移。": "This archive keeps the source-skill preview only as a reference. Actual battle input is still pending migration.",
	"把这名执笔者的前几步 build 顺序先看清，再入卷会更容易顺着掉落继续写。": "Review this hero's early build order first so it is easier to follow later drops once the run begins.",
	"当前先保留 web 原型的 build 顺序与路线提示，Godot 战斗内还没有真正的路线权重修正与额外掉落偏向。": "The current build still keeps the source route order only as a preview. Godot battle has not yet restored route bias or extra drop weighting.",
	"偏旁先补齐成字，成字满级后再去砚台磨成词技。": "Complete radicals into formed glyphs first, then refine them into phrase arts at the inkstone once they are maxed.",
	"进入残卷前先看一眼路线，升级三选一时会更容易判断当前该补哪一笔。": "Review the route before entering battle so each three-choice level-up is easier to judge.",
	"成字：%s  Lv.%d": "Glyph: %s  Lv.%d",
	"磨词：%s  Lv.%d  砚台消耗 %d": "Phrase: %s  Lv.%d  Inkstone cost %d",
	"独立偏旁": "Independent Radical",
	"当前还没有试阵记录。用第 10 / 20 波捷径打一轮后，这里会单独留下试阵榜。": "There are no test-run records yet. Use the wave 10 or wave 20 shortcut once and this board will fill in separately.",
	"当前还没有可展示的主卷战绩。下一次从第 1 波真正开卷后，这里会留下你的记录。": "There are no main-scroll results to show yet. Finish a true run from wave 1 and your record will appear here.",
	"试阵榜会单独记录第 10 / 20 波捷径，不与主卷榜混排。": "Test runs keep wave 10 and wave 20 shortcuts on a separate board.",
	"主卷榜只统计从第 1 波真正开卷的正式战绩。": "The main-scroll board only tracks full runs that begin at wave 1.",
	"当前排序：%s。": "Sorted by %s.",
	"试阵榜单独收录第 10 / 20 波捷径，方便检查敌潮、build 与 HUD；现在也能在波次 / 击破 / 存活三种排序之间切换，更接近 source 榜单的回看方式。": "The test board keeps wave 10 and wave 20 shortcuts separate so you can inspect enemy mixes, builds, and HUD behavior. It now also pivots between wave, kills, and survival-time ordering so route checks read closer to the source leaderboard.",
	"主卷榜只收从第 1 波真正开卷的战绩；现在也能在波次 / 击破 / 存活三种排序之间切换，开局前可以从不同角度回看 route 成果。": "The main-scroll board only keeps real runs that start from wave 1. It now also pivots between wave, kills, and survival-time ordering so you can review route outcomes from different angles before the next run.",
	"主卷榜": "Main Board",
	"试阵榜": "Test Board",
	"试阵 W%d": "Test Run W%d",
	"按波次": "Wave",
	"按击破": "Kills",
	"按存活": "Time",
	"按波次优先": "wave",
	"按击破优先": "kills",
	"按存活优先": "survival time",
	"定卷": "Completed",
	"残卷": "Scroll",
	"卷主": "Bosses",
	"波次": "Wave",
	"击破": "Kills",
	"等级": "Level",
	"存活": "Time",
	"书生": "Scholar",
	"偏旁 %s": "Radicals %s",
	"成字 %s": "Glyphs %s",
	"词技 %s": "Phrases %s",
	"剑势": "Blade Arc",
	"笔锋": "Brush Edge",
	"击倒 %s": "Takedowns %s",
	"时区 %s": "Time Zone %s",
	"以下条目对应当前残卷里已经接入的敌人谱系、预警方式与最实用的临场处理思路。": "The entries below describe enemy families, warnings, and counters that are already implemented in the current remnant scroll.",
	"  预警：%s": "  Warning: %s",
	"  应对：%s": "  Counter: %s",
	"当前 Godot 保持无固定起手偏旁，第一批掉落更适合顺势决定这一局往哪条合字线转。": "The current Godot build keeps this hero without fixed opening radicals, so the first drops are meant to decide which fusion line the run should follow.",
	"当前 Godot 会带着 %s 入卷，让这名执笔者更早摸到自己的开场路线。": "This Godot build starts with %s, letting the hero reach their opening route earlier.",
	"无固定起手，顺第一批掉落决定路线。": "No fixed opener. Let the first drops decide the line.",
	"起手自带 %s。": "Starts with %s.",
	"无固定起手": "No fixed opener",
	"当前还没有可对照的源稿字技条目。": "There is no matching source skill entry for this hero yet.",
	"当前这名执笔者还没有额外记录到独立字技说明。": "This hero does not yet have an extra source-skill note.",
	"执笔映像": "Scribe Presence",
	"出处 · %s": "Source · %s",
	"轻触当前展示位，重播执笔回应。": "Tap the active showcase to replay the scribe response.",
	"已选中": "Selected",
	"正在展示": "On Stage",
	"进入主舞台": "Take the stage",
	"设备默认侠名仍在生效；保存自定义署名后，之后的战绩会切到这个名字。": "The device is still using its default wuxia alias. Saving a custom alias will switch later records to this name.",
	"如果不另外保存自定义署名，系统会继续沿用本机默认侠名：%s": "If you do not save a custom alias, the system keeps using the device default: %s",
	"当前默认署名会自动复用到之后的本地排行榜记录里。": "The saved alias will be reused automatically for later local leaderboard records.",
	"清空或恢复默认后，会重新回退到本机默认侠名：%s": "Clear or reset it to fall back to the device default again: %s",
	"已保存默认署名：%s": "Saved default alias: %s",
	"已恢复设备默认侠名：%s": "Restored device default alias: %s",
	"%.2f /秒": "%.2f/s",
	"%.1f 秒冷却": "%.1fs cooldown",
	"%s 执笔，落字入卷。": "%s enters the scroll and sets the first glyph."
}


static func launcher_top_actions() -> Array:
	return LAUNCHER_TOP_ACTIONS.duplicate(true)


static func launcher_mobile_info_panels() -> Array:
	return LAUNCHER_MOBILE_INFO_PANELS.duplicate(true)


static func launcher_game_cards() -> Array:
	return LAUNCHER_GAME_CARDS.duplicate(true)


static func launcher_roadmap_info_panels() -> Array:
	return LAUNCHER_ROADMAP_INFO_PANELS.duplicate(true)


static func launcher_about_content() -> Dictionary:
	return LAUNCHER_ABOUT_CONTENT.duplicate(true)


static func launcher_update_spotlight() -> Dictionary:
	return LAUNCHER_UPDATE_SPOTLIGHT.duplicate(true)


static func launcher_changelog_history() -> Array:
	return LAUNCHER_CHANGELOG_HISTORY.duplicate(true)


static func cangjie_portal_sections() -> Array:
	return CANGJIE_PORTAL_SECTIONS.duplicate(true)


static func launcher_changelog_content() -> Dictionary:
	return LAUNCHER_CHANGELOG_CONTENT.duplicate(true)


static func launcher_profile_content() -> Dictionary:
	return LAUNCHER_PROFILE_CONTENT.duplicate(true)


static func menu_page_content() -> Dictionary:
	return MENU_PAGE_CONTENT.duplicate(true)


static func menu_top_actions() -> Array:
	return MENU_TOP_ACTIONS.duplicate(true)


static func menu_quick_start_actions() -> Array:
	return MENU_QUICK_START_ACTIONS.duplicate(true)


static func menu_overlay_content() -> Dictionary:
	return MENU_OVERLAY_CONTENT.duplicate(true)


static func menu_transition_content() -> Dictionary:
	return MENU_TRANSITION_CONTENT.duplicate(true)


static func menu_archive_content() -> Dictionary:
	return MENU_ARCHIVE_CONTENT.duplicate(true)


static func menu_recipe_content() -> Dictionary:
	return MENU_RECIPE_CONTENT.duplicate(true)


static func menu_leaderboard_content() -> Dictionary:
	return MENU_LEADERBOARD_CONTENT.duplicate(true)


static func menu_enemy_content() -> Dictionary:
	return MENU_ENEMY_CONTENT.duplicate(true)
