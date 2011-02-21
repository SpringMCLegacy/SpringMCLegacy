function gadget:GetInfo()
	return {
		name = "LUS Helper",
		desc = "Parses UnitDef and Model data for LUS",
		author = "FLOZi (C. Lawrence)",
		date = "20/02/2011", -- 25 today ;_;
		license = "GNU GPL v2",
		layer = 1,
		enabled = false
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations

-- Synced Read
local GetUnitPieceMap		= Spring.GetUnitPieceMap
-- Synced Ctrl

-- Unsynced Ctrl
-- Constants

-- Variables

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	-- Parse Model Data
	local pieceMap = GetUnitPieceMap(unitID)
end

function gadget:GamePreload()
	-- Parse UnitDef Data
	for unitDefID, unitDef in pairs(UnitDefs) do

	end
	
end

else

-- UNSYNCED

end
