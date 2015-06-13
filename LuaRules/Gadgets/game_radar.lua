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

local FRAME_FUDGE = 16

local BEACON_ID = UnitDefNames["beacon"].id

local NARC_ID = WeaponDefNames["narc"].id
local NARC_DURATION = 30 * 60 -- 60 seconds
Spring.SetGameRulesParam("NARC_DURATION", NARC_DURATION)

local TAG_ID = WeaponDefNames["tag"].id

local PPC_IDS = {}
for weaponDefID, weaponDef in pairs(WeaponDefs) do
	if weaponDef.name:find("ppc") then
		PPC_IDS[weaponDefID] = true
	end
end

-- Variables
local modOptions = Spring.GetModOptions()
local inRadarUnits = {}
local outRadarUnits = {}
local allyJammers = {}

local allyTeams = Spring.GetAllyTeamList()
local numAllyTeams = #allyTeams
local teamsInAllyTeams = {}
local deadTeams = {}

for i = 1, numAllyTeams do
	local allyTeam = allyTeams[i]
	inRadarUnits[allyTeam] = {}
	outRadarUnits[allyTeam] = {}
	allyJammers[allyTeam] = {}
	teamsInAllyTeams[allyTeam] = Spring.GetTeamList(allyTeam)
end

local narcUnits = {}

local PPC_DURATION = 5 * 30 -- 5 seconds
local sensorTypes = {"radar", "seismic", "radarJammer"}
local unitSensorRadii = {} -- unitSensorRadii[unitID] = {radar = a, seismic = b ...}
local ppcUnits = {} -- ppcUnits[unitID] = gameframe

local function FinishPPC(unitID)
	if ppcUnits[unitID] and ppcUnits[unitID] <= (Spring.GetGameFrame() - PPC_DURATION) then
		for _, sensorType in pairs(sensorTypes) do
			Spring.SetUnitSensorRadius(unitID, sensorType, unitSensorRadii[unitID][sensorType])
		end
		ppcUnits[unitID] = nil
		SetUnitRulesParam(unitID, "PPC_HIT", -1, {inlos = true})
	end
end

local function ApplyPPC(unitID)
	if not ppcUnits[unitID] then -- not yet under PPC effects
		unitSensorRadii[unitID] = {}
		for _, sensorType in pairs(sensorTypes) do
			-- perks change radii so can't rely on unitdef values
			unitSensorRadii[unitID][sensorType] = Spring.GetUnitSensorRadius(unitID, sensorType)
			Spring.SetUnitSensorRadius(unitID, sensorType, 0) -- ECM & BAP are disabled altogether
		end
		-- BAP is disabled - return to regular radar (TODO: should really reset the emit height too! Needs engine change)
		-- FIXME: set these default values in a single place and read them from there
		Spring.SetUnitSensorRadius(unitID, "radar", 2000) --L138 unitdefs_post
	end
	ppcUnits[unitID] = Spring.GetGameFrame()
	SetUnitRulesParam(unitID, "PPC_HIT", ppcUnits[unitID], {inlos = true})
	GG.Delay.DelayCall(FinishPPC, {unitID}, PPC_DURATION)
end

local function GetUnitUnderJammer(unitID)
	return (GetUnitRulesParam(unitID, "FRIENDLY_ECM") or 0) + FRAME_FUDGE >= GetGameFrame() 
end
GG.GetUnitUnderJammer = GetUnitUnderJammer

-- helper functions for LUS
local function IsUnitNARCed(unitID)
	return (GetUnitRulesParam(unitID, "NARC") or 0) > 0
end
GG.IsUnitNARCed = IsUnitNARCed

local function IsUnitTAGed(unitID)
	return (GetUnitRulesParam(unitID, "TAG") or 0) + FRAME_FUDGE >= GetGameFrame()
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
	if UnitDefs[unitDefID].speed > 0 then
		outRadarUnits[allyTeam][unitID] = nil
	end
end

function gadget:UnitLeftRadar(unitID, unitTeam, allyTeam, unitDefID)
	--Spring.Echo(UnitDefs[unitDefID].name .. " left radar " .. allyTeam)
	if UnitDefs[unitDefID].speed > 0 then
		outRadarUnits[allyTeam][unitID] = true
		inRadarUnits[allyTeam][unitID] = nil
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
	-- Don't allow any damage to beacons or dropzones
	if unitDefID == BEACON_ID or UnitDefs[unitDefID].name:find("dropzone") or UnitDefs[unitDefID].customParams.decal then return 0 end
	-- ignore none weapons
	if not attackerID then return damage end
	-- NARCs
	if weaponID == NARC_ID then
		-- Don't allow dropships to be NARCed
		if UnitDefs[unitDefID].customParams.dropship then return 0 end
		--if GetUnitUnderJammer(unitID, unitTeam) then return 0 end
		local allyTeam = select(6, GetTeamInfo(attackerTeam))
		-- do the NARC, delay the deNARC
		local duration = GetUnitRulesParam(attackerID, "NARC_DURATION") or NARC_DURATION
		NARC(unitID, allyTeam, duration)
		DelayCall(DeNARC, {unitID, allyTeam}, duration)
		-- NARC does 0 damage
		return 0
	elseif weaponID == TAG_ID then
		-- Don't allow dropships to be TAGed
		if not UnitDefs[unitDefID].customParams.dropship then
			SetUnitRulesParam(unitID, "TAG", GetGameFrame(), {inlos = true})
			--Spring.Echo("I AM BEING TAGGED!")
		end
		return 0
	elseif PPC_IDS[weaponID] then
		ApplyPPC(unitID)
	end
	return damage, 1
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local ud = UnitDefs[unitDefID]
	local jamRadius = ud.jammerRadius
	if jamRadius > 0 then
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
	ppcUnits[unitID] = nil
	SetUnitRulesParam(unitID, "FRIENDLY_ECM", 0)
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		inRadarUnits[allyTeam][unitID] = nil
		outRadarUnits[allyTeam][unitID] = nil
		allyJammers[allyTeam][unitID] = nil
	end
	SetUnitRulesParam(unitID, "FRIENDLY_ECM", 0)
	gadget:UnitCreated(unitID, unitDefID, newTeam)
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
		for jammerID, radius in pairs(allyJammers[allyTeam]) do
			if Spring.ValidUnitID(jammerID) and not Spring.GetUnitIsDead(jammerID) and not ppcUnits[jammerID] and GetUnitIsActive(jammerID) then
			local x,y,z = Spring.GetUnitPosition(jammerID)
			for _, teamID in pairs(teamsInAllyTeams[allyTeam]) do
				if not deadTeams[teamID] then
					local nearbyUnits = Spring.GetUnitsInCylinder(x, z, radius, teamID)
						--Spring.Echo("Jammer", jammerID, "(", UnitDefs[Spring.GetUnitDefID(jammerID)].name, ")")
					for i = 1, #nearbyUnits do
						--Spring.Echo("nearby", UnitDefs[Spring.GetUnitDefID(nearbyUnits[i])].name)
						SetUnitRulesParam(nearbyUnits[i], "FRIENDLY_ECM", n)
					end
				end
			end
		end
	end
	end
	if Spring.IsGameOver() then
		gadgetHandler:RemoveGadget()
	end
end

function gadget:TeamDied(teamID)
	deadTeams[teamID] = true
end

else

-- UNSYNCED

end
