function gadget:GetInfo()
	return {
		name		= "Outpost - Orbital Uplink",
		desc		= "Controls Orbital Uplink's abilities",
		author		= "FLOZi (C. Lawrence)",
		date		= "22/08/13",
		license 	= "GNU GPL v2",
		layer		= 5, -- after unit_perks
		enabled	= true	--	loaded by default?
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetUnitPosition		= Spring.GetUnitPosition
local GetUnitTeam			= Spring.GetUnitTeam
local GetTeamResources		= Spring.GetTeamResources
local GetTeamList			= Spring.GetTeamList
local AreTeamsAllied		= Spring.AreTeamsAllied
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
local COLOURS = GG.GameConstants.colours
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local UPLINK_ID = UnitDefNames["outpost_uplink"].id

local artyWeaponInfo = {
	[1] = { -- NAC/10
		id 			= WeaponDefNames["nac10"].id,
		burst 		= 5,
		reload		= 3 * 30,
		salvo 		= 3,
		cooldown	= 50 * 30,
		delay		= 10 * 30,
		spread		= 350,
		sound 		= "sounds/" .. WeaponDefNames["nac10"].fireSound[1].name:lower() .. ".wav",
		cost		= 8000,
	},
	[2] = { -- NPPC
		id 			= WeaponDefNames["nppc"].id,
		burst		= 4,
		reload		= 3.5 * 30,
		salvo 		= 4,
		cooldown	= 75 * 30,
		delay		= 10 * 30,
		spread 		= 250,
		sound		= "sounds/" .. WeaponDefNames["nppc"].fireSound[1].name:lower() .. ".wav",
		cost		= 12000,
	},
	[3] = { -- NL45
		id 			= UnitDefNames["naval_laser"].id,
		cooldown	= 90 * 30,
		delay		= 10 * 30,
		--sound		= "sounds/" .. WeaponDefNames["nac40"].fireSound[1].name:lower() .. ".wav",
		cost		= 16000,
	}
}

local uplinkLevels = {} -- uplinkLevels[uplinkID] = 1, 2 or 3
GG.uplinkLevels = uplinkLevels

-- ARTY
local ARTY_HEIGHT = 10000
local artyLastFired = {} -- artyLastFired[teamID] = gameFrame
local artyCanFire = {} -- artyCanFire[teamID] = gameFrame
GG.artyCanFire = artyCanFire

-- TODO: move to outpost_aircon
-- AERO
local AERO_COST = 16000
local vicOffsets = {
	[1] = {0, 0, 0},
	[2] = {-150, 0, -150},
	[3] = {150, 0, -150},
}
local spawnPoints = {} -- unitID = {x,y,z}
local targetVics = {} -- targetID = {id1, id2, id3}

-- ASSAULT
local ASSAULT_COST = 36000

-- Variables
local nacCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_UPLINK_NAC", artyWeaponInfo[1].cost),
	type	= CMDTYPE.ICON_MAP, -- UNIT_OR_MAP?
	name 	= GG.Pad("Naval AC","Strike"),
	action	= "uplink_nac",
	tooltip = "Area bombardment with heavy Naval AutoCannon. Explosive damage with large area of effect. " .. COLOURS.cbills .. "C-Bill cost: " .. artyWeaponInfo[1].cost,
	cursor	= "Attack",
}
local nppcCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_UPLINK_NPPCC", artyWeaponInfo[2].cost),
	type	= CMDTYPE.ICON_MAP, -- UNIT_OR_MAP?
	name 	= GG.Pad("Naval PPC","Strike"),
	action	= "uplink_nppc",
	tooltip = "Area bombardment with heavy Naval Particle Projector Cannon. Disrupts sensors and generates heat. " .. COLOURS.cbills .. "C-Bill cost: " .. artyWeaponInfo[2].cost,
	cursor	= "Attack",
	hidden	= true,
}
local nlCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_UPLINK_NL", artyWeaponInfo[3].cost),
	type	= CMDTYPE.ICON_MAP, -- UNIT_OR_MAP?
	name 	= GG.Pad("Naval Laser","Strike"),
	action	= "uplink_nl",
	tooltip = "Point target removal with heavy Naval Laser. Sustained damage against point-targets " .. COLOURS.cbills .. "C-Bill cost: " .. artyWeaponInfo[3].cost,
	cursor	= "Attack",
	hidden	= true,
}
-- TODO: move to outpost_aircon
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

