function gadget:GetInfo()
	return {
		name      = "Beacon Manager",
		desc      = "Populates maps with flags and handles control",
		author    = "FLOZi",
		date      = "Adopted from S44 flagManager 10/02/2011",
		license   = "GNU GPL v2",
		layer     = 1,
		enabled   = true  --  loaded by default?
	}
end

-- function localisations
local floor						= math.floor
-- Synced Read
local AreTeamsAllied			= Spring.AreTeamsAllied
local GetFeatureDefID			= Spring.GetFeatureDefID
local GetFeaturePosition		= Spring.GetFeaturePosition
local GetGroundHeight			= Spring.GetGroundHeight
local GetGroundInfo				= Spring.GetGroundInfo
local GetUnitsInCylinder		= Spring.GetUnitsInCylinder
local GetUnitTeam				= Spring.GetUnitTeam
local GetTeamRulesParam			= Spring.GetTeamRulesParam
local GetTeamUnitDefCount 		= Spring.GetTeamUnitDefCount

-- Synced Ctrl
local CallCOBScript				= Spring.CallCOBScript
local CreateUnit				= Spring.CreateUnit
local DestroyFeature			= Spring.DestroyFeature
local GiveOrderToUnit			= Spring.GiveOrderToUnit
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
local PROFILE_PATH = "maps/flagConfig/" .. Game.mapName .. "_profile.lua"
local DEBUG	= false -- enable to print out flag locations in profile format

local CAP_MULT = 0.25 --multiplies against the FBI defined CapRate
local DEF_MULT = 0.25 --multiplies against the FBI defined DefRate

-- variables

local flagTypes = {"beacon"}
local flags = {} -- flags[flagType][index] == flagUnitID
local numFlags = {} -- numFlags[flagType] == numberOfFlagsOfType
local flagTypeData = {} -- flagTypeData[flagType] = {radius = radius, etc}
local flagTypeSpots = {} -- flagTypeSpots[flagType][metalSpotCount] == {x = x_coord, z = z_coord}
local flagTypeCappers = {} -- cappers[flagType][unitID] = true
local flagTypeDefenders	= {} -- defenders[flagType][unitID] = true

for _, flagType in pairs(flagTypes) do
	local cp = UnitDefNames[flagType].customParams
	flagTypeData[flagType] = {
		radius = tonumber(cp.flagradius) or 230, -- radius of flagTypes capping area
		capThreshold = tonumber(cp.capthreshold) or 10, -- number of capping points needed for flagType to switch teams
		regen = tonumber(cp.flagregen) or 1, -- how fast a flagType with no defenders or attackers will reduce capping statuses
		tooltip = UnitDefNames[flagType].tooltip or "Beacon", -- what to call the flagType when it switches teams
		limit = cp.flaglimit or Game.maxUnits, -- How many of this flagType a player can hold at once
	}
	flags[flagType] = {}
	numFlags[flagType] = 0
	flagTypeSpots[flagType] = {}
	flagTypeCappers[flagType] = {}
	flagTypeDefenders[flagType] = {}
end


local flagCapStatuses = {} -- table of flag's capping statuses
local teams	= Spring.GetTeamList()

local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end
local metalMake = tonumber(modOptions.map_command_per_player) or -1

if (gadgetHandler:IsSyncedCode()) then
-- SYNCED

local DelayCall = GG.Delay.DelayCall

-- this function is used to add any additional flagType specific behaviour
function FlagSpecialBehaviour(flagType, flagID, flagTeamID, teamID)
end

function PlaceFlag(spot, flagType)
	if DEBUG then
		Spring.Echo("{")
		Spring.Echo("	x = " .. spot.x .. ",")
		Spring.Echo("	z = " .. spot.z .. ",")
		Spring.Echo("},")
	end
	
	local newFlag = CreateUnit(flagType, spot.x, 0, spot.z, 0, GAIA_TEAM_ID)
	numFlags[flagType] = numFlags[flagType] + 1
	flags[flagType][numFlags[flagType]] = newFlag
	flagCapStatuses[newFlag] = {}
	
	SetUnitNeutral(newFlag, true)
	SetUnitNoSelect(newFlag, true)
	SetUnitAlwaysVisible(newFlag, true)
end


