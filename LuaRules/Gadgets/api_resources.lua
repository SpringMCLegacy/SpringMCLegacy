function gadget:GetInfo()
	return {
		name		= "API - Resources",
		desc		= "Controls game resources",
		author		= "FLOZi (C. Lawrence)",
		date		= "28/08/26",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled		= true,
	}
end


if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
local modOptions = Spring.GetModOptions()

--SyncedRead
local GetUnitHarvestStorage		= Spring.GetUnitHarvestStorage
local spGetTeamResources		= Spring.GetTeamResources
local ValidUnitID				= Spring.ValidUnitID

--SyncedCtrl
local SetUnitHarvestStorage 	= Spring.SetUnitHarvestStorage
local SetUnitRulesParam			= Spring.SetUnitRulesParam
local SetTeamRulesParam			= Spring.SetTeamRulesParam
local spSetTeamResource			= Spring.SetTeamResource
local spAddTeamResource			= Spring.AddTeamResource
local spUseTeamResource			= Spring.UseTeamResource
-- UnsyncedCtrl


local RESOURCE_ALIAS = { -- alias for engine resources, 
	["cbills"]			= {
		amount				= "m",
		storage				= "ms",
	},
	["tonnage"] 	= {
		amount				= "e",
		storage				= "es",
	},
}

local teamResources = {}
local teamStorages = {}

function gadget:Initialize()
	local existingTeams = Spring.GetTeamList() -- i = teamID
	local gaiaTeamID = Spring.GetGaiaTeamID()
	for i, teamID in pairs(existingTeams) do
		if teamID ~= gaiaTeamID then
			teamResources[teamID] = {}
			teamStorages[teamID] = {}
		end
	end
end

-- Get
local function GetTeamResource(teamID, resource)
	local alias = RESOURCE_ALIAS[resource]
	if alias then
		return spGetTeamResources(teamID, alias.amount)
	else
		return teamResources[teamID][resource] or 0 -- assume no resource if none yet allocated
	end
end
GG.GetTeamResource = GetTeamResource

local function GetTeamStorage(teamID, resource)
	local alias = RESOURCE_ALIAS[resource]
	if alias then
		return spGetTeamResources(teamID, alias.storage)
	else
		return teamStorages[teamID][resource] or math.huge -- assume infinite storage if not specified
	end
end
GG.GetTeamStorage = GetTeamStorage

-- Set
local function SetTeamResource(teamID, resource, amount)
	local alias = RESOURCE_ALIAS[resource]
	local safeAmount = math.min(amount, GetTeamStorage(teamID, alias and alias.storage or resource))
	if alias then
		spSetTeamResource(teamID, alias.amount, safeAmount)
	else
		teamResources[teamID][resource] = safeAmount
		SetTeamRulesParam(teamID, resource, teamResources[teamID][resource])
	end
end
GG.SetTeamResource = SetTeamResource

local function SetTeamStorage(teamID, resource, maxAmount)
	local alias = RESOURCE_ALIAS[resource]
	if alias then
		spSetTeamResource(teamID, alias.storage, maxAmount)
	else
		teamStorages[teamID][resource] = maxAmount
	end
end
GG.SetTeamStorage = SetTeamStorage

-- Change
local function ChangeTeamResource(teamID, resource, delta)
	local alias = RESOURCE_ALIAS[resource]
	if alias then
		if delta > 0 then
			spAddTeamResource(teamID, alias.amount, delta)
		elseif delta < 0 then
			spUseTeamResource(teamID, alias.amount, -delta)
		end
	else
		teamResources[teamID][resource] = (teamResources[teamID][resource] or 0) + delta
		SetTeamRulesParam(teamID, resource, teamResources[teamID][resource])
	end
end
GG.ChangeTeamResource = ChangeTeamResource

else
--	UNSYNCED

--return false 
end