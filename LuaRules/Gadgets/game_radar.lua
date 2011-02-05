function gadget:GetInfo()
	return {
		name = "Game Radar",
		desc = "Units in radar range become visible",
		author = "FLOZi (C. Lawrence)",
		date = "02/02/2011",
		license = "GNU GPL v2",
		layer = 1,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations
-- Synced Read
-- Synced Ctrl
local SetUnitLosMask 	= Spring.SetUnitLosMask
local SetUnitLosState 	= Spring.SetUnitLosState

-- Unsynced Ctrl
-- Constants
-- Variables
local modOptions = Spring.GetModOptions()
local inRadarUnits = {}
local outRadarUnits = {}

function gadget:GameFrame(n)
	for unitID, allyTeam in pairs(inRadarUnits) do
		SetUnitLosState(unitID, allyTeam, {los=true, prevLos=true, radar=true, contRadar=true} ) 
		SetUnitLosMask(unitID, allyTeam, {los=true, prevLos=false, radar=false, contRadar=false} )
	end
	inRadarUnits = {}
	for unitID, allyTeam in pairs(outRadarUnits) do
		SetUnitLosMask(unitID, allyTeam, {los=false, prevLos=false, radar=false, contRadar=false} )
	end
	outRadarUnits = {}
end

function gadget:UnitEnteredRadar(unitID, unitTeam, allyTeam, unitDefID)
	inRadarUnits[unitID] = allyTeam
end

function gadget:UnitLeftRadar(unitID, unitTeam, allyTeam, unitDefID)
	outRadarUnits[unitID] = allyTeam
end

else

-- UNSYNCED

end
