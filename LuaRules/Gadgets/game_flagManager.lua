function gadget:GetInfo()
	return {
		name      = "Beacon Manager",
		desc      = "Populates maps with flags and handles control",
		author    = "FLOZi",
		date      = "Adopted from S44 flagManager 10/02/2011",
		license   = "GNU GPL v2",
		layer     = 1, -- must be before game_spawn
		enabled   = true  --  loaded by default?
	}
end

-- function localisations
local floor						= math.floor
-- Synced Read
local AreTeamsAllied			= Spring.AreTeamsAllied
local GetFeatureDefID			= Spring.GetFeatureDefID
local GetFeaturePosition		= Spring.GetFeaturePosition
local GetFeaturesInRectangle	= Spring.GetFeaturesInRectangle
local GetGroundHeight			= Spring.GetGroundHeight
local GetGroundInfo				= Spring.GetGroundInfo
local GetUnitHeading			= Spring.GetUnitHeading
local GetUnitPosition			= Spring.GetUnitPosition
local GetUnitsInCylinder		= Spring.GetUnitsInCylinder
local GetUnitTeam				= Spring.GetUnitTeam
local GetTeamInfo 				= Spring.GetTeamInfo
local GetTeamRulesParam			= Spring.GetTeamRulesParam
local GetTeamUnitDefCount 		= Spring.GetTeamUnitDefCount

-- Synced Ctrl
local CallCOBScript				= Spring.CallCOBScript
local CreateUnit				= Spring.CreateUnit
local DestroyFeature			= Spring.DestroyFeature
local GameOver					= Spring.GameOver
local GiveOrderToUnit			= Spring.GiveOrderToUnit
local KillTeam					= Spring.KillTeam
local SetGameRulesParam 		= Spring.SetGameRulesParam
local SetTeamRulesParam			= Spring.SetTeamRulesParam
local SetUnitAlwaysVisible		= Spring.SetUnitAlwaysVisible
local SetUnitMetalExtraction	= Spring.SetUnitMetalExtraction
local SetUnitNeutral			= Spring.SetUnitNeutral
local SetUnitNoSelect			= Spring.SetUnitNoSelect
local SetUnitResourcing			= Spring.SetUnitResourcing
local SetUnitRulesParam			= Spring.SetUnitRulesParam
local TransferUnit				= Spring.TransferUnit

-- constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local GAIA_ALLY_ID = select(6, GetTeamInfo(GAIA_TEAM_ID))
local PROFILE_PATH = "maps/flagConfig/" .. Game.mapName .. "_profile.lua"
local DEBUG	= false -- enable to print out flag locations in profile format

local CAP_MULT = 1 --multiplies against the FBI defined CapRate
local DEF_MULT = 1 --multiplies against the FBI defined DefRate

local BEACON_ID = UnitDefNames["beacon"].id 

-- variables

local unitDefsToIgnore = {}
local flagTypes = {"beacon"}
local flags = {} -- flags[flagType][index] == flagUnitID
local numFlags = {} -- numFlags[flagType] == numberOfFlagsOfType
local totalFlags = 0
local flagTypeSpots = {} -- flagTypeSpots[flagType][metalSpotCount] == {x = x_coord, z = z_coord}


for _, flagType in pairs(flagTypes) do
	flags[flagType] = {}
	numFlags[flagType] = 0
	flagTypeSpots[flagType] = {}
end

local CAP_THRESHOLD = 20
local CAP_RADIUS = 460
local REGEN = 1

local flagCapStatuses = {} 	-- flagCapStatus[flagID] = {allyTeamID = {team = teamID, cap = cap}, ...}
local teams	= Spring.GetTeamList()
local teamUnitCounts = {}

for _, teamID in pairs(Spring.GetTeamList()) do
	teamUnitCounts[teamID] = 0
end

local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

-- BEACON TICKET DECLARATIONS
local START_TICKETS = tonumber(modOptions.start_tickets) or 100
local TICKET_LOSS_PER_BEACON = 1
local beaconsPerAllyTeam = {}
local tickets = {}
local bleedTimes = {}
local allyTeamAlive = {}
local deadAllyTeams = 0
local allyTeams = Spring.GetAllyTeamList()
for i = 1, #allyTeams do
	local allyTeam = allyTeams[i]
	if allyTeam == GAIA_ALLY_ID then 
		allyTeams[i] = nil
	else
		tickets[allyTeam] = START_TICKETS
		bleedTimes[allyTeam] = 0
		beaconsPerAllyTeam[allyTeam] = 0
		allyTeamAlive[allyTeam] = true
	end
