--------------------------------------------------------------------------------
-- MCL faction paint-scheme definitions
-- Author: zvero + ChatGPT
--
-- Faction keys use the shortName values from gamedata/sidedata.lua.
-- "Team" is the implicit default for every faction and does not need to be
-- repeated in these lists.
--
-- The texmod key is the internal/debug name used for DDS/PNG filenames and
-- synced logic. "display" is optional player-facing localization. If display is
-- missing or empty, the selector falls back to the debug name.
-- WARNING: Texmod names can not have numbers in them!
--------------------------------------------------------------------------------

return {
	FS = {
		texmods = {
			DavionGuards = {
				display = "Davion Guards",
			},
			Crucis = {
				display = "8th Crucis Lancers",
			},
		},
	},

	CC = {
		texmods = {
			DeathCommandos = {
				display = "Death Commandos",
			},
			Imarra = {
				display = "Warrior House Imarra",
			},
		},
	},

	DC = {
		texmods = {
			SwordofLight = {
				display = "Sword of Light",
			},
			Genyosha = {
				display = "2nd Genyosha",
			},
		},
	},

	FW = {
		texmods = {
			MarikMilitia = {
				display = "Marik Militia",
			},
			Regulan = {
				display = "5th Regulan Hussars",
			},
		},
	},

	LA = {
		texmods = {
			LyranGuards = {
				display = "Lyran Guards",
			},
			SkyeRangers = {
				display = "Skye Rangers",
			},
		},
	},

	SJ = {
		texmods = {
			SJAlpha = {
				display = "Alpha Galaxy",
			},
			SJZeta = {
				display = "Zeta Galaxy",
			},
		},
	},

	WF = {
		texmods = {
			WFAlpha = {
				display = "Alpha Galaxy",
			},
			WFBeta = {
				display = "Beta Galaxy",
			},
			WolfInExile = {
				display = "Wolf-in-Exile",
			},
		},
	},
}
