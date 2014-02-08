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
		}
	},
}

local unitPieceFXs = {}

	local function EmitLupsSfx(unitID, effectName, pieceNum, options)
		local Lups = GG.Lups
		--Spring.Echo("Got this far!", Lups, unitID, effectName, pieceNum, options)
		local overrides = {}
		if options then
			for k,v in spairs(options) do overrides[k] = v end
		end
		local effect = effects[effectName]
		effect.options.unit = unitID
		effect.options.piecenum = pieceNum
		for k, v in pairs(effect.options) do
			if not overrides[k] then
				overrides[k] = v
			end
		end
		local fxID = Lups.AddParticles(effect.class, overrides)
		if not unitPieceFXs[unitID] then -- first effect
			unitPieceFXs[unitID] = {}
		else -- remove existing ones first TODO: make a toggle via param?
			Lups.RemoveParticles(unitPieceFXs[unitID][pieceNum])
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