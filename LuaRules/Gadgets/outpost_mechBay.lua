function gadget:GetInfo()
	return {
		name		= "Outpost - Mech Bay",
		desc		= "Controls mech bay & salvage",
		author		= "FLOZi (C. Lawrence)",
		date		= "10/08/20",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true,
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetUnitPosition		= Spring.GetUnitPosition
local GetTeamResources		= Spring.GetTeamResources
--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local SetUnitRulesParam		= Spring.SetUnitRulesParam
local SetTeamRulesParam		= Spring.SetTeamRulesParam
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local MECHBAY_ID = UnitDefNames["outpost_mechbay"].id
local PICKUP_DIST = 50

local getOutCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_MECHBAY_GETOUT"),
	type	= CMDTYPE.ICON,
	name 	= " Get  \n Out  ",
	action	= "mechbay_out",
	tooltip = "Emergency unload",
}

-- Variables
local pieces = {}
local names = {
	["torso"] = true,
	["lupperarm"] = true,
	["rupperarm"] = true,
	["turret"] = true,
}

local teamSalvages = {} -- teamID = salvageAmount
local salvageSources = {} -- featureID = {x,z}
local salvageCache = {} -- featureDefID = true
local salvageArray = {} -- [1] = featureDefID1, ...

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == MECHBAY_ID then
		InsertUnitCmdDesc(unitID, getOutCmdDesc)
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == MECHBAY_ID then
		if cmdID == getOutCmdDesc.id then
			env = Spring.UnitScript.GetScriptEnv(unitID)
			if env and env.script and env.script.TransportDrop then
				local transporting = Spring.GetUnitIsTransporting(unitID)
				if transporting then
					Spring.UnitScript.CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
					return true
				end
			end
			return false
		end
	end
	return true
end

function gadget:FeatureCreated(featureID, allyTeamID)
	if salvageCache[Spring.GetFeatureDefID(featureID)] then
		local x,y,z = Spring.GetFeaturePosition(featureID)
		salvageSources[featureID] = {
			["x"] = x, 
			["z"] = z,
			["amount"] = 1, -- TODO: customparam
		}
	end
end

function gadget:FeatureDestroyed(featureID)
	salvageSources[featureID] = nil
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	local name = Spring.GetProjectileName(proID)
	local weap, piece = Spring.GetProjectileType(proID)
	if piece and names[name] then pieces[proID] = true end
	--Spring.Echo("PC", proID, proOwnerID, weaponID, name, defID, weap, piece)
end
	
function gadget:ProjectileDestroyed(proID)
	if pieces[proID] then
		local x,y,z = Spring.GetProjectilePosition(proID)
		Spring.CreateFeature(salvageArray[math.random(#salvageArray)], x,y,z)
		pieces[proID] = nil
	end
end

function gadget:GameFrame(n)
	if n % 10 == 0 then -- 3 times a second
		for featureID, info in pairs(salvageSources) do
			local units = Spring.GetUnitsInCylinder(info.x, info.z, PICKUP_DIST)
			if units[1] then
				local unitDefID = Spring.GetUnitDefID(units[1])
				if GG.mechCache[unitDefID] then
					local teamID = Spring.GetUnitTeam(units[1])
					teamSalvages[teamID] = (teamSalvages[teamID] or 0) + info.amount
					Spring.SetTeamRulesParam(teamID, "SALVAGE", teamSalvages[teamID])
					Spring.DestroyFeature(featureID)
				end
			end
		end
	end
end

function gadget:Initialize()
	Script.SetWatchWeapon(-1, true) -- pieces
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	for featureDefID, featureDef in pairs(FeatureDefs) do
		if featureDef.name:find("salvage") then -- TODO: customparam
			salvageCache[featureDefID] = true
			table.insert(salvageArray, featureDefID)
		end
	end
end

else
--	UNSYNCED

end