function gadget:GamePreload()
	if modOptions and (modOptions.income == "damageonly" or modOptions.income == "none") then gadgetHandler:RemoveGadget() end
	if DEBUG then Spring.Echo(PROFILE_PATH) end
	-- CHECK FOR PROFILES
	if VFS.FileExists(PROFILE_PATH) then
		local flagSpots, buoySpots = VFS.Include(PROFILE_PATH)
		if flagSpots and #flagSpots > 0 then 
			Spring.Echo("Map Beacon Profile found. Loading Beacon positions...", #flagSpots)
			flagTypeSpots[flagTypes[1]] = flagSpots 
		end
		--[[if buoySpots and #buoySpots > 0 then 
			Spring.Echo("Map Buoy Profile found. Loading Buoy positions...")
			flagTypeSpots["buoy"] = buoySpots 
		end]]
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


function gadget:GameFrame(n)
	-- FLAG CONTROL
	if n % 30 == 5 then -- every second with a 5 frame offset
		for _, flagType in pairs(flagTypes) do
			local flagData = flagTypeData[flagType]
			--for spotNum, flagID in pairs(flags[flagType]) do
			for spotNum = 1, numFlags[flagType] do -- WARNING: Assumes flags are placed in order they exist in flags[flagType]
				local flagID = flags[flagType][spotNum]
				local flagTeamID = GetUnitTeam(flagID)
				local spots = flagTypeSpots[flagType]
				local cappers = flagTypeCappers[flagType]
				local defenders = flagTypeDefenders[flagType]
				local defendTotal = 0
				local unitsAtFlag = GetUnitsInCylinder(spots[spotNum].x, spots[spotNum].z, flagData.radius)
				--Spring.Echo ("There are " .. #unitsAtFlag .. " units at flag " .. flagID)
				if #unitsAtFlag == 1 then -- Only the flag, no other units
					for teamID = 0, #teams-1 do
						if teamID ~= flagTeamID then
							if (flagCapStatuses[flagID][teamID] or 0) > 0 then
								flagCapStatuses[flagID][teamID] = flagCapStatuses[flagID][teamID] - flagData.regen
								SetUnitRulesParam(flagID, "cap" .. tostring(teamID), flagCapStatuses[flagID][teamID], {public = true})
							end
						end
					end
				else -- Attackers or defenders (or both) present
					for i = 1, #unitsAtFlag do
						local unitID = unitsAtFlag[i]
						local unitTeamID = GetUnitTeam(unitID)
						if defenders[unitID] and AreTeamsAllied(unitTeamID, flagTeamID) then
							--Spring.Echo("Defender at flag " .. flagID .. " Value is: " .. defenders[unitID])
							defendTotal = defendTotal + defenders[unitID]
						end
						if cappers[unitID] and (not AreTeamsAllied(unitTeamID, flagTeamID)) then
							if (flagTeamID ~= GAIA_TEAM_ID or GetTeamUnitDefCount(unitTeamID, UnitDefNames[flagType].id) < flagData.limit) then
								--Spring.Echo("Capper at flag " .. flagID .. " Value is: " .. cappers[unitID])
								flagCapStatuses[flagID][unitTeamID] = (flagCapStatuses[flagID][unitTeamID] or 0) + cappers[unitID]
							end
						end
					end
					for j = 1, #teams do
						teamID = teams[j]
						if teamID ~= flagTeamID then
							if (flagCapStatuses[flagID][teamID] or 0) > 0 then
								--Spring.Echo("Capping: " .. flagCapStatuses[flagID][teamID] .. " Defending: " .. defendTotal)
								flagCapStatuses[flagID][teamID] = flagCapStatuses[flagID][teamID] - defendTotal
								if flagCapStatuses[flagID][teamID] < 0 then
									flagCapStatuses[flagID][teamID] = 0
								end
								SetUnitRulesParam(flagID, "cap" .. tostring(teamID), flagCapStatuses[flagID][teamID], {public = true})
							end
						end
						if (flagCapStatuses[flagID][teamID] or 0) > flagData.capThreshold and teamID ~= flagTeamID then
							-- Flag is ready to change team
							if (flagTeamID == GAIA_TEAM_ID) then
								-- Neutral flag being capped
								Spring.SendMessageToTeam(teamID, flagData.tooltip .. " Captured!")
								TransferUnit(flagID, teamID, false)
								SetTeamRulesParam(teamID, flagType .. "s", (GetTeamRulesParam(teamID, flagType .. "s") or 0) + 1, {public = true})
							else
								-- Team flag being neutralised
								Spring.SendMessageToTeam(teamID, flagData.tooltip .. " Neutralised!")
								TransferUnit(flagID, GAIA_TEAM_ID, false)
								SetTeamRulesParam(teamID, flagType .. "s", (GetTeamRulesParam(teamID, flagType .. "s") or 0) - 1, {public = true})
							end
							-- Perform any flagType specific behaviours
							--FlagSpecialBehaviour(flagType, flagID, flagTeamID, teamID)
							-- Turn flag back on
							GiveOrderToUnit(flagID, CMD.ONOFF, {1}, {})
							-- Flag has changed team, reset capping statuses
							for cleanTeamID = 0, #teams-1 do
								flagCapStatuses[flagID][cleanTeamID] = 0
								SetUnitRulesParam(flagID, "cap" .. tostring(cleanTeamID), 0, {public = true})
							end
						end
						-- cleanup defenders
						flagCapStatuses[flagID][flagTeamID] = 0
					end
				end
			end
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	local ud = UnitDefs[unitDefID]
	if ud.speed > 0 then
		local cp = ud.customParams
		local flagCapRate = 1 --cp.flagcaprate
		local flagDefendRate = cp.flagdefendrate or flagCapRate
		local flagCapType = ud.customParams.flagcaptype or flagTypes[1]
		if flagCapRate then
			flagTypeCappers[flagCapType][unitID] = (CAP_MULT * flagCapRate)
			flagTypeDefenders[flagCapType][unitID] = (DEF_MULT * flagCapRate)
		end
	end
end


function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	local ud = UnitDefs[unitDefID]
	if ud.speed > 0 then
		local cp = ud.customParams
		local flagCapRate = 1 -- cp.flagcaprate
		local flagCapType = ud.customParams.flagcaptype or flagTypes[1]
		if flagCapRate then
			flagTypeCappers[flagCapType][unitID] = nil
			flagTypeDefenders[flagCapType][unitID] = nil
		end
	end
end

else
-- UNSYNCED
end
