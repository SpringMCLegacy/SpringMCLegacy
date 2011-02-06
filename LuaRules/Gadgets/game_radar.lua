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
local DelayCall = GG.Delay.DelayCall
local SetUnitRulesParam	= Spring.SetUnitRulesParam
-- Synced Read
local GetGameFrame 		= Spring.GetGameFrame
local GetTeamInfo		= Spring.GetTeamInfo
-- Synced Ctrl
local SetUnitLosMask 	= Spring.SetUnitLosMask
local SetUnitLosState 	= Spring.SetUnitLosState

-- Unsynced Ctrl
-- Constants
local NARC_ID = WeaponDefNames["narc"].id
local NARC_DURATION = 32 * 30 -- 30 seconds

-- Variables
local modOptions = Spring.GetModOptions()
local inRadarUnits = {}
local outRadarUnits = {}
local narcUnits = {}

local function NARC(unitID, allyTeam)
	local narcFrame = GetGameFrame() + NARC_DURATION
	narcUnits[unitID] = narcFrame
	SetUnitLosState(unitID, allyTeam, {los=true, prevLos=true, radar=true, contRadar=true} ) 
	SetUnitLosMask(unitID, allyTeam, {los=true, prevLos=false, radar=false, contRadar=false} )	
	-- Set rules param here so that widgets know the unit is NARCed, value points to the frame NARC runs out
	SetUnitRulesParam(unitID, "NARC", GetGameFrame() + NARC_DURATION, {inlos = true})
end

local function DeNARC(unitID, allyTeam)
	if narcUnits[unitID] <= GetGameFrame() + 1 then
		narcUnits[unitID] = nil
		SetUnitLosMask(unitID, allyTeam, {los=false, prevLos=false, radar=false, contRadar=false} )
		-- unset rules param
		SetUnitRulesParam(unitID, "NARC", -1, {inlos = true})
	end
end

function gadget:UnitEnteredRadar(unitID, unitTeam, allyTeam, unitDefID)
	inRadarUnits[unitID] = allyTeam
	outRadarUnits[unitID] = nil
end

function gadget:UnitLeftRadar(unitID, unitTeam, allyTeam, unitDefID)
	outRadarUnits[unitID] = allyTeam
	inRadarUnits[unitID] = nil
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	-- ignore non-NARC weapons
	if weaponID ~= NARC_ID or not attackerID then return damage end
	local allyTeam = select(6, GetTeamInfo(attackerTeam))
	-- do the NARC, delay the deNARC
	NARC(unitID, allyTeam)
	DelayCall(DeNARC, {unitID, allyTeam}, NARC_DURATION)
	-- NARC does 0 damage
	return 0
end

function gadget:GameFrame(n)
	for unitID, allyTeam in pairs(inRadarUnits) do
		if not narcUnits[unitID] then
			SetUnitLosState(unitID, allyTeam, {los=true, prevLos=true, radar=true, contRadar=true} ) 
			SetUnitLosMask(unitID, allyTeam, {los=true, prevLos=false, radar=false, contRadar=false} )	
			inRadarUnits[unitID] = nil
		end
	end
	for unitID, allyTeam in pairs(outRadarUnits) do
		if not narcUnits[unitID] then
			SetUnitLosMask(unitID, allyTeam, {los=false, prevLos=false, radar=false, contRadar=false} )
			outRadarUnits[unitID] = nil
		end
	end
end

else

-- UNSYNCED

end
