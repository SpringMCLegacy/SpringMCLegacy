function gadget:GetInfo()
	return {
		name		= "Outpost - Orbital Uplink",
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
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetUnitPosition		= Spring.GetUnitPosition
local GetTeamResources		= Spring.GetTeamResources
--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local SetUnitRulesParam		= Spring.SetUnitRulesParam
local SetTeamRulesParam		= Spring.SetTeamRulesParam
local SpawnProjectile		= Spring.SpawnProjectile
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local FramesToMinutesAndSeconds = GG.FramesToMinutesAndSeconds
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local UPLINK_ID = UnitDefNames["outpost_uplink"].id
local MECHBAY_ID = UnitDefNames["outpost_mechbay"].id

local artyWeaponInfo = {
	[1] = { -- NAC/10
		id 			= WeaponDefNames["nac10"].id,
		salvo 		= 8,
		cooldown	= 50 * 30,
		delay		= 10 * 30,
		spread		= 500,
		sound 		= "sounds/" .. WeaponDefNames["nac10"].fireSound[1].name:lower() .. ".wav",
	},
	[2] = { -- NPPC
		id 			= WeaponDefNames["nppc"].id,
		salvo 		= 8,
		cooldown	= 75 * 30,
		delay		= 10 * 30,
		spread 		= 400,
		sound		= "sounds/" .. WeaponDefNames["nppc"].fireSound[1].name:lower() .. ".wav",
	},
	[3] = { -- NAC/40
		id 			= WeaponDefNames["nac40"].id,
		salvo 		= 5,
		cooldown	= 90 * 30,
		delay		= 15 * 30,
		spread		= 400,
		sound		= "sounds/" .. WeaponDefNames["nac40"].fireSound[1].name:lower() .. ".wav",
	}
}

local uplinkLevels = {} -- uplinkLevels[uplinkID] = 1, 2 or 3

-- ARTY
local ARTY_COST = 10000
local ARTY_HEIGHT = 10000
local artyLastFired = {} -- artyLastFired[teamID] = gameFrame
local artyCanFire = {} -- artyCanFire[teamID] = gameFrame

-- AERO
local AERO_COST = 1--0000
local vicOffsets = {
	[1] = {0, 0, 0},
	[2] = {-150, 0, -150},
	[3] = {150, 0, -150},
}
local spawnPoints = {} -- unitID = {x,y,z}
local targetVics = {} -- targetID = {id1, id2, id3}

-- ASSAULT
local ASSAULT_COST = 10000

-- Variables
local artyCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_UPLINK_ARTILLERY", ARTY_COST),
	type	= CMDTYPE.ICON_MAP, -- UNIT_OR_MAP?
	name 	= GG.Pad("Orbital","Strike"),
	action	= "uplink_arty",
	tooltip = "C-Bill cost: " .. ARTY_COST,
	cursor	= "Attack",
}
local aeroCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_UPLINK_AERO", AERO_COST),
	type	= CMDTYPE.ICON_UNIT,
	name 	= GG.Pad("Aero","Sortie"),
	action	= "uplink_aero",
	tooltip = "C-Bill cost: " .. AERO_COST,
	cursor	= "Attack",
	hidden 	= true,
}
local assaultCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_UPLINK_ASSAULT", ASSAULT_COST),
	type	= CMDTYPE.ICON_MAP, -- UNIT_OR_MAP?
	name 	= GG.Pad("Assault","Dropship"),
	action	= "uplink_assault",
	tooltip = "C-Bill cost: " .. ASSAULT_COST,
	cursor	= "Attack",
	hidden 	= true,
}


local getOutCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_MECHBAY_GETOUT"),
	type	= CMDTYPE.ICON,
	name 	= " Get  \n Out  ",
	action	= "mechbay_out",
	tooltip = "Emergency unload",
}

local function UplinkUpgrade(unitID, level)
	uplinkLevels[unitID] = level
	if level == 2 then
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, aeroCmdDesc.id), {hidden = false})
	elseif level == 3 then
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, assaultCmdDesc.id), {hidden = false})
	end
end
GG.UplinkUpgrade = UplinkUpgrade

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == UPLINK_ID then
		InsertUnitCmdDesc(unitID, artyCmdDesc)
		InsertUnitCmdDesc(unitID, aeroCmdDesc)
		InsertUnitCmdDesc(unitID, assaultCmdDesc)
		uplinkLevels[unitID] = 1
	elseif unitDefID == MECHBAY_ID then
		InsertUnitCmdDesc(unitID, getOutCmdDesc)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, builderID)
	local vic = targetVics[unitID]
	if vic then -- unit was the target of an aero attack, tell the team to bug out
		-- can't assume all of them made it
		for i = 1, #vic do
			Spring.GiveOrderToUnit(vic[i], CMD.MOVE, spawnPoints[vic[i]], {})
		end
		targetVics[unitID] = nil
	end
	spawnPoints[unitID] = nil
end

local function ArtyShot(level, teamID, x,y,z)
	local projParams = {}
	projParams.gravity = -3 + math.random()
	projParams.pos = {x, y, z}
	SpawnProjectile(artyWeaponInfo[level].id, projParams)
	GG.PlaySoundForTeam(teamID, artyWeaponInfo[level].sound, 1)
end

