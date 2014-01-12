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
local GetUnitIsActive 	= Spring.GetUnitIsActive
local GetUnitIsDead 	= Spring.GetUnitIsDead
local GetUnitLosState	= Spring.GetUnitLosState
local GetUnitRulesParam	= Spring.GetUnitRulesParam
local GetUnitSeparation	= Spring.GetUnitSeparation
local GetUnitTeam		= Spring.GetUnitTeam
-- Synced Ctrl
local SetUnitLosMask 	= Spring.SetUnitLosMask
local SetUnitLosState 	= Spring.SetUnitLosState

-- Unsynced Ctrl
-- Constants
local BEACON_ID = UnitDefNames["beacon"].id

local NARC_ID = WeaponDefNames["narc"].id
local NARC_DURATION = 30 * 60 -- 60 seconds
Spring.SetGameRulesParam("NARC_DURATION", NARC_DURATION)

local TAG_ID = WeaponDefNames["tag"].id

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

local function GetUnitUnderJammer(unitID, teamID)
	if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead then return false end
	if not teamID then teamID = GetUnitTeam(unitID) end
	local allyTeam = select(6, GetTeamInfo(teamID))
	for jammerID, radius in pairs(allyJammers[allyTeam]) do
		if GetUnitSeparation(unitID, jammerID) < radius and GetUnitIsActive(jammerID) then return true end
	end
	return false
end
GG.GetUnitUnderJammer = GetUnitUnderJammer

-- helper functions for LUS
local function IsUnitNARCed(unitID)
	return (GetUnitRulesParam(unitID, "NARC") or 0) > 0
end
GG.IsUnitNARCed = IsUnitNARCed

local function IsUnitTAGed(unitID)
	local TAGFrame = GetUnitRulesParam(unitID, "TAG") or 0
	local gameFrame = GetGameFrame()
	return TAGFrame >= gameFrame - 5
end
GG.IsUnitTAGed = IsUnitTAGed

local function ResetLosStates(unitID, allyTeam)
	if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
		local radarState = GetUnitLosState(unitID, allyTeam).radar
		SetUnitLosState(unitID, allyTeam, {los = radarState})
		SetUnitLosMask(unitID, allyTeam, {los=radarState, prevLos=radarState, radar=false, contRadar=false} )
	end
end

local function NARC(unitID, allyTeam, duration)
	local narcFrame = GetGameFrame() + duration
	narcUnits[unitID] = {frame = narcFrame, allyTeam = allyTeam}
	SetUnitLosState(unitID, allyTeam, {los=true, prevLos=true, radar=true, contRadar=true} ) 
	SetUnitLosMask(unitID, allyTeam, {los=true, prevLos=false, radar=false, contRadar=false} )	
	-- Set rules param here so that widgets know the unit is NARCed, value points to the frame NARC runs out
	SetUnitRulesParam(unitID, "NARC", narcFrame, {inlos = true})
end

local function DeNARC(unitID, allyTeam, force)
	if not GetUnitIsDead(unitID) and narcUnits[unitID] and (narcUnits[unitID].frame <= GetGameFrame() + 1 or force) then
		narcUnits[unitID] = nil
		-- unset rules param
		SetUnitRulesParam(unitID, "NARC", -1, {inlos = true})
		ResetLosStates(unitID, allyTeam)
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
	-- Don't allow any damage to beacons or dropzones
	if unitDefID == BEACON_ID or UnitDefs[unitDefID].name:find("dropzone") or UnitDefs[unitDefID].customParams.decal then return 0 end
	-- ignore none weapons
	if not attackerID then return damage end
	-- NARCs
	if weaponID == NARC_ID then
		--if GetUnitUnderJammer(unitID, unitTeam) then return 0 end
		local allyTeam = select(6, GetTeamInfo(attackerTeam))
		-- do the NARC, delay the deNARC
		local duration = GetUnitRulesParam(attackerID, "NARC_DURATION") or NARC_DURATION
		NARC(unitID, allyTeam, duration)
		DelayCall(DeNARC, {unitID, allyTeam}, duration)
		-- NARC does 0 damage
		return 0
	elseif weaponID == TAG_ID then
		SetUnitRulesParam(unitID, "TAG", GetGameFrame(), {inlos = true})
		return 0
	end
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

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	--Spring.Echo("Unit Given: " .. unitID)
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		DelayCall(ResetLosStates, {unitID, allyTeam}, 2)
	end
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
		-- We no longer want to remove NARCS under ECM, only prevent them
		--[[for unitID, data in pairs(narcUnits) do
			local teamID = GetUnitTeam(unitID)
			if GetUnitUnderJammer(unitID, teamID) then DeNARC(unitID, data.allyTeam, true) end
		end]]
	end
	if Spring.IsGameOver() then
		gadgetHandler:RemoveGadget()
	end
end

else

-- UNSYNCED

end
