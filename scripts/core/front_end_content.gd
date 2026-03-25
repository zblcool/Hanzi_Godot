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
		"id": "run_controls",
		"title": {"zh": "运行控台", "en": "Run Controls"},
		"eyebrow": "Run Shell",
		"accent": Color(0.58, 0.76, 0.94, 1.0),
		"summary": {
			"zh": "source《仓颉之路》进入页面后，不会把关键操作和状态藏起来；`重新开局 / 查看牌组 / 返回启动器` 与 `Floor / HP / Deck / Relics / Gold` 会一直留在前台壳里。",
			"en": "Once the source Cangjie Road page opens, it does not hide the key controls or run state. `Restart Run / Open Deck / Back To Launcher` and the `Floor / HP / Deck / Relics / Gold` frame stay in the front shell."
		},
		"points": [
			{
				"zh": "常驻操作条让测试时可以立刻重开、翻牌组，或退回启动器，不必靠刷新页面找入口。",
				"en": "The always-on action strip lets testing restart immediately, inspect the deck, or step back to the launcher without hunting for a reset path."
			},
			{
				"zh": "顶部状态条会一直保留层数、气血、牌组厚度、遗物数量和 Gold，先把当前爬塔读法钉在前台。",
				"en": "The top status row keeps floor, HP, deck thickness, relic count, and Gold visible so the current climb read stays pinned to the front."
			},
			{
				"zh": "Godot 先把这层 run shell 作为 portal 预览讲清楚，后续真接入可玩场景时更容易复用同样的导航结构。",
				"en": "Godot explains this run shell in the portal first so the same navigation frame is easier to reuse once a playable scene lands."
			}
		],
		"run_shell_preview": {
			"title": {"zh": "运行壳预览", "en": "Run Shell Preview"},
			"summary": {
				"zh": "source 页面的 `重新开局 / 查看牌组 / 返回启动器` 不是摆设。Godot 现在先把其中最关键的 `查看牌组` 做成可点开的轻量样张，方便在 portal 里直接读 deck 形状和遗物节奏。",
				"en": "On the source page, `Restart Run / Open Deck / Back To Launcher` are not decorative. Godot now restores the key `Open Deck` beat as a lightweight tappable sample so deck shape and relic pacing can be read directly inside the portal."
			},
			"actions": [
				{
					"id": "restart",
					"label": {"zh": "重新开局", "en": "Restart Run"},
					"tone": Color(0.94, 0.74, 0.42, 1.0)
				},
				{
					"id": "deck",
					"label": {"zh": "查看牌组", "en": "Open Deck"},
					"active_label": {"zh": "收起牌组", "en": "Close Deck"},
					"tone": Color(0.58, 0.76, 0.94, 1.0)
				},
				{
					"id": "back",
					"label": {"zh": "返回启动器", "en": "Back To Launcher"},
					"tone": Color(0.78, 0.66, 0.94, 1.0)
				}
			],
			"status_pills": [
				{
					"label": {"zh": "Floor", "en": "Floor"},
					"value": "1",
					"tone": Color(0.94, 0.74, 0.42, 1.0)
				},
				{
					"label": {"zh": "HP", "en": "HP"},
					"value": "72 / 72",
					"tone": Color(0.54, 0.82, 0.88, 1.0)
				},
				{
					"label": {"zh": "Deck", "en": "Deck"},
					"value": "10",
					"tone": Color(0.66, 0.68, 0.94, 1.0)
				},
				{
					"label": {"zh": "Relics", "en": "Relics"},
					"value": "2",
					"tone": Color(0.88, 0.58, 0.62, 1.0)
				},
				{
					"label": {"zh": "Gold", "en": "Gold"},
					"value": "40",
					"tone": Color(0.96, 0.82, 0.46, 1.0)
				}
			],
			"deck_preview": {
				"hint": {
					"zh": "点按 `查看牌组`，展开一份 source 风格的当前牌组 / 遗物样张。",
					"en": "Tap `Open Deck` to reveal a source-style current deck and relic sample."
				},
				"title": {"zh": "当前牌组样张", "en": "Current Deck Sample"},
				"summary": {
					"zh": "source 的 `Open Deck` 会把当前牌组厚度、主线走向和已持遗物一起摊开。Godot 先在 portal 里补回这层轻量 deck sheet，后续真接入爬塔场景时更容易沿用同一层读法。",
					"en": "The source `Open Deck` lays out deck thickness, current line, and owned relics together. Godot now restores that layer as a lightweight portal-side deck sheet so the same read can carry into a future playable climb."
				},
				"tags": [
					{"zh": "Deck 10", "en": "Deck 10"},
					{"zh": "Relics 2", "en": "Relics 2"},
					{"zh": "明 / 雷 / 休 主线", "en": "Bright / Thunder / Rest lines"}
				],
				"groups": [
					{
						"title": {"zh": "当前牌组", "en": "Current Deck"},
						"summary": {
							"zh": "用 3 张代表牌先把当前牌组的起手、成字与引擎关系摊开，不必等真正进战后再回忆 deck 形状。",
							"en": "These representative cards expose the opener, fusion, and engine relationship up front so the deck shape does not have to wait for a real battle scene."
						},
						"cards": [
							{
								"glyph": "日",
								"title": {"zh": "日 · 起手偏旁", "en": "日 · Sun Trace"},
								"subtitle": {"zh": "偏旁起手", "en": "Radical opener"},
								"body": {
									"zh": "造成 6 伤害，并把「明」这条线提前写进牌组。",
									"en": "Deal 6 damage and seed the 明 line into the deck early."
								},
								"tags": [
									{"zh": "偏旁", "en": "Radical"},
									{"zh": "铺垫", "en": "Setup"}
								]
							},
							{
								"glyph": "明",
								"title": {"zh": "明 · 节奏成字", "en": "明 · Twin Gleam"},
								"subtitle": {"zh": "日 + 月", "en": "Sun + moon"},
								"body": {
									"zh": "成型后同时补伤害、抽牌与墨流，是 source 里很典型的节奏主线。",
									"en": "Once formed it gives damage, draw, and Ink flow together, making it a typical source tempo spine."
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
									"zh": "抽 2 并补 1 墨，提醒这条线不只靠合字，还要靠真正的 draw / Ink 引擎维持厚牌组运转。",
									"en": "Draw 2 and gain 1 Ink, showing the line relies on a real draw and Ink engine instead of fusions alone."
								},
								"tags": [
									{"zh": "引擎", "en": "Engine"},
									{"zh": "抽墨", "en": "Draw + Ink"}
								]
							}
						]
					},
					{
						"title": {"zh": "已持遗物", "en": "Owned Relics"},
						"summary": {
							"zh": "source deck sheet 也会把遗物一起摊开，提醒这条线的节奏判断不只来自牌本身。",
							"en": "The source deck sheet also exposes relics so route judgment is not read from cards alone."
						},
						"cards": [
							{
								"glyph": "砚",
								"title": {"zh": "砚 · 开局多抽", "en": "Inkstone · Opening Draw"},
								"subtitle": {"zh": "战斗起手", "en": "Battle opener"},
								"body": {
									"zh": "每场战斗开局多抽 1，让慢线更快碰到关键偏旁与成字。",
									"en": "Draw 1 extra card at the start of each battle so slower lines hit key radicals and fusions sooner."
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
									"zh": "每回合第一次打出重复偏旁时抽 1，直接改写重复材料的价值判断。",
									"en": "The first repeated radical each turn draws 1, directly changing how duplicate material is valued."
								},
								"tags": [
									{"zh": "重复利用", "en": "Repeat use"},
									{"zh": "资源再估值", "en": "Revalue resources"}
								]
							}
						]
					}
				]
			}
		},
		"sample_groups": [
			{
				"title": {"zh": "常驻操作", "en": "Always-On Controls"},
				"cards": [
					{
						"glyph": "启",
						"title": {"zh": "重新开局", "en": "Restart Run"},
						"subtitle": {"zh": "快速回到第一层", "en": "Fast reset to floor one"},
						"body": {
							"zh": "source 把 `Restart Run` 固定在顶栏，方便反复测试路线、敌意与奖励链路，不用刷新页面。",
							"en": "The source pins `Restart Run` in the top action row so route, intent, and reward-chain tests can restart without a page refresh."
						},
						"tags": [
							{"zh": "重开", "en": "Reset"},
							{"zh": "快速迭代", "en": "Fast iteration"}
						]
					},
					{
						"glyph": "牌",
						"title": {"zh": "查看牌组", "en": "Open Deck"},
						"subtitle": {"zh": "随时翻看当前构筑", "en": "Inspect the current build"},
						"body": {
							"zh": "`Open Deck` 让地图、战斗和奖励前都能直接核对牌组形状，避免只靠记忆判断构筑。",
							"en": "`Open Deck` keeps the current deck one click away from map, battle, or reward states so build shape is not left to memory."
						},
						"tags": [
							{"zh": "牌组总览", "en": "Deck view"},
							{"zh": "构筑核对", "en": "Build check"}
						]
					},
					{
						"glyph": "返",
						"title": {"zh": "返回启动器", "en": "Back To Launcher"},
						"subtitle": {"zh": "保留双项目入口", "en": "Keep both game fronts close"},
						"body": {
							"zh": "source 在同一页顶栏保留 `Back To Launcher`，方便 deckbuilder 与字海入口之间随时来回对照。",
							"en": "The source keeps `Back To Launcher` in the same top strip so the deckbuilder and Ink-Sea fronts stay close together."
						},
						"tags": [
							{"zh": "入口切换", "en": "Entry swap"},
							{"zh": "启动器联动", "en": "Launcher link"}
						]
					}
				]
			},
			{
				"title": {"zh": "顶部状态", "en": "Top Status"},
				"cards": [
					{
						"glyph": "层",
						"title": {"zh": "层数 / 气血", "en": "Floor / HP"},
						"subtitle": {"zh": "这一爬到哪了", "en": "Where the climb stands"},
						"body": {
							"zh": "`Floor` 与 `HP` 常驻在状态条里，先把这一局的推进深度和存活压力钉住。",
							"en": "`Floor` and `HP` stay pinned in the top status row so depth and survival pressure remain readable."
						},
						"tags": [
							{"zh": "推进深度", "en": "Run depth"},
							{"zh": "存活压力", "en": "Survival pressure"}
						]
					},
					{
						"glyph": "构",
						"title": {"zh": "牌组 / 遗物", "en": "Deck / Relics"},
						"subtitle": {"zh": "构筑形状不离视线", "en": "Build shape stays visible"},
						"body": {
							"zh": "牌组张数与遗物数量直接挂在顶栏，读 deck 厚薄和 relic 节奏不必先开二层面板。",
							"en": "Deck count and relic total stay in the top bar, so deck thickness and relic pace can be read without opening a second layer."
						},
						"tags": [
							{"zh": "牌组厚度", "en": "Deck size"},
							{"zh": "遗物节奏", "en": "Relic pace"}
						]
					},
					{
						"glyph": "金",
						"title": {"zh": "Gold", "en": "Gold"},
						"subtitle": {"zh": "商店与奖励预算", "en": "Budget for shops and rewards"},
						"body": {
							"zh": "Gold 也在顶栏长期可见，让节点价值、删牌节奏和奖励跳过判断更像一条完整的 run shell。",
							"en": "Gold also stays visible at the top, tying node value, deck trims, and reward skips into one readable run shell."
						},
						"tags": [
							{"zh": "商店预算", "en": "Shop budget"},
							{"zh": "路线取舍", "en": "Route tradeoff"}
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
		"reward_chain_preview": {
			"title": {"zh": "战后链路手感预览", "en": "Reward Handoff Preview"},
			"summary": {
				"zh": "source 的战后流程不是只有一张奖励牌。普通战斗、跳过保薄、精英 / Boss 遗物跟进各自会把路线往不同方向轻推。",
				"en": "The source post-battle flow is more than a single reward card. Regular drafts, lean skips, and elite or boss relic follow-through each nudge the route in a different direction."
			},
			"hint": {
				"zh": "点按下面任一链路，预览 source 的战后节奏会怎样把 Gold、选牌与遗物判断串成一段完整 handoff。",
				"en": "Tap one of the branches below to preview how the source strings Gold, card choice, and relic valuation into one post-battle handoff."
			},
			"options": [
				{
					"id": "draft",
					"glyph": "赏",
					"title": {"zh": "常规拿牌", "en": "Regular Draft"},
					"subtitle": {"zh": "Gold 结算后继续三选一", "en": "Settle Gold, then pick one of three"},
					"summary": {
						"zh": "这条线保留 source 最常见的节奏：先拿本场 Gold，再看三张候选牌里哪一张最值得把当前路线写得更厚。",
						"en": "This keeps the source's most common cadence: settle this fight's Gold first, then decide which of three reward cards deserves to thicken the current route."
					},
					"tone": Color(0.94, 0.74, 0.42, 1.0),
					"result_group": {
						"title": {"zh": "常规战后链路", "en": "Regular Post-Battle Chain"},
						"summary": {
							"zh": "先结算 Gold，再读三张候选牌的角色差异。你不是无脑拿高数值，而是在决定哪条字路继续向前写。",
							"en": "Gold resolves first, then the three reward cards are judged by role. The choice is not just raw numbers, but which character line should keep moving."
						},
						"cards": [
							{
								"glyph": "金",
								"title": {"zh": "Gold +18", "en": "Gold +18"},
								"subtitle": {"zh": "先落袋本场收益", "en": "Bank the fight first"},
								"body": {
									"zh": "普通战斗会先给一笔稳定的 Gold，让后续商店、删牌和遗物预算都有真实重量。",
									"en": "Regular fights first pay a steady Gold amount so later shops, trims, and relic budgets all carry real weight."
								},
								"tags": [
									{"zh": "战后收益", "en": "Post-fight gain"},
									{"zh": "预算", "en": "Budget"}
								]
							},
							{
								"glyph": "明",
								"title": {"zh": "候选 · 明", "en": "Offer · 明"},
								"subtitle": {"zh": "节奏成字", "en": "Tempo fusion"},
								"body": {
									"zh": "补一张能接伤害、抽牌与墨流的成字，让当前节奏线继续往中盘延伸。",
									"en": "Adds a formed glyph that links damage, draw, and Ink flow so the current tempo line keeps extending into the midgame."
								},
								"tags": [
									{"zh": "成字", "en": "Fusion"},
									{"zh": "节奏", "en": "Tempo"}
								]
							},
							{
								"glyph": "学",
								"title": {"zh": "候选 · 学", "en": "Offer · 学"},
								"subtitle": {"zh": "抽墨引擎", "en": "Draw + Ink engine"},
								"body": {
									"zh": "不一定直接补爆发，而是让厚一点的牌组也能顺畅运转，强化抽牌和墨的节奏骨架。",
									"en": "Instead of immediate burst, this keeps a slightly thicker deck moving by strengthening the draw-and-Ink backbone."
								},
								"tags": [
									{"zh": "引擎", "en": "Engine"},
									{"zh": "抽墨", "en": "Draw + Ink"}
								]
							},
							{
								"glyph": "思",
								"title": {"zh": "候选 · 思", "en": "Offer · 思"},
								"subtitle": {"zh": "稳住控制面", "en": "Steady control lane"},
								"body": {
									"zh": "如果这层更需要把敌方节拍按住，控制向奖励也会在这里介入，不是每次都继续贪主线伤害。",
									"en": "If the floor needs enemy pacing held down first, a control-biased reward can surface here instead of always greedily deepening damage."
								},
								"tags": [
									{"zh": "控制", "en": "Control"},
									{"zh": "取舍", "en": "Tradeoff"}
								]
							}
						]
					}
				},
				{
					"id": "skip",
					"glyph": "简",
					"title": {"zh": "跳过保薄", "en": "Skip To Stay Lean"},
					"subtitle": {"zh": "不拿牌，先守抽牌质量", "en": "Take no card and protect draw quality"},
					"summary": {
						"zh": "source 明确允许直接跳过奖励牌，让“更干净的抽牌质量”成为主动选择；如果带着算盘类遗物，这步还会反过来补 Gold。",
						"en": "The source explicitly allows reward skips so cleaner draw quality becomes an active choice; with an abacus-style relic this step can even refund extra Gold."
					},
					"tone": Color(0.58, 0.82, 0.78, 1.0),
					"result_group": {
						"title": {"zh": "保薄链路", "en": "Lean-Deck Handoff"},
						"summary": {
							"zh": "这条分支提醒《仓颉之路》不是每次都要拿牌。有时最强的战后决定，正是维持牌组更干净、再把预算存给后面。",
							"en": "This branch reinforces that Cangjie Road does not always want another card. Sometimes the strongest reward decision is to keep the deck cleaner and save the budget for later."
						},
						"cards": [
							{
								"glyph": "金",
								"title": {"zh": "Gold +18", "en": "Gold +18"},
								"subtitle": {"zh": "基础战后收益照常入账", "en": "Base fight payout still lands"},
								"body": {
									"zh": "跳过的是奖励牌，不是整场战斗的收益；你依然会带着这笔 Gold 去重配后续节点价值。",
									"en": "The skip only removes the card reward, not the fight's payout; that Gold still travels forward into later node valuation."
								},
								"tags": [
									{"zh": "预算保留", "en": "Budget kept"},
									{"zh": "战后收益", "en": "Post-fight gain"}
								]
							},
							{
								"glyph": "简",
								"title": {"zh": "跳过本轮奖励牌", "en": "Skip This Reward"},
								"subtitle": {"zh": "让牌组别再变厚", "en": "Keep the deck from thickening"},
								"body": {
									"zh": "当当前牌组已经够能运转时，少拿一张牌往往比再堆一个候选更值，因为后面每一抽都会更稳定。",
									"en": "Once the current deck already functions, skipping a card is often worth more than adding another option because every later draw becomes steadier."
								},
								"tags": [
									{"zh": "精简", "en": "Lean deck"},
									{"zh": "抽牌质量", "en": "Draw quality"}
								]
							},
							{
								"glyph": "算",
								"title": {"zh": "算盘 · 跳牌转 Gold", "en": "Lean Ledger · Skip Into Gold"},
								"subtitle": {"zh": "遗物把保薄改写成预算", "en": "A relic rewrites the skip into budget"},
								"body": {
									"zh": "带着 `算盘 / Lean Ledger` 时，跳过奖励牌还能额外拿一笔 Gold，让“少拿一张”不只是防守，而是下一段更有计划地花。",
									"en": "When carrying `Lean Ledger`, skipping the reward also grants extra Gold so 'take nothing' becomes planned spending leverage instead of only caution."
								},
								"tags": [
									{"zh": "遗物联动", "en": "Relic synergy"},
									{"zh": "Gold", "en": "Gold"}
								]
							}
						]
					}
				},
				{
					"id": "relic",
					"glyph": "匣",
					"title": {"zh": "精英 / Boss 跟进", "en": "Elite / Boss Follow-Through"},
					"subtitle": {"zh": "选牌后再来一轮遗物偏转", "en": "A relic bend after the draft"},
					"summary": {
						"zh": "高压战斗不会在选牌后就结束。source 还会继续丢出 2 到 3 件遗物，把后续节点价值和牌张估值一起扭向新的方向。",
						"en": "High-pressure fights do not end after the draft. The source then throws 2 to 3 relic choices on top, twisting later node value and card valuation together."
					},
					"tone": Color(0.72, 0.62, 0.94, 1.0),
					"result_group": {
						"title": {"zh": "高压战后链路", "en": "High-Pressure Reward Chain"},
						"summary": {
							"zh": "精英 / Boss 的战后不是单次补强，而是先看牌、再看遗物，把这层风险真正换成一次更完整的路线改写。",
							"en": "Elite and boss rewards are not a single power spike. They first ask for a card read, then a relic read, turning the risk of that floor into a fuller route rewrite."
						},
						"cards": [
							{
								"glyph": "赏",
								"title": {"zh": "先选 1 张奖励牌", "en": "Draft 1 Reward Card First"},
								"subtitle": {"zh": "战后第一拍仍是读牌", "en": "The first beat still reads cards"},
								"body": {
									"zh": "就算是精英或 Boss，source 也不会跳过战后选牌这一拍，路线仍先通过牌张继续加深或修正。",
									"en": "Even after elites or bosses, the source still keeps the draft beat first so the route is deepened or corrected through cards before relics step in."
								},
								"tags": [
									{"zh": "先看牌", "en": "Cards first"},
									{"zh": "节拍完整", "en": "Full cadence"}
								]
							},
							{
								"glyph": "墨",
								"title": {"zh": "行墨罐", "en": "Traveling Inkwell"},
								"subtitle": {"zh": "开局自带 1 墨", "en": "Start each battle with 1 Ink"},
								"body": {
									"zh": "这类遗物会把后续牌组里偏墨、偏成字的判断整体往前推，让某些卡的价值突然明显升高。",
									"en": "A relic like this pushes later Ink and fusion valuation forward, suddenly raising the worth of certain cards across the deck."
								},
								"tags": [
									{"zh": "遗物", "en": "Relic"},
									{"zh": "墨流", "en": "Ink flow"}
								]
							},
							{
								"glyph": "镜",
								"title": {"zh": "镜简", "en": "Mirror Slip"},
								"subtitle": {"zh": "重复偏旁返抽", "en": "Repeated radicals draw back"},
								"body": {
									"zh": "它不会直接给伤害，却会把重复偏旁从“有点尴尬”改写成“愿意主动拿”的资源。",
									"en": "It does not add direct damage, but rewrites repeated radicals from awkward filler into material you may actively want."
								},
								"tags": [
									{"zh": "重复利用", "en": "Repeat use"},
									{"zh": "抽牌", "en": "Draw"}
								]
							},
							{
								"glyph": "契",
								"title": {"zh": "契印", "en": "Broker Seal"},
								"subtitle": {"zh": "商店与遗物折扣", "en": "Cheaper shops and relics"},
								"body": {
									"zh": "有些遗物不会立刻改写战斗，而是把下一段商店、删牌与遗物预算全都压向更激进的方向。",
									"en": "Some relics do not rewrite the next battle immediately, but instead push later shop, purge, and relic budgets toward greedier decisions."
								},
								"tags": [
									{"zh": "商店线", "en": "Shop line"},
									{"zh": "路线偏转", "en": "Route bend"}
								]
							}
						]
					}
				}
			],
			"footnote": {
				"zh": "Godot 这里先给战后链路补上一份可切换的前台样张，让入口能先解释 regular / skip / relic 三种节拍，而不是假装已经接好真实卡战奖励系统。",
				"en": "Godot adds a switchable front-end sample of the reward chain here first, so the portal can explain the regular / skip / relic cadences without pretending the live card-battle reward system already exists in this repo."
			}
		},
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
		"route_preview": {
			"title": {"zh": "三路线塔图预览", "en": "Three-Lane Route Preview"},
			"summary": {
				"zh": "source《仓颉之路》会先把真正的三路线塔图摆出来，而不是只列节点名称。Godot 现在先把这层 route shell 和层间连线一起迁回入口，方便在真正开打前就读懂这次 climb 的转向点。",
				"en": "The source Cangjie Road opens with an actual three-lane tower board instead of only listing node names. Godot now brings that route shell plus its between-row path links back into the portal so the climb's pivot points can be read before a real run starts."
			},
			"default_node_id": "entry_battle",
			"hint": {
				"zh": "点按任一节点，查看 source 里这类房间会怎样改写牌组、资源和后续路线，并预览它更像接哪种战后 / 路书 handoff。",
				"en": "Tap any node to inspect how that room type reshapes the deck, resources, and later route in the source run, including which reward or route-ledger handoff it most naturally feeds into."
			},
			"progress_stub": {
				"title": {"zh": "样张步态", "en": "Sample Step State"},
				"summary": {
					"zh": "source 真正开跑时，点下一个房间后，它会立刻转成已走节点，并把直连下一层点亮成可走。Godot 这里先按当前聚焦节点演示这一步态，让 route shell 更接近 live tower map 的 available / completed 读法。",
					"en": "In the live source climb, choosing a room immediately turns it into a completed node and lights the directly connected next row as available. Godot now stages that same step around the current focus so the route shell reads closer to the live tower map's available / completed flow."
				},
				"cards": [
					{
						"id": "completed",
						"glyph": "已",
						"badge": {"zh": "已走", "en": "Completed"},
						"title": {"zh": "样张已走节点", "en": "Sample Completed Rooms"},
						"body": {
							"zh": "沿当前样张路径已经压过的节点，会保留更实的笔触和层间连线，像 source 里已经踩过的旧拍。",
							"en": "Nodes already pressed through on the sample route keep a firmer stroke and path links, reading like earlier beats already consumed in the source climb."
						},
						"tone": Color(0.94, 0.76, 0.46, 1.0)
					},
					{
						"id": "available",
						"glyph": "启",
						"badge": {"zh": "已开", "en": "Available"},
						"title": {"zh": "下一层可走房间", "en": "Unlocked Next Rooms"},
						"body": {
							"zh": "只有与当前聚焦房间直连的下一层节点会被点亮，先把 source 那种“选完一格再开下一排”的读法挂回前台。",
							"en": "Only the next-row rooms directly connected to the focused stop light up, bringing back the source read where the next row only opens after one room is chosen."
						},
						"tone": Color(0.52, 0.84, 0.8, 1.0)
					},
					{
						"id": "locked",
						"glyph": "锁",
						"badge": {"zh": "未亮", "en": "Locked"},
						"title": {"zh": "仍待开启的侧枝", "en": "Still-Locked Branches"},
						"body": {
							"zh": "其余未接上的房间先保持压暗，避免整张样图像同时可走的静态摆设。",
							"en": "The other unconnected rooms stay dimmed first so the sample map no longer reads like a static board where every stop is equally open."
						},
						"tone": Color(0.64, 0.7, 0.82, 1.0)
					}
				],
				"footnote_format": {
					"zh": "当前样张基于：%s。点按别的节点，会按那一格改写已走与已开状态。",
					"en": "Current sample basis: %s. Tapping another node rewrites the completed and available states around that stop."
				}
			},
			"next_row_handoff": {
				"title": {"zh": "下一排接续", "en": "Next-Row Handoff"},
				"summary": {
					"zh": "source 真正点下一个节点后，亮起的下一排不会只剩状态颜色，而会立刻变成新的路线问题。Godot 这里先把当前聚焦节点真正会点亮的房间抽成一组接续卡，并补上它们更像接战后拿牌、路书事件、稳线修整还是遗物偏转的提示；现在每张卡还会直接带出一小条节点节拍与一枚 `路线读法 / Route Read` cue，先读这一格最常见的 `节点 -> 关键决策 -> 跟进`，以及它更像压深、补短、存势还是保薄兑现。",
					"en": "After the live source map locks a room in, the newly lit row is not just a state color. It immediately becomes the next route question. Godot now pulls the rooms the current focus would actually unlock into a handoff strip, spells out whether they lean toward post-battle drafting, route-ledger pressure, stabilizing resets, or relic bends, and now also exposes both a compact `node -> decision -> follow-through` beat strip and a `Route Read` cue so each unlocked card says whether it behaves more like deepen, patch, tempo bank, or lean-deck cash-in."
				},
				"open_count_format": {
					"zh": "%s · 已开 %d 个节点",
					"en": "%s · %d rooms open"
				},
				"badge": {"zh": "已开房间", "en": "Available Now"},
				"footnote_format": {
					"zh": "当前聚焦：%s。source 真正开跑时，下一排只会点亮这些直连房间，并同时把它们的后手压力一起暴露出来。",
					"en": "Current focus: %s. In the live source climb, only these directly connected rooms would light up on the next row, along with the downstream pressure each one creates."
				},
				"empty_title": {"zh": "塔顶收束", "en": "Summit Closure"},
				"empty_body": {
					"zh": "当前聚焦已经来到样张收束处，下一排不会再展开新房间；source 真正塔顶也会在这里把这次 climb 收回最终 verdict。",
					"en": "The current focus is already at the sample closure, so no new row opens from here; at the live source summit the climb also folds back into its final verdict at this point."
				}
			},
			"state_legend": {
				"title": {"zh": "塔图读法图例", "en": "Route Read Legend"},
				"summary": {
					"zh": "source 真正开跑时，塔图会把当前主脉、侧向转笔与塔顶收束读得很清楚。Godot 这里先用样张图例把 route shell 的读法讲明白，让静态壳层也能更像一张可导航的爬塔图。",
					"en": "In the live source climb, the map clearly separates the current backbone, lateral pivots, and summit closure. Godot stages that same read as a sample legend first so the route shell feels closer to a navigable tower board."
				},
				"items": [
					{
						"id": "path",
						"glyph": "主",
						"badge": {"zh": "主脉", "en": "Backbone"},
						"title": {"zh": "当前主脉", "en": "Current Backbone"},
						"body": {
							"zh": "样张里更稳、更常见的推进拍，会把这一层 climb 的主方向先压出来。",
							"en": "The steadier, more common forward beats in the sample that press the climb's main direction first."
						},
						"tone": Color(0.94, 0.76, 0.46, 1.0)
					},
					{
						"id": "option",
						"glyph": "转",
						"badge": {"zh": "转笔", "en": "Pivot"},
						"title": {"zh": "侧向转笔", "en": "Lateral Pivot"},
						"body": {
							"zh": "更像事件、修薄或高压换向的侧枝节点，告诉你路线可以在这里偏转。",
							"en": "The side-branch beats that act more like events, trims, or high-pressure route bends."
						},
						"tone": Color(0.72, 0.66, 0.94, 1.0)
					},
					{
						"id": "boss",
						"glyph": "定",
						"badge": {"zh": "收束", "en": "Closure"},
						"title": {"zh": "塔顶收束", "en": "Summit Closure"},
						"body": {
							"zh": "塔图的收尾检验拍，把整条路线压到最后一次总判定上。",
							"en": "The end-cap exam beat that collapses the whole route into one final verdict."
						},
						"tone": Color(0.86, 0.68, 0.96, 1.0)
					},
					{
						"id": "focus",
						"glyph": "焦",
						"badge": {"zh": "聚焦", "en": "Focus"},
						"title": {"zh": "当前点按", "en": "Current Focus"},
						"body": {
							"zh": "当前点按节点会同步带出路线丝带和战后 / 路书跟进样张，方便一眼看到前后手。",
							"en": "The tapped node also drives the Route Ribbon and linked reward or ledger follow-through so the before-and-after beat is visible at a glance."
						},
						"tone": Color(0.52, 0.84, 0.8, 1.0)
					}
				]
			},
			"route_ribbon": {
				"title": {"zh": "路线丝带", "en": "Route Ribbon"},
				"summary": {
					"zh": "source 的塔图不会把节点孤立看待。Godot 这里先把当前聚焦房间塞回一条代表性 climb 样张里，让你先读到它前后通常会怎样接续。",
					"en": "The source tower board does not treat nodes as isolated stops. Godot now drops the focused room back into a representative climb sample so its before-and-after handoff reads more like one route."
				}
			},
			"node_details": {
				"battle": {
					"route_read": {
						"title": {"zh": "主线加深", "en": "Main-Line Deepen"},
						"summary": {
							"zh": "Gold 加上三选一奖励，让这类房间最适合继续把当前主线写厚；若牌组已经够稳，也会顺手提醒你保薄仍是选项。",
							"en": "Gold plus the three-card reward makes this the cleanest room for thickening the current spine, while still reminding you that staying lean remains an option once the deck already runs well."
						},
						"tone": Color(0.94, 0.74, 0.42, 1.0)
					},
					"follow_through": {
						"label": {"zh": "联动预览 · 战后抉择", "en": "Linked Preview · Post-Battle Flow"},
						"tags": [
							{"zh": "Gold + 选牌", "en": "Gold + draft"},
							{"zh": "继续压深或保薄", "en": "Deepen or stay lean"}
						]
					},
					"summary": {
						"zh": "普通战斗会先结算 Gold，再给三选一奖励牌或跳过保薄，是最稳定的路线读法。",
						"en": "Regular battles settle Gold first, then offer a three-card reward or a lean skip, making them the steadiest route read."
					},
					"route_ribbon": {
						"title": {"zh": "节点节拍带", "en": "Node Beat Ribbon"},
						"summary": {
							"zh": "把 source 里这一类节点最常见的 `战斗 -> Gold -> 选牌或跳过` 节拍直接拉成前台样张，让塔图不只剩一个静态说明卡。",
							"en": "This pulls the source node's usual `battle -> Gold -> draft or skip` cadence into a front-end sample, so the tower map reads as more than a static explainer."
						},
						"steps": [
							{
								"glyph": "战",
								"title": {"zh": "战斗", "en": "Battle"},
								"subtitle": {"zh": "先读敌意图", "en": "Read intents first"}
							},
							{
								"glyph": "金",
								"title": {"zh": "Gold", "en": "Gold"},
								"subtitle": {"zh": "先落本层预算", "en": "Bank the floor budget"}
							},
							{
								"glyph": "牌",
								"title": {"zh": "选牌 / 跳过", "en": "Draft / Skip"},
								"subtitle": {"zh": "压深或保薄", "en": "Deepen or stay lean"}
							}
						]
					},
					"group": {
						"title": {"zh": "节点聚焦 · 战斗", "en": "Node Focus · Battle"},
						"summary": {
							"zh": "source 的普通战斗不是纯清杂，而是用最稳定的奖后节拍反复验证这副牌到底想往哪条字路走。",
							"en": "Source normal battles are not filler fights. Their stable post-fight cadence repeatedly checks which glyph route the deck truly wants to follow."
						},
						"cards": [
							{
								"glyph": "战",
								"title": {"zh": "Gold + 选牌 / 跳过", "en": "Gold + Draft / Skip"},
								"subtitle": {"zh": "最直接的主线读法", "en": "The cleanest line read"},
								"body": {
									"zh": "普通战斗会先把 Gold 落袋，再逼你判断这一层是继续补主线、补控制，还是干脆保薄不再加厚牌组。",
									"en": "A normal fight banks Gold first, then forces a judgment call: deepen the main line, patch control, or stay lean and skip thickening the deck."
								},
								"tags": [
									{"zh": "Gold", "en": "Gold"},
									{"zh": "三选一", "en": "Pick one of three"},
									{"zh": "保薄", "en": "Stay lean"}
								]
							}
						]
					}
				},
				"event": {
					"route_read": {
						"title": {"zh": "顺势压深", "en": "Press The Current Lean"},
						"summary": {
							"zh": "事件房会先读当前牌组倾向，所以它最像顺着已经冒头的那条线再压一拍，而不是给一份不看上下文的平面奖励。",
							"en": "Event rooms read the current deck lean first, so they behave most like pressing the line that is already surfacing instead of handing out a flat reward with no context."
						},
						"tone": Color(0.94, 0.74, 0.42, 1.0)
					},
					"follow_through": {
						"label": {"zh": "联动预览 · 路书对照", "en": "Linked Preview · Route Ledger"},
						"tags": [
							{"zh": "读当前 deck 倾向", "en": "Read current deck lean"},
							{"zh": "压深 / 补短 / 存势", "en": "Deepen / patch / tempo"}
						]
					},
					"summary": {
						"zh": "事件节点会像 `路书对照`、讲师提问或破页掮客那样，让短期收益和长期结构直接撞在一起。",
						"en": "Event nodes act more like `Route Ledger`, the tutor prompt, or the page broker, colliding short-term gain with long-term structure."
					},
					"route_ribbon": {
						"title": {"zh": "节点节拍带", "en": "Node Beat Ribbon"},
						"summary": {
							"zh": "source 的事件不是平铺奖励，而是先读当前牌组倾向，再把 `路书 -> 回应` 这层抉择摊到台面上。",
							"en": "Source events are not flat rewards. They read the current deck lean first, then surface the `ledger -> response` decision directly."
						},
						"steps": [
							{
								"glyph": "异",
								"title": {"zh": "事件", "en": "Event"},
								"subtitle": {"zh": "先读当前倾向", "en": "Read the current lean"}
							},
							{
								"glyph": "路",
								"title": {"zh": "路书对照", "en": "Route Ledger"},
								"subtitle": {"zh": "把路线摊开", "en": "Lay the route bare"}
							},
							{
								"glyph": "势",
								"title": {"zh": "回应三选一", "en": "Choose A Response"},
								"subtitle": {"zh": "压深 / 补短 / 存势", "en": "Deepen / patch / tempo"}
							}
						]
					},
					"group": {
						"title": {"zh": "节点聚焦 · 事件", "en": "Node Focus · Event"},
						"summary": {
							"zh": "source 事件房的价值在于先读当前 deck 倾向，再决定是压深主线、补齐短板，还是换一笔资源留给后面。",
							"en": "Source event rooms matter because they read the current deck lean first, then choose whether to deepen the line, patch a weak point, or bank resources for later."
						},
						"cards": [
							{
								"glyph": "异",
								"title": {"zh": "路书 / 教案 / 掮客", "en": "Ledger / Tutor / Broker"},
								"subtitle": {"zh": "短期换长期", "en": "Short term vs long term"},
								"body": {
									"zh": "这里最能看出《仓颉之路》的 deckbuilder 身份，因为事件会主动改写路线，而不是只给一张通用奖励牌。",
									"en": "This is where Cangjie Road reads most like a deckbuilder, because events actively rewrite the route instead of handing out one generic reward."
								},
								"tags": [
									{"zh": "路书对照", "en": "Route Ledger"},
									{"zh": "取舍", "en": "Tradeoff"},
									{"zh": "路线偏转", "en": "Route bend"}
								]
							}
						]
					}
				},
				"rest": {
					"route_read": {
						"title": {"zh": "补齐短板", "en": "Patch The Weak Point"},
						"summary": {
							"zh": "这类节点先把血线、格挡或起手容错拉回来，所以更像给当前 deck 补底板，而不是继续贪主线厚度。",
							"en": "This node restores HP, defense, or opening margin first, so it reads more like raising the deck's floor than greedily thickening the main line again."
						},
						"tone": Color(0.56, 0.84, 0.8, 1.0)
					},
					"follow_through": {
						"label": {"zh": "联动预览 · 稳线节拍", "en": "Linked Preview · Stabilize Beat"},
						"tags": [
							{"zh": "回血 / 起手准备", "en": "Heal / opening setup"},
							{"zh": "低风险调整", "en": "Low-risk reset"}
						]
					},
					"summary": {
						"zh": "歇息点不是单纯回血，而是在 `回气 18` 与 `回气 8 + 下场 +1 Energy / +1 Ink` 之间做低风险准备。",
						"en": "Rest stops are not pure healing. They split between `heal 18` and `heal 8 + next battle +1 Energy / +1 Ink`."
					},
					"route_ribbon": {
						"title": {"zh": "节点节拍带", "en": "Node Beat Ribbon"},
						"summary": {
							"zh": "歇息房的关键不是停下来，而是把 `歇息 -> 回气或备战 -> 下场起手` 这段低风险节拍讲清楚。",
							"en": "Rest rooms matter less as a pause than as a clear `rest -> heal or prepare -> next opener` cadence."
						},
						"steps": [
							{
								"glyph": "歇",
								"title": {"zh": "歇息", "en": "Rest"},
								"subtitle": {"zh": "稳住当前血线", "en": "Stabilize current HP"}
							},
							{
								"glyph": "气",
								"title": {"zh": "回气 / 备战", "en": "Heal / Prepare"},
								"subtitle": {"zh": "二选一起手", "en": "Pick the safer opener"}
							},
							{
								"glyph": "启",
								"title": {"zh": "下场起手", "en": "Next Opener"},
								"subtitle": {"zh": "把节奏垫前一拍", "en": "Pull the tempo forward"}
							}
						]
					},
					"group": {
						"title": {"zh": "节点聚焦 · 歇息", "en": "Node Focus · Rest"},
						"summary": {
							"zh": "source 的歇息房把保命和下一场起手准备放在同一张 prompt 上，提醒路线判断不只发生在拿牌时。",
							"en": "Source rest rooms put survival and next-battle setup on the same prompt, reminding you that route judgment does not happen only while drafting."
						},
						"cards": [
							{
								"glyph": "歇",
								"title": {"zh": "回气 / 备战二选一", "en": "Heal / Prepare Split"},
								"subtitle": {"zh": "稳住血线或抢起手", "en": "Stabilize HP or frontload tempo"},
								"body": {
									"zh": "当血线还算安全时，歇息房也可以转成下场的节奏垫片，而不是永远只做回血站。",
									"en": "When HP is still safe enough, a rest room can convert into a tempo pad for the next fight instead of always acting as a heal station."
								},
								"tags": [
									{"zh": "回血", "en": "Healing"},
									{"zh": "下场起手", "en": "Next-battle opener"},
									{"zh": "低风险调整", "en": "Low-risk reset"}
								]
							}
						]
					}
				},
				"shop": {
					"route_read": {
						"title": {"zh": "先存节奏", "en": "Bank Tempo First"},
						"summary": {
							"zh": "商店会把 Gold 变成补货、删牌和货架取舍，所以它更像先把下一段预算与起手势能握稳，而不一定立刻再拿一张牌。",
							"en": "Shops turn Gold into restocks, purges, and shelf tradeoffs, so they read more like banking the next stretch's budget and opener tempo than immediately taking another card."
						},
						"tone": Color(0.72, 0.62, 0.94, 1.0)
					},
					"follow_through": {
						"label": {"zh": "联动预览 · Gold 重配", "en": "Linked Preview · Gold Reallocation"},
						"tags": [
							{"zh": "买牌 / 遗物 / 删牌", "en": "Cards / relics / purge"},
							{"zh": "restock", "en": "Restock"}
						]
					},
					"summary": {
						"zh": "商店会同时卖牌和遗物，还支持 restock 与花 Gold 删牌，是整条 climb 里最显性的资源重配节点。",
						"en": "Shops sell both cards and relics while also supporting restocks and paid deck trims, making them the clearest resource-reallocation node in the climb."
					},
					"route_ribbon": {
						"title": {"zh": "节点节拍带", "en": "Node Beat Ribbon"},
						"summary": {
							"zh": "source 商店会把 `货架 -> 补货 / 删牌` 串成一段连续的 Gold 重配节拍，而不是一次性买完就走。",
							"en": "The source shop turns `shelf -> restock / purge` into a continuous Gold-reallocation beat instead of a one-and-done purchase."
						},
						"steps": [
							{
								"glyph": "肆",
								"title": {"zh": "商店", "en": "Shop"},
								"subtitle": {"zh": "先读当前预算", "en": "Read the current budget"}
							},
							{
								"glyph": "货",
								"title": {"zh": "牌 / 遗物货架", "en": "Card / Relic Shelf"},
								"subtitle": {"zh": "决定买哪一侧", "en": "Choose where to spend"}
							},
							{
								"glyph": "刷",
								"title": {"zh": "补货 / 删牌", "en": "Restock / Purge"},
								"subtitle": {"zh": "重洗或修薄", "en": "Reroll or thin the deck"}
							}
						]
					},
					"group": {
						"title": {"zh": "节点聚焦 · 商店", "en": "Node Focus · Shop"},
						"summary": {
							"zh": "source 商店不是单次消费，而是在买牌、买遗物、删牌和重洗货架之间重新分配 Gold。",
							"en": "The source shop is not a one-off purchase. It reallocates Gold across cards, relics, purges, and shelf restocks."
						},
						"cards": [
							{
								"glyph": "肆",
								"title": {"zh": "买牌 / 买遗物 / 删牌", "en": "Buy / Relic / Purge"},
								"subtitle": {"zh": "Gold 真正开始写路线", "en": "Gold starts steering the route"},
								"body": {
									"zh": "当 run 已有明显倾向时，商店会把 Gold 从数值资源变成路线投资，甚至能靠 restock 继续追更贴线的货架。",
									"en": "Once a run has a visible lean, the shop turns Gold from a flat resource into route investment, and restock can keep chasing a more aligned shelf."
								},
								"tags": [
									{"zh": "Gold 重配", "en": "Gold reallocation"},
									{"zh": "restock", "en": "Restock"},
									{"zh": "删牌", "en": "Purge"}
								]
							}
						]
					}
				},
				"elite": {
					"route_read": {
						"title": {"zh": "高压换方向", "en": "Risk For Direction"},
						"summary": {
							"zh": "精英的压力更高，但战后还会继续接遗物偏转，所以它最像用一拍高风险换一次更重的路线改写。",
							"en": "Elites bring more pressure, but the post-fight relic bend keeps going afterward, so they read most like trading one high-risk beat for a heavier route rewrite."
						},
						"tone": Color(0.72, 0.62, 0.94, 1.0)
					},
					"follow_through": {
						"label": {"zh": "联动预览 · 战后遗物", "en": "Linked Preview · Post-Elite Relic"},
						"tags": [
							{"zh": "高压换 relic", "en": "Pressure for relic"},
							{"zh": "二次偏转路线", "en": "Second route bend"}
						]
					},
					"summary": {
						"zh": "精英不只更痛，它还会把战后流程往后推一层：先打高压意图，再接遗物跟进，让路线被二次偏转。",
						"en": "Elites are not only harder. They push the post-battle flow one layer deeper: survive heavier intents, then take a relic follow-up that bends the route again."
					},
					"route_ribbon": {
						"title": {"zh": "节点节拍带", "en": "Node Beat Ribbon"},
						"summary": {
							"zh": "精英房会把 `高压战斗 -> 选牌 -> 遗物` 串成一段更重的路线改写节拍，让风险和方向绑在一起。",
							"en": "Elite rooms chain `high-pressure fight -> draft -> relic` into a heavier route-rewrite cadence, binding risk and direction together."
						},
						"steps": [
							{
								"glyph": "魁",
								"title": {"zh": "精英", "en": "Elite"},
								"subtitle": {"zh": "顶住更重敌意图", "en": "Survive heavier intents"}
							},
							{
								"glyph": "牌",
								"title": {"zh": "战后选牌", "en": "Post-Battle Draft"},
								"subtitle": {"zh": "先读牌组缺口", "en": "Read the deck gap first"}
							},
							{
								"glyph": "宝",
								"title": {"zh": "遗物跟进", "en": "Relic Follow-Up"},
								"subtitle": {"zh": "再弯一次路线", "en": "Bend the route again"}
							}
						]
					},
					"group": {
						"title": {"zh": "节点聚焦 · 精英", "en": "Node Focus · Elite"},
						"summary": {
							"zh": "source 精英是“高压换方向”的代表房型，因为它把更危险的敌意图和遗物后续绑在同一个节点里。",
							"en": "Source elites are the clearest `risk for direction` room because they bind heavier intents and relic follow-through inside the same node."
						},
						"cards": [
							{
								"glyph": "魁",
								"title": {"zh": "高压战后遗物", "en": "High-Pressure Relic Follow-Up"},
								"subtitle": {"zh": "更痛，但也更会改路", "en": "Harder, but more route-defining"},
								"body": {
									"zh": "精英战后不是只多拿一点数值，而是会在选牌后继续给 2 到 3 件遗物，让后面的节点估值一起改写。",
									"en": "Elite fights do not just pay larger numbers. After the reward card they continue into 2 to 3 relic choices, rewriting the value of later nodes as well."
								},
								"tags": [
									{"zh": "高压", "en": "High pressure"},
									{"zh": "遗物后续", "en": "Relic follow-up"},
									{"zh": "换方向", "en": "Route bend"}
								]
							}
						]
					}
				},
				"archive": {
					"route_read": {
						"title": {"zh": "保薄兑现", "en": "Cash In Lean Deck"},
						"summary": {
							"zh": "删改房会把前面保薄或修线的判断真正兑现成更干净的抽牌质量，所以它更像把已有克制换成稳定收益。",
							"en": "Archive rooms cash earlier lean-deck or route-tuning choices into cleaner draws, so they behave like turning existing discipline into steadier value."
						},
						"tone": Color(0.58, 0.82, 0.78, 1.0)
					},
					"follow_through": {
						"label": {"zh": "联动预览 · 修薄 / 复制", "en": "Linked Preview · Trim / Duplicate"},
						"tags": [
							{"zh": "删牌", "en": "Trim"},
							{"zh": "复制关键件", "en": "Duplicate key piece"}
						]
					},
					"summary": {
						"zh": "删改房不是单一删牌口。source 会在 `删 1 张` 与 `复制 1 张非 Smudge 牌` 之间切换，让牌组形状同时可收可放。",
						"en": "Archive rooms are not trim-only. The source switches between `remove 1 card` and `copy 1 non-Smudge card`, so deck shape can tighten or widen on purpose."
					},
					"route_ribbon": {
						"title": {"zh": "节点节拍带", "en": "Node Beat Ribbon"},
						"summary": {
							"zh": "删改房的重点是把 `删改 -> 选模式 -> 改牌组形状` 变成一段清晰节拍，而不是只把它当成一个删牌按钮。",
							"en": "Archive rooms matter because they turn `archive -> choose mode -> reshape deck` into a clear cadence instead of a single trim button."
						},
						"steps": [
							{
								"glyph": "删",
								"title": {"zh": "删改", "en": "Archive"},
								"subtitle": {"zh": "先读 deck 厚薄", "en": "Read deck thickness first"}
							},
							{
								"glyph": "择",
								"title": {"zh": "修薄 / 复制", "en": "Trim / Duplicate"},
								"subtitle": {"zh": "决定收还是放", "en": "Tighten or widen on purpose"}
							},
							{
								"glyph": "形",
								"title": {"zh": "牌组形状改写", "en": "Deck Shape Rewrite"},
								"subtitle": {"zh": "把抽牌质量往回拉", "en": "Pull draw quality back"}
							}
						]
					},
					"group": {
						"title": {"zh": "节点聚焦 · 删改", "en": "Node Focus · Archive"},
						"summary": {
							"zh": "source 的 archive 房把“修薄”和“复制关键件”放在一起，说明 deck 质量不只靠少，也可能靠更准确的重复。",
							"en": "Source archive rooms keep trimming and duplicating key pieces together, showing that deck quality is not only about having fewer cards but also about cleaner repetition."
						},
						"cards": [
							{
								"glyph": "删",
								"title": {"zh": "修薄或复制", "en": "Trim Or Duplicate"},
								"subtitle": {"zh": "控制牌组形状", "en": "Control deck shape"},
								"body": {
									"zh": "当主线已经够清楚时，archive 会帮你去掉拖节奏的页；若关键件还不够稳，也可以复制一张真正贴线的牌。",
									"en": "Once the main line is clear, archive can cut the pages that drag the pace; if the key piece is still too rare, it can also duplicate the card that truly fits the route."
								},
								"tags": [
									{"zh": "删牌", "en": "Trim"},
									{"zh": "复制", "en": "Duplicate"},
									{"zh": "抽牌质量", "en": "Draw quality"}
								]
							}
						]
					}
				},
				"treasure": {
					"route_read": {
						"title": {"zh": "遗物偏转", "en": "Relic Bend"},
						"summary": {
							"zh": "可见遗物会直接改写你对后续牌、商店和节点的估值，所以这类分支最像把整条 climb 的判断口径一起扭向新方向。",
							"en": "Visible relics directly rewrite how later cards, shops, and nodes are valued, so this branch behaves like twisting the climb's judgment scale toward a new direction at once."
						},
						"tone": Color(0.72, 0.62, 0.94, 1.0)
					},
					"follow_through": {
						"label": {"zh": "联动预览 · 可见遗物", "en": "Linked Preview · Visible Relic"},
						"tags": [
							{"zh": "三选一 relic", "en": "Pick 1 relic"},
							{"zh": "改写后续估值", "en": "Rewrite later value"}
						]
					},
					"summary": {
						"zh": "遗物房会把几件可见 relic 摊在面前，让你直接挑那件最能偏转当前路线的东西，而不是只吃随机宝箱。",
						"en": "Treasure rooms lay several visible relics in front of you so you can choose the one that best bends the current route instead of taking a blind chest roll."
					},
					"route_ribbon": {
						"title": {"zh": "节点节拍带", "en": "Node Beat Ribbon"},
						"summary": {
							"zh": "遗物房会把 `打开遗物匣 -> 可见三选一 -> 重估后续节点` 这段改路节拍直接摆在玩家面前。",
							"en": "Treasure rooms put the `open relic shelf -> visible pick -> revalue later nodes` cadence directly in front of the player."
						},
						"steps": [
							{
								"glyph": "宝",
								"title": {"zh": "遗物房", "en": "Treasure"},
								"subtitle": {"zh": "先开这一层匣子", "en": "Open this floor's shelf"}
							},
							{
								"glyph": "择",
								"title": {"zh": "可见三选一", "en": "Visible Relic Pick"},
								"subtitle": {"zh": "挑最贴线那件", "en": "Choose the most aligned one"}
							},
							{
								"glyph": "改",
								"title": {"zh": "后续重估", "en": "Revalue Later Floors"},
								"subtitle": {"zh": "连节点估值都改写", "en": "Even node value bends afterward"}
							}
						]
					},
					"group": {
						"title": {"zh": "节点聚焦 · 遗物", "en": "Node Focus · Treasure"},
						"summary": {
							"zh": "source 的 treasure 房会把遗物选择直接放到塔图节奏里，让路线判断不只发生在精英或 Boss 奖励之后。",
							"en": "Source treasure rooms place relic choice directly inside the tower rhythm, so route judgment does not happen only after elite or boss rewards."
						},
						"cards": [
							{
								"glyph": "宝",
								"title": {"zh": "可见遗物三选一", "en": "Visible Relic Choice"},
								"subtitle": {"zh": "直接弯一次路线", "en": "Bend the line directly"},
								"body": {
									"zh": "遗物房会把路线判断从抽牌层抬到整套 run shell：之后的 Gold、商店和战后选牌都会跟着这件 relic 重新估值。",
									"en": "Treasure rooms raise route judgment above drafting alone: later Gold, shop choices, and reward cards are all re-evaluated through the chosen relic."
								},
								"tags": [
									{"zh": "遗物", "en": "Relic"},
									{"zh": "节点偏转", "en": "Node bend"},
									{"zh": "路线再估值", "en": "Revalue route"}
								]
							}
						]
					}
				},
				"boss": {
					"route_read": {
						"title": {"zh": "终局定稿", "en": "Final Verdict"},
						"summary": {
							"zh": "塔顶会把前面所有压深、补漏、存势和遗物偏转一起检验完，所以这一步更像整副牌的最终定稿，而不是单个节点奖励。",
							"en": "The summit tests every earlier deepen, patch, tempo-bank, and relic bend together, so this step reads more like the build's final verdict than a single-node reward."
						},
						"tone": Color(0.86, 0.68, 0.96, 1.0)
					},
					"follow_through": {
						"label": {"zh": "联动预览 · 塔顶定稿", "en": "Linked Preview · Summit Verdict"},
						"tags": [
							{"zh": "整副牌总检验", "en": "Full-build exam"},
							{"zh": "收尾 relic / verdict", "en": "Finishing relic / verdict"}
						]
					},
					"summary": {
						"zh": "Boss 是整副牌的总检验。此时路线、遗物、Gold 重配与事件取舍都会一起压到最后一场问答里。",
						"en": "The boss is the full-build exam. By then the route, relics, Gold reallocation, and event tradeoffs all collapse into one final question."
					},
					"route_ribbon": {
						"title": {"zh": "节点节拍带", "en": "Node Beat Ribbon"},
						"summary": {
							"zh": "source 塔顶会把 `Boss -> 塔顶抉择 -> 路线定稿` 串成最后一段总结，让 climb 真正落到一个 verdict 上。",
							"en": "At the source summit, `boss -> summit choice -> route verdict` becomes the final summary cadence that lets the climb land on a real verdict."
						},
						"steps": [
							{
								"glyph": "塔",
								"title": {"zh": "Boss", "en": "Boss"},
								"subtitle": {"zh": "整副牌受检", "en": "Test the full build"}
							},
							{
								"glyph": "判",
								"title": {"zh": "塔顶抉择", "en": "Summit Choice"},
								"subtitle": {"zh": "读最后一笔取舍", "en": "Read the final tradeoff"}
							},
							{
								"glyph": "定",
								"title": {"zh": "路线定稿", "en": "Route Verdict"},
								"subtitle": {"zh": "看这条线是否站稳", "en": "See whether the line truly holds"}
							}
						]
					},
					"group": {
						"title": {"zh": "节点聚焦 · Boss", "en": "Node Focus · Boss"},
						"summary": {
							"zh": "source 的 summit 并不只是血量更厚，而是会用更完整的敌意图与节奏问题要求整套 deck 给出清晰答案。",
							"en": "The source summit is not just a larger HP bar. It uses fuller intent patterns and pacing questions to demand a clear answer from the entire deck."
						},
						"cards": [
							{
								"glyph": "塔",
								"title": {"zh": "整副牌的总检验", "en": "Full-Build Exam"},
								"subtitle": {"zh": "路线是否真的成型", "en": "Did the route truly form"},
								"body": {
									"zh": "到了塔顶，之前所有战后拿牌、事件补件、删改与遗物偏转都会一起接受检验，告诉你这条字路到底有没有站稳。",
									"en": "At the summit, every earlier draft, event patch, archive pass, and relic bend is tested together to reveal whether the chosen glyph route truly holds."
								},
								"tags": [
									{"zh": "Boss", "en": "Boss"},
									{"zh": "总检验", "en": "Final exam"},
									{"zh": "路线定稿", "en": "Route verdict"}
								]
							}
						]
					}
				}
			},
			"rows": [
				{
					"floor": {"zh": "第 1 层", "en": "Floor 1"},
					"nodes": [
						{
							"id": "entry_battle",
							"kind": "battle",
							"lane": "left",
							"glyph": "战",
							"label": {"zh": "战斗", "en": "Battle"},
							"note": {"zh": "先读主线", "en": "Read the line"},
							"focus_title": {"zh": "战斗节点 · 读主线", "en": "Battle Node · Read The Line"},
							"focus_body": {
								"zh": "普通战斗最稳定地把 Gold 和三选一奖励接在一起，适合先看清这一趟 climb 到底在往哪条字路倾斜。",
								"en": "Regular battles are the steadiest way to chain Gold into a three-card reward, making them the cleanest place to read which line this climb is really leaning toward."
							},
							"focus_tags": [
								{"zh": "Gold + 选牌", "en": "Gold + draft"},
								{"zh": "常规战后", "en": "Regular reward"}
							],
							"linked_preview_kind": "reward_chain",
							"linked_preview_option": "draft",
							"connections": ["mid_battle", "shop_node"],
							"tone": Color(0.94, 0.74, 0.42, 1.0),
							"state": "path"
						},
						{
							"id": "route_event",
							"kind": "event",
							"lane": "center",
							"glyph": "异",
							"label": {"zh": "事件", "en": "Event"},
							"note": {"zh": "短期换长期", "en": "Short vs long"},
							"focus_title": {"zh": "事件节点 · 回写路线", "en": "Event Node · Write Back The Route"},
							"focus_body": {
								"zh": "事件节点更像一面镜子，会先读当前牌组倾向，再决定是继续压深、补齐短板，还是先把节奏存起来。",
								"en": "Event nodes act more like mirrors: they read the current deck lean first, then decide whether to deepen it, patch a weak point, or bank tempo instead."
							},
							"focus_tags": [
								{"zh": "deck-read", "en": "Deck read"},
								{"zh": "事件分支", "en": "Event branch"}
							],
							"linked_preview_kind": "route_ledger",
							"linked_preview_option": "deepen",
							"connections": ["mid_battle", "shop_node", "elite_node"],
							"tone": Color(0.72, 0.62, 0.94, 1.0),
							"state": "option"
						},
						{
							"id": "rest_stop",
							"kind": "rest",
							"lane": "right",
							"glyph": "歇",
							"label": {"zh": "歇息", "en": "Rest"},
							"note": {"zh": "稳住气血", "en": "Stabilize HP"},
							"focus_title": {"zh": "歇息节点 · 稳住底板", "en": "Rest Node · Raise The Floor"},
							"focus_body": {
								"zh": "歇息节点先把气血和容错拉回来，再决定下一拍是补防守短板，还是更贪后面的爆发窗口。",
								"en": "Rest nodes restore HP and margin first, then let the climb decide whether the next beat should patch defense or greed toward a later spike."
							},
							"focus_tags": [
								{"zh": "续航", "en": "Sustain"},
								{"zh": "补短板", "en": "Patch first"}
							],
							"linked_preview_kind": "route_ledger",
							"linked_preview_option": "patch",
							"connections": ["shop_node", "elite_node"],
							"tone": Color(0.54, 0.82, 0.88, 1.0),
							"state": "option"
						}
					]
				},
				{
					"floor": {"zh": "第 2 层", "en": "Floor 2"},
					"nodes": [
						{
							"id": "mid_battle",
							"kind": "battle",
							"lane": "left",
							"glyph": "战",
							"label": {"zh": "战斗", "en": "Battle"},
							"note": {"zh": "继续拿牌", "en": "Keep drafting"},
							"focus_title": {"zh": "战斗节点 · 继续塑形", "en": "Battle Node · Keep Shaping"},
							"focus_body": {
								"zh": "战斗节点会继续把拿牌和 Gold 合并在一起，让路线判断不是一锤子买卖，而是层层加深的 build 选择。",
								"en": "Battle nodes keep card rewards and Gold bundled together so route reading is not a one-off decision, but a build direction reinforced floor after floor."
							},
							"focus_tags": [
								{"zh": "继续拿牌", "en": "Keep drafting"},
								{"zh": "稳定推进", "en": "Steady push"}
							],
							"linked_preview_kind": "reward_chain",
							"linked_preview_option": "draft",
							"connections": ["archive_node", "treasure_node"],
							"tone": Color(0.94, 0.74, 0.42, 1.0),
							"state": "option"
						},
						{
							"id": "shop_node",
							"kind": "shop",
							"lane": "center",
							"glyph": "肆",
							"label": {"zh": "商店", "en": "Shop"},
							"note": {"zh": "重配 Gold", "en": "Reassign Gold"},
							"focus_title": {"zh": "商店节点 · 重配预算", "en": "Shop Node · Reassign The Budget"},
							"focus_body": {
								"zh": "商店节点会把前面攒下的 Gold 和抽牌洁净度真正换成路线重配空间，不只是单纯买一张更大的牌。",
								"en": "Shop nodes turn saved Gold and a cleaner deck into real route-reassignment room instead of simply buying the numerically biggest card."
							},
							"focus_tags": [
								{"zh": "Gold 预算", "en": "Gold budget"},
								{"zh": "节奏存势", "en": "Bank tempo"}
							],
							"linked_preview_kind": "route_ledger",
							"linked_preview_option": "tempo",
							"connections": ["archive_node", "treasure_node", "late_battle"],
							"tone": Color(0.96, 0.82, 0.46, 1.0),
							"state": "path"
						},
						{
							"id": "elite_node",
							"kind": "elite",
							"lane": "right",
							"glyph": "魁",
							"label": {"zh": "精英", "en": "Elite"},
							"note": {"zh": "高压换方向", "en": "Risk for direction"},
							"focus_title": {"zh": "精英节点 · 用压力换方向", "en": "Elite Node · Risk For Direction"},
							"focus_body": {
								"zh": "精英往往是最容易把路线真正扳向一侧的压力点，因为战后不只拿牌，还会继续接遗物跟进。",
								"en": "Elites are often the point where a route truly swings to one side, because the aftermath does not stop at cards and keeps going into relic follow-through."
							},
							"focus_tags": [
								{"zh": "高压", "en": "Pressure"},
								{"zh": "遗物跟进", "en": "Relic follow-up"}
							],
							"linked_preview_kind": "reward_chain",
							"linked_preview_option": "relic",
							"connections": ["treasure_node", "late_battle"],
							"tone": Color(0.94, 0.58, 0.48, 1.0),
							"state": "option"
						}
					]
				},
				{
					"floor": {"zh": "第 3 层", "en": "Floor 3"},
					"nodes": [
						{
							"id": "archive_node",
							"kind": "archive",
							"lane": "left",
							"glyph": "删",
							"label": {"zh": "删改", "en": "Archive"},
							"note": {"zh": "把牌组修薄", "en": "Thin the deck"},
							"focus_title": {"zh": "删改节点 · 把保薄兑现", "en": "Archive Node · Cash In Leaning Out"},
							"focus_body": {
								"zh": "删改节点更像给整副牌做手术，适合把“跳过奖励保薄”这类选择真正兑现成更干净的抽牌质量。",
								"en": "Archive nodes feel more like surgery on the whole deck, making them the right place to cash in choices such as skipping rewards to preserve cleaner draws."
							},
							"focus_tags": [
								{"zh": "精简", "en": "Trim"},
								{"zh": "保薄", "en": "Stay lean"}
							],
							"linked_preview_kind": "reward_chain",
							"linked_preview_option": "skip",
							"connections": ["summit_boss"],
							"tone": Color(0.86, 0.8, 0.56, 1.0),
							"state": "option"
						},
						{
							"id": "treasure_node",
							"kind": "treasure",
							"lane": "center",
							"glyph": "宝",
							"label": {"zh": "遗物", "en": "Treasure"},
							"note": {"zh": "遗物偏转", "en": "Relic bend"},
							"focus_title": {"zh": "遗物节点 · 改写估值", "en": "Treasure Node · Rewrite Value"},
							"focus_body": {
								"zh": "遗物节点的关键不在数值更大，而在它会改写你对后续牌、商店和节点价值的判断。",
								"en": "Treasure nodes matter not because the numbers are bigger, but because they rewrite how later cards, shops, and node choices are evaluated."
							},
							"focus_tags": [
								{"zh": "遗物", "en": "Relic"},
								{"zh": "后续偏转", "en": "Future bend"}
							],
							"linked_preview_kind": "reward_chain",
							"linked_preview_option": "relic",
							"connections": ["summit_boss"],
							"tone": Color(0.52, 0.84, 0.8, 1.0),
							"state": "path"
						},
						{
							"id": "late_battle",
							"kind": "battle",
							"lane": "right",
							"glyph": "战",
							"label": {"zh": "战斗", "en": "Battle"},
							"note": {"zh": "继续进塔", "en": "Keep climbing"},
							"focus_title": {"zh": "战斗节点 · 把路线写到底", "en": "Battle Node · Write The Route Through"},
							"focus_body": {
								"zh": "到了更高层时，战斗节点更像一次总检阅，确认现在该继续拿牌压深，还是回头修整整副牌的厚度。",
								"en": "By the higher floors, a battle node reads like a full inspection that tests whether the climb should keep drafting deeper or step back and trim deck thickness first."
							},
							"focus_tags": [
								{"zh": "继续进塔", "en": "Keep climbing"},
								{"zh": "路线定稿", "en": "Lock the line"}
							],
							"linked_preview_kind": "reward_chain",
							"linked_preview_option": "draft",
							"connections": ["summit_boss"],
							"tone": Color(0.94, 0.74, 0.42, 1.0),
							"state": "option"
						}
					]
				},
				{
					"floor": {"zh": "塔顶", "en": "Summit"},
					"nodes": [
						{
							"id": "summit_boss",
							"kind": "boss",
							"lane": "summit",
							"glyph": "塔",
							"label": {"zh": "Boss", "en": "Boss"},
							"note": {"zh": "整副牌的总检验", "en": "Full-build exam"},
							"focus_title": {"zh": "Boss 节点 · 终局定卷", "en": "Boss Node · Final Build Verdict"},
							"focus_body": {
								"zh": "塔顶 Boss 会把整副牌的方向性一起检验完，再用战后遗物把这次 climb 的最终 verdict 写死。",
								"en": "The summit boss checks the whole build direction at once, then seals the run's final verdict through the relic follow-through after victory."
							},
							"focus_tags": [
								{"zh": "终局检验", "en": "Final exam"},
								{"zh": "Boss 遗物", "en": "Boss relic"}
							],
							"linked_preview_kind": "reward_chain",
							"linked_preview_option": "relic",
							"tone": Color(0.86, 0.68, 0.96, 1.0),
							"state": "boss"
						}
					]
				}
			],
			"footnote": {
				"zh": "这只是 source 三路线塔图的前台壳预览，不假装已经接通真正的 Godot 节点逻辑。",
				"en": "This is only a front-shell preview of the source three-lane tower board, not a claim that Godot already has the real node logic wired up."
			}
		},
		"route_ledger_preview": {
			"title": {"zh": "路书对照预览", "en": "Route Ledger Preview"},
			"summary": {
				"zh": "source 的事件节点不只是随机奖励。`路书对照 / Route Ledger` 会先读当前牌组倾向，再给出压深主线、补齐短板或先存节奏三种回应。",
				"en": "Source event nodes are not flat random rewards. `Route Ledger` reads the deck's current lean first, then offers three responses: deepen the main line, patch the weak point, or bank tempo."
			},
			"hint": {
				"zh": "点按下面任一路书条目，预览 source 事件如何顺着当前 deck 走向回写奖励。",
				"en": "Tap one of the ledger entries below to preview how the source event writes rewards back into the current deck direction."
			},
			"options": [
				{
					"id": "deepen",
					"glyph": "主",
					"title": {"zh": "压深主线", "en": "Press The Main Line"},
					"subtitle": {"zh": "顺着当前牌组倾向继续写深", "en": "Lean harder into the current deck read"},
					"summary": {
						"zh": "这份样张假设牌组已经偏向 `明 / 学` 的节奏抽墨线，于是事件会补两张能继续压深主线的牌，而不是给一张通用大数值。",
						"en": "This sample assumes the deck is already leaning toward a `明 / 学` tempo-and-Ink line, so the event adds two cards that deepen that spine instead of one generic high-number reward."
					},
					"tone": Color(0.94, 0.74, 0.42, 1.0),
					"result_group": {
						"title": {"zh": "当前倾向 · 压深主线", "en": "Current Lean · Press The Main Line"},
						"summary": {
							"zh": "把 source 的 deck-read 事件先迁回 portal 前台，说明它会根据当前构筑倾向投递更贴线的双牌组合。",
							"en": "This brings the source deck-read event back into the portal front-end, showing how it can deliver a more route-aligned two-card package."
						},
						"cards": [
							{
								"glyph": "明",
								"title": {"zh": "明 · 节奏成字", "en": "明 · Tempo Fusion"},
								"subtitle": {"zh": "顺着日 / 月主线继续压深", "en": "Deepen the sun / moon spine"},
								"body": {
									"zh": "补伤害、抽牌与墨流，让已经成型的主线继续稳稳地接管中盘。",
									"en": "Adds damage, draw, and Ink flow so the formed line can keep taking over the midgame cleanly."
								},
								"tags": [
									{"zh": "成字", "en": "Fusion"},
									{"zh": "主线加深", "en": "Main-line deepen"}
								]
							},
							{
								"glyph": "学",
								"title": {"zh": "学 · 抽墨引擎", "en": "学 · Study Thread"},
								"subtitle": {"zh": "让节奏线真正转起来", "en": "Keep the tempo line turning"},
								"body": {
									"zh": "补上 draw / Ink 引擎，让这条路不只靠合字爆点，而能真的把厚牌组运转起来。",
									"en": "Adds the draw-and-Ink engine so the line does not rely only on fusion spikes and can truly keep a thicker deck moving."
								},
								"tags": [
									{"zh": "引擎", "en": "Engine"},
									{"zh": "抽墨", "en": "Draw + Ink"}
								]
							}
						]
					}
				},
				{
					"id": "patch",
					"glyph": "补",
					"title": {"zh": "补齐短板", "en": "Patch The Weak Point"},
					"subtitle": {"zh": "稳住最容易先裂开的地方", "en": "Stabilize the first likely crack"},
					"summary": {
						"zh": "source 的另一种路书回应不是继续贪主线，而是补一张更稳的牌，再顺手回一口气，把 deck 的底板抬起来。",
						"en": "Another source-ledger response does not press greedier into the main line. It adds a steadier card and tops up HP so the deck's floor rises first."
					},
					"tone": Color(0.56, 0.84, 0.8, 1.0),
					"result_group": {
						"title": {"zh": "弱点修补 · 稳住底板", "en": "Weak-Point Patch · Raise The Floor"},
						"summary": {
							"zh": "这类事件回应会优先补防守或续航，提醒爬塔线不是每次都要继续加码进攻。",
							"en": "This style of response prioritizes defense or sustain first, reinforcing that a tower climb should not always keep doubling down on offense."
						},
						"cards": [
							{
								"glyph": "休",
								"title": {"zh": "休 · 稳健补漏", "en": "休 · Quiet Breath"},
								"subtitle": {"zh": "补续航与格挡", "en": "Restore sustain and Block"},
								"body": {
									"zh": "补一张更稳的回复 / 防守牌，让半成型 deck 先站住，再决定要不要继续追更高的回报。",
									"en": "Adds a steadier heal-and-defense card so a half-built deck can stand first before chasing larger payoffs again."
								},
								"tags": [
									{"zh": "续航", "en": "Sustain"},
									{"zh": "补漏洞", "en": "Patch gap"}
								]
							},
							{
								"glyph": "气",
								"title": {"zh": "回气 8", "en": "Restore 8 HP"},
								"subtitle": {"zh": "抬高当前容错", "en": "Raise the current margin"},
								"body": {
									"zh": "和补牌一起给一口回气，把这次修补变成真实的下一层容错，而不是纸面上的牌库变动。",
									"en": "Comes with an HP top-up so the patch becomes real next-floor breathing room instead of a purely theoretical deck tweak."
								},
								"tags": [
									{"zh": "回血", "en": "HP"},
									{"zh": "稳线", "en": "Stabilize"}
								]
							}
						]
					}
				},
				{
					"id": "tempo",
					"glyph": "势",
					"title": {"zh": "先存节奏", "en": "Bank The Tempo"},
					"subtitle": {"zh": "不加牌，先换下场爆发点", "en": "Skip cards and bank the next spike"},
					"summary": {
						"zh": "source 还会给第三种更轻的回应：不把 deck 再压厚，直接存一笔 Gold，并把下一场战斗的 Energy / Ink 起手往前推。",
						"en": "The source also keeps a lighter third response: do not thicken the deck again, just bank some Gold and push the next battle's opening Energy and Ink forward."
					},
					"tone": Color(0.72, 0.62, 0.94, 1.0),
					"result_group": {
						"title": {"zh": "节奏存势 · 下场爆点", "en": "Tempo Bank · Next Battle Spike"},
						"summary": {
							"zh": "这类选择强调《仓颉之路》并不总靠拿牌推进，资源和下场起手权本身也会成为路线抉择。",
							"en": "This option shows that Cangjie Road does not advance only through drafting. Resources and next-battle opening leverage also become route decisions."
						},
						"cards": [
							{
								"glyph": "金",
								"title": {"zh": "Gold +28", "en": "Gold +28"},
								"subtitle": {"zh": "先把商店预算攒起来", "en": "Bank the next shop budget"},
								"body": {
									"zh": "不急着再拿一张牌，先把这层事件换成更自由的下一段消费与删改空间。",
									"en": "Instead of taking another card immediately, this event can be converted into more flexible spending and trim space on the next stretch."
								},
								"tags": [
									{"zh": "预算", "en": "Budget"},
									{"zh": "商店线", "en": "Shop line"}
								]
							},
							{
								"glyph": "启",
								"title": {"zh": "下场开局 +1 Energy / +1 Ink", "en": "Next battle +1 Energy / +1 Ink"},
								"subtitle": {"zh": "把起手爆点提前一拍", "en": "Bring the spike one beat earlier"},
								"body": {
									"zh": "把下场的第一拍拉前，适合 deck 已经够厚、但这回合更想先存起手爆点的路线。",
									"en": "Pulls the next battle's first spike forward, fitting runs that are already thick enough and would rather bank an opening burst now."
								},
								"tags": [
									{"zh": "起手势能", "en": "Opening tempo"},
									{"zh": "不增牌", "en": "No extra card"}
								]
							}
						]
					}
				}
			],
			"footnote": {
				"zh": "Godot 这里先展示一份代表性的 route-ledger 样张，不假装已经在本仓库里接通真实 deck 分析与事件分支。",
				"en": "Godot shows a representative route-ledger sample here first, without pretending this repository already has real deck analysis or live event branching wired in."
			}
		},
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
					},
					{
						"glyph": "歇",
						"title": {"zh": "歇息", "en": "Rest"},
						"subtitle": {"zh": "回气 / 预埋节奏", "en": "Recover / preload tempo"},
						"body": {
							"zh": "回血或蓄势，决定下一场是先求稳，还是提前把节奏贪出来。",
							"en": "Heal or prepare, depending on whether the next floor needs stability first or greedier tempo early."
						},
						"tags": [
							{"zh": "恢复", "en": "Recovery"},
							{"zh": "蓄势", "en": "Prepare"}
						]
					},
					{
						"glyph": "肆",
						"title": {"zh": "商店", "en": "Shop"},
						"subtitle": {"zh": "重配 Gold", "en": "Reassign Gold"},
						"body": {
							"zh": "在买牌、买遗物和修薄之间重新分配 Gold，是把路线往更贪或更稳偏转的关键节点。",
							"en": "Reallocates Gold between cards, relics, and thinning, making it a key node for bending the route greedier or steadier."
						},
						"tags": [
							{"zh": "Gold", "en": "Gold"},
							{"zh": "再分配", "en": "Reassign"}
						]
					},
					{
						"glyph": "删",
						"title": {"zh": "删改", "en": "Archive"},
						"subtitle": {"zh": "让牌组更薄", "en": "Thin the deck"},
						"body": {
							"zh": "修薄牌组很多时候比多拿一张奖励牌更值，会直接抬高后续每回合的抽牌质量。",
							"en": "Making the deck thinner is often worth more than adding one more reward card because it directly lifts later draw quality."
						},
						"tags": [
							{"zh": "修薄", "en": "Thin"},
							{"zh": "抽牌质量", "en": "Draw quality"}
						]
					},
					{
						"glyph": "异",
						"title": {"zh": "事件", "en": "Event"},
						"subtitle": {"zh": "短期换长期", "en": "Short vs long"},
						"body": {
							"zh": "事件房会把短期收益和长期稳定放到同一题面上，常常比普通战斗更暴露路线判断。",
							"en": "Event rooms put short-term gain and long-term stability on the same prompt, often exposing route judgment more clearly than normal battles."
						},
						"tags": [
							{"zh": "取舍", "en": "Tradeoff"},
							{"zh": "路线判断", "en": "Route read"}
						]
					},
					{
						"glyph": "塔",
						"title": {"zh": "Boss", "en": "Boss"},
						"subtitle": {"zh": "塔顶总检验", "en": "Summit exam"},
						"body": {
							"zh": "到塔顶时，这套牌必须已经把自己的路线回答得够清楚，才能真正通过整副牌的总检验。",
							"en": "By the summit, the deck line needs to answer its own questions clearly enough to pass the full-build exam."
						},
						"tags": [
							{"zh": "综合检验", "en": "Full exam"},
							{"zh": "路线定卷", "en": "Line verdict"}
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
						"glyph": "魇",
						"title": {"zh": "魇页使", "en": "Nightmare Page Envoy"},
						"subtitle": {"zh": "蓄势 / 多段攻击", "en": "Charge / multi-hit pressure"},
						"body": {
							"zh": "会先蓄势再打高伤，也会切进多段输出，逼你提前读懂下一回合真正的问题。",
							"en": "Telegraphs heavier hits through charge turns and can pivot into multi-hit pressure, rewarding earlier reads of the next turn's real question."
						},
						"tags": [
							{"zh": "战斗层", "en": "Battle floor"},
							{"zh": "蓄势读招", "en": "Intent read"}
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
	"record_section_title": "人物来路",
	"quote_source_format": "出处 · %s",
	"opening_title": "起笔落点",
	"opening_empty_summary": "当前 Godot 保持无固定起手偏旁，第一批掉落更适合顺势决定这一局往哪条合字线转。",
	"opening_started_summary": "当前 Godot 会带着 %s 入卷，让这名执笔者更早摸到自己的开场路线。",
	"starting_label_format": "%s %s",
	"starting_summary_joiner": " / ",
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
	"active_skill_headline_joiner": " · ",
	"progression_title": "残卷路线",
	"progression_summary": "把这名执笔者的前几步 build 顺序先看清，再入卷会更容易顺着掉落继续写。",
	"progression_note": "当前先保留 web 原型的 build 顺序与路线提示，Godot 战斗内还没有真正的路线权重修正与额外掉落偏向。",
	"build_route_title": "源稿构筑方向",
	"build_route_summary": "对照 web 原型现有的路线选择，把更贴近这名执笔者的构筑方向与词技 / 遗物搭配保留成前台参考。",
	"build_route_note": "这些卡片当前不直接改战斗数值、掉落权重或路线偏向，只帮助对照 web 原型的构筑意图。",
	"build_route_relic_title": "源稿遗物偏向",
	"build_route_word_title": "源稿词技偏向",
	"build_route_hint_prefix_format": "%s %s",
	"build_route_hint_joiner": " · ",
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
	"local_title_manual": "本地主卷榜",
	"local_title_test": "本地试阵榜",
	"result_label_manual": "本轮残卷",
	"result_label_test": "本轮试阵",
	"sorted_format": "当前排序：%s。",
	"run_alias_title": "战绩署名",
	"latest_alias_title": "最近一条战绩署名",
	"game_over_alias_detail_manual": "本轮记录已经写入主卷榜。你可以直接改成想显示的名字；留空则保留玩家名帖里的默认署名。",
	"game_over_alias_detail_test": "本轮试阵记录已经写入试阵榜，不会影响主卷榜排序。你可以直接改成想显示的名字；留空则保留玩家名帖里的默认署名。",
	"latest_alias_detail_manual": "这里显示最近写入主卷榜的那条战绩；如果刚结束的是试阵捷径，可以先切到试阵榜再改名。",
	"latest_alias_detail_test": "这里显示最近写入试阵榜的那条战绩；试阵记录会和主卷榜分开保留。",
	"identity_hero_fallback": "书生",
	"identity_format": "%s · %s",
	"summary_test": "试阵榜单独收录第 10 / 20 波捷径，方便检查敌潮、build 与 HUD；现在也能在波次 / 击破 / 存活三种排序之间切换，更接近 source 榜单的回看方式。",
	"summary_manual": "主卷榜只收从第 1 波真正开卷的战绩；现在也能在波次 / 击破 / 存活三种排序之间切换，开局前可以从不同角度回看 route 成果。",
	"main_board": "主卷榜",
	"test_board": "试阵榜",
	"view_board_format": "查看%s",
	"view_button_count_format": "%s · %d",
	"switch_to_test_format": "切到试阵榜 · %d",
	"switch_to_main_format": "切到主卷榜 · %d",
	"back_to_summary": "返回结算",
	"scroll_top": "返回顶部",
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
	"recorded_on_format": "记录于 %s",
	"time_zone_format": "时区 %s",
	"alias_status_format": "当前署名：%s",
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

const BATTLE_STATE_CONTENT := {
	"pause_title": {"zh": "墨阵暂歇", "en": "Inkfield Interlude"},
	"summary_title": {"zh": "当前进度", "en": "Current run"},
	"summary_compact_format": {"zh": "存活 %s  ·  波次 %d  ·  击破 %d  ·  Lv.%d", "en": "Time %s  ·  W%d  ·  K%d  ·  Lv.%d"},
	"summary_time_format": {"zh": "存活 %s", "en": "Time %s"},
	"summary_stats_format": {"zh": "波次 %d   击破 %d   等级 Lv.%d", "en": "Wave %d   Kills %d   Level Lv.%d"},
	"carry_state_title": {"zh": "卷间余势", "en": "Interlude Carry"},
	"carry_modifier_reward_supply": {
		"zh": "补给余势：下一位卷主前，压境敌群更容易掉落残纸与战印。",
		"en": "Supply carry: until the next scroll lord, pressure enemies are more likely to drop paper scraps and seals."
	},
	"carry_modifier_reward_supply_compact": {
		"zh": "补给余势：敌群更易掉残纸 / 战印",
		"en": "Supply carry: more paper and seal drops"
	},
	"carry_modifier_scroll_echo": {
		"zh": "残卷回响：下一位卷主前，压境敌群会额外回响残纸，精英也可能掉落疾书令。",
		"en": "Scroll Echo: until the next scroll lord, pressure enemies echo extra paper scraps and elites can drop Swift Edict."
	},
	"carry_modifier_scroll_echo_compact": {
		"zh": "残卷回响：敌群补残纸，精英可掉疾书令",
		"en": "Scroll Echo: extra paper, elite Swift Edicts"
	},
	"carry_modifier_short_rest": {
		"zh": "歇笔余势：下一位卷主前，后续字潮推进仍会回补一小口气。",
		"en": "Recovery carry: until the next scroll lord, later wave pushes still echo a smaller heal."
	},
	"carry_modifier_short_rest_compact": {
		"zh": "歇笔余势：后续推进再补一口气",
		"en": "Recovery carry: later pushes echo healing"
	},
	"carry_lean_format": {"zh": "偏旁偏向：%s", "en": "Draft lean: %s"},
	"carry_lean_compact_format": {"zh": "偏向：%s", "en": "Lean: %s"},
	"pause_controls_compact": {"zh": "按 E / Esc 继续，R 重开", "en": "E / Esc resume · R restart"},
	"pause_controls_full": {"zh": "按 E 或 Esc 继续，按 R 立即重开。", "en": "Press E or Esc to resume, or R to restart immediately."},
	"game_over_title": {"zh": "字海沉没", "en": "The Ink Sea Sinks"},
	"game_over_summary_manual": {
		"zh": "墨潮吞没了你。按 R 立即重开，或按 Esc 返回二级菜单。",
		"en": "The ink tide swallowed you. Press R to restart immediately, or Esc to return to the sub-menu."
	},
	"game_over_summary_test": {
		"zh": "试阵记录已写入试阵榜，不会影响主卷榜。按 R 立即重开，或按 Esc 返回二级菜单。",
		"en": "This test-run result has been written to the test board and will not affect the main-scroll board. Press R to restart immediately, or Esc to return to the sub-menu."
	},
	"game_over_summary_shortcut": {
		"zh": "这次捷径不会写入排行榜。按 R 立即重开，或按 Esc 返回二级菜单。",
		"en": "This shortcut run will not be written into the leaderboard. Press R to restart immediately, or Esc to return to the sub-menu."
	},
	"settings_title": {"zh": "战场布置", "en": "Battle Setup"},
	"settings_body_format": {
		"zh": "对照 hanziHero 的 Performance / LOD 面板，当前战场布置已经补齐完整的低风险首轮矩阵。改动会立即生效，并写入本地运行设置。\n\n当前\n演出档：%s\n视觉字效：%s\n敌方血条：%s\n环境字影：%s\n远敌细节：%s",
		"en": "Mirroring the hanziHero Performance / LOD panel, the Godot battlefield now keeps a complete first-pass set of safe presentation toggles. Changes apply immediately and are saved locally.\n\nCurrent\nPerformance: %s\nGlyph FX: %s\nEnemy Health Bars: %s\nAmbient Glyphs: %s\nDistant Enemy Detail: %s"
	},
	"settings_performance_format": {"zh": "演出档：%s", "en": "Performance: %s"},
	"settings_visual_effects_format": {"zh": "视觉字效：%s", "en": "Glyph FX: %s"},
	"settings_enemy_health_bars_format": {"zh": "敌方血条：%s", "en": "Enemy Health Bars: %s"},
	"settings_ambient_density_format": {"zh": "环境字影：%s", "en": "Ambient Glyphs: %s"},
	"settings_enemy_detail_format": {"zh": "远敌细节：%s", "en": "Distant Enemy Detail: %s"},
	"performance_mode_performance": {"zh": "轻量", "en": "Performance"},
	"performance_mode_quality": {"zh": "质感", "en": "Quality"},
	"performance_mode_balanced": {"zh": "平衡", "en": "Balanced"},
	"toggle_show": {"zh": "显示", "en": "Show"},
	"toggle_hide": {"zh": "隐藏", "en": "Hide"},
	"toggle_enabled": {"zh": "开启", "en": "Enabled"},
	"toggle_reduced": {"zh": "收束", "en": "Reduced"},
	"ambient_density_off": {"zh": "关闭", "en": "Off"},
	"ambient_density_high": {"zh": "浓", "en": "Dense"},
	"ambient_density_medium": {"zh": "疏", "en": "Sparse"},
	"enemy_detail_full": {"zh": "完整", "en": "Full"},
	"enemy_detail_near_only": {"zh": "近距", "en": "Near Only"},
	"action_resume_battle": {"zh": "继续战斗", "en": "Resume Battle"},
	"action_open_settings": {"zh": "战场布置", "en": "Battle Setup"},
	"action_restart_run": {"zh": "重新开始", "en": "Restart Run"},
	"action_return_menu": {"zh": "返回菜单", "en": "Return to Menu"},
	"action_back_to_pause": {"zh": "返回暂停", "en": "Back to Pause"},
	"action_continue_deeper": {"zh": "续卷入深层", "en": "Continue Deeper"},
	"elite_incoming_banner": {"zh": "精英现身", "en": "Elite Incoming"},
	"boss_appears_banner": {"zh": "卷主现身", "en": "Boss Appears"},
	"boss_appears_log_format": {"zh": "卷主现身 · %s", "en": "Boss Appears · %s"},
	"pressure_rises_banner": {"zh": "字潮再涨", "en": "The Tide Surges Higher"},
	"threat_wave_banner_format": {"zh": "字潮第 %d 波", "en": "Glyph Tide Wave %d"},
	"threat_wave_log_format": {"zh": "第 %d 波 · 字潮推进", "en": "Wave %d · Tide Advances"},
	"threat_wave_major_banner_format": {"zh": "字潮第 %d 波 · 大潮", "en": "Glyph Tide Wave %d · Major Surge"},
	"threat_wave_major_log_format": {"zh": "第 %d 波 · 大潮压境", "en": "Wave %d · Major Surge"},
	"weapon_core_attuned_banner_format": {"zh": "%s 入%s", "en": "%s into %s"},
	"radical_attuned_banner_format": {"zh": "领悟 %s", "en": "Attuned %s"},
	"glyph_formed_banner_format": {"zh": "合字成型  %s", "en": "Glyph Formed  %s"},
	"glyph_formed_reveal_kicker": {"zh": "合字成型", "en": "Glyph Formed"},
	"glyph_formed_log_format": {"zh": "合字成型 · %s", "en": "Glyph Formed · %s"},
	"glyph_level_banner_format": {"zh": "%s 进为 Lv.%d", "en": "%s rises to Lv.%d"},
	"glyph_level_log_format": {"zh": "%s 升至 Lv.%d", "en": "%s reaches Lv.%d"},
	"phrase_formed_banner_format": {"zh": "词技成型  %s", "en": "Phrase Art Formed  %s"},
	"phrase_formed_reveal_kicker": {"zh": "词技成型", "en": "Phrase Art Formed"},
	"phrase_formed_log_format": {"zh": "词技成型 · %s", "en": "Phrase Art Formed · %s"},
	"phrase_level_banner_format": {"zh": "%s 进为 Lv.%d", "en": "%s rises to Lv.%d"},
	"phrase_level_log_format": {"zh": "%s 升至 Lv.%d", "en": "%s reaches Lv.%d"},
	"chapter_secured_banner": {"zh": "残卷一暂定", "en": "Scroll I Secured"},
	"chapter_secured_tip": {
		"zh": "本卷卷主都已崩散，章节目标完成。继续战斗可测试成长上限。",
		"en": "All scroll lords have collapsed. The chapter goal is complete, and you can keep fighting to test the build ceiling."
	},
	"chapter_secured_log": {"zh": "残卷一暂定 · 卷主尽散", "en": "Scroll I Secured · Bosses gone"},
	"boss_dispersed_banner": {"zh": "卷主退散", "en": "Boss Dispersed"},
	"boss_dispersed_tip": {
		"zh": "卷主崩散后，先清掉残留字灵；战场安静下来后，会先停在卷间缓冲再继续入深层。",
		"en": "The scroll lord has fallen. Clear the lingering glyph spirits and a chamber break will open before the run pushes deeper."
	},
	"boss_dispersed_log": {"zh": "卷主退散 · 残卷继续翻开", "en": "Boss Dispersed · The scroll unfolds deeper"}
}

const BATTLE_HUD_CONTENT := {
	"health_format": {"zh": "气血  %d / %d", "en": "Vitality  %d / %d"},
	"progress_format": {"zh": "字墨  Lv.%d   %d / %d", "en": "Ink  Lv.%d   %d / %d"},
	"status_multiline_format": {"zh": "存活  %02d:%02d\n波次  %d\n击破  %d", "en": "Time  %02d:%02d\nWave  %d\nKills  %d"},
	"status_compact_format": {"zh": "存活 %02d:%02d  ·  波次 %d  ·  击破 %d", "en": "Time %02d:%02d  ·  Wave %d  ·  Kills %d"},
	"radicals_empty_detail": {"zh": "当前尚未留存偏旁", "en": "No radicals are currently stored."},
	"radicals_fully_fused_label": {"zh": "全部化字", "en": "Fully fused"},
	"radicals_compact_empty": {"zh": "偏旁 0 枚  ·  当前全部化字", "en": "Radicals 0  ·  fully fused"},
	"radicals_stored_detail_format": {
		"zh": "当前留存 %d 枚偏旁，可继续合字或磨词",
		"en": "Stored %d radicals. Keep fusing glyphs or bring them to the inkstone."
	},
	"radicals_compact_format": {"zh": "偏旁 %d 枚  ·  %s", "en": "Radicals %d  ·  %s"},
	"compact_tip_placeholder": {"zh": "击倒字灵收集字力与补给。", "en": "Defeat glyph spirits to collect ink power and supplies."},
	"compact_route_placeholder": {"zh": "墨守流  ·  开卷补笔", "en": "Inkguard Route  ·  Opening Strokes"},
	"route_focus_state_title": {"zh": "路线参考", "en": "Route Focus"},
	"route_progress_format": {"zh": "构筑进度：偏旁 %d  ·  成字 %d  ·  词技 %d", "en": "Build: radicals %d  ·  glyphs %d  ·  phrases %d"},
	"skill_badge_phrase_art": {"zh": "成词技能", "en": "Phrase Art"},
	"skill_badge_glyph_skill": {"zh": "成字技能", "en": "Glyph Skill"},
	"skill_refine_format": {"zh": "磨词 %d/%d", "en": "Refine %d/%d"},
	"skill_complete": {"zh": "已写满", "en": "Complete"},
	"weapon_core_badge": {"zh": "武器核心", "en": "Weapon Core"},
	"weapon_core_title_blade": {"zh": "刀势", "en": "Blade Arc"},
	"weapon_core_title_brush": {"zh": "笔锋", "en": "Brush Edge"},
	"weapon_core_detail": {
		"zh": "独立强化主武器强度，和角色身份直接绑定。",
		"en": "Directly strengthens the primary weapon and stays tied to this hero."
	},
	"compact_skill_waiting_title": {"zh": "待成字", "en": "Waiting"},
	"compact_skill_waiting_level": {"zh": "预备", "en": "Ready"},
	"compact_skill_more": {"zh": "更多技能字", "en": "More Skills"},
	"skill_placeholder_badge": {"zh": "等待成字", "en": "Waiting to Form"},
	"skill_placeholder_title": {"zh": "尚未成型", "en": "Not Formed Yet"},
	"skill_placeholder_detail": {
		"zh": "先通过偏旁三选一推进合字，再把满级合字带去砚台磨成词技。",
		"en": "Advance fusions through radical picks first, then bring maxed glyphs to the inkstone for phrase refinement."
	},
	"skill_placeholder_level": {"zh": "预备", "en": "Readying"},
	"callout_title": {"zh": "战场呼应", "en": "Battle Callout"},
	"callout_placeholder": {"zh": "字潮翻动时，呼应会在这里出现。", "en": "Callouts will appear here when the glyph tide shifts."},
	"callout_detail_placeholder": {"zh": "印记 · 白纸起卷", "en": "Mark · Blank Scroll Begins"},
	"objective_title": {"zh": "当前目标", "en": "Current Objective"},
	"objective_placeholder_tip": {"zh": "尚未收集，或已经全部化字。", "en": "Nothing left to collect, or everything has already fused."},
	"route_focus_title": {"zh": "源稿路线参考", "en": "Source Route Guide"},
	"route_focus_placeholder_title": {"zh": "守  墨守流  ·  续航 / 站场", "en": "Guard  Inkguard Route  ·  Sustain / Hold"},
	"route_focus_placeholder_detail": {
		"zh": "先把最稳的 build 主线写深，再让砚台磨词接手中盘。",
		"en": "Push the steadiest build lane first, then let inkstone refinement take over the midgame."
	},
	"route_focus_placeholder_stage": {"zh": "当前阶段：开卷补笔  ·  明 / 海 / 休", "en": "Stage: Opening Strokes  ·  Ming / Hai / Xiu"},
	"route_focus_fallback_detail": {
		"zh": "让一条路线始终比其余分支领先，后续磨词才有清晰主线。",
		"en": "Keep one route ahead of the other branches so later refinement still has a clear spine."
	},
	"route_focus_stage_format": {"zh": "当前阶段：%s", "en": "Stage: %s"},
	"identity_mark_format": {"zh": "印记：%s", "en": "Mark: %s"},
	"identity_route_seal_format": {"zh": "路印：%s", "en": "Route Seal: %s"},
	"identity_mark_and_route_format": {"zh": "印记：%s  ·  路印：%s", "en": "Mark: %s  ·  Route Seal: %s"},
	"intro_route_seal_format": {"zh": "主路线印：%s", "en": "Route Seal: %s"},
	"intro_opening_format": {"zh": "起笔：%s", "en": "Opener: %s"},
	"intro_source_format": {"zh": "出处 · %s", "en": "Source · %s"},
	"callout_mark_format": {"zh": "印记 · %s", "en": "Mark · %s"},
	"callout_route_format": {"zh": "路印 · %s", "en": "Route Seal · %s"},
	"no_fixed_opener": {"zh": "无固定起手", "en": "No fixed opener"},
	"event_log_placeholder": {"zh": "波次、卷主、合字和拾取会记在这里。", "en": "Wave shifts, bosses, fused glyphs, and pickups will appear here."},
	"reveal_glyph_placeholder": {"zh": "字", "en": "Glyph"},
	"reveal_kicker_placeholder": {"zh": "字境相变", "en": "Realm Shift"},
	"reveal_title_placeholder": {"zh": "碑林", "en": "Stele Grove"},
	"reveal_detail_placeholder": {
		"zh": "大字揭示会在这里提示合字、词技与字境变化。",
		"en": "Big reveal cards here announce fused glyphs, phrase arts, and realm shifts."
	},
	"boss_descends": {"zh": "卷主降阵", "en": "Boss Descends"},
	"boss_descends_health_format": {"zh": "卷主降阵   %d / %d", "en": "Boss Descends   %d / %d"},
	"choice_radical_title_placeholder": {"zh": "字力突破", "en": "Ink Breakthrough"},
	"choice_radical_title_format": {"zh": "字力突破  Lv.%d", "en": "Ink Breakthrough  Lv.%d"},
	"choice_word_title": {"zh": "砚台磨词", "en": "Inkstone Refinement"},
	"radical_choice_hint_micro_format": {"zh": "三选一偏旁。剩余：%d", "en": "Pick 1 radical. Left: %d"},
	"radical_choice_hint_tight_format": {
		"zh": "三选一偏旁，推进合字路线。剩余：%d",
		"en": "Pick 1 radical to advance a glyph route. Left: %d"
	},
	"radical_choice_hint_full_format": {
		"zh": "从三枚偏旁里选一枚。它会推进合字，满级后继续磨成词技。剩余待选：%d",
		"en": "Pick one of the three radicals. It pushes a glyph route forward and later refines into a phrase art. Remaining picks: %d"
	},
	"word_choice_hint_micro": {"zh": "消耗 1 枚相关偏旁，磨成词技。", "en": "Spend 1 linked radical to refine a phrase art."},
	"word_choice_hint_tight": {
		"zh": "消耗 1 枚相关偏旁，把满级合字磨成词技。",
		"en": "Spend one linked radical to refine a maxed glyph into a phrase art."
	},
	"word_choice_hint_full": {
		"zh": "把满级合字的余材磨成更高一层的词技。每次磨词会消耗一枚相关偏旁。",
		"en": "Use extra maxed-glyph stock to refine a higher phrase art. Each refinement spends one related radical."
	},
	"map_title": {"zh": "残卷地图", "en": "Scroll Map"},
	"map_summary_format": {
		"zh": "%s  ·  敌群 %d  ·  砚台 %d  ·  草丛 %d  ·  地标 %d  ·  探索 %d%%",
		"en": "%s  ·  Enemies %d  ·  Inkstones %d  ·  Bushes %d  ·  Landmarks %d  ·  Explored %d%%"
	},
	"map_summary_empty": {
		"zh": "敌群 0  ·  砚台 0  ·  草丛 0",
		"en": "Enemies 0  ·  Inkstones 0  ·  Bushes 0"
	},
	"map_legend_title": {"zh": "图例", "en": "Legend"},
	"map_help_micro": {"zh": "拖拽查看，按钮缩放。Esc / M 收起。", "en": "Drag to pan. Buttons zoom. Esc / M closes."},
	"map_help_tight": {"zh": "拖拽查看，滚轮或按钮缩放。Esc / Tab / M 收起。", "en": "Drag to pan. Wheel or buttons zoom. Esc / Tab / M closes."},
	"map_help_full": {"zh": "拖拽视野，滚轮或按钮缩放。按 Esc、Tab、M 或再次点地图收起。", "en": "Drag to pan. Use the wheel or buttons to zoom. Press Esc, Tab, M, or the map button again to close."},
	"map_zoom_format": {"zh": "缩放  %.2fx", "en": "Zoom  %.2fx"},
	"map_zoom_out": {"zh": "缩小", "en": "Zoom Out"},
	"map_zoom_in": {"zh": "放大", "en": "Zoom In"},
	"map_zoom_reset": {"zh": "重置", "en": "Reset"},
	"map_close": {"zh": "收起地图", "en": "Close Map"},
	"state_preview_title": {"zh": "下一段预览", "en": "Next Preview"},
	"alias_placeholder_keep_sigil": {"zh": "留空则保留玩家名帖署名", "en": "Leave blank to keep the Player Sigil alias"},
	"alias_save_text": {"zh": "保存署名", "en": "Save Alias"},
	"controls_move": {"zh": "WASD / 方向键移动", "en": "WASD / Arrow Keys move"},
	"controls_attack": {"zh": "自动朝最近敌人出手", "en": "Auto-attack the nearest enemy"},
	"controls_radical_choice": {"zh": "升级时三选一偏旁", "en": "Pick 1 of 3 radicals on level-up"},
	"controls_inkstone": {"zh": "靠近砚台按 E 磨词", "en": "Press E near the inkstone to refine phrases"},
	"controls_map_restart": {"zh": "M / Tab 地图，R 重开，Esc 返回菜单", "en": "M / Tab map, R restart, Esc return to menu"},
	"controls_test_tools": {"zh": "试阵模式：右上可直接跳到下一波，并实时显示 FPS", "en": "Test mode: jump to the next wave from the top-right and keep FPS visible"},
	"current_guide_title": {"zh": "当前指引", "en": "Active Guide"},
	"soundtrack_cue_title": {"zh": "配乐提示", "en": "Music Cue"},
	"soundtrack_placeholder_title": {"zh": "苔月幽林", "en": "Mosslight Canopy"},
	"soundtrack_placeholder_detail": {"zh": "16-bit 静夜丛林 · 入卷铺陈", "en": "16-bit Quiet Forest · Scroll Opening"},
	"map_legend_rows": [
		{
			"symbol": "▲",
			"title": {"zh": "执笔者", "en": "Scribe"},
			"detail": {"zh": "当前角色朝向与位置。", "en": "Your current position and facing."},
			"color": Color(0.98, 0.78, 0.42, 1.0)
		},
		{
			"symbol": "●",
			"title": {"zh": "敌群", "en": "Enemy Pack"},
			"detail": {"zh": "常规敌人正在逼近的位置。", "en": "Where regular enemies are currently converging."},
			"color": Color(0.92, 0.42, 0.34, 1.0)
		},
		{
			"symbol": "■",
			"title": {"zh": "卷主 / 砚台 / 宝箱", "en": "Boss / Inkstone / Chest"},
			"detail": {"zh": "方块标出卷主、磨词砚台与可开启宝箱。", "en": "Squares mark bosses, phrase-grinding inkstones, and unopened chests."},
			"color": Color(0.98, 0.76, 0.54, 1.0)
		},
		{
			"symbol": "○",
			"title": {"zh": "树丛 / 墨池", "en": "Bush / Ink Pool"},
			"detail": {"zh": "圆形轮廓对应草丛与墨池。", "en": "Circular markers represent bushes and ink pools."},
			"color": Color(0.56, 0.84, 0.66, 1.0)
		},
		{
			"symbol": "◆",
			"title": {"zh": "碑刻 / 卷架", "en": "Stele / Scroll Rack"},
			"detail": {"zh": "静态地标，便于定方位。", "en": "Static landmarks that help orientation."},
			"color": Color(0.62, 0.84, 1.0, 1.0)
		},
		{
			"symbol": "▩",
			"title": {"zh": "迷雾", "en": "Fog"},
			"detail": {"zh": "未探索区域会被雾面遮住，走到附近才会展开。", "en": "Unexplored areas stay covered until you move close enough."},
			"color": Color(0.58, 0.66, 0.76, 1.0)
		}
	]
}

const BATTLE_PICKUP_CONTENT := {
	"paper_banner_format": {"zh": "拾得残纸  +%d 字墨", "en": "Paper Scrap  +%d Ink"},
	"paper_log_format": {"zh": "拾得残纸 · +%d 字墨", "en": "Paper Scrap · +%d Ink"},
	"ink_banner_format": {"zh": "拾得墨团  回气 %d", "en": "Ink Cluster  Heal %d"},
	"ink_log_format": {"zh": "拾得墨团 · 回气 %d", "en": "Ink Cluster · Heal %d"},
	"seal_banner_format": {"zh": "拾得战印  %s +%d", "en": "Battle Seal  %s +%d"},
	"seal_log_format": {"zh": "拾得战印 · %s +%d", "en": "Battle Seal · %s +%d"},
	"magnet_banner_gain_format": {"zh": "拾得聚墨符  收束 %d 字墨", "en": "Ink Magnet  Gathered %d Ink"},
	"magnet_banner_empty": {"zh": "拾得聚墨符  场上已无散墨", "en": "Ink Magnet  No loose ink remains"},
	"magnet_tip": {
		"zh": "聚墨符会把战场上遗落的字墨尽数回收，适合在绕场之后一口气补等级。",
		"en": "The ink magnet recalls every loose ink pickup on the field, making it ideal after a long kite around the arena."
	},
	"magnet_log_gain_format": {"zh": "拾得聚墨符 · 收束 %d 字墨", "en": "Ink Magnet · Gathered %d Ink"},
	"magnet_log_empty": {"zh": "拾得聚墨符 · 场上已无散墨", "en": "Ink Magnet · No loose ink remains"},
	"fury_banner_format": {"zh": "拾得疾书令  攻速移速提升 %d 秒", "en": "Swift Edict  Attack and move speed up for %d s"},
	"fury_tip": {
		"zh": "疾书令会短时间拉高攻速与移速，适合强开精英或抢一波散落补给。",
		"en": "Swift Edict boosts attack and movement speed for a short burst, which is perfect for forcing elites or sweeping pickups."
	},
	"fury_log_format": {"zh": "拾得疾书令 · 提速 %d 秒", "en": "Swift Edict · Speed up for %d s"},
	"potion_banner_format": {"zh": "拾得回春丹  回复 %d%% 气血", "en": "Spring Pill  Restore %d%% Vitality"},
	"potion_tip": {
		"zh": "回春丹会按最大气血比例回气，适合硬吃一波精英或卷主技能后迅速稳住局势。",
		"en": "Spring Pill heals a percentage of your maximum vitality, making it ideal after tanking an elite or boss pattern."
	},
	"potion_log_format": {"zh": "拾得回春丹 · 回复 %d%% 气血", "en": "Spring Pill · Restore %d%% Vitality"},
	"brush_banner_format": {"zh": "拾得文笔  机动提升 %d 秒", "en": "Writers Brush  Mobility up for %d s"},
	"brush_tip": {
		"zh": "文笔加身，短时间内移动更快，适合拉扯敌群和抢补给。",
		"en": "The writer's brush speeds you up for a short window, which is ideal for dragging the crowd or scooping supplies."
	},
	"brush_log_format": {"zh": "拾得文笔 · 机动提升 %d 秒", "en": "Writers Brush · Mobility up for %d s"},
	"chest_banner": {"zh": "宝箱开启", "en": "Chest Opened"},
	"chest_tip": {
		"zh": "宝箱散出补给。先收残纸与墨团，再决定是压等级还是补状态。",
		"en": "The chest spills supplies across the field. Grab paper scraps and ink first, then decide whether to push levels or recover."
	},
	"chest_log": {"zh": "宝箱开启 · 补给散落", "en": "Chest Opened · Supplies scattered"}
}

const BATTLE_HUD_EN_TEXT := {
	"待入曲": "Awaiting Cue",
	"战场乐题": "Battle Track",
	"战局开始后会同步当前曲名与气氛提示。": "The active track name and mood cue will appear once the battle begins.",
	"偏旁存量": "Radical Stock",
	"当前尚未留存偏旁": "No radicals stored yet",
	"全部化字": "Fully fused",
	"战场速记": "Battle Notes",
	"战报": "Battle Log",
	"地图": "Map",
	"暂停": "Pause",
	"下一波": "Next Wave",
	"卷主降阵": "Boss Descends",
	"战局摘要": "Run Summary",
	"偏旁 0 枚  ·  当前全部化字": "Radicals 0  ·  fully fused",
	"击倒字灵收集字力与补给。": "Defeat glyph spirits to collect ink power and supplies.",
	"战场呼应": "Battle Callout",
	"字潮翻动时，呼应会在这里出现。": "Callouts will appear here when the glyph tide shifts.",
	"当前目标": "Current Objective",
	"当前指引": "Active Guide",
	"尚未收集，或已经全部化字。": "Nothing left to collect, or everything has already fused.",
	"源稿路线参考": "Source Route Guide",
	"已成技能字": "Formed Skill Glyphs",
	"已成技艺": "Ready Skills",
	"配乐提示": "Music Cue",
	"残卷地图": "Scroll Map",
	"图例": "Legend",
	"执笔者": "Scribe",
	"当前角色朝向与位置。": "Your current position and facing.",
	"敌群": "Enemy Pack",
	"常规敌人正在逼近的位置。": "Where regular enemies are currently converging.",
	"卷主 / 砚台 / 宝箱": "Boss / Inkstone / Chest",
	"方块标出卷主、磨词砚台与可开启宝箱。": "Squares mark bosses, phrase-grinding inkstones, and unopened chests.",
	"树丛 / 墨池": "Bush / Ink Pool",
	"圆形轮廓对应草丛与墨池。": "Circular markers represent bushes and ink pools.",
	"碑刻 / 卷架": "Stele / Scroll Rack",
	"静态地标，便于定方位。": "Static landmarks that help orientation.",
	"迷雾": "Fog",
	"未探索区域会被雾面遮住，走到附近才会展开。": "Unexplored areas stay covered until you move close enough.",
	"拖拽视野，滚轮或按钮缩放。按 Esc、Tab、M 或再次点地图收起。": "Drag to pan. Use the wheel or buttons to zoom. Press Esc, Tab, M, or the map button again to close.",
	"缩小": "Zoom Out",
	"放大": "Zoom In",
	"重置": "Reset",
	"收起地图": "Close Map",
	"字力突破": "Ink Breakthrough",
	"留空则保留玩家名帖署名": "Leave blank to keep the Player Sigil alias",
	"保存署名": "Save Alias",
	"等待成字": "Waiting to Form",
	"尚未成型": "Not Formed Yet",
	"先通过偏旁三选一推进合字，再把满级合字带去砚台磨成词技。": "Advance fused glyphs through radical drafts first, then take maxed glyphs to the inkstone for phrase arts.",
	"预备": "Readying",
	"更多技能字": "More Skill Glyphs",
	"WASD / 方向键移动": "Move with WASD / arrow keys",
	"自动朝最近敌人出手": "Auto-attack the nearest enemy",
	"升级时三选一偏旁": "Pick one of three radicals on level-up",
	"靠近砚台按 E 磨词": "Press E near an inkstone to refine phrases",
	"M / Tab 地图，R 重开，Esc 返回菜单": "M / Tab map, R restart, Esc return to menu",
	"试阵模式：右上可直接跳到下一波，并实时显示 FPS": "Test mode: jump to the next wave from the top-right and watch FPS live",
	"下一段预览": "Next Chamber Preview",
	"主路线印：%s": "Route Seal: %s",
	"起笔：%s": "Opener: %s",
	"印记 · %s": "Mark · %s",
	"路印 · %s": "Route Seal · %s",
	"路线参考": "Route Focus",
	"当前阶段：%s": "Stage: %s",
	"让一条路线始终比其余分支领先，后续磨词才有清晰主线。": "Keep one route ahead of the rest so later phrase refinement has a clear lane.",
	"印记 · 白纸起卷": "Mark · Blank Scroll Begins",
	"守  墨守流  ·  续航 / 站场": "Guard  Inkguard Route  ·  Sustain / Hold",
	"先把最稳的 build 主线写深，再让砚台磨词接手中盘。": "Push the steadiest build lane first, then let inkstone refinement take over the midgame.",
	"当前阶段：开卷补笔  ·  明 / 海 / 休": "Stage: Opening Strokes  ·  Ming / Hai / Xiu",
	"波次、卷主、合字和拾取会记在这里。": "Wave shifts, bosses, fused glyphs, and pickups will appear here.",
	"字境相变": "Realm Shift",
	"碑林": "Stele Grove",
	"大字揭示会在这里提示合字、词技与字境变化。": "Big reveal cards here announce fused glyphs, phrase arts, and realm shifts.",
	"拖拽查看，按钮缩放。Esc / M 收起。": "Drag to pan. Buttons zoom. Esc / M closes.",
	"拖拽查看，滚轮或按钮缩放。Esc / Tab / M 收起。": "Drag to pan. Wheel or buttons zoom. Esc / Tab / M closes.",
	"敌群 0  ·  砚台 0  ·  草丛 0": "Enemy pack 0  ·  Inkstone 0  ·  Bush 0"
}

const BATTLE_INTERLUDE_CONTENT := {
	"reward_archive_banner_format": {"zh": "简库拓片  偏旁「%s」", "en": "Archive Rubbing  Radical %s"},
	"reward_archive_tip_format": {
		"zh": "简库拓片已经带上，偏旁「%s」会一并随你入深层，下一段掉落仍会继续偏向残纸与战印，后续偏旁三选一也会更偏向 %s。",
		"en": "Archive rubbing secured. `%s` now enters the next chamber, enemy drops there still lean toward paper and seals, and later radical drafts also lean toward %s."
	},
	"reward_archive_log_format": {"zh": "卷间抉择 · 简库拓片 %s · 偏旁偏向 %s", "en": "Between Chambers · Archive Rubbing %s · Draft lean %s"},
	"reward_vault_banner_format": {"zh": "雷纹拓笔  偏旁「%s」", "en": "Storm Etching  Radical %s"},
	"reward_vault_tip_format": {
		"zh": "雷纹拓笔已经定下，偏旁「%s」会一并带进雷纹内库，而且开场先带着 %d 秒文笔提速。",
		"en": "Storm etching secured. `%s` now enters Thunder Vault, and the room opens with %d s of brush haste."
	},
	"reward_vault_log_format": {"zh": "卷间抉择 · 雷纹拓笔 %s", "en": "Between Chambers · Storm Etching %s"},
	"reward_abyss_banner_format": {"zh": "终室备墨  偏旁「%s」", "en": "Final Draft  Radical %s"},
	"reward_abyss_tip_format": {
		"zh": "终室备墨已经定下，偏旁「%s」会一并带进卷渊终室，最后一段开场就能先补齐这组字路。",
		"en": "Final draft sealed. `%s` now enters Abyss Sanctum, so the last chamber opens with the full pair already in hand."
	},
	"reward_abyss_log_format": {"zh": "卷间抉择 · 终室备墨 %s", "en": "Between Chambers · Final Draft %s"},
	"reward_default_banner": {"zh": "偏旁补给  下一段残纸更盛", "en": "Radical Cache  Next chamber drops rise"},
	"reward_default_tip_format": {
		"zh": "偏旁补给已经带上，「%s」会跟着你继续入深层，下一段敌人也会带来更多残纸和战印，后续偏旁三选一也会更偏向 %s。",
		"en": "Radical supply secured. `%s` now enters the next chamber, enemy drops there will carry more paper and seals, and later radical drafts will lean toward %s."
	},
	"reward_default_log_format": {"zh": "卷间抉择 · 偏旁补给 %s · 偏旁偏向 %s", "en": "Between Chambers · Radical supply %s · Draft lean %s"},
	"event_archive_banner_format": {"zh": "封钥借契  疾书令 %d 秒", "en": "Latch Bargain  Swift Edict %d s"},
	"event_archive_tip_format": {
		"zh": "封钥借契已经定下：下一段会先带着 %d 秒疾书令与 %d 秒纸域护势入场，残卷回响也会继续保留额外残纸与精英疾书令，直到下一位卷主；后续偏旁三选一会更偏向 %s。",
		"en": "Latch bargain sealed. The next chamber opens with %d s of Swift Edict plus %d s of paper ward, Scroll Echo still carries extra paper plus elite edicts until the next scroll lord, and later radical drafts tilt toward %s."
	},
	"event_archive_log_format": {"zh": "卷间抉择 · 封钥借契已经挂载 · 偏旁偏向 %s", "en": "Between Chambers · Latch Bargain armed · Draft lean %s"},
	"event_vault_banner_format": {"zh": "伏雷换契  疾书令 %d 秒", "en": "Vault Bargain  Swift Edict %d s"},
	"event_vault_tip_format": {
		"zh": "伏雷换契已经定下：雷纹内库开场就会先带着 %d 秒疾书令。",
		"en": "Vault bargain sealed. Thunder Vault opens with %d s of Swift Edict already active."
	},
	"event_vault_log": {"zh": "卷间抉择 · 伏雷换契已经挂载", "en": "Between Chambers · Vault Bargain armed"},
	"event_abyss_banner": {"zh": "渊页誓约  双势并起", "en": "Abyss Pact  Dual Momentum"},
	"event_abyss_tip_format": {
		"zh": "渊页誓约已经定下：卷渊终室开场会同时带着 %d 秒疾书令与 %d 秒文笔提速。",
		"en": "Abyss pact sealed. Abyss Sanctum opens with %d s of Swift Edict and %d s of brush haste together."
	},
	"event_abyss_log": {"zh": "卷间抉择 · 渊页誓约已经挂载", "en": "Between Chambers · Abyss Pact armed"},
	"event_default_banner": {"zh": "残卷回响已挂载", "en": "Scroll Echo Armed"},
	"event_default_tip": {
		"zh": "这次卷间异事会一路带进下一段：压境敌群会额外回响残纸，精英也能多吐一枚疾书令，持续到下一位卷主。",
		"en": "This chamber choice now carries into the next chamber: pressure enemies echo extra paper, and elites can drop Swift Edict until the next scroll lord."
	},
	"event_default_log": {"zh": "卷间抉择 · 残卷回响会一路带进下一段", "en": "Between Chambers · Scroll Echo armed for the next chamber"},
	"recovery_archive_banner_format": {"zh": "守灯静读  回复 %d%% 气血", "en": "Lamp Respite  Restore %d%% Vitality"},
	"recovery_archive_tip_format": {
		"zh": "守灯静读会先回气、解眩晕，并把 %d 秒文笔提速带进简库中庭；后续偏旁三选一会更偏向 %s，后面字潮推进仍会再补一小口气。",
		"en": "Lamp respite restores vitality, clears stun, carries %d s of brush haste into the archive, and later radical drafts tilt toward %s before later wave pushes echo smaller recovery."
	},
	"recovery_archive_log_format": {"zh": "卷间抉择 · 守灯静读 %d%% · 偏旁偏向 %s", "en": "Between Chambers · Lamp Respite %d%% · Draft lean %s"},
	"recovery_vault_banner_format": {"zh": "伏纹稳息  回复 %d%% 气血", "en": "Grounding Ward  Restore %d%% Vitality"},
	"recovery_vault_tip_format": {
		"zh": "伏纹稳息会先回气、解眩晕，并把 %d 秒纸域护势带进雷纹内库。",
		"en": "Grounding ward restores vitality, clears stun, and carries %d s of paper ward into Thunder Vault."
	},
	"recovery_vault_log_format": {"zh": "卷间抉择 · 伏纹稳息 %d%%", "en": "Between Chambers · Grounding Ward %d%%"},
	"recovery_abyss_banner_format": {"zh": "压关静息  回复 %d%% 气血", "en": "Stilling Breath  Restore %d%% Vitality"},
	"recovery_abyss_tip_format": {
		"zh": "压关静息会先回气、解眩晕，并把 %d 秒纸域护势带进卷渊终室。",
		"en": "Stilling breath restores vitality, clears stun, and carries %d s of paper ward into Abyss Sanctum."
	},
	"recovery_abyss_log_format": {"zh": "卷间抉择 · 压关静息 %d%%", "en": "Between Chambers · Stilling Breath %d%%"},
	"recovery_default_banner_format": {"zh": "歇笔回气  回复 %d%% 气血", "en": "Short Rest  Restore %d%% Vitality"},
	"recovery_default_tip_format": {
		"zh": "歇笔修整会先回气、解眩晕，并补上 %d 秒文笔提速；下一段后续字潮推进还会再补一小口气。",
		"en": "Short rest restores vitality, clears stun, and gives %d s of brush haste now; later wave pushes in the next chamber also echo smaller recovery."
	},
	"recovery_default_log_format": {"zh": "卷间抉择 · 歇笔回气 %d%%", "en": "Between Chambers · Short Rest %d%%"},
	"transition_body_format": {
		"zh": "这次卷间抉择已经定下，下一段会进入「%s」。真正续卷后，迷雾显形、场景布置和下一波压境都会按新房间重新铺开。\n\n先再看一眼下一段预览，准备好后再续卷入深层。",
		"en": "Your between-chambers choice is sealed. %s is next, and entering it will reset the fog, field props, and pressure layout around a fresh chamber state.\n\nCheck the final preview below, then continue deeper when ready."
	},
	"transition_title_format": {"zh": "房间已清 · %s", "en": "Chamber Cleared · %s"},
	"transition_banner_format": {"zh": "下一房间 · %s", "en": "Next Chamber · %s"},
	"transition_reveal_title": {"zh": "卷间换房", "en": "Between Chambers"},
	"transition_log_format": {"zh": "房间更替 · %s", "en": "Chamber Shift · %s"},
	"chamber_break_suffix": {"zh": "卷间缓冲", "en": "Chamber Break"},
	"chamber_interlude_suffix": {"zh": "卷间抉择", "en": "Between Chambers"},
	"layer_break_suffix": {"zh": "破卷入深层", "en": "Layer Break"},
	"option_archive_reward_format": {"zh": "奖励 · 简库拓片「%s」", "en": "Reward · Archive Rubbing %s"},
	"option_archive_event": {"zh": "异事 · 封钥借契", "en": "Event · Latch Bargain"},
	"option_archive_recovery": {"zh": "修整 · 守灯静读", "en": "Recovery · Lamp Respite"},
	"option_vault_reward_format": {"zh": "奖励 · 雷纹拓笔「%s」", "en": "Reward · Storm Etching %s"},
	"option_vault_event": {"zh": "异事 · 伏雷换契", "en": "Event · Vault Bargain"},
	"option_vault_recovery": {"zh": "修整 · 伏纹稳息", "en": "Recovery · Grounding Ward"},
	"option_abyss_reward_format": {"zh": "奖励 · 终室备墨「%s」", "en": "Reward · Final Draft %s"},
	"option_abyss_event": {"zh": "异事 · 渊页誓约", "en": "Event · Abyss Pact"},
	"option_abyss_recovery": {"zh": "修整 · 压关静息", "en": "Recovery · Stilling Breath"},
	"option_default_reward_format": {"zh": "奖励 · 偏旁「%s」", "en": "Reward · Radical %s"},
	"option_default_event": {"zh": "异事 · 残卷回响", "en": "Event · Scroll Echo"},
	"option_default_recovery": {"zh": "修整 · 歇笔回气", "en": "Recovery · Short Rest"},
	"preview_line_chamber_format": {"zh": "下一房间 · %s", "en": "Chamber · %s"},
	"preview_line_wave_format": {"zh": "下一波 · 第 %d 波%s", "en": "Next Wave · %d%s"},
	"preview_wave_major_suffix": {"zh": " · 大潮压境", "en": " · Major Surge"},
	"preview_line_realm_format": {"zh": "字境 · %s", "en": "Realm · %s"},
	"preview_line_pressure_format": {"zh": "压境重点 · %s", "en": "Pressure · %s"},
	"preview_line_threat_mix_format": {"zh": "威胁混编 · %s", "en": "Threat Mix · %s"},
	"short_rest_echo_banner_format": {"zh": "歇笔回气  再补 %d%% 气血", "en": "Short Rest  Echo heal %d%%"},
	"short_rest_echo_log_format": {"zh": "第 %d 波 · 歇笔回气再次回响", "en": "Wave %d · Short Rest echoes again"},
	"interlude_body_archive_format": {
		"zh": "首位卷主已散，当前房间也暂时清空，下一段会推入「%s」。\n\n简库中庭会先换成更贴近 source 的专属卷间抉择：\n奖励 · 简库拓片：带走偏旁「%s」，下一段敌人仍会更常掉残纸 / 战印，后续偏旁三选一也会更偏向这两笔。\n异事 · 封钥借契：保留残卷回响，同时开场先带着 %d 秒疾书令与 %d 秒纸域护势入深层，后续偏旁三选一会更偏向 %s。\n修整 · 守灯静读：先回复 %d%% 气血、解除眩晕，并把 %d 秒文笔提速一并带进下一段；后续偏旁三选一会更偏向 %s，后面每逢字潮推进还会再补一小口气。",
		"en": "The first scroll lord is gone and the chamber has gone quiet. The run is about to shift into %s.\n\nSlip Archive now swaps in a denser chamber choice:\nReward · Archive Rubbing: carry radicals %s, the next chamber still lifts paper / seal drops, and later radical drafts lean toward %s.\nEvent · Latch Bargain: arm Scroll Echo for the next chamber, open it with %d s of Swift Edict plus %d s of paper ward, and tilt later radical drafts toward %s.\nRecovery · Lamp Respite: restore %d%% vitality, clear stun, take %d s of brush haste forward, and tilt later radical drafts toward %s before later wave pushes echo a smaller %d%% recovery."
	},
	"interlude_body_vault_format": {
		"zh": "当前卷主已散，房间也暂时清空，下一段会推入「%s」。\n\n雷纹内库会先换成更贴近 source 的专属卷间抉择：\n奖励 · 雷纹拓笔：带走偏旁「%s」，并带着 %d 秒文笔提速入场。\n异事 · 伏雷换契：下一段会先带着 %d 秒疾书令闯入雷纹内库。\n修整 · 伏纹稳息：先回复 %d%% 气血、解除眩晕，并把 %d 秒纸域护势带进下一段。",
		"en": "The current scroll lord is gone and the chamber has gone quiet. The run is about to shift into %s.\n\nThunder Vault now swaps in a colder chamber choice:\nReward · Storm Etching: carry radical %s and enter with %d s of brush haste.\nEvent · Vault Bargain: enter with %d s of Swift Edict already running.\nRecovery · Grounding Ward: restore %d%% vitality, clear stun, and carry %d s of paper ward into the next chamber."
	},
	"interlude_body_abyss_format": {
		"zh": "当前卷主已散，房间也暂时清空，下一段会推入「%s」。\n\n卷渊终室会先换成一组终室专属卷间抉择：\n奖励 · 终室备墨：带走偏旁「%s」，把最后一轮字路先补齐。\n异事 · 渊页誓约：终室开场会同时带着 %d 秒疾书令与 %d 秒文笔提速。\n修整 · 压关静息：先回复 %d%% 气血、解除眩晕，并把 %d 秒纸域护势一并带进终室。",
		"en": "The current scroll lord is gone and the chamber has gone quiet. The run is about to shift into %s.\n\nAbyss Sanctum now swaps in a final chamber choice:\nReward · Final Draft: carry radicals %s before the last chamber.\nEvent · Abyss Pact: open the sanctum with %d s of Swift Edict and %d s of brush haste together.\nRecovery · Stilling Breath: restore %d%% vitality, clear stun, and carry %d s of paper ward into the final room."
	},
	"interlude_body_default_format": {
		"zh": "首位卷主已散，当前房间也暂时清空，下一段会推入「%s」。\n\n先看下方下一段预览，再定一项：\n奖励 · 偏旁补给：带走偏旁「%s」，而且下一段敌人会更常掉残纸 / 战印。\n异事 · 残卷回响：给下一段挂上一层掉落偏向，让压境敌群额外回响残纸，精英也能额外吐出 %d 秒疾书令，持续到下一位卷主。\n修整 · 歇笔回气：先回复 %d%% 气血、解除眩晕并获得 %d 秒文笔提速，后面每逢字潮推进还会再补一小口气。",
		"en": "The first scroll lord is gone and the chamber has gone quiet. The run is about to shift into %s.\n\nCheck the next push below, then choose one:\nReward keeps radical %s and lifts paper / seal drops through the next chamber.\nEvent carries a Scroll Echo forward so pressure enemies echo extra paper and elites can drop %d s of Swift Edict until the next scroll lord.\nRecovery restores %d%% vitality, clears stun, and grants %d s of brush haste now, then repeats a smaller %d%% recovery echo on later wave pushes."
	}
}

const BATTLE_CHAMBER_CONTENT := {
	"chambers": {
		"entry_court": {
			"name": {"zh": "入卷前庭", "en": "Entry Court"},
			"tip": {
				"zh": "这是开卷前庭，树阵、卷架与补给点还保持第一层较开阔的铺陈。",
				"en": "This is the opening court: a wider first chamber where trees, racks, and supplies still sit in their broad entry spread."
			},
			"objectives": {
				"seal_gatekeeper": {
					"name": {"zh": "前庭启门印", "en": "Courtyard Gate Seal"},
					"tip": {
						"zh": "卷主退散后，先触碰这枚封门印，逼出守关魁首。只有守魁倒下，卷间奖印才会真正显形。",
						"en": "Once the scroll lord falls, touch the sealed ward to force out its gatekeeper. Only after that warden falls will the chamber reward beacon rise."
					},
					"gatekeepers": {
						"entry_court_gatekeeper": {
							"name": {"zh": "砚门守魁", "en": "Ink Gate Warden"},
							"taunt": {"zh": "封门未开，先过我。", "en": "The seal stays shut until I fall."}
						}
					}
				},
				"seal_relay": {
					"name": {"zh": "前庭连锁印", "en": "Courtyard Relay Seals"},
					"tip": {
						"zh": "卷主退散后，前庭会再亮起两枚副印。逐一收束后，卷间奖印才会真正显形。",
						"en": "Once the scroll lord falls, two relay seals light up across the courtyard. Collapse both of them before the chamber reward beacon can rise."
					}
				}
			}
		},
		"slip_archive": {
			"name": {"zh": "简库中庭", "en": "Slip Archive"},
			"tip": {
				"zh": "更深一层会推入简库中庭，卷架与碑刻挤得更近，补给点和砚台也会重排成新的房间读法。",
				"en": "The next layer opens into Slip Archive, where racks and stelae crowd the room more tightly and the supply / inkstone rhythm is fully re-seeded."
			},
			"objectives": {
				"storm_latch_seal": {
					"name": {"zh": "雷纹转钥封", "en": "Storm Latch Seal"},
					"tip": {
						"zh": "简库卷主退散后，先触碰这枚转钥封，逼出简雷守将。只有守将倒下，通往雷纹内库的卷间奖印才会显形。",
						"en": "Once the archive lord falls, touch this latch seal to force out the Slip Storm Marshal. Only after it falls will the reward beacon toward Thunder Vault rise."
					},
					"gatekeepers": {
						"slip_archive_gatekeeper": {
							"name": {"zh": "简雷守将", "en": "Slip Storm Marshal"},
							"taunt": {"zh": "转钥未开，先破我阵。", "en": "Break my lattice before the vault unseals."}
						}
					}
				}
			}
		},
		"thunder_vault": {
			"name": {"zh": "雷纹内库", "en": "Thunder Vault"},
			"tip": {
				"zh": "更深一层会推入雷纹内库，冷色石架、雷碑与补给改成更紧的中轴布置，房间读法也会跟着收束。",
				"en": "The next layer opens into Thunder Vault, where colder stone racks, storm stelae, and mirrored supplies tighten the room around a central lane."
			}
		},
		"abyss_sanctum": {
			"name": {"zh": "卷渊终室", "en": "Abyss Sanctum"},
			"tip": {
				"zh": "更深一层会推入卷渊终室，深墨卷架、压阵石碑与终室补给会围成更稳的终局读法。",
				"en": "The next layer opens into Abyss Sanctum, where darker scroll racks, sealing stelae, and a final supply ring frame the last chamber."
			}
		}
	}
}

const BATTLE_GUIDANCE_CONTENT := {
	"default_tip": {
		"zh": "击倒字灵收集字力与补给，升级时三选一偏旁。靠近砚台按 E 磨词。",
		"en": "Defeat glyph spirits to collect ink power and supplies. Choose one of three radicals on level-up, then press E near the inkstone to refine phrases."
	},
	"inkstone_ready_tip": {
		"zh": "靠近砚台，按 E 磨词。词技只会在这里成型。",
		"en": "Move close to the inkstone and press E to refine phrases. Phrase arts can only be formed here."
	},
	"inkstone_waiting_tip": {
		"zh": "砚台静候。先把合字升满，再带着相关偏旁来磨词。",
		"en": "The inkstone waits. Max a fused glyph first, then bring its related radicals here for phrase refinement."
	},
	"inkstone_no_glyph_ready": {
		"zh": "砚上无字可磨",
		"en": "No glyph is ready for the inkstone"
	},
	"choice_complete_glyph_now_format": {
		"zh": "补上最后一笔，立成「%s」。",
		"en": "Complete the final stroke and form `%s` immediately."
	},
	"choice_collect_glyph_route_format": {
		"zh": "收集成字，通往「%s」。",
		"en": "Collect toward `%s` and open this glyph route."
	},
	"choice_upgrade_glyph_format": {
		"zh": "提升「%s」 Lv.%d -> Lv.%d。",
		"en": "Upgrade `%s` Lv.%d -> Lv.%d."
	},
	"choice_no_phrase_followthrough_format": {
		"zh": "「%s」当前已经写满；额外「%s」余材暂时还没有后续词技。",
		"en": "`%s` is already complete in this build. Extra `%s` stock has no phrase follow-through yet."
	},
	"choice_phrase_unlock_progress_format": {
		"zh": "为「%s」添一枚余材，可去砚台磨词 %d/%d。",
		"en": "Add one more stock to `%s`, then refine it at the inkstone %d/%d."
	},
	"choice_phrase_upgrade_ready_format": {
		"zh": "补充词材，可在砚台将「%s」升到 Lv.%d。当前余材 %d。",
		"en": "Add more phrase stock to raise `%s` to Lv.%d at the inkstone. Current stock %d."
	},
	"choice_weapon_core_suffix_format": {
		"zh": " 并强化%s。",
		"en": " Also strengthen %s."
	},
	"word_refine_stock_missing": {
		"zh": "余材不足",
		"en": "Not enough stock"
	},
	"word_refine_progress_format": {
		"zh": "%s 磨词 %d/%d",
		"en": "%s refine %d/%d"
	},
	"word_choice_headline_refine_format": {
		"zh": "磨词 %d/%d",
		"en": "Refine %d/%d"
	},
	"word_choice_headline_upgrade_format": {
		"zh": "词技升级  Lv.%d -> Lv.%d",
		"en": "Phrase Upgrade  Lv.%d -> Lv.%d"
	},
	"word_choice_description_format": {
		"zh": "%s\n当前余材：%d 枚，来自「%s」。",
		"en": "%s\nCurrent stock: %d, drawn from `%s`."
	},
	"hero_callout_title_format": {
		"zh": "%s应声",
		"en": "%s Responds"
	},
	"hero_callout_log_prefix_format": {
		"zh": "%s：",
		"en": "%s: "
	},
	"enemy_taunt_title_format": {
		"zh": "%s叫阵",
		"en": "%s Challenges You"
	},
	"enemy_taunt_log_prefix_format": {
		"zh": "%s：",
		"en": "%s: "
	},
	"enemy_entrance_taunts": {
		"elite": {
			"zh": [
				"魇潮已至，退无可退。",
				"把名字留在败卷里。",
				"这一页写你的败笔。"
			],
			"en": [
				"The nightmare tide is here. There is no retreat.",
				"Leave your name in the broken scroll.",
				"This page will record your failed stroke."
			]
		},
		"boss": {
			"zh": [
				"残卷深处，不留活笔。",
				"你会写进我的卷底。",
				"到此为止，执笔者。"
			],
			"en": [
				"No living stroke survives this deep in the scroll.",
				"Your name will be written into the bottom of my scroll.",
				"This is where your writing ends, scribe."
			]
		}
	},
	"room_objective_gatekeeper_default_name": {
		"zh": "守关魁首",
		"en": "Gatekeeper"
	},
	"room_objective_status_gatekeeper_active_format": {
		"zh": "%s · %s 击败%s后，卷间奖印才会解封。",
		"en": "%s · %s Defeat %s to unseal the reward beacon."
	},
	"room_objective_status_gatekeeper_reach_format": {
		"zh": "%s · %s 先靠近封门印，逼出守关魁首。",
		"en": "%s · %s Reach the sealed ward to draw the gatekeeper out."
	},
	"room_objective_status_seal_remaining_format": {
		"zh": "%s · %s 当前还差 %d / %d 枚封印。",
		"en": "%s · %s Remaining seals %d/%d."
	},
	"guidance_sealed_ward": {
		"zh": "封门印",
		"en": "Sealed Ward"
	},
	"guidance_seals_remaining_format": {
		"zh": "封印 %d/%d",
		"en": "Seals %d/%d"
	},
	"guidance_reward_beacon": {
		"zh": "卷间奖印",
		"en": "Reward Beacon"
	},
	"reward_beacon_banner": {
		"zh": "卷间奖印显形",
		"en": "Reward Beacon Raised"
	},
	"reward_beacon_reveal_title": {
		"zh": "卷间奖印",
		"en": "Reward Beacon"
	},
	"reward_beacon_reveal_body": {
		"zh": "卷间抉择已经显在附近。先走到这枚奖印前，才能真正定下下一条路。",
		"en": "The chamber break is nearby now. Reach the reward beacon to resolve one between-chambers choice."
	},
	"reward_beacon_tip": {
		"zh": "卷间奖印已经亮起。先亲自走到奖印前，卷间抉择才会真正打开。",
		"en": "The chamber reward beacon is now active. Walk to it before the next chamber choice can resolve."
	},
	"reward_beacon_log": {
		"zh": "卷间奖印 · 靠近后再定下一路",
		"en": "Reward Beacon · Reach the chamber prize"
	},
	"room_objective_banner_format": {
		"zh": "房间目标  %s",
		"en": "Room Objective  %s"
	},
	"room_objective_reveal_title": {
		"zh": "房间目标",
		"en": "Room Objective"
	},
	"room_objective_log_format": {
		"zh": "房间目标 · %s",
		"en": "Room Objective · %s"
	},
	"room_objective_gatekeeper_banner_format": {
		"zh": "%s  守关现身",
		"en": "%s  Gatekeeper waiting"
	},
	"room_objective_gatekeeper_reveal_title": {
		"zh": "封门守魁",
		"en": "Seal Warden"
	},
	"room_objective_gatekeeper_reveal_body_format": {
		"zh": "击败%s后，卷间奖印才会真正解封。",
		"en": "Defeat %s to unseal the reward beacon."
	},
	"room_objective_gatekeeper_log_format": {
		"zh": "%s · %s拦路",
		"en": "%s · %s emerges"
	},
	"room_objective_seals_remaining_banner_format": {
		"zh": "%s  还差 %d 枚",
		"en": "%s  %d seals remain"
	},
	"room_objective_seals_remaining_log_format": {
		"zh": "%s · 尚余 %d 枚封印",
		"en": "%s · %d seals remain"
	},
	"room_objective_complete_banner_format": {
		"zh": "%s  奖印显形",
		"en": "%s  Reward beacon raised"
	},
	"room_objective_complete_log_format": {
		"zh": "%s完成 · 奖印显形",
		"en": "%s complete · Reward beacon raised"
	},
	"room_objective_gatekeeper_callout_title_format": {
		"zh": "%s拦路",
		"en": "%s Challenges You"
	},
	"room_objective_gatekeeper_callout_source_format": {
		"zh": "%s：",
		"en": "%s: "
	},
	"intro_banner_format": {
		"zh": "%s  ·  %s %s",
		"en": "%s  ·  %s %s"
	},
	"intro_entry_suffix": {
		"zh": "入卷",
		"en": "enters the scroll"
	},
	"intro_log_format": {
		"zh": "%s · %s %s",
		"en": "%s · %s %s"
	},
	"boss_spawn_detail_first": {
		"zh": "先躲开场的大禁阵，再抓卷主回气时的空档。",
		"en": "Large forbidden arrays arrive first. Dodge the opening layer, then punish the recovery."
	},
	"boss_spawn_detail_deeper": {
		"zh": "更深的卷主会把弹幕、冲锋和禁阵连成更长一套节奏。",
		"en": "This deeper lord chains volleys, charges, and forbidden arrays into one longer rhythm."
	},
	"boss_stage_tip_first": {
		"zh": "卷主踏入墨阵。先躲大范围禁阵，再抓它施法后的空档。",
		"en": "The scroll lord has entered the inkfield. Dodge the large forbidden arrays first, then punish the gaps after each cast."
	},
	"boss_stage_tip_deeper": {
		"zh": "更深的卷主现身了。它会把弹幕、冲锋和禁阵叠在一起。",
		"en": "A deeper scroll lord has appeared. It layers volleys, charges, and forbidden arrays into one sequence."
	},
	"scroll_label_current": {
		"zh": "残卷一",
		"en": "Scroll I"
	},
	"boss_stage_label_first": {
		"zh": "首卷主",
		"en": "First Scroll Lord"
	},
	"boss_stage_label_deeper": {
		"zh": "深层卷主",
		"en": "Deeper Scroll Lord"
	},
	"boss_reveal_title_first_format": {
		"zh": "%s压阵而至",
		"en": "%s enters the field"
	},
	"boss_reveal_title_deeper_format": {
		"zh": "%s自深卷降阵",
		"en": "%s descends deeper"
	},
	"boss_defeat_reveal_title_complete": {
		"zh": "本卷卷主皆已崩散",
		"en": "All scroll lords have fallen"
	},
	"boss_defeat_reveal_title_next": {
		"zh": "更深一层正在翻开",
		"en": "The deeper layer unfolds"
	},
	"boss_defeat_detail_complete": {
		"zh": "本卷目标已经定住，后续战斗主要用于继续测试这条 build 的上限。",
		"en": "Chapter target secured. Keep fighting only to test how far this build can still climb."
	},
	"boss_defeat_detail_next": {
		"zh": "先收拢散落补给，再准备迎接下一位卷主和更密的混编字潮。",
		"en": "Gather the scattered supplies, then prepare for the next scroll lord and denser mixed waves."
	},
	"boss_defeat_banner_complete": {
		"zh": "残卷一暂定",
		"en": "Scroll I Secured"
	},
	"boss_defeat_tip_complete": {
		"zh": "本卷卷主都已崩散，章节目标完成。继续战斗可测试成长上限。",
		"en": "All scroll lords have collapsed. The chapter goal is complete, and you can keep fighting to test the build ceiling."
	},
	"boss_defeat_log_complete": {
		"zh": "残卷一暂定 · 卷主尽散",
		"en": "Scroll I Secured · Bosses gone"
	},
	"boss_defeat_soundtrack_complete": {
		"zh": "残卷暂定",
		"en": "Scroll Secured"
	},
	"boss_defeat_banner_next": {
		"zh": "卷主退散",
		"en": "Boss Dispersed"
	},
	"boss_defeat_tip_next": {
		"zh": "卷主崩散后，先清掉残留字灵；战场安静下来后，会先停在卷间缓冲再继续入深层。",
		"en": "The scroll lord has fallen. Clear the lingering glyph spirits and a chamber break will open before the run pushes deeper."
	},
	"boss_defeat_log_next": {
		"zh": "卷主退散 · 残卷继续翻开",
		"en": "Boss Dispersed · The scroll unfolds deeper"
	},
	"boss_defeat_soundtrack_next": {
		"zh": "残卷回气",
		"en": "Scroll Recovery"
	},
	"test_jump_banner_format": {
		"zh": "试阵跃迁 · 第 %d 波",
		"en": "Test Jump · Wave %d"
	},
	"test_jump_tip_format": {
		"zh": "已清空当前敌群并切到第 %d 波，可继续观察刷怪节奏、演出密度和 FPS。",
		"en": "The current enemies, hazards, and projectiles were cleared and the run jumped to wave %d so you can inspect pacing, effect density, and FPS."
	},
	"phrase_reward_heal_format": {
		"zh": "回复 %d 点气血",
		"en": "restore %d vitality"
	},
	"phrase_reward_xp_format": {
		"zh": "获得 %d 点字墨",
		"en": "gain %d ink"
	},
	"phrase_reward_reveal": {
		"zh": "扩开附近迷雾显形",
		"en": "widen nearby fog reveal"
	},
	"phrase_reward_radical_format": {
		"zh": "获得偏旁「%s」",
		"en": "gain radical %s"
	},
	"phrase_reward_default": {
		"zh": "领取句阵赏赐",
		"en": "claim the sentence reward"
	},
	"phrase_guardian_banner_format": {
		"zh": "句阵守卫 · %s",
		"en": "Sentence Guardian · %s"
	},
	"phrase_guardian_reveal_title": {
		"zh": "守句现身",
		"en": "Guarded Phrase"
	},
	"phrase_guardian_reveal_body_format": {
		"zh": "击败守句魁首，即可%s。",
		"en": "Defeat the guardian to %s."
	},
	"phrase_guardian_tip_format": {
		"zh": "这段房间里已经显出「%s」句阵。击败守句魁首后，就能%s。",
		"en": "The guarded phrase `%s` has surfaced in this chamber. Defeat its guardian to %s."
	},
	"phrase_guardian_log_format": {
		"zh": "句阵守卫 · %s",
		"en": "Phrase Guardian · %s"
	},
	"phrase_guardian_default_name": {
		"zh": "守句魁首",
		"en": "Sentence Guardian"
	},
	"phrase_guardian_stela_badge": {
		"zh": "句阵守卫",
		"en": "Guarded Phrase"
	},
	"phrase_revealed_banner_format": {
		"zh": "句成异动 · %s",
		"en": "Phrase Revealed · %s"
	},
	"phrase_revealed_reveal_title": {
		"zh": "句成异动",
		"en": "Verse Revealed"
	},
	"phrase_revealed_reward_format": {
		"zh": "奖励 · %s",
		"en": "Reward · %s"
	},
	"phrase_revealed_tip_format": {
		"zh": "「%s」句阵已经显成，句阵赏赐会为你%s。",
		"en": "The guarded phrase `%s` is now yours. The sentence reward will %s."
	},
	"phrase_revealed_log_format": {
		"zh": "句成异动 · %s · %s",
		"en": "Phrase Revealed · %s · %s"
	},
	"chamber_pressure_big_wave": {
		"zh": "刷怪速度和场上字灵上限都会一起抬高。",
		"en": "Enemy cap and spawn rate both rise together."
	},
	"chamber_pressure_wave_2": {
		"zh": "弓手会开始混进字潮，远程牵制变多。",
		"en": "Ranged pressure starts mixing into the tide."
	},
	"chamber_pressure_wave_3": {
		"zh": "突刺和地阵会开始叠在一起施压。",
		"en": "Dashes and ground arrays start overlapping."
	},
	"chamber_pressure_wave_4": {
		"zh": "冲锋线会开始切穿混编字潮。",
		"en": "Charge lines start cutting through mixed waves."
	},
	"chamber_pressure_wave_default": {
		"zh": "魁首会更常压阵，混编节奏会更硬。",
		"en": "Elites begin anchoring the pack more often."
	},
	"threat_tip_big_wave": {
		"zh": "大潮压境。刷怪频率和场上敌量上限同时抬高，先清外围远程，再留技能处理中心重压。",
		"en": "A major surge is here. Spawn rate and enemy cap both rise, so clear the outer ranged threats before spending skills on the center crush."
	},
	"threat_tip_wave_2": {
		"zh": "字潮抬升。弓手开始混入阵线，注意被远程拉扯。",
		"en": "The tide rises. Archers start entering the line, so watch for ranged pressure while kiting."
	},
	"threat_tip_wave_3": {
		"zh": "字潮再涨。忍与阵师入场，突刺和地阵会一起施压。",
		"en": "The tide swells again. Assassins and ritualists join the wave, so dashes and ground arrays will overlap."
	},
	"threat_tip_wave_4": {
		"zh": "墨骑踏阵。保持走位，不要在冲锋预警线里停太久。",
		"en": "Ink cavalry has entered the field. Keep moving and do not stand inside the charge line for too long."
	},
	"threat_tip_wave_default": {
		"zh": "魁首开始现身，补给和成词节奏都要提前准备。",
		"en": "Elites begin appearing more often, so prepare supplies and phrase timing before the next pressure spike."
	}
}

const BATTLE_FIELD_PHASE_CONTENT := {
	"shift_banner_format": {"zh": "字境相变 · %s", "en": "Realm Shift · %s"},
	"shift_reveal_title": {"zh": "字境相变", "en": "Realm Shift"},
	"shift_tip_format": {"zh": "第 %d 波切入%s。%s", "en": "Wave %d enters %s. %s"},
	"themes": {
		"stelaeGrove": {
			"name": {"zh": "碑林", "en": "Stele Grove"},
			"cue": {"zh": "字境·碑林", "en": "Realm Shift · Stele Grove"},
			"tip": {
				"zh": "碑林压阵，石色字痕会留在你当时落脚的位置。",
				"en": "Stone-lit script settles over the arena, leaving carved glyph marks where you were standing."
			}
		},
		"inkTide": {
			"name": {"zh": "墨潮", "en": "Ink Tide"},
			"cue": {"zh": "字境·墨潮", "en": "Realm Shift · Ink Tide"},
			"tip": {
				"zh": "墨潮翻卷，地表会偏向水墨青蓝，古纹像潮线一样缓慢游动。",
				"en": "The field turns toward blue-black ink and the old patterns drift like tide lines."
			}
		},
		"thunderScript": {
			"name": {"zh": "雷纹", "en": "Thunder Script"},
			"cue": {"zh": "字境·雷纹", "en": "Realm Shift · Thunder Script"},
			"tip": {
				"zh": "雷纹显形，雾色会更冷更亮，环境字阵也会抬高可见度。",
				"en": "Fog turns colder and brighter, and the ambient glyph array becomes easier to read."
			}
		},
		"ancientScroll": {
			"name": {"zh": "残卷", "en": "Ancient Scroll"},
			"cue": {"zh": "字境·残卷", "en": "Realm Shift · Ancient Scroll"},
			"tip": {
				"zh": "残卷回暖，纸本山水会偏回赭金，巨字像旧墨一样烙在地上。",
				"en": "Warm parchment tones return and giant glyphs press into the ground like old ink seals."
			}
		}
	}
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
	"人物来路": "Background",
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
	"记录于 %s": "Logged %s",
	"返回顶部": "Back to Top",
	"当前还没有试阵记录。用第 10 / 20 波捷径打一轮后，这里会单独留下试阵榜。": "There are no test-run records yet. Use the wave 10 or wave 20 shortcut once and this board will fill in separately.",
	"当前还没有可展示的主卷战绩。下一次从第 1 波真正开卷后，这里会留下你的记录。": "There are no main-scroll results to show yet. Finish a true run from wave 1 and your record will appear here.",
	"试阵榜会单独记录第 10 / 20 波捷径，不与主卷榜混排。": "Test runs keep wave 10 and wave 20 shortcuts on a separate board.",
	"主卷榜只统计从第 1 波真正开卷的正式战绩。": "The main-scroll board only tracks full runs that begin at wave 1.",
	"当前排序：%s。": "Sorted by %s.",
	"本地主卷榜": "Local Main Board",
	"本地试阵榜": "Local Test Board",
	"本轮残卷": "Main Scroll",
	"本轮试阵": "Test Run",
	"战绩署名": "Run Alias",
	"最近一条战绩署名": "Latest Entry Alias",
	"本轮记录已经写入主卷榜。你可以直接改成想显示的名字；留空则保留玩家名帖里的默认署名。": "This run was written into the main-scroll board. You can rename it here, or leave the field blank to keep the default Player Sigil alias.",
	"本轮试阵记录已经写入试阵榜，不会影响主卷榜排序。你可以直接改成想显示的名字；留空则保留玩家名帖里的默认署名。": "This test run was written into the test board and will not affect the main-scroll ranking. You can rename it here, or leave the field blank to keep the default Player Sigil alias.",
	"这里显示最近写入主卷榜的那条战绩；如果刚结束的是试阵捷径，可以先切到试阵榜再改名。": "This view shows the latest entry written into the main-scroll board. If you just finished a shortcut test run, switch to the test board first before renaming it.",
	"这里显示最近写入试阵榜的那条战绩；试阵记录会和主卷榜分开保留。": "This view shows the latest entry written into the test board. Test records stay separate from the main-scroll board.",
	"试阵榜单独收录第 10 / 20 波捷径，方便检查敌潮、build 与 HUD；现在也能在波次 / 击破 / 存活三种排序之间切换，更接近 source 榜单的回看方式。": "The test board keeps wave 10 and wave 20 shortcuts separate so you can inspect enemy mixes, builds, and HUD behavior. It now also pivots between wave, kills, and survival-time ordering so route checks read closer to the source leaderboard.",
	"主卷榜只收从第 1 波真正开卷的战绩；现在也能在波次 / 击破 / 存活三种排序之间切换，开局前可以从不同角度回看 route 成果。": "The main-scroll board only keeps real runs that start from wave 1. It now also pivots between wave, kills, and survival-time ordering so you can review route outcomes from different angles before the next run.",
	"主卷榜": "Main Board",
	"试阵榜": "Test Board",
	"查看%s": "View %s",
	"切到试阵榜 · %d": "Switch to Test Board · %d",
	"切到主卷榜 · %d": "Switch to Main Board · %d",
	"返回结算": "Back to Summary",
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
	"当前署名：%s": "Current alias: %s",
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


static func localize_menu_text(text: String, english: bool) -> String:
	if not english:
		return text
	if text.begins_with("• "):
		return "• %s" % localize_menu_text(text.substr(2), true)
	return String(MENU_EN_TEXT.get(text, text))


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


static func local_leaderboard_content() -> Dictionary:
	return MENU_LEADERBOARD_CONTENT.duplicate(true)


static func battle_state_content() -> Dictionary:
	return BATTLE_STATE_CONTENT.duplicate(true)


static func battle_hud_content() -> Dictionary:
	return BATTLE_HUD_CONTENT.duplicate(true)


static func battle_pickup_content() -> Dictionary:
	return BATTLE_PICKUP_CONTENT.duplicate(true)


static func localize_battle_text(text: String, english: bool) -> String:
	if not english:
		return text
	if BATTLE_HUD_EN_TEXT.has(text):
		return String(BATTLE_HUD_EN_TEXT.get(text, text))
	return localize_menu_text(text, true)


static func battle_interlude_content() -> Dictionary:
	return BATTLE_INTERLUDE_CONTENT.duplicate(true)


static func battle_chamber_content() -> Dictionary:
	return BATTLE_CHAMBER_CONTENT.duplicate(true)


static func battle_guidance_content() -> Dictionary:
	return BATTLE_GUIDANCE_CONTENT.duplicate(true)


static func battle_field_phase_content() -> Dictionary:
	return BATTLE_FIELD_PHASE_CONTENT.duplicate(true)


static func menu_leaderboard_content() -> Dictionary:
	return MENU_LEADERBOARD_CONTENT.duplicate(true)


static func menu_enemy_content() -> Dictionary:
	return MENU_ENEMY_CONTENT.duplicate(true)