local function ArtyStrike(unitID, teamID, x, y, z)
	local canFireFrame = artyCanFire[teamID]
	local currFrame = GetGameFrame()
	local weapInfo = artyWeaponInfo[uplinkLevels[unitID]]
	if canFireFrame and canFireFrame > currFrame then -- still cooling
		local minutes, seconds = FramesToMinutesAndSeconds(canFireFrame - currFrame)
		Spring.SendMessageToTeam(teamID, "Not yet! " .. minutes .. " min " .. seconds .. " seconds left")
		return false
	end
	local money = GetTeamResources(teamID, "metal")
	if money < ARTY_COST then  -- not enough C-Bills (TODO: Should never get this far, button disabled by unit_purchasing.lua?)
		GG.PlaySoundForTeam(teamID, "BB_Insufficient_Funds", 1)
		Spring.SendMessageToTeam(teamID, "Not enough C-Bills for artillery strike!")
		return false 
	end
	UseTeamResource(teamID, "metal", ARTY_COST)
	artyCanFire[teamID] = currFrame + weapInfo.cooldown
	SetTeamRulesParam(teamID, "UPLINK_ARTILLERY", currFrame + weapInfo.cooldown) -- frame this team can fire arty again
	local dx, dz
	for i = 1, weapInfo.salvo do
		local angle = math.random(360)
		local length = math.random(weapInfo.spread)
		dx = math.sin(angle) * length
		dz = math.cos(angle) * length
		DelayCall(ArtyShot, {1, teamID, x + dx, y + ARTY_HEIGHT, z + dz}, weapInfo.delay + math.random(150))
	end
	GG.PlaySoundForTeam(teamID, "BB_OrbitalStrike_Inbound", 1)
	--DelayCall(GG.PlaySoundForTeam, {teamID, "BB_OrbitalStrike_Available_In_60", 1}, weapInfo.cooldown - 62 * 30) -- fudge
	DelayCall(GG.PlaySoundForTeam, {teamID, "BB_OrbitalStrike_Available", 1}, weapInfo.cooldown)
	return true
end

local function SpawnVic(teamID, targetID)
	local facing = math.random(0,3)
	local sx, sy, sz
	if facing % 2 == 0 then -- N/S
		sx = math.random(0, Game.mapSizeX)
		sz = facing == 0 and 150 or Game.mapSizeZ - 150
	else -- E/W
		sz = math.random(0, Game.mapSizeZ)
		sx = facing == 1 and 150 or Game.mapSizeX - 150
	end
	local side = GG.teamSide[teamID]
	local vic = {}
	for i = 1, 3 do
		local ox, oy, oz = unpack(vicOffsets[i])
		ox, oy, oz = GG.Vector.RotateY(ox, oy, oz, math.rad(facing * 90))
		vic[i] = Spring.CreateUnit(side .. "_corsair", sx+ox, 500, sz+oz, facing, teamID)
		spawnPoints[vic[i]] = {sx+ox, 500, sz+oz}
		SendToUnsynced("TOGGLE_SELECT", vic[i], teamID, false)
	end
	targetVics[targetID] = vic
	Spring.GiveOrderToUnitArray(vic, CMD.ATTACK, {targetID}, {})
end

local function AeroStrike(unitID, teamID, targetID)
	local money = GetTeamResources(teamID, "metal")
	if money < AERO_COST then
		GG.PlaySoundForTeam(teamID, "BB_Insufficient_Funds", 1)
		Spring.SendMessageToTeam(teamID, "Not enough C-Bills for aero fighter strike!")
		return false 
	end	
	UseTeamResource(teamID, "metal", AERO_COST)
	SpawnVic(teamID, targetID)
	return true
end


local function AssaultStrike(unitID, teamID, tx, ty, tz)
	local money = GetTeamResources(teamID, "metal")
	if money < ASSAULT_COST then
		GG.PlaySoundForTeam(teamID, "BB_Insufficient_Funds", 1)
		Spring.SendMessageToTeam(teamID, "Not enough C-Bills for assault dropship strike!")
		return false 
	end	
	UseTeamResource(teamID, "metal", ASSAULT_COST)
	local avenger = Spring.CreateUnit("is_avenger", tx, ty, tz, "s", teamID)
	return true
end

function gadget:UnitCmdDone(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOpts, cmdTag)
	if spawnPoints[unitID] then
		if cmdID == CMD.MOVE then
			DelayCall(DestroyUnit, {unitID, false, true}, 30 * 5) -- 5 seconds
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == UPLINK_ID then
		if cmdID == artyCmdDesc.id then
			local x,y,z = unpack(cmdParams)
			return ArtyStrike(unitID, teamID, x, y, z)
		elseif cmdID == aeroCmdDesc.id then
			local targetID = cmdParams[1]
			local targetTeam = Spring.GetUnitTeam(targetID)
			local targetDef = UnitDefs[Spring.GetUnitDefID(targetID)]
			if Spring.AreTeamsAllied(teamID, targetTeam) or targetTeam == GAIA_TEAM_ID or targetDef.modCategories["beacon"] then
				return false
			end
			return AeroStrike(unitID, teamID, cmdParams[1])
		elseif cmdID == assaultCmdDesc.id then
			local x,y,z = unpack(cmdParams)
			return AssaultStrike(unitID, teamID, x, y, z)
		end
	elseif unitDefID == MECHBAY_ID then
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
