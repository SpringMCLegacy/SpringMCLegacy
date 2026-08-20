function gadget:GetInfo()
	return {
		name      = "Game - Beacon Manager",
		desc      = "Populates maps with flags and handles control",
		author    = "FLOZi",
		date      = "Adopted from S44 flagManager 10/02/2011",
		license   = "GNU GPL v2",
		layer     = 2, -- must be after game_spawn
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

local unitCapStrengths = {} -- unitCapStrengths[unitID] = number or 1
local unitDefsToIgnore = {}
local flagTypes = {"beacon"}
local flags = {} -- flags[flagType][index] == flagUnitID
local numFlags = {} -- numFlags[flagType] == numberOfFlagsOfType
local totalFlags = 0
local flagTypeSpots = {} -- flagTypeSpots[flagType][metalSpotCount] == {x = x_coord, z = z_coord}
local EXPECTED_FLAGS = 0

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
local CAP_BONUS = tonumber(modOptions.capincome) or 2000
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

local function SetUnitCapStrength(unitID, mult)
	unitCapStrengths[unitID] = unitCapStrengths[unitID] * mult
end
GG.SetUnitCapStrength = SetUnitCapStrength

function UpdateBeacons(teamID, num)
	if teamID == GAIA_TEAM_ID then return end -- Gaia does not have tickets
	local allyTeam = select(6, GetTeamInfo(teamID))
	beaconsPerAllyTeam[allyTeam] = beaconsPerAllyTeam[allyTeam] + num
	SetTeamRulesParam(teamID, "beacons", (GetTeamRulesParam(teamID, "beacons") or 0) + num, {public = true})
	SendToUnsynced("BEACONUPDATE", allyTeam, beaconsPerAllyTeam[allyTeam])
end


local firstWarning = {}
function DecrementTickets(allyTeam)
	if allyTeam == GAIA_ALLY_ID then return end -- Gaia does not have tickets
	if tickets[allyTeam] > 0 then
		tickets[allyTeam] = tickets[allyTeam] - 1
		--Spring.Echo("AllyTeam " .. allyTeam .. "[".. beaconsPerAllyTeam[allyTeam] .. "] lost 1 ticket (" .. tickets[allyTeam] .. ")")
		SetGameRulesParam("tickets" .. allyTeam, tickets[allyTeam], {public = true})
	end
	if tickets[allyTeam] <= 10 and not firstWarning[allyTeam] then
		firstWarning[allyTeam] = true
		local teams = Spring.GetTeamList(allyTeam)
		for i = 1, #teams do
			GG.PlaySoundForTeam(teams[i], "bb_tickets_low", 1)
		end
		local lastEnemyAllyTeam = #allyTeams - deadAllyTeams == 2
		local sound = lastEnemyAllyTeam and "bb_tickets_leading" or "bb_tickets_enemy_low"
		for i, otherAllyTeam in pairs(allyTeams) do
			if otherAllyTeam ~= allyTeam and allyTeamAlive[otherAllyTeam] then
				local teams = Spring.GetTeamList(otherAllyTeam)
				for i = 1, #teams do
					GG.PlaySoundForTeam(teams[i], sound, 1)
				end
			end
		end		
	elseif tickets[allyTeam] <= 0 then
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
					if alive then 
						GameOver({team}) 
						GG.PlaySoundForTeam(team, "bb_game_won", 1)
					else
						GG.PlaySoundForTeam(team, "bb_game_lost", 1)
					end
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


function PlaceFlag(spot, flagType, newFlag, spotNum)
	if DEBUG then
		Spring.Echo("{")
		Spring.Echo("	x = " .. spot.x .. ",")
		Spring.Echo("	z = " .. spot.z .. ",")
		Spring.Echo("},")
	end
	spot.y = Spring.GetGroundHeight(spot.x, spot.z)
	if not newFlag then
		for teamID, startPos in pairs(GG.teamStarts) do
			startPos.y = startPos.y or Spring.GetGroundHeight(startPos.x, startPos.z)
			if GG.Vector.DistanceBetween(spot.x, spot.y, spot.z, startPos.x, startPos.y, startPos.z) < 1.5 * CAP_RADIUS then
				--Spring.Echo("Uhhhhh, deleting a flag, spotNum", spotNum)
				EXPECTED_FLAGS = EXPECTED_FLAGS - 1
				flagTypeSpots[flagType][spotNum] = nil
				return
			end
		end
		newFlag = CreateUnit(flagType, spot.x, spot.y, spot.z, 0, GAIA_TEAM_ID)
	end
	numFlags[flagType] = numFlags[flagType] + 1
	totalFlags = totalFlags + 1
	--flags[flagType][numFlags[flagType]] = newFlag
	flags[flagType][spotNum] = newFlag
	flagCapStatuses[newFlag] = {}
	
	SetUnitNeutral(newFlag, true)
	SetUnitAlwaysVisible(newFlag, true)
	
	local squareSize = 100
	local features = GetFeaturesInRectangle(spot.x - squareSize, spot.z - squareSize, spot.x + squareSize, spot.z + squareSize)
	for i = 1, #features do
		DestroyFeature(features[i])
	end
	spot.radius = spot.radius or CAP_RADIUS * (spot.radiusmult or 1)
	SetUnitRulesParam(newFlag, "BEACON_CAP_RADIUS", spot.radius, {public = true})
	spot.points = spot.points or tonumber(modOptions.beaconpoints) or 3
	spot.spotNum = spotNum
	--Spring.MarkerAddPoint(spot.x, spot.y, spot.z, spotNum)
	SetUnitRulesParam(newFlag, "BEACON_NUM_POINTS", spot.points, {public = true})
	SetUnitRulesParam(newFlag, "BEACON_SPOT_NUM", spotNum, {public = true})
end

local function LoadProfile()
	local flagSpots = {}
	local startPos = {}
	-- CHECK FOR PROFILES
	if VFS.FileExists(PROFILE_PATH) then
		flagSpots, _, startPos = VFS.Include(PROFILE_PATH)
		if #flagSpots > 0 then 
			Spring.Echo("Map Beacon Profile found. Loading " .. (#flagSpots or 0) .. " Beacon positions...")
		end
		if startPos then
			for t, start in pairs(startPos) do
				if not GG.teamStarts[t] and start.alwaysbeacon then
					table.insert(flagSpots, start)
				end
			end
		end
	else
		Spring.Echo("NO MAP PROFILE FOUND FOR " .. Game.mapName, "FALLING BACK TO USING START POSITIONS")
		Map = {}
		Map.configFile = "maps/" .. Game.mapName .. ".smd"
		local mh = VFS.Include("maphelper/mapinfo.lua")

		for t = #teams - 1, #(mh.teams) do -- start beyond spawned teams
			table.insert(flagSpots, mh.teams[t]["startpos"])
		end
	end
	EXPECTED_FLAGS = #flagSpots + GG.numActiveTeams -- 1
	Spring.Echo("Map has " .. EXPECTED_FLAGS .. " expected beacons. (" .. #flagSpots .. " flagSpots & " .. (GG.numActiveTeams) .. " team starts)")
	flagTypeSpots["beacon"] = flagSpots
	GG.beaconSpots = flagSpots
end

function gadget:GamePreload()
	if DEBUG then Spring.Echo(PROFILE_PATH) end
	local temps = {}
	-- CHECK FOR PROFILES
	if VFS.FileExists(PROFILE_PATH) then
		_, temps, _ = VFS.Include(PROFILE_PATH)
	end
	temps.ambient = temps.ambient or 20
	temps.water = temps.water or 10
	GG.MapTemperatures = temps
	Spring.SetGameRulesParam("MAP_TEMP_AMBIENT", temps.ambient)
	Spring.SetGameRulesParam("MAP_TEMP_WATER", temps.water)
	-- cache ignored unitDefIDs
	for unitDefID, ud in pairs(UnitDefs) do
		if ud.canFly or string.tobool(ud.customParams.ignoreatbeacon) then
			unitDefsToIgnore[unitDefID] = true
		end
	end
end

local beaconsDeployed = math.huge
local function DeployBeacons(skip) 
	if Game.startPosType == 2 then
		GG.KillDecals("decal_start")
	end
	if not skip then
		Spring.SendCommands("toggleoverview")
		Spring.PlaySoundFile("bb_startup_beacon_deploying", 1, "ui")
	end
	-- FLAG PLACEMENT
	for _, flagType in pairs(flagTypes) do
		if DEBUG then Spring.Echo("-- flagType is " .. flagType) end
		--for i = 1, #flagTypeSpots[flagType] do
		for spotNum, spot in pairs(flagTypeSpots[flagType]) do
			--PlaceFlag(flagTypeSpots[flagType][i], flagType, nil, i)
			PlaceFlag(spot, flagType, nil, spotNum)
		end
		GG[flagType .. "s"] = flags[flagType] -- nicer to have GG.flags rather than GG.flag
	end
end

local skip = modOptions and modOptions.skip_briefing
if skip == nil or skip == '1' then skip = true elseif skip == '0' then skip = false end -- modoption bools passed as 0 and 1 as strings, because pain.
GG.skip = skip

function gadget:GameStart()
	LoadProfile()
	if skip then
		DeployBeacons(skip)
	end
	GG.Delay.DelayCall(skip and GG.DeploySpawnBeacons or DeployBeacons, {skip}, skip and 1 or 4.5 * 30) -- delay 5 seconds for 'all systems nomnimal'
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

local function TransferFlag(flagID, flagTeamID, newTeamID, capTeamID)
	local capped = flagTeamID == GAIA_TEAM_ID
	local neuted = newTeamID == GAIA_TEAM_ID
	TransferUnit(flagID, capped and capTeamID or GAIA_TEAM_ID, false)
	if capped or neuted then
		Spring.AddTeamResource(capTeamID, "metal", CAP_BONUS) -- 2k CBills for neut or cap
		-- Flag has changed status, reset capping statuses
		flagCapStatuses[flagID] = {}
		for _, cleanTeamID in pairs(Spring.GetTeamList()) do
			SetUnitRulesParam(flagID, "cap" .. tostring(cleanTeamID), 0, {public = true})
		end
		UpdateBeacons(capped and capTeamID or flagTeamID, capped and 1 or -1)
	else -- player transfered
		-- Update both teams
		UpdateBeacons(newTeamID, 1)
		UpdateBeacons(flagTeamID, -1)
	end
	-- Turn flag back on TODO: check if this can be avoided in MCL?
	GiveOrderToUnit(flagID, CMD.ONOFF, {1}, {})
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
		GG.PlaySoundForTeam(flagTeamID, "bb_beacon_secured", 1)
		SetUnitRulesParam(flagID, "secure", 1, {public = true})
		flagCapStatuses[flagID][allyTeamID].cap = 0
	elseif flagCapStatuses[flagID][allyTeamID].cap < 2 then -- first cap step, mark as insecure
		SetUnitRulesParam(flagID, "secure", 0, {public = true})
	elseif 	flagCapStatuses[flagID][allyTeamID].cap >= math.floor(0.25 * CAP_THRESHOLD) 
		and flagCapStatuses[flagID][allyTeamID].cap <  math.floor(0.25 * CAP_THRESHOLD) + 1 then -- dropped to 75%, inform player
		if change > 0 and flagTeamID ~= GAIA_TEAM_ID then
			GG.PlaySoundForTeam(flagTeamID, "bb_beacon_underattack", 1)
			local x,y,z = Spring.GetUnitPosition(flagID) -- TODO: use spotNum?
			SendToUnsynced("MESSAGE", teamID, x,y,z)
		end
	elseif flagCapStatuses[flagID][allyTeamID].cap > CAP_THRESHOLD and teamID ~= flagTeamID then -- capped or neutralised
		if Spring.GetTeamUnitDefCount(flagTeamID, BEACON_ID) == 0 then -- this was the last beacon!
			GG.PlaySoundForTeam(flagTeamID, "bb_dropzone_lost_last", 1)
		elseif GG.dropZoneBeaconIDs[flagTeamID] == flagID and not (GG.orderStatus[GG.teamDropZones[flagTeamID]] or 0 > 0) then -- this was the dropzone beacon! (and no order pending)
			GG.PlaySoundForTeam(flagTeamID, "bb_dropzone_lost_noauto", 1)
		elseif change > 0 then
			GG.PlaySoundForTeam(flagTeamID, "bb_beacon_lost", 1)
		end
		local newTeamID
		if flagTeamID == GAIA_TEAM_ID then -- flag was capped, not neutralised
			GG.PlaySoundForTeam(teamID, "bb_beacon_secured", 1)
			SetUnitRulesParam(flagID, "secure", 1, {public = true})
			newTeamID = teamID
		else
			newTeamID = GAIA_TEAM_ID
		end
		TransferFlag(flagID, flagTeamID, newTeamID, teamID)
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
	if n > beaconsDeployed and n % 30 == 5 then -- every second with a 5 frame offset
		for _, flagType in pairs(flagTypes) do
			for spotNum, flagID in pairs(flags[flagType]) do
			--for spotNum = 1, numFlags[flagType] do -- WARNING: Assumes flags are placed in order they exist in flags[flagType]
				local flagID = flags[flagType][spotNum]
				local flagTeamID = GetUnitTeam(flagID)
				local flagAllyTeam = select(6, Spring.GetTeamInfo(flagTeamID))
				local spots = flagTypeSpots[flagType]
				local currSpot = spots[spotNum]
				local flagTeamCounts = {} -- flagTeamCounts[teamID] = number
				local flagAllyTeamCounts = {} -- flagAllyTeamCounts[teamID] = number
				-- First check if there are any friendly (ally) units here -> flag is defended
				if not currSpot.radius then
					--Spring.Echo("DERPADERPRA no radius on spotNum", spotNum, "(",currSpot.x, currSpot.z,")")
					--Spring.MarkerAddPoint(currSpot.x, 0, currSpot.z)
					currSpot.radius = CAP_RADIUS * (currSpot.radiusmult or 1)
				end
				local unitsAtFlag = GetUnitsInCylinder(currSpot.x, currSpot.z, currSpot.radius)
				StripUnits(unitsAtFlag) -- strips table (in place) of ignored unitdefs
				
				for i, unitID in ipairs(unitsAtFlag) do
					local teamID = Spring.GetUnitTeam(unitID)
					flagTeamCounts[teamID] = (flagTeamCounts[teamID] or 0) + (unitCapStrengths[unitID] or 1)
					local allyTeamID = select(6, Spring.GetTeamInfo(teamID))
					flagAllyTeamCounts[allyTeamID] = (flagAllyTeamCounts[allyTeamID] or 0) + (unitCapStrengths[unitID] or 1)
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
						FlagCapChange(flagID, flagTeamID, cappingAllyTeam, cappingTeam, maxCount)
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
		unitCapStrengths[unitID] = 1
	end
	if unitDefID == BEACON_ID and unitTeam ~= GAIA_TEAM_ID then
		local x,_, z = Spring.GetUnitPosition(unitID)
		local newSpot = {["x"] = x, ["z"] = z}
		local spotNum = #flagTypeSpots["beacon"] + 1
		table.insert(flagTypeSpots["beacon"], newSpot)
		--Spring.Echo("Oh mai, new beacon, teamID", teamID, "spotNum", spotNum)
		PlaceFlag(newSpot, "beacon", unitID, spotNum)
		UpdateBeacons(unitTeam, 1)
		if #flagTypeSpots["beacon"] == EXPECTED_FLAGS then
			Spring.Echo("Map actually has " .. EXPECTED_FLAGS .. " beacons created.")
			beaconsDeployed = Spring.GetGameFrame() + 5
		end
	end
end

function SetTickets(allyTeam, amount)
	tickets[allyTeam] = math.min(amount, tickets[allyTeam])
	DecrementTickets(allyTeam)
end

function CheckAllyTeamUnits(unitTeam)
	if unitTeam == GAIA_TEAM_ID then return end -- Gaia does not have tickets
	if Spring.GetTeamUnitDefCount(unitTeam, BEACON_ID) == 0 then
		-- lost last beacon, panic
		if teamUnitCounts[unitTeam] then
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
end

local deadDropshipTeams = {}
GG.deadDropshipTeams = deadDropshipTeams

function NotifyDropshipDied(teamID)
	deadDropshipTeams[teamID] = true
	local allyTeam = select(6, Spring.GetTeamInfo(teamID))
	local teamsInAlliance = Spring.GetTeamList(allyTeam)
	local numTeams = #teamsInAlliance
	SetTickets(allyTeam, math.floor((numTeams - 1)/numTeams * tickets[allyTeam] + 1))
	if numTeams > 1 then
		local alliedTeams = {}
		-- inform allied teams
		for _, team in pairs(teamsInAlliance) do
			alliedTeams[team] = true
			if team == teamID then
				GG.PlaySoundForTeam(team, "bb_elimination", 1)
			else
				GG.PlaySoundForTeam(team, "bb_elimination_ally", 1)
			end
		end
		-- inform enemy teams
		for _, team in pairs(Spring.GetTeamList()) do
			if not alliedTeams[team] then
				GG.PlaySoundForTeam(team, "bb_elimination_enemy", 1)
			end
		end
	end
	-- remove the dropzone
	local dzID = GG.teamDropZones[teamID]
	if dzID and Spring.ValidUnitID(dzID) then
		Spring.DestroyUnit(dzID, false, true)
	end
end
GG.NotifyDropshipDied = NotifyDropshipDied

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


function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
	if unitDefID == BEACON_ID then
		local capped = oldTeam == GAIA_TEAM_ID
		local neuted = newTeam == GAIA_TEAM_ID
		local flagAllyTeam = select(6, GetTeamInfo(oldTeam))
		local newAllyTeam = select(6, GetTeamInfo(newTeam))
		local neutCheck = Spring.GetUnitRulesParam(unitID, "secure") == 0
		
		if capped or (neuted and neutCheck) then return true end
		-- TODO: There is a potential issue here where you can give your beacons away to GAIA to recap them for the income bonus
		local flagAllyTeam = select(6, GetTeamInfo(oldTeam))
		local newAllyTeam = select(6, GetTeamInfo(newTeam))
		return flagAllyTeam == newAllyTeam
	end
	return true
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	local ud = UnitDefs[unitDefID]
	if ud.customParams.baseclass == "mech" then
		teamUnitCounts[oldTeam] = teamUnitCounts[oldTeam] - 1
		teamUnitCounts[newTeam] = teamUnitCounts[newTeam] + 1
	elseif unitDefID == BEACON_ID then
		local capped = oldTeam == GAIA_TEAM_ID
		local neuted = newTeam == GAIA_TEAM_ID
		if capped or neuted then return end
		-- transfered within allyTeam
		local allyTeamID = select(6, GetTeamInfo(newTeam))
		FlagCapChange(unitID, oldTeam, allyTeamID, newTeam, 0)
	end
	DelayCall(CheckAllyTeamUnits, {oldTeam}, 1)
end

local firstBeaconDeployed = false
function gadget:MoveCtrlNotify(unitID, unitDefID, unitTeam, data)
	-- check for tower drops too
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	env = Spring.UnitScript.GetScriptEnv(unitID)
	if env.TouchDown then
		Spring.UnitScript.CallAsUnit(unitID, env.TouchDown)
		Spring.MoveCtrl.Disable(unitID)
	end
	if not firstBeaconDeployed and unitDef.name == "beacon" and not GG.skip then
		GG.DeploySpawnBeacons()
		firstBeaconDeployed = true
	end
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
