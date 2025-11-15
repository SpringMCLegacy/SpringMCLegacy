--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    game_spawn.lua
--  brief:   spawns start unit and sets storage levels
--  author:  Tobi Vollebregt
--
--  Copyright (C) 2010.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Game - Spawn",
		desc      = "spawns start unit and sets storage levels",
		author    = "Tobi Vollebregt",
		date      = "January, 2010",
		license   = "GNU GPL, v2 or later",
		layer     = 1, -- must be before flagManager, before unit_purchasing
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


if gadgetHandler:IsSyncedCode() then
--	SYNCED

local startPosType = Game.startPosType -- 0 (in order), 1 (random), 2 (choose ingame), 3 (choose before game)
local teamStarts
local PROFILE_PATH = "maps/flagConfig/" .. Game.mapName .. "_profile.lua"
if VFS.FileExists(PROFILE_PATH) then
	_, _, teamStarts = VFS.Include(PROFILE_PATH)
end
teamStarts = teamStarts or {}
local sideStartUnits = {}

local modOptions = Spring.GetModOptions()
if not modOptions.startcbills then -- load via file
	local raw = VFS.Include("modoptions.lua", nil, VFS.ZIP)
	for i, v in ipairs(raw) do
		if v.type ~= "section" then
			modOptions[v.key] = v.def
		end
	end
	startPosType = 1 -- randomise when testing via spring.exe
end
-- Need the raw sidedata for short names
local sideData = VFS.Include("gamedata/sidedata.lua", nil, VFS.ZIP)
local SideNames = {}
local ValidSides = {}
for sideNum, data in pairs(sideData) do
	SideNames[data.name:lower()] = data.shortName:lower()
	ValidSides[data.shortName:lower()] = true
end
GG.SideNames = SideNames
GG.ValidSides = ValidSides

function gadget:GameID(id)
	math.randomseed(tonumber(id,16))
end

