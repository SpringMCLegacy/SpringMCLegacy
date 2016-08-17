local fxs = {
	flameHeat = {
		class = "JitterParticles2",
		options = {
			colormap		= { {1,1,1,1},{1,1,1,1} },
			count			= 6,
			life			= 50,
			delaySpread		= 25,
			force			= {0,1.5,0},
			emitRotSpread	= 10,
			speed			= 7,
			speedSpread		= 0,
			speedExp		= 1.5,
			size			= 15,
			sizeGrowth		= 5.0,
			scale			= 1.5,
			strength		= 1.0,
			heat			= 2,
		},
	},
	missileEngine = {
		class = "ribbon", 
		options = {size = 4, width = 4, color = {0.95, 0.65, 0.4,0.6}, texture1 = ":c:bitmaps/ProjectileTextures/missiletrail.png"},
	},
	srmEngine = {
		class = "ribbon", 
		options = {size = 1, width = 2, color = {0.95, 0.65, 0.4,0.6}},
	},
	amsTracer = {
		class = "ribbon",
		options = {size = 2, width = 1, color = {0.95, 0.65, 0,0.6}},
	},
	ppcTail = {
		class = "ribbon",
		options = {size = 24, width = 6, color = {0.55, 0.65, 1,0.6}, texture1 = ":c:bitmaps/ProjectileTextures/ppctrail.png"},
	},
	nppcTail = {
		class = "ribbon",
		options = {size = 72, width = 10, color = {0.55, 0.65, 1,0.6}, texture1 = ":c:bitmaps/ProjectileTextures/ppctrail.png"},
	},
}

return fxs