end

if (gadgetHandler:IsSyncedCode()) then
-- SYNCED

local DelayCall = GG.Delay.DelayCall

function UpdateBeacons(teamID, num)
	if teamID == GAIA_TEAM_ID then return end -- Gaia does not have tickets
	local allyTeam = select(6, GetTeamInfo(teamID))
	beaconsPerAllyTeam[allyTeam] = beaconsPerAllyTeam[allyTeam] + num
	SetTeamRulesParam(teamID, "beacons", (GetTeamRulesParam(teamID, "beacons") or 0) + num, {public = true})
	SendToUnsynced("BEACONUPDATE", allyTeam, beaconsPerAllyTeam[allyTeam])
end

function DecrementTickets(allyTeam)
	if allyTeam == GAIA_ALLY_ID then return end -- Gaia does not have tickets
	if tickets[allyTeam] > 0 then
		tickets[allyTeam] = tickets[allyTeam] - 1
		--Spring.Echo("AllyTeam " .. allyTeam .. "[".. beaconsPerAllyTeam[allyTeam] .. "] lost 1 ticket (" .. tickets[allyTeam] .. ")")
		SetGameRulesParam("tickets" .. allyTeam, tickets[allyTeam], {public = true})
	end
	if tickets[allyTeam] == 0 then
		if allyTeamAlive[allyTeam] then
			local teams = Spring.GetTeamList(allyTeam)
			for i = 1, #teams do
				local teamID = teams[i]
				local teamUnits = Spring.GetTeamUnits(teamID)
				for i = 1, #teamUnits do
					TransferUnit(teamUnits[i], GAIA_TEAM_ID, false)
				end
				KillTeam(teamID)
			end
			allyTeamAlive[allyTeam] = false
			deadAllyTeams = deadAllyTeams + 1
			if deadAllyTeams == (#allyTeams - 1) then
				for team, alive in pairs(allyTeamAlive) do
					if alive then GameOver({team}) break end
				end
			end
		end
	end
end


-- this function is used to add any additional flagType specific behaviour
function FlagSpecialBehaviour(action, flagType, flagID, flagTeamID, teamID)
	--[[if action == "placed" then

	elseif action == "capped" then

	end]]
end


function PlaceFlag(spot, flagType, newFlag)
	if DEBUG then
		Spring.Echo("{")
		Spring.Echo("	x = " .. spot.x .. ",")
		Spring.Echo("	z = " .. spot.z .. ",")
		Spring.Echo("},")
	end
	
	if not newFlag then
		newFlag = CreateUnit(flagType, spot.x, Spring.GetGroundHeight(spot.x, spot.z), spot.z, 0, GAIA_TEAM_ID)
	end
	numFlags[flagType] = numFlags[flagType] + 1
	totalFlags = totalFlags + 1
	flags[flagType][numFlags[flagType]] = newFlag
	flagCapStatuses[newFlag] = {}
	
	SetUnitNeutral(newFlag, true)
	SetUnitAlwaysVisible(newFlag, true)
	
	local squareSize = 100
	local features = GetFeaturesInRectangle(spot.x - squareSize, spot.z - squareSize, spot.x + squareSize, spot.z + squareSize)
	for i = 1, #features do
		DestroyFeature(features[i])
	end
	FlagSpecialBehaviour("placed", flagType, newFlag, GAIA_TEAM_ID, GAIA_TEAM_ID)
end


function gadget:GamePreload()
	if DEBUG then Spring.Echo(PROFILE_PATH) end
	-- CHECK FOR PROFILES
	if VFS.FileExists(PROFILE_PATH) then
		local flagSpots, temps = VFS.Include(PROFILE_PATH)
		if flagSpots and #flagSpots > 0 then 
			Spring.Echo("Map Beacon Profile found. Loading " .. (#flagSpots or 0) .. " Beacon positions...")
			flagTypeSpots["beacon"] = flagSpots 
		end
		-- setup default ambient temps
		if not temps then temps = {} end
		temps.ambient = temps.ambient or 20
		temps.water = temps.water or 10
		GG.MapTemperatures = temps
		Spring.SetGameRulesParam("MAP_TEMP_AMBIENT", temps.ambient)
		Spring.SetGameRulesParam("MAP_TEMP_WATER", temps.water)
	else
		for i=1,20 do
			Spring.Echo("NO MAP PROFILE FOUND FOR " .. Game.mapName)
		end
		local temps = {ambient = 20, water = 10}
		GG.MapTemperatures = temps
		Spring.SetGameRulesParam("MAP_TEMP_AMBIENT", temps.ambient)
		Spring.SetGameRulesParam("MAP_TEMP_WATER", temps.water)
	end
	for unitDefID, ud in pairs(UnitDefs) do -- cache ignored unitDefIDs
		if ud.canFly or string.tobool(ud.customParams.ignoreatbeacon) then
			unitDefsToIgnore[unitDefID] = true
		end
	end
end


function gadget:GameStart()
	-- FLAG PLACEMENT
	for _, flagType in pairs(flagTypes) do
		if DEBUG then Spring.Echo("-- flagType is " .. flagType) end
		for i = 1, #flagTypeSpots[flagType] do
			PlaceFlag(flagTypeSpots[flagType][i], flagType)
		end
		GG[flagType .. "s"] = flags[flagType] -- nicer to have GG.flags rather than GG.flag
	end
end

local function StripUnits(unitsAtFlag)
	for i = #unitsAtFlag, 1, -1 do -- iterate over list in reverse so removing doesn't screw with index
		local unitID = unitsAtFlag[i]
		local unitDefID = Spring.GetUnitDefID(unitID)
		 -- bad defs are cached, but also ignore any units currently being transported
		if unitDefsToIgnore[unitDefID] or Spring.GetUnitTransporter(unitID) then
			table.remove(unitsAtFlag, i)
		end
	end
end

local function TransferFlag(flagID, flagTeamID, teamID)
	local capped = flagTeamID == GAIA_TEAM_ID
	TransferUnit(flagID, capped and teamID or GAIA_TEAM_ID, false)
	Spring.AddTeamResource(teamID, "metal", 2000) -- 2k CBills for neut or cap
	if capped then -- new team is gaining a beacon
		-- Update the new team
		UpdateBeacons(teamID, 1)
	else -- neutralised, so old team is losing a beacon
		-- Update the old team
		UpdateBeacons(flagTeamID, -1)
	end
	-- Turn flag back on TODO: check if this can be avoided in MCL?
	GiveOrderToUnit(flagID, CMD.ONOFF, {1}, {})
	-- Flag has changed team, reset capping statuses
	flagCapStatuses[flagID] = {}
	for _, cleanTeamID in pairs(Spring.GetTeamList()) do
		SetUnitRulesParam(flagID, "cap" .. tostring(cleanTeamID), 0, {public = true})
	end
end

local function FlagCapChange(flagID, flagTeamID, allyTeamID, teamID, change)
	if not flagCapStatuses[flagID][allyTeamID] then
		flagCapStatuses[flagID][allyTeamID] = {team = teamID, cap = 0}
	end
	if (flagCapStatuses[flagID][allyTeamID].cap == 0) and change < 0 then 
		return -- trying to regen when already 0, quit
	end
	if flagCapStatuses[flagID][allyTeamID].team ~= teamID then
		SetUnitRulesParam(flagID, "cap" .. tostring(flagCapStatuses[flagID][allyTeamID].team), 0, {public = true}) -- reset the old team to 0
		flagCapStatuses[flagID][allyTeamID].team = teamID -- update teamID, switched to another team in the same alliance
	end
	flagCapStatuses[flagID][allyTeamID].cap = flagCapStatuses[flagID][allyTeamID].cap + change -- add the cap increase
	SetUnitRulesParam(flagID, "cap" .. tostring(teamID), flagCapStatuses[flagID][allyTeamID].cap, {public = true}) -- set the rules param per team for team colour
	if flagCapStatuses[flagID][allyTeamID].cap <= 0 then
		-- TODO: Really we need to check that __all__ non-ally statuses are 0
		GG.PlaySoundForTeam(flagTeamID, "BB_Beacon_Secured", 1)
		SetUnitRulesParam(flagID, "secure", 1, {public = true})
		--GG.ToggleUpgradeOptions(flagID, true) -- REMOVE
	elseif flagCapStatuses[flagID][allyTeamID].cap == 1 then -- first cap step
		GG.PlaySoundForTeam(flagTeamID, "BB_Beacon_UnderAttack", 1)
		SetUnitRulesParam(flagID, "secure", 0, {public = true})
		--GG.ToggleUpgradeOptions(flagID, false) -- REMOVE
	elseif flagCapStatuses[flagID][allyTeamID].cap > CAP_THRESHOLD and teamID ~= flagTeamID then -- capped or neutralised
		TransferFlag(flagID, flagTeamID, teamID)
		GG.PlaySoundForTeam(flagTeamID, "BB_Beacon_Lost", 1)
		if flagTeamID == GAIA_TEAM_ID then -- flag was capped, not neutralised
			GG.PlaySoundForTeam(teamID, "BB_Beacon_Captured", 1)
			SetUnitRulesParam(flagID, "secure", 1, {public = true})
			--GG.ToggleUpgradeOptions(flagID, true) -- REMOVE
		end
	end
end

-- updates caps for all teams
local function FlagCapRegen(flagID, flagTeamID, change)
	for _, teamID in pairs(Spring.GetTeamList()) do
		local isDead, _, _, allyTeamID = select(3, Spring.GetTeamInfo(teamID))
		if teamID ~= flagTeamID and not isDead then
			FlagCapChange(flagID, flagTeamID, allyTeamID, teamID, change)
		end
	end
end

function gadget:GameFrame(n)
	-- FLAG CONTROL
	if n % 30 == 5 then -- every second with a 5 frame offset
		for _, flagType in pairs(flagTypes) do
			--for spotNum, flagID in pairs(flags[flagType]) do
			for spotNum = 1, numFlags[flagType] do -- WARNING: Assumes flags are placed in order they exist in flags[flagType]
				local flagID = flags[flagType][spotNum]
				local flagTeamID = GetUnitTeam(flagID)
				local flagAllyTeam = select(6, Spring.GetTeamInfo(flagTeamID))
				local spots = flagTypeSpots[flagType]
				
				local flagTeamCounts = {} -- flagTeamCounts[teamID] = number
				local flagAllyTeamCounts = {} -- flagAllyTeamCounts[teamID] = number
				-- First check if there are any friendly (ally) units here -> flag is defended
				local unitsAtFlag = GetUnitsInCylinder(spots[spotNum].x, spots[spotNum].z, CAP_RADIUS)
				StripUnits(unitsAtFlag) -- strips table (in place) of ignored unitdefs
				
				for i, unitID in ipairs(unitsAtFlag) do
					local teamID = Spring.GetUnitTeam(unitID)
					flagTeamCounts[teamID] = (flagTeamCounts[teamID] or 0) + 1
					local allyTeamID = select(6, Spring.GetTeamInfo(teamID))
					flagAllyTeamCounts[allyTeamID] = (flagAllyTeamCounts[allyTeamID] or 0) + 1
				end
				if flagAllyTeamCounts[flagAllyTeam] or 0 > 0 then -- flag is defended, reduce all cap status
					FlagCapRegen(flagID, flagTeamID, -REGEN)
				else -- flag is undefended, proceed to check for cappers
					local numberOfAllyTeamsAtFlag = 0
					local cappingAllyTeam
					for allyTeamID, count in pairs(flagAllyTeamCounts) do
						if count > 0 then 
							numberOfAllyTeamsAtFlag = numberOfAllyTeamsAtFlag + 1
							cappingAllyTeam = allyTeamID
						end
					end	
					if numberOfAllyTeamsAtFlag == 1 then -- only one allyteam present, we can cap!
						-- check for the highest team count and set this as the allyteams cap team
						local capStatus = flagCapStatuses[flagID][cappingAllyTeam]
						local cappingTeam = capStatus and capStatus.team or nil
						local maxCount = flagTeamCounts[cappingTeam] or 0
						for teamID, count in pairs(flagTeamCounts) do
							if count > maxCount then 
								maxCount = count
								cappingTeam = teamID
							end
						end
						FlagCapChange(flagID, flagTeamID, cappingAllyTeam, cappingTeam, 1)
						-- TODO: if equal then go for team with fewest beacons
						-- TODO: if equal pick first unit in list
					elseif numberOfAllyTeamsAtFlag > 1 then -- flag is contested, pause cap status
						-- probably don't need to actually do anything here
					elseif flagAllyTeam == GAIA_ALLY_ID then -- no allyTeam units present, flag is an empty neutral flag
						--Spring.Echo(flagID, "Ronery, so rorenery")
						FlagCapRegen(flagID, flagTeamID, -REGEN)
					else -- no allyTeam units present, flag is empty
						--Spring.Echo("Nothing at flag, regen")
						FlagCapRegen(flagID, flagTeamID, -REGEN)
					end
				end
			end
		end
		local maxBeacon = 0
		-- manage tickets	
		for allyTeam, numBeacon in pairs(beaconsPerAllyTeam) do
			maxBeacon = math.max(numBeacon, maxBeacon)
		end
		for allyTeam, numBeacon in pairs(beaconsPerAllyTeam) do
			if numBeacon < maxBeacon then
				bleedTimes[allyTeam] = math.floor(totalFlags / (maxBeacon - numBeacon) * 30) -- 7/1 = 7, 
			else
				bleedTimes[allyTeam] = 0
			end
		end
	end
	for allyTeam, bleed in pairs(bleedTimes) do
		if bleed > 0 and n % bleed == 0 then
			DecrementTickets(allyTeam)
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp.baseclass == "mech" then
		teamUnitCounts[unitTeam] = teamUnitCounts[unitTeam] + 1
	end
	if unitDefID == BEACON_ID and unitTeam ~= GAIA_TEAM_ID then
		local x,_, z = Spring.GetUnitPosition(unitID)
		local newSpot = {["x"] = x, ["z"] = z}
		table.insert(flagTypeSpots["beacon"], newSpot)
		PlaceFlag(newSpot, "beacon", unitID)
		UpdateBeacons(unitTeam, 1)
	end
end

function SetTickets(allyTeam, amount)
	tickets[allyTeam] = math.min(amount, tickets[allyTeam])
	DecrementTickets(allyTeam)
end
GG.SetTickets = SetTickets

function CheckAllyTeamUnits(unitTeam)
	if unitTeam == GAIA_TEAM_ID then return end -- Gaia does not have tickets
	if teamUnitCounts[unitTeam] + Spring.GetTeamUnitDefCount(unitTeam, BEACON_ID) == 0 then
		-- Check if this was last unit on whole allyteam
		local allyTeam = select(6, Spring.GetTeamInfo(unitTeam))
		local allyTeamUnitCount = 0
		for _, teamID in pairs(Spring.GetTeamList(allyTeam)) do
			allyTeamUnitCount = allyTeamUnitCount + teamUnitCounts[teamID] + Spring.GetTeamUnitDefCount(teamID, BEACON_ID)
		end
		-- If it was, this implies they lost all beacons and DZ so can't get any more
		if allyTeamUnitCount == 0 then
			-- Therefore deduct (nearly) all their remaining tickets
			SetTickets(allyTeam, 5)
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	local ud = UnitDefs[unitDefID]
	
	if ud.customParams.baseclass == "mech" and Spring.GetUnitRulesParam(unitID, "sold") ~= 1 then
		teamUnitCounts[unitTeam] = teamUnitCounts[unitTeam] - 1
		-- Remove 1 ticket for each mech killed
		local allyTeam = select(6, Spring.GetTeamInfo(unitTeam))
		DelayCall(DecrementTickets, {allyTeam}, 1)
		DelayCall(CheckAllyTeamUnits, {unitTeam}, 1)
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	local ud = UnitDefs[unitDefID]
	if ud.customParams.baseclass == "mech" then
		teamUnitCounts[oldTeam] = teamUnitCounts[oldTeam] - 1
		teamUnitCounts[newTeam] = teamUnitCounts[newTeam] + 1
	end
	DelayCall(CheckAllyTeamUnits, {oldTeam}, 1)
end

function gadget:Initialize()
	if Spring.GetGameFrame() >  1 then
		gadget:GamePreload()
		--[[for _,unitID in ipairs(Spring.GetAllUnits()) do
			local teamID = Spring.GetUnitTeam(unitID)
			local unitDefID = Spring.GetUnitDefID(unitID)
			gadget:UnitCreated(unitID, unitDefID, teamID)
		end]]
	end
end

else
-- UNSYNCED

function PassToUI(eventID, allyTeamID, new)
	if Script.LuaUI.BEACONUPDATE then
		Script.LuaUI.BEACONUPDATE(allyTeamID, new)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("BEACONUPDATE", PassToUI)
end

end
