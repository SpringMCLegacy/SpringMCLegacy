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
local activeTeams = {} -- teamID = true

local modOptions = Spring.GetModOptions()
if not modOptions.startcbills then -- load via file
	local raw = VFS.Include("modoptions.lua", nil, VFS.ZIP)
	for i, v in ipairs(raw) do
		if v.type ~= "section" then
			modOptions[v.key] = v.def
		end
	end
	startPosType = 1 -- randomise when testing via spring.exe
	-- set the gamerules param to notify other gadgets it was a direct launch
	Spring.SetGameRulesParam("runningWithoutScript", 1)
end
-- Need the raw sidedata for short names
local sideData = VFS.Include("gamedata/sidedata.lua", nil, VFS.ZIP)
local SideNames = {}
local ValidSides = {}
local SideTechBases = {}
local TechBaseSides = {}
for sideNum, data in pairs(sideData) do
	SideNames[data.name:lower()] = data.shortName:lower()
	SideTechBases[data.shortName:lower()] = data.techBase:lower()
	TechBaseSides[data.techBase:lower()] = TechBaseSides[data.techBase:lower()] or {}
	table.insert(TechBaseSides[data.techBase:lower()], data.shortName:lower())
	ValidSides[data.shortName:lower()] = data.name:lower()
end
GG.SideNames = SideNames
GG.SideTechBases = SideTechBases
GG.TechBaseSides = TechBaseSides
GG.ValidSides = ValidSides

function gadget:GameID(id)
	math.randomseed(tonumber(id,16))
end

