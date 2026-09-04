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
--------------------------------------------------------------------------------

return {
	FS = {
		texmods = {
			DavionGuards = {
				display = "Davion Guards",
			},
		},
	},

	CC = {
		texmods = {
			DeathCommandos = {
				display = "Death Commandos",
			},
		},
	},

	DC = {
		texmods = {
			SwordofLight = {
				display = "Sword of Light",
			},
		},
	},

	FW = {
		texmods = {
			MarikMilitia = {
				display = "Marik Militia",
			},
		},
	},

	LA = {
		texmods = {
			LyranGuards = {
				display = "Lyran Guards",
			},
		},
	},

	SJ = {
		texmods = {
			SJAlpha = {
				display = "Smoke Jaguar Alpha Galaxy",
			},
		},
	},

	WF = {
		texmods = {
			WFBeta = {
				display = "Wolf Beta Galaxy",
			},
			WolfInExile = {
				display = "Wolf in Exile",
			},
		},
	},
}
