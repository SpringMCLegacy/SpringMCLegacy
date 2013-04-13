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
local GetUnitIsDead 	= Spring.GetUnitIsDead
local GetUnitLosState	= Spring.GetUnitLosState
local GetUnitRulesParam	= Spring.GetUnitRulesParam
local GetUnitSeparation	= Spring.GetUnitSeparation
-- Synced Ctrl
local SetUnitLosMask 	= Spring.SetUnitLosMask
local SetUnitLosState 	= Spring.SetUnitLosState

-- Unsynced Ctrl
-- Constants
local NARC_ID = WeaponDefNames["narc"].id
local NARC_DURATION = 32 * 60 -- 30 seconds
Spring.SetGameRulesParam("NARC_DURATION", NARC_DURATION)

-- Variables
local modOptions = Spring.GetModOptions()
local inRadarUnits = {}
local outRadarUnits = {}
local allyJammers = {}

local allyTeams = Spring.GetAllyTeamList()
local numAllyTeams = #allyTeams

for i = 1, numAllyTeams do
	local allyTeam = allyTeams[i]
	inRadarUnits[allyTeam] = {}
	outRadarUnits[allyTeam] = {}
	allyJammers[allyTeam] = {}
end

local narcUnits = {}

local function GetUnitUnderJammmer(unitID, allyTeam)
	for jammerID, radius in pairs(allyJammers[allyTeam]) do
		if GetUnitSeparation(unitID, jammerID) < radius then return true end
	end
	return false
end

local function NARC(unitID, allyTeam, duration)
	local narcFrame = GetGameFrame() + duration
	narcUnits[unitID] = narcFrame
	SetUnitLosState(unitID, allyTeam, {los=true, prevLos=true, radar=true, contRadar=true} ) 
	SetUnitLosMask(unitID, allyTeam, {los=true, prevLos=false, radar=false, contRadar=false} )	
	-- Set rules param here so that widgets know the unit is NARCed, value points to the frame NARC runs out
	SetUnitRulesParam(unitID, "NARC", narcFrame, {inlos = true})
end

local function DeNARC(unitID, allyTeam)
	if not GetUnitIsDead(unitID) and narcUnits[unitID] and narcUnits[unitID] <= GetGameFrame() + 1 then
		narcUnits[unitID] = nil
		-- unset rules param
		SetUnitRulesParam(unitID, "NARC", -1, {inlos = true})
		local radarState = GetUnitLosState(unitID, allyTeam).radar
		SetUnitLosState(unitID, allyTeam, {los = radarState})
		SetUnitLosMask(unitID, allyTeam, {los=radarState, prevLos=radarState, radar=false, contRadar=false} )
	end
end

function gadget:UnitEnteredRadar(unitID, unitTeam, allyTeam, unitDefID)
	--Spring.Echo(UnitDefs[unitDefID].name .. " entered radar " .. allyTeam)
	inRadarUnits[allyTeam][unitID] = true
	outRadarUnits[allyTeam][unitID] = nil
end

function gadget:UnitLeftRadar(unitID, unitTeam, allyTeam, unitDefID)
	--Spring.Echo(UnitDefs[unitDefID].name .. " left radar " .. allyTeam)
	outRadarUnits[allyTeam][unitID] = true
	inRadarUnits[allyTeam][unitID] = nil
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
	-- ignore non-NARC weapons
	if weaponID ~= NARC_ID or not attackerID then return damage end
	if GetUnitUnderJammer(unitID, select(6, GetTeamInfo(unitTeam)) then return 0 end
	local allyTeam = select(6, GetTeamInfo(attackerTeam))
	-- do the NARC, delay the deNARC
	local duration = GetUnitRulesParam(attackerID, "NARC_DURATION") or NARC_DURATION
	NARC(unitID, allyTeam, duration)
	DelayCall(DeNARC, {unitID, allyTeam}, duration)
	-- NARC does 0 damage
	return 0
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local ud = UnitDefs[unitDefID]
	local jamRadius = ud.jammerRadius
	if jamRadius then
		local allyTeam = select(6, GetTeamInfo(teamID))
		allyJammers[allyTeam][unitID] = jamRadius
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		inRadarUnits[allyTeam][unitID] = nil
		outRadarUnits[allyTeam][unitID] = nil
		allyJammers[allyTeam][unitID] = nil
	end
	narcUnits[unitID] = nil
end

function gadget:GameFrame(n)
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		for unitID in pairs(inRadarUnits[allyTeam]) do
			if not narcUnits[unitID] then
				SetUnitLosState(unitID, allyTeam, {los=true, prevLos=true, radar=true, contRadar=true} ) 
				SetUnitLosMask(unitID, allyTeam, {los=true, prevLos=false, radar=false, contRadar=false} )	
				inRadarUnits[allyTeam][unitID] = nil
			end
		end
		for unitID in pairs(outRadarUnits[allyTeam]) do
			if not narcUnits[unitID] then
				SetUnitLosMask(unitID, allyTeam, {los=false, prevLos=false, radar=false, contRadar=false} )
				outRadarUnits[allyTeam][unitID] = nil
			end
		end
	end
end

else

-- UNSYNCED

end