local function GetStartUnit(teamID)
	if not activeTeams[teamID] then return false end
	-- get the team startup info
	local side = GG.teamSide[teamID] or select(5, Spring.GetTeamInfo(teamID))
	local startUnit
	if (side == "") then
		-- startscript didn't specify a side for this team
		local sidedata = Spring.GetSideData()
		if (sidedata and #sidedata > 0) then
			local sideNum = teamID == 0 and math.random(1,#TechBaseSides.is) or math.random(#TechBaseSides.is+1,#TechBaseSides.is+#TechBaseSides.cl)
			startUnit = sidedata[sideNum].startUnit
			side = sidedata[sideNum].sideName
		end
	else
		startUnit = Spring.GetSideData(side)
	end
	GG.teamSide[teamID] = SideNames[side]
	Spring.SetTeamRulesParam(teamID, "side", SideNames[side])
	return startUnit
end

local function SpawnStartUnit(teamID)
	if not activeTeams[teamID] then return false end
	local startUnit = GetStartUnit(teamID)--sideStartUnits[teamID]
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
		Spring.SetTeamShareLevel(teamID, "metal", 100000000000000000)
		GG.ChangeTeamResource(teamID, "salvage", modOptions.startsalvage or 100)
	end
	if (e and tonumber(e) ~= 0) then
		-- remove the pre-existing storage
		--   must be done after the start unit is spawned,
		--   otherwise the starting resources are lost!
		Spring.SetTeamResource(teamID, "es", tonumber(e))
		Spring.SetTeamResource(teamID, "e", 0)
		Spring.AddTeamResource(teamID, "e", tonumber(e))
		Spring.SetTeamShareLevel(teamID, "energy", 100000000000000000)
	end
end

function gadget:Initialize()
	GG.teamSide = {}
end

local lockToProfileStarts = modOptions.locktoprofile == '1'
local DistBetween = GG.Vector.DistanceBetween 

function gadget:GamePreload()
	Spring.PlaySoundFile("bb_startup_all_systems_nominal", 1, "ui")
	if startPosType == 2 and lockToProfileStarts then
		for id, pos in pairs(teamStarts) do
			GG.SpawnDecal("decal_start", pos.x, pos.z)
		end
	end
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

function gadget:GameStart()
	local existingTeams = Spring.GetTeamList() -- i = teamID
	local gaiaTeamID = Spring.GetGaiaTeamID()
	--Spring.Echo("Gaia ID is", gaiaTeamID)
	local numActiveTeams = 0
	if true then--startPosType <= 1 or startPosType == 3 then -- Fixed or random, no player selection
		--Spring.Echo("[Game_Spawn.lua]", #teamStarts+1, "profile starts &", #(Spring.GetMapStartPositions()), "map defined starts")
		local usingProfile = teamStarts[0] and -- it exist
							(((startPosType == 3 or startPosType == 2) and lockToProfileStarts) -- choose before game with restriction
							or (startPosType <=1)) -- fixed /random starts and profile exists
		for i, teamID in pairs(existingTeams) do
			--Spring.Echo("[Game_Spawn.lua] team", i, "has teamID", teamID)
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
					--Spring.Echo("teamID", teamID, "teamStarts", x, y, z, "vs mapStarts", x2, y2, z2)
				else -- using profile positions
					local numProfileSpots = #teamStarts + 1 -- need to +1 to account for teamID 0
					if teamID < numProfileSpots then
						teamStarts[teamID].y = Spring.GetGroundHeight(teamStarts[teamID].x,teamStarts[teamID].z)
						--Spring.Echo("teamID", teamID, "teamStarts", teamStarts[teamID].x, teamStarts[teamID].y, teamStarts[teamID].z)
					else
						Spring.Echo("More teams than map profile allows, (",numProfileSpots, ") forcing", teamID, "to spectator")
						--local teamPlayers = Spring.GetPlayerList(teamID)
						Spring.KillTeam(teamID)
						activeTeams[teamID] = nil
						numActiveTeams = numActiveTeams - 1
					end
				end
				--sideStartUnits[teamID] = activeTeams[teamID] and GetStartUnit(teamID)
			end
		end
		if (startPosType == 3 or startPosType == 2) and lockToProfileStarts then
			-- at this point teamStarts is populated by the correct profile positions
			local sortedStarts = {}
			local unSelectedStarts = {}
			table.copy(teamStarts, unSelectedStarts)
			for teamID in pairs(activeTeams) do
				local shortest = math.huge
				local closePosID
				local rx, ry, rz = Spring.GetTeamStartPosition(teamID)
				for posID, pos in pairs(unSelectedStarts) do
					--Spring.Echo("Inner Loop", teamID, rx, ry, rz, posID, pos.x, pos.y, pos.z)
					local dist = DistBetween(rx, ry, rz, pos.x, pos.y or 0, pos.z)
					if dist < shortest then
						shortest = dist
						closePosID = posID
					end
				end
				unSelectedStarts[closePosID] = nil
				--Spring.Echo("Outer Loop", teamID, "closest position was ", closePosID, shortest)
				local pos = teamStarts[closePosID]
				sortedStarts[teamID] = {
					["x"] = pos.x,
					["y"] = pos.y,
					["z"] = pos.z,
				}
			end
			teamStarts = sortedStarts
		end
		if startPosType == 1 then -- Random
			shuffle(teamStarts)
		end
	end
	-- strip any profile teamstarts not used by an active team
	for teamID, info in pairs(teamStarts) do
		if not activeTeams[teamID] then
			--Spring.Echo("Stripping team", teamID, "from teamStarts")
			teamStarts[teamID] = nil
		end
	end
	GG.numActiveTeams = numActiveTeams
	GG.teamStarts = teamStarts
end

function gadget:AllowStartPosition(playerID, teamID, readyState, x, y, z)
	--Spring.Echo("gadget:AllowStartPosition", playerID, teamID, readyState, x, y, z)
	return true
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

-- keep track of choosing faction ingame
function gadget:RecvLuaMsg(msg, playerID)
	-- these messages are only useful during pre-game placement
	if Spring.GetGameFrame() > 0 then
		return false
	end

	local code = string.sub(msg,1,1)
	if code ~= '\138' then
		return
	end
	local side = string.sub(msg,2,string.len(msg))
	local _, _, playerIsSpec, playerTeam = Spring.GetPlayerInfo(playerID)
	if not playerIsSpec then
		GG.teamSide[playerTeam] = ValidSides[side]
		Spring.SetTeamRulesParam(playerTeam, "side", side, {allied=true, public=false}) -- visible to allies only, set visible to all on GameStart
		--side = select(5, Spring.GetTeamInfo(playerTeam))
		return true
	end
end

else
-- UNSYNCED

	function gadget:GameSetup(label, ready, playerStates)
		--Spring.Echo("gadget:GameSetup", label, ready, playerStates)
		--for k,v in pairs(playerStates) do Spring.Echo("playerStates", k, v) end
		-- some optional delay here
		return ready, ready
	end
	
end