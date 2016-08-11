return {
	["ecm_ping"] = {
		groundflash = {
			air                = true,
			--alwaysvisible      = true,
			circlealpha        = 0.6,
			circlegrowth       = 6,
			flashalpha         = 0.9,
			flashsize          = 220,
			ground             = true,
			ttl                = 13,
			water              = true,
			color = {
				[1]  = 0,
				[2]  = 0.5,
				[3]  = 1,
			},
		},
	},
	["ecm_ping2"] = {
		ecm1 = {
			class = "CSimpleGroundFlash",
			ground = true,
			water = true,
			air = true,
			properties = {
				size = 220,
				sizegrowth = 6,
				ttl = 13,
				colormap = [[0 0.5 1 0.9  0 0.5 1 0.9]],
				texture = "seismic",
			},
		}
	},
	["bap_ping"] = {
		groundflash = {
			air                = true,
			alwaysvisible      = true,
			circlealpha        = 0.4,
			circlegrowth       = 2,
			flashalpha         = 0.8,
			flashsize          = 180,
			ground             = true,
			ttl                = 24,
			water              = true,
			color = {
				[1]  = 1,
				[2]  = 0.1,
				[3]  = 0,
			},
		},
	},
}
