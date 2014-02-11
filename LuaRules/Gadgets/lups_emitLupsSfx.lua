function gadget:GetInfo()
  return {
    name      = "Emit Lups Sfx",
    desc      = "",
    author    = "FLOZi (C. Lawrence)",
    date      = "Feb. 2014",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true
  }
end


if (gadgetHandler:IsSyncedCode()) then

local unsyncedBuffer = {}
local bufferSize = 0

-- SYNCED

local function BlendJet(time, unitID, piecenum, ID)
	for t = 0, (time/3) do
		local i = 1 - t / (time/3)
		if (i == 0) then
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", piecenum, {id = ID, repeatEffect = true, delay = t*3, width = 20, length = 60})
		elseif (i > 0.33) then
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", piecenum, {id = ID, life = 3, delay = t*3, width = 20 + i * 60, length = 60 + i * 190})
		else
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", piecenum, {id = ID, life = 1, delay = t*3,   width = 20 + i * 60, length = 60 + i * 190})
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", piecenum, {id = ID, life = 2, delay = t*3+1, width = 20 + i * 40, length = 60 + i * 90})
		end
	end
end
GG.BlendJet = BlendJet

	local function EmitLupsSfx(unitID, effectName, pieceNum, options)
		--GG.Delay.DelayCall(SendToUnsynced,{"lups_emitsfx", unitID, effectName, pieceNum, unpack(options)},0))
		bufferSize = bufferSize + 1
		unsyncedBuffer[bufferSize] = {"lups_emitsfx", unitID, effectName, pieceNum, options} -- TODO: serialise options table here, currently passed as string
	end
	GG.EmitLupsSfx = EmitLupsSfx

	local function RemoveLupsSfx(unitID, fxNameID)
		bufferSize = bufferSize + 1
		unsyncedBuffer[bufferSize] = {"lups_removesfx", unitID, fxNameID}
	end
	GG.RemoveLupsSfx = RemoveLupsSfx
	
	function gadget:GameFrame(n)
		--[[for i = 1, bufferSize do
			SendToUnsynced(unpack(unsyncedBuffer[i]))
		end]]
		_G.unsyncedBuffer = unsyncedBuffer
		SendToUnsynced("lups_updatefx")
		_G.unsyncedBuffer = nil
		bufferSize = 0
		unsyncedBuffer = {}
	end

else

-- UNSYNCED

-- TODO: move to config file
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
			emitVector     = {0,0,-1},
			pos            = {0,0,0}, --// start pos
			partpos        = "0,0,0",
			count          = 30,
			force          = {0,0,0}, --// global effect force
			forceExp       = 0.5,
			speed          = 10,
			speedSpread    = 20,
			speedExp       = 1.5, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow
			life           = 120,
			lifeSpread     = 0,
			delaySpread    = 120,
			rotSpeed       = 5,
			rotSpeedSpread = -10,
			rotSpread      = 360,
			rotExp         = 2, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)
			emitRot        = 0,
			emitRotSpread  = 10,
			size           = 80,
			sizeSpread     = 50,
			sizeGrowth     = 10,
			sizeExp        = 1, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)
			colormap       = { {0.2, 0.2, 0.2, 0.01}, {0.2, 0.2, 0.2, 0.01}, {0, 0, 0, 0} }, --//max 16 entries
			texture        = 'bitmaps/cgtextures/Flames0028_2_S.jpg',
			repeatEffect   = true, --can be a number,too
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
}

local namedFXs = {}

	local function foo(st, i, n, ...)
		if i == 0 then return ... end
		return foo(st,i-1,n, st[i], ...)
	end

	local function sunpack(st)
		if #st > 0 then return unpack(st) end
		local n = 1; while st[n] do n=n+1 end; n=n-1
		return foo(st, n, n)
	end

	local function EmitLupsSfx(unitID, effectName, pieceNum, options)
		local Lups = GG.Lups
		--Spring.Echo("Got this far!", Lups, unitID, effectName, pieceNum, options)

		local effect = effects[effectName]
		local opts = {}
		assert(effect)

		for k,v in pairs(effect.options) do
			opts[k] = v
		end
		if options then
			for k,v in spairs(options) do
				opts[k] = v
			end
		end
		opts.unit = unitID
		opts.piecenum = pieceNum

		local fxID = Lups.AddParticles(effect.class, opts)

		if opts.id then
			local tu = namedFXs[unitID]
			if not tu then tu = {}; namedFXs[unitID] = tu; end
			local t = tu[opts.id]
			if not t then t = {}; tu[opts.id] = t; end
			t[#t+1] = fxID
		end
	end

	local function RemoveLupsSfx(unitID, fxNameID)
		local Lups = GG.Lups

		local tu = namedFXs[unitID]
		if not tu then return end
		local t = tu[fxNameID]
		if not t then return end

		for i=1,#t do
			Lups.RemoveParticles(t[i])
		end
		tu[fxNameID] = nil
	end
	
	local function UpdateLupsSfx()
		local Lups = GG.Lups
		for i, callInfo in spairs(SYNCED.unsyncedBuffer) do
			--for k,v in spairs(callInfo) do Spring.Echo(k,v) end
			if callInfo[1] == "lups_emitsfx" then
				EmitLupsSfx(select(2, sunpack(callInfo)))
			elseif callInfo[1] == "lups_removesfx" then
				RemoveLupsSfx(select(2, sunpack(callInfo)))
			end
		end
	end

	function gadget:Initialize()
		gadgetHandler:AddSyncAction("lups_updatefx", UpdateLupsSfx)
	end

	function gadget:Shutdown()
		gadgetHandler.RemoveSyncAction("lups_updatefx")
	end

end