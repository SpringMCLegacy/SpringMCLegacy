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

	local function EmitLupsSfx(unitID, effectName, pieceNum, options)
		--GG.Delay.DelayCall(SendToUnsynced,{"lups_emitsfx", unitID, effectName, pieceNum, unpack(options)},0))
		bufferSize = bufferSize + 1
		unsyncedBuffer[bufferSize] = {"lups_emitsfx", unitID, effectName, pieceNum, options} -- TODO: serialise options table here, currently passed as string
	end
	GG.EmitLupsSfx = EmitLupsSfx

	local function RemoveLupsSfx(unitID, pieceNum)
		bufferSize = bufferSize + 1
		unsyncedBuffer[bufferSize] = {"lups_removesfx", unitID, pieceNum}
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
	dropship_vertical_exhaust = {
		class = "AirJet",
		options = {
			emitVector = {0, 0, 1},
			length = 55,
			width = 15,
			color = {0.2, 0.5, 0.9, 0.01},
			distortion    = 0.015,
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
	dropship_vertical_exhaust2 = {
		class = "JitterParticles2",
		options = {
			pos            = {0,0,0}, --// start pos
			partpos        = "0,0,0", --// particle relative start pos (can contain lua code!)
			layer          = 0,

			count          = 20,

			life           = 20,
			lifeSpread     = 0,
			delaySpread    = 20,

			emitVector     = {0,0,-1},
			emitRot        = 0,
			emitRotSpread  = 15,

			force          = {0,0,0}, --// global effect force
			forceExp       = 1,

			speed          = 10,
			speedSpread    = 1,
			speedExp       = 1.3, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow

			size           = 50,
			sizeSpread     = 50,
			sizeGrowth     = -2,
			sizeExp        = 1, --// >1 : first decrease slow, then fast;  <1 : decrease fast, then slow;  <0 : invert x-axis (start large become smaller)

			strength       = 0.25, --// distortion strength
			scale          = 2.8, --// scales the distortion texture
			animSpeed      = 0.01, --// speed of the distortion
			heat           = 10, --// brighten distorted regions by "length(distortionVec)*heat"

			repeatEffect   = true, --can be a number,too
		},
	},
}

local unitPieceFXs = {}

	local function EmitLupsSfx(unitID, effectName, pieceNum, options)
		local Lups = GG.Lups
		--Spring.Echo("Got this far!", Lups, unitID, effectName, pieceNum, options)

		local effect = effects[effectName]
		local opts = {}

		if options then
			for k,v in pairs(effect.options) do
				opts[k] = v
			end
			for k,v in spairs(options) do
				opts[k] = v
			end
		end
		opts.unit = unitID
		opts.piecenum = pieceNum

		local fxID = Lups.AddParticles(effect.class, opts)

		if opts.replace then
			if unitPieceFXs[unitID] then -- remove existing ones first TODO: make a toggle via param?
				Lups.RemoveParticles(unitPieceFXs[unitID][pieceNum])
				unitPieceFXs[unitID][pieceNum] = nil
			end
		end
		if not unitPieceFXs[unitID] then
			unitPieceFXs[unitID] = {}
		end
		unitPieceFXs[unitID][pieceNum] = fxID
	end

	local function RemoveLupsSfx(unitID, pieceNum)
		local Lups = GG.Lups
		Lups.RemoveParticles(unitPieceFXs[unitID][pieceNum])
		unitPieceFXs[unitID][pieceNum] = nil
	end
	
	local function UpdateLupsSfx()
		local Lups = GG.Lups
		for i, callInfo in spairs(SYNCED.unsyncedBuffer) do 
			--for k,v in spairs(callInfo) do Spring.Echo(k,v) end
			if callInfo[1] == "lups_emitsfx" then
				local unitID, effectName, pieceNum, options = callInfo[2], callInfo[3], callInfo[4], callInfo[5]
				EmitLupsSfx(unitID, effectName, pieceNum, options)
			elseif callInfo[1] == "lups_removesfx" then
				local unitID, pieceNum = callInfo[2], callInfo[3]
				RemoveLupsSfx(unitID, pieceNum)
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