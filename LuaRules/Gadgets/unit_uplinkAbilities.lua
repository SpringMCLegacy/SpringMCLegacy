function gadget:GetInfo()
	return {
		name		= "Uplink Abilities",
		desc		= "Controls Orbital Uplink's abilities",
		author		= "FLOZi (C. Lawrence)",
		date		= "22/08/13",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
local SetUnitRulesParam		= Spring.SetUnitRulesParam
--SyncedRead
local GetUnitPosition		= Spring.GetUnitPosition
--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local TransferUnit			= Spring.TransferUnit
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local SetUnitNeutral		= Spring.SetUnitNeutral
local SetUnitRotation		= Spring.SetUnitRotation
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local UPLINK_ID = UnitDefNames["upgrade_uplink"].id

local ARTY_WEAPON_ID = WeaponDefNames["sniper"].id
local ARTY_HEIGHT = 10000
local ARTY_SALVO = 100
local ARTY_RADIAL_SPREAD = 500

local CMD_UPGRADE = GG.CustomCommands.GetCmdID("CMD_UPGRADE")

-- Variables
local artyCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_UPLINK_ARTILLERY"),
	type	= CMDTYPE.ICON_MAP, -- UNIT_OR_MAP?
	name 	= " Artillery \n Strike ",
	action	= "uplink_arty",
	tooltip = "C-Bill cost: ", -- ..cBillCost
	cursor	= "Attack",
}


function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == UPLINK_ID then
		InsertUnitCmdDesc(unitID, artyCmdDesc)
	end
end

local function ArtyShot(x,y,z)
	local projParams = {}
	projParams.gravity = -3 + math.random()
	projParams.pos = {x, y, z}
	Spring.SpawnProjectile(ARTY_WEAPON_ID, projParams)
end

local function ArtyStrike(x, y, z)
	local dx, dz
	for i = 1, ARTY_SALVO do
		local angle = math.random(360)
		local length = math.random(ARTY_RADIAL_SPREAD)
		dx = math.sin(angle) * length
		dz = math.cos(angle) * length
		DelayCall(ArtyShot, {x + dx, y + ARTY_HEIGHT, z + dz}, math.random(150))
	end
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == UPLINK_ID then
		if cmdID == artyCmdDesc.id then
			local x,y,z = unpack(cmdParams)
			return ArtyStrike(x, y, z)
		end
	end
	return true
end

function gadget:Initialize()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED

end
