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
		"id": "overview",
		"title": "仓颉之路",
		"eyebrow": "Deckbuilder Climb",
		"summary": "原项目里的《仓颉之路》已经不是空概念，而是一条可玩的 deckbuilder 爬塔原型。当前 Godot 仓库还没有把这条战斗/地图基础迁进来，所以这里先把它做成正式入口页，而不是继续停在“后续接入”。",
		"points": [
			"核心节奏是爬塔、抽牌、出牌和字形组合，不走字海残卷那套自动攻击幸存者循环。",
			"战斗舞台会把卡牌信息直接浮在场中，强调“字形 + 动作 + 语义”的同时反馈。",
			"当前最适合在 Godot 里先迁的是入口层、图谱层和长期设计说明，再等真正的卡牌战斗基础跟上。"
		]
	},
	{
		"id": "card_codex",
		"title": "卡牌字库",
		"eyebrow": "Card Codex",
		"summary": "web 原型已经把牌分成偏旁基牌、合字牌和引擎牌三层，不是单一数值卡堆。",
		"points": [
			"偏旁牌负责起手和过渡，是后续合字路线的材料层。",
			"合字牌会把结构真正写成战斗效果，让“组字”变成卡组成长的一部分。",
			"引擎牌继续推进抽牌、留牌、回气或连锁，让 deckbuilder 身份成立。"
		]
	},
	{
		"id": "fusion_atlas",
		"title": "合字图谱",
		"eyebrow": "Fusion Atlas",
		"summary": "《仓颉之路》不是只把汉字当皮肤，而是把合字路线直接做成牌组构筑图谱。",
		"points": [
			"不同合字路线会决定你这次爬塔偏向爆发、连锁、续航还是控制。",
			"图谱层会比字海残卷更强调“先收什么，再往哪条组合线转”。",
			"Godot 当前已经有字海的偏旁 -> 合字 -> 词技主线，后面可以把这套图谱思路反向迁回来。"
		]
	},
	{
		"id": "relic_shelf",
		"title": "遗物架",
		"eyebrow": "Relic Shelf",
		"summary": "web 原型里《仓颉之路》有独立遗物层，负责给整套牌组和路线额外偏转。",
		"points": [
			"遗物不会只加一点基础数值，而是会改变抽牌、留牌、字形连锁和节点选择价值。",
			"这条系统也正是 Godot 《字海残卷》当前还缺的第二成长线之一。",
			"后续如果先在启动器把遗物架说明、样例和目标整理好，会更适合衔接真正的系统迁移。"
		]
	},
	{
		"id": "tower_guide",
		"title": "塔路导览",
		"eyebrow": "Tower Guide",
		"summary": "原型里塔路节点和敌人意图已经是独立设计，不只是打完一场接一场的线性战斗。",
		"points": [
			"路线会混合战斗、恢复、事件和构筑节点，逼你在短期强度和长期牌组之间做取舍。",
			"敌人不是字海那种大群追击，而是更接近回合制对局里的意图压迫和节奏管理。",
			"Godot 端现在先用这层 portal 把路线、节点和敌意图整理清楚，避免第二项目继续只剩一张静态卡片。"
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
	"detail_title": "执笔者档案",
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
	"quick_start_summary": "对照 web 原型保留第 10 / 20 波捷径，便于快速检查 HUD、混编敌潮与角色 build。试阵入口会单独写入试阵榜，不影响主卷榜。"
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