local function UplinkUpgrade(unitID, level)
	uplinkLevels[unitID] = level
	if level == 2 then
		--EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, aeroCmdDesc.id), {hidden = false})
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, nppcCmdDesc.id), {hidden = false})
	elseif level == 3 then
		--EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, assaultCmdDesc.id), {hidden = false})
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, nlCmdDesc.id), {hidden = false})
	end
end
GG.UplinkUpgrade = UplinkUpgrade

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == UPLINK_ID then
		InsertUnitCmdDesc(unitID, nacCmdDesc)
		InsertUnitCmdDesc(unitID, nppcCmdDesc)
		InsertUnitCmdDesc(unitID, nlCmdDesc)
		--InsertUnitCmdDesc(unitID, aeroCmdDesc)
		--InsertUnitCmdDesc(unitID, assaultCmdDesc)
		uplinkLevels[unitID] = 1
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)
	if unitDefID == UPLINK_ID then
		artyCanFire[teamID] = Spring.GetGameFrame()
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, builderID)
	local vic = targetVics[unitID]
	if vic then -- unit was the target of an aero attack, tell the team to bug out
		-- can't assume all of them made it
		for i = 1, #vic do
			if Spring.ValidUnitID(vic[i]) and not Spring.GetUnitIsDead(vic[i]) then
				Spring.GiveOrderToUnit(vic[i], CMD.MOVE, spawnPoints[vic[i]], {})
			end
		end
		targetVics[unitID] = nil
	end
	spawnPoints[unitID] = nil
end

local function ArtyShot(strikeType, unitID, teamID, x,y,z)
	local projParams = {}
	projParams.gravity = -3 + math.random()
	projParams.pos = {x, y, z}
	projParams["end"] = {x, y - ARTY_HEIGHT, z}
	--projParams.ttl = 600
	projParams.owner = unitID
	projParams.team = teamID
	SpawnProjectile(artyWeaponInfo[strikeType].id, projParams)
	GG.PlaySoundForTeam(teamID, artyWeaponInfo[strikeType].sound, 1)
end

local function ArtyStrike(unitID, teamID, x, y, z, cost, strikeType)
	local canFireFrame = artyCanFire[teamID]
	local currFrame = GetGameFrame()
	local weapInfo = artyWeaponInfo[strikeType]
	if canFireFrame and canFireFrame > currFrame then -- still cooling
		local minutes, seconds = FramesToMinutesAndSeconds(canFireFrame - currFrame)
		Spring.SendMessageToTeam(teamID, "Not yet! " .. minutes .. " min " .. seconds .. " seconds left")
		return false
	end
	local money = GetTeamResources(teamID, "metal")
	if money < cost then  -- not enough C-Bills (TODO: Should never get this far, button disabled by unit_purchasing.lua?)
		GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
		Spring.SendMessageToTeam(teamID, "Not enough C-Bills for artillery strike!")
		return false 
	end
	UseTeamResource(teamID, "metal", cost)
	artyCanFire[teamID] = currFrame + weapInfo.cooldown
	SetTeamRulesParam(teamID, "UPLINK_ARTILLERY", currFrame + weapInfo.cooldown) -- frame this team can fire arty again
	local dx, dz
	local lastDelay = 0
	if strikeType < 3 then -- artillery style
		for i = 1, weapInfo.salvo do
			for j = 1, (weapInfo.burst or 1) do
				local angle = math.random(360)
				local length = math.random(weapInfo.spread)
				dx = math.sin(angle) * length
				dz = math.cos(angle) * length
				lastDelay = math.random(15)
				DelayCall(ArtyShot, {strikeType, unitID, teamID, x + dx, y + ARTY_HEIGHT, z + dz}, weapInfo.delay + (i-1) * (weapInfo.reload or 0) + lastDelay)
			end
		end
	else -- spawn a fully armed and operational battle-station
		DelayCall(Spring.CreateUnit, {weapInfo.id, x, y, z, 0, teamID, false, false}, weapInfo.delay)
	end
	GG.PlaySoundForTeam(teamID, "bb_orbitalstrike_inbound", 1)
	DelayCall(GG.PlaySoundForTeam, {teamID, "bb_orbitalstrike_available_in_60", 1}, weapInfo.delay + lastDelay + 30 * 8) -- fudge for time to fall from orbit after spawned
	DelayCall(GG.PlaySoundForTeam, {teamID, "bb_orbitalstrike_available", 1}, weapInfo.cooldown)
	-- let all enemies know
	GG.PlaySoundForTeam(teamID, "bb_Enemy_Orbital_Inbound", 1, true)
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
	if not side then return end -- implies team died
	local vic = {}
	for i = 1, 3 do
		local ox, oy, oz = unpack(vicOffsets[i])
		ox, oy, oz = GG.Vector.RotateY(ox, oy, oz, math.rad(facing * 90))
		local aero = side == "wf" and side .. "_sulla" or side .. "_corsair"
		vic[i] = Spring.CreateUnit(aero, sx+ox, 500, sz+oz, facing, teamID)
		spawnPoints[vic[i]] = {sx+ox, 500, sz+oz}
		SendToUnsynced("TOGGLE_SELECT", vic[i], teamID, false)
	end
	targetVics[targetID] = vic
	Spring.GiveOrderToUnitArray(vic, CMD.ATTACK, {targetID}, {})
