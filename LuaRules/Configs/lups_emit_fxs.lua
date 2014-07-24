local effects = {
	dropship_hull_heat = {
		class = "SimpleParticles2",
		options = {
			emitVector     = {0,1,0},
			pos            = {0,-200,0}, --// start pos
			partpos        = "0,0,0",

			count          = 40,
			force          = {0,15,0}, --// global effect force
			forceExp       = 0.5,
			speed          = 2,
			speedSpread    = 8,
			speedExp       = 5, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow
			life           = 20,
			lifeSpread     = 0,
			delaySpread    = 40,
			rotSpeed       = 10,
			rotSpeedSpread = -20,
			rotSpread      = 360,
			rotExp         = 1, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)
			emitRot        = 70,
			emitRotSpread  = 10,
			size           = 100,
			sizeSpread     = 0,
			sizeGrowth     = -1,
			sizeExp        = 2, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)
			colormap       = { {0.2, 0.2, 0.2, 0.03}, {0.13, 0.13, 0.13, 0.01}, {0, 0, 0, 0} }, --//max 16 entries
			texture        = 'bitmaps/cgtextures/Flames0028_2_S.jpg',
			repeatEffect   = true, --can be a number,too
		},
	},
	plume = {
		class = "SimpleParticles2",
		options = {
			emitVector     = {0,-1,0},
			pos            = {0,0,0}, --// start pos
			partpos        = "0,0,0",
			count          = 10,
			force          = {0,-3,0}, --// global effect force
			forceExp       = 0.5,
			speed          = 10,
			speedSpread    = 2,
			speedExp       = 1.5, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow
			life           = 120,
			lifeSpread     = 0,
			delaySpread    = 30,
			rotSpeed       = 5,
			rotSpeedSpread = -10,
			rotSpread      = 360,
			rotExp         = 2, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)
			emitRot        = 0,
			emitRotSpread  = 90,
			size           = 4,
			sizeSpread     = 0,
			sizeGrowth     = 4,
			sizeExp        = 1, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)
			colormap       = { {0.3, 0.3, 0.3, 0.01}, {0.3, 0.3, 0.3, 0.01}, {0.3, 0.3, 0.3, 0} }, --//max 16 entries
			texture        = 'bitmaps/ProjectileTextures/kfoam.tga',
			--repeatEffect   = true, --can be a number,too
		},
	},
	dropship_vertical_exhaust = {
		class = "AirJet",
		options = {
			emitVector = {0, 0, 1},
			length = 55,
			width = 15,
			color = {0.2, 0.5, 0.9, 0.01},
			distortion    = 0,
			texture2      = ":c:bitmaps/GPL/lups/shot.tga",       --// shape
			texture3      = ":c:bitmaps/GPL/lups/shot.tga",       --// jitter shape
			repeatEffect  = false,
		}
	},
	exhaust_ground_winds = {
		class = "JitterParticles2",
		options = {
			pos            = {0,-150,0}, --// start pos
			partpos        = "0,0,0", --// particle relative start pos (can contain lua code!)
			layer          = 0,

			count          = 200,

			life           = 15,
			lifeSpread     = 0,
			delaySpread    = 80,

			emitVector     = {0,1,0},
			emitRot        = 85,
			emitRotSpread  = 10,

			force          = {0,-0.1,0}, --// global effect force
			forceExp       = 1,

			speed          = 15,
			speedSpread    = 10,
			speedExp       = 3.2, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow

			size           = 20,
			sizeSpread     = 20,
			sizeGrowth     = 10,
			sizeExp        = 1, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)

			strength       = 0.4, --// distortion strength
			scale          = 2, --// scales the distortion texture
			animSpeed      = 0.1, --// speed of the distortion
			heat           = -5, --// brighten distorted regions by "length(distortionVec)*heat"
		},
	},
	dropship_horizontal_jitter_strong = {
		class = "JitterParticles2",
		options = {
			pos            = {0,0,0}, --// start pos
			partpos        = "0,0,0", --// particle relative start pos (can contain lua code!)
			layer          = 0,

			count          = 10,

			life           = 20,
			lifeSpread     = 0,
			delaySpread    = 30,

			emitVector     = {0,0,-1},
			emitRot        = 0,
			emitRotSpread  = 25,

			force          = {0,0,0}, --// global effect force
			forceExp       = 1,

			speed          = 5,
			speedSpread    = 15,
			speedExp       = 1.4, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow

			size           = 60,
			sizeSpread     = 10,
			sizeGrowth     = -1,
			sizeExp        = 1, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)

			strength       = 0.50, --// distortion strength
			scale          = 2.8, --// scales the distortion texture
			animSpeed      = 0.03, --// speed of the distortion
			heat           = 10, --// brighten distorted regions by "length(distortionVec)*heat"

			repeatEffect   = 5,
		},
	},
	dropship_horizontal_jitter_weak = {
		class = "JitterParticles2",
		options = {
			pos            = {0,0,-30}, --// start pos
			partpos        = "0,0,0", --// particle relative start pos (can contain lua code!)
			layer          = 0,

			count          = 10,

			life           = 20,
			lifeSpread     = 0,
			delaySpread    = 20,

			emitVector     = {0,0,-1},
			emitRot        = 0,
			emitRotSpread  = 15,

			force          = {0,2,0}, --// global effect force
			forceExp       = 2,

			speed          = 1,
			speedSpread    = 5,
			speedExp       = 1.3, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow

			size           = 50,
			sizeSpread     = 50,
			sizeGrowth     = -1,
			sizeExp        = 1, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)

			strength       = 0.20, --// distortion strength
			scale          = 2.8, --// scales the distortion texture
			animSpeed      = 0.03, --// speed of the distortion
			heat           = 10, --// brighten distorted regions by "length(distortionVec)*heat"

			repeatEffect   = true, --can be a number,too
		},
	},
	valve_release = {
		class = "JitterParticles2",
		options = {
			texture        = 'bitmaps/cgtextures/Flames0028_2_S.jpg',
			pos            = {120,125,0}, --// start pos
			partpos        = "0,0,0", --// particle relative start pos (can contain lua code!)
			layer          = 0,

			count          = 20,

			life           = 25,
			lifeSpread     = 0,
			delaySpread    = 10,

			emitVector     = {1,0,0},
			emitRot        = 0,
			emitRotSpread  = 10,

			--force          = {0,-0.1,0}, --// global effect force
			--forceExp       = 1,

			speed          = 1,--5,
			speedSpread    = 0,
			speedExp       = 1.3, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow

			size           = 2,--4,
			sizeSpread     = 0,
			sizeGrowth     = 1.4,--4,
			sizeExp        = 1, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)

			strength       = 0.4, --// distortion strength
			scale          = 2, --// scales the distortion texture
			animSpeed      = 0.1, --// speed of the distortion
			heat           = 12, --// brighten distorted regions by "length(distortionVec)*heat"
		},
	},
	valve_sound = {
		class = "Sound",
		options = {
			volume = 5,
			--repeatEffect   = true,
			--length = 120,
			--file = "sounds/fire-flame-burner.wav",
			file = "sounds/spray.wav",
		},
	},
	land_sound = {
		class = "Sound",
		options = {
			volume = 10,
			file = "sounds/unit/stomp.wav",
		},
	},
	engine_sound = {
		class = "Sound",
		options = {
			volume = 50,
			--repeatEffect = 1,
			length = 210,
			file = "sounds/fire-flame-burner.wav",
		},
	},
}

return effects