local function GetStartUnit(teamID)
	-- get the team startup info
	local side = select(5, Spring.GetTeamInfo(teamID))
	local startUnit
	if (side == "") then
		-- startscript didn't specify a side for this team
		local sidedata = Spring.GetSideData()
		if (sidedata and #sidedata > 0) then
			local sideNum = math.random(1,#Spring.GetSideData()) --TODO: 2 + teamID % #sidedata
			startUnit = sidedata[sideNum].startUnit
			side = sidedata[sideNum].sideName
		end
		-- set the gamerules param to notify other gadgets it was a direct launch
		Spring.SetGameRulesParam("runningWithoutScript", 1)
	else
		startUnit = Spring.GetSideData(side)
	end
	GG.teamSide[teamID] = SideNames[side]
	Spring.SetTeamRulesParam(teamID, "side", SideNames[side])
	return startUnit
end

local function SpawnStartUnit(teamID)
	local startUnit = sideStartUnits[teamID]
	if (startUnit and startUnit ~= "") then
		-- spawn the specified start unit
		local startPos = teamStarts[teamID]
		local x,y,z
		x = startPos.x
		y = startPos.y
		z = startPos.z
		-- facing toward map center
		local facing=math.abs(Game.mapSizeX/2 - x) > math.abs(Game.mapSizeZ/2 - z)
			and ((x>Game.mapSizeX/2) and "west" or "east")
			or ((z>Game.mapSizeZ/2) and "north" or "south")
		local unitID = Spring.CreateUnit(startUnit, x, y, z, facing, teamID)
	end

	-- set start resources, either from mod options or custom team keys
	local teamOptions = select(7, Spring.GetTeamInfo(teamID))
	local m = modOptions.startcbills
	local e = modOptions.starttonnage * modOptions.tonnagemult

	-- using SetTeamResource to get rid of any existing resource without affecting stats
	-- using AddTeamResource to add starting resource and counting it as income
	if (m and tonumber(m) ~= 0) then
		-- remove the pre-existing storage
		--   must be done after the start unit is spawned,
		--   otherwise the starting resources are lost!
		Spring.SetTeamResource(teamID, "ms", tonumber(m * 100))
		Spring.SetTeamResource(teamID, "m", 0)
		Spring.AddTeamResource(teamID, "m", tonumber(m))
		GG.ChangeTeamSalvage(teamID, modOptions.startsalvage or 100)
	end
	if (e and tonumber(e) ~= 0) then
		-- remove the pre-existing storage
		--   must be done after the start unit is spawned,
		--   otherwise the starting resources are lost!
		Spring.SetTeamResource(teamID, "es", tonumber(e))
		Spring.SetTeamResource(teamID, "e", 0)
		Spring.AddTeamResource(teamID, "e", tonumber(e))
	end
end

function gadget:Initialize()
	GG.teamSide = {}
end

function gadget:GamePreload()
	Spring.PlaySoundFile("bb_startup_all_systems_nominal", 1, "ui")
end

local function shuffle(t)
    local n = #t  -- this gives the highest consecutive key starting at 1
    -- teamID starts at 0, treat array as size n+1
    local start = 0
    local stop = n

    for i = stop, start + 1, -1 do
        local j = math.random(start, i)
        t[i], t[j] = t[j], t[i]
    end
end

local lockToProfileStarts = false

function gadget:GameStart()
	local existingTeams = Spring.GetTeamList() -- i = teamID
	local gaiaTeamID = Spring.GetGaiaTeamID()
	Spring.Echo("Gaia ID is", gaiaTeamID)
	local activeTeams = {} -- teamID = true
	local numActiveTeams = 0
	if startPosType <= 1 or startPosType == 3 then -- Fixed or random, no player selection
		--Spring.Echo("[Game_Spawn.lua]", #teamStarts+1, "profile starts &", #(Spring.GetMapStartPositions()), "map defined starts")
		local usingProfile = (startPosType == 3 and lockToProfileStarts) -- choose before game with restriction
							or (startPosType <=1 and teamStarts[0]) -- fixed /random starts and profile exists
		for i, teamID in pairs(existingTeams) do
			Spring.Echo("[Game_Spawn.lua] team", i, "has teamID", teamID)
			if teamID ~= gaiaTeamID then
				activeTeams[teamID] = true
				numActiveTeams = numActiveTeams + 1
				-- ask engine in these cases
				if not usingProfile then 
					local x,y,z = Spring.GetTeamStartPosition(teamID)
					--[[local mapStarts = Spring.GetMapStartPositions()
					local mapStart = mapStarts[teamID+1]
					local x2, y2, z2 = unpack(mapStart or {-1, -1, -1})]]
					teamStarts[teamID] = {
						["x"] = x,
						["y"] = y,
						["z"] = z,
					}
					Spring.Echo("teamID", teamID, "teamStarts", x, y, z, "vs mapStarts", x2, y2, z2)
				else -- using profile positions
					local numProfileSpots = #teamStarts + 1 -- need to +1 to account for teamID 0
					if teamID < numProfileSpots then
						teamStarts[teamID].y = Spring.GetGroundHeight(teamStarts[teamID].x,teamStarts[teamID].z)
					else
						Spring.Echo("More teams than map profile allows, (",numProfileSpots, ") forcing", teamID, "to spectator")
						--local teamPlayers = Spring.GetPlayerList(teamID)
						Spring.KillTeam(teamID)
						activeTeams[teamID] = nil
						numActiveTeams = numActiveTeams - 1
					end
				end
				sideStartUnits[teamID] = activeTeams[teamID] and GetStartUnit(teamID)
			end
		end
		if startPosType == 1 then -- Random
			shuffle(teamStarts)
		end
	end
	-- strip any profile teamstarts not used by an active team
	for teamID, info in pairs(teamStarts) do
		if not activeTeams[teamID] then
			teamStarts[teamID] = nil
		end
	end
	GG.numActiveTeams = numActiveTeams
	GG.teamStarts = teamStarts
end

local function DeploySpawnBeacons(skip)
	if not skip then
		Spring.PlaySoundFile("bb_startup_beacon_deployed", 1, "ui")
	end
	-- spawn start units
	local gaiaTeamID = Spring.GetGaiaTeamID()
	local teams = Spring.GetTeamList()
	for i = 1,#teams do
		local teamID = teams[i]
		-- don't spawn a start unit for the Gaia team
		if (teamID ~= gaiaTeamID) then
			SpawnStartUnit(teamID)
		end
	end
end
GG.DeploySpawnBeacons = DeploySpawnBeacons

else
-- UNSYNCED

	function gadget:GameSetup(label, ready, playerStates)
		--Spring.Echo("gadget:GameSetup", label, ready, playerStates)
		-- some optional delay here
		return true, true
	end
	
	function gadget:AllowStartPosition(playerID, teamID, readyState, x, y, z)
		--Spring.Echo("gadget:AllowStartPosition", playerID, teamID, readyState, x, y, z)
		return true
	end
end