end

local function AeroStrike(unitID, teamID, targetID, cost)
	local money = GetTeamResources(teamID, "metal")
	if money < cost then
		GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
		Spring.SendMessageToTeam(teamID, "Not enough C-Bills for aero fighter strike!")
		return false 
	end	
	UseTeamResource(teamID, "metal", cost)
	SpawnVic(teamID, targetID)
	-- only let target team know
	GG.PlaySoundForTeam(GetUnitTeam(targetID), "bb_Enemy_Aero_Inbound", 1)
	return true
end


local function AssaultStrike(unitID, teamID, tx, ty, tz, cost)
	local money = GetTeamResources(teamID, "metal")
	if money < cost then
		GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
		Spring.SendMessageToTeam(teamID, "Not enough C-Bills for assault dropship strike!")
		return false 
	end	
	UseTeamResource(teamID, "metal", cost)
	local avenger = Spring.CreateUnit("is_avenger", tx, ty, tz, "s", teamID)
	SendToUnsynced("TOGGLE_SELECT", avenger, teamID, false)
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
		if cmdID == nacCmdDesc.id then
			local x,y,z = unpack(cmdParams)
			return ArtyStrike(unitID, teamID, x, y, z, Spring.IsNoCostEnabled() and 0 or artyWeaponInfo[1].cost, 1)
		elseif cmdID == nppcCmdDesc.id then
			local x,y,z = unpack(cmdParams)
			return ArtyStrike(unitID, teamID, x, y, z, Spring.IsNoCostEnabled() and 0 or artyWeaponInfo[2].cost, 2)
		elseif cmdID == nlCmdDesc.id then
			local x,y,z = unpack(cmdParams)
			return ArtyStrike(unitID, teamID, x, y, z, Spring.IsNoCostEnabled() and 0 or artyWeaponInfo[3].cost, 3)
		--[[elseif cmdID == aeroCmdDesc.id and teamID then
			local targetID = cmdParams[1]
			local targetTeam = Spring.GetUnitTeam(targetID)
			local targetDef = UnitDefs[Spring.GetUnitDefID(targetID)]
			if targetTeam and Spring.AreTeamsAllied(teamID, targetTeam) or targetTeam == GAIA_TEAM_ID or targetDef.modCategories["beacon"] then
				return false
			end
			return AeroStrike(unitID, teamID, cmdParams[1], Spring.IsNoCostEnabled() and 0 or AERO_COST)
		elseif cmdID == assaultCmdDesc.id then
			local x,y,z = unpack(cmdParams)
			return AssaultStrike(unitID, teamID, x, y, z, Spring.IsNoCostEnabled() and 0 or ASSAULT_COST)--]]
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
return false end