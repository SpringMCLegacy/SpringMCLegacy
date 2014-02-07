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
		for i = 1, bufferSize do
			SendToUnsynced(unpack(unsyncedBuffer[i]))
		end
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

	local function EmitLupsSfx(_, unitID, effectName, pieceNum, options)
		local Lups = GG.Lups
		--Spring.Echo("Got this far!", Lups, unitID, effectName, pieceNum, options)
		local effect = effects[effectName]
		local overrides = GG.StringToTable(options)
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
  
	local function RemoveLupsSfx(_, unitID, pieceNum)
		local Lups = GG.Lups
		Lups.RemoveParticles(unitPieceFXs[unitID][pieceNum])
		unitPieceFXs[unitID][pieceNum] = nil
	end
	
	function gadget:Initialize()
		gadgetHandler:AddSyncAction("lups_emitsfx", EmitLupsSfx)
		gadgetHandler:AddSyncAction("lups_removesfx", RemoveLupsSfx)
	end

	function gadget:Shutdown()
		gadgetHandler.RemoveSyncAction("lups_emitsfx")
		gadgetHandler.RemoveSyncAction("lups_removesfx")
	end

end