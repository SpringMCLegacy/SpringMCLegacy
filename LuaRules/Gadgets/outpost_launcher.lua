function gadget:GetInfo()
	return {
		name		= "Outpost - Launcher",
		desc		= "Controls cruise missile launcher",
		author		= "FLOZi (C. Lawrence)",
		date		= "24/07/25(!)",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations

--SyncedRead
local GetTeamList			= Spring.GetTeamList
local GetTeamResources		= Spring.GetTeamResources
local GetUnitStockpile		= Spring.GetUnitStockpile
--SyncedCtrl
local AddTeamResource		= Spring.AddTeamResource
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local UseTeamResource 		= Spring.UseTeamResource

-- Constants
local COLOURS = GG.GameConstants.colours
local CRUISE_MISSILE_COST = 10000
local CRUISE_MISSILE_ID = WeaponDefNames["cruisemissile"].id
local MELTDOWN_WDID = WeaponDefNames["meltdown"].id
local LAUNCHER_ID = UnitDefNames["outpost_launcher"].id
local ICON_ID = UnitDefNames["nuke_icon"].id
local CMD_STOCKPILE = CMD.STOCKPILE

-- Variables
local CMs = {}

function gadget:StockpileChanged(unitID, unitDefID, unitTeam, weaponNum, oldCount, newCount)
	--Spring.Echo("StockpileChanged", unitID, unitDefID, unitTeam, weaponNum, oldCount, newCount)
	if newCount > oldCount then
		GG.PlaySoundForTeam(unitTeam, "bb_outpost_launcher_ready", 1)
	else -- launch
		local teams = GetTeamList()
		for i, teamID in pairs(teams) do
			if teamID ~= unitTeam then
				GG.PlaySoundForTeam(teamID, "bb_enemy_nuke_detected", 1)
			end
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == LAUNCHER_ID then
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD.STOCKPILE), {tooltip = "Stockpile a cruise missile. " .. COLOURS.cbills .. "C-Bill cost: " .. CRUISE_MISSILE_COST})
	elseif unitDefID == ICON_ID then
		Spring.SetUnitBlocking(unitID, false, false, false, false, false, false, false)
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == LAUNCHER_ID then
		if cmdID == CMD_STOCKPILE then
			if cmdOptions.shift or cmdOptions.ctrl then return false end -- otherwise we can (dramatically) circumvent costs
			local price = Spring.IsNoCostEnabled() and 0 or CRUISE_MISSILE_COST
			if not cmdOptions.right then -- ordering new
				if GetTeamResources(teamID, "metal") >= price then
					UseTeamResource(teamID, "metal", price)
					GG.PlaySoundForTeam(teamID, "bb_outpost_launcher_preparing", 1)
					return true
				else
					GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
					return false
				end
			else -- cancelling
				local stockpiled, queued = GetUnitStockpile(unitID)
				if queued > 0 then
					AddTeamResource(teamID, "metal", price)
					GG.PlaySoundForTeam(teamID, "bb_outpost_launcher_refund", 1)
					return true
				end
				return false
			end
		end
	end
	-- let everything else through this gadget
	return true
end


function NukeIcon(proID, teamID, iconUnit)
	if not iconUnit then
		CMs[proID] = true
		local x,y,z = Spring.GetProjectilePosition(proID)
		iconUnit = Spring.CreateUnit("nuke_icon", x, y, z, 0, teamID)
		Spring.MoveCtrl.Enable(iconUnit)
	end
	if CMs[proID] then
		local x,y,z = Spring.GetProjectilePosition(proID)
		local vx,vy,vz = Spring.GetProjectileVelocity(proID)
		Spring.MoveCtrl.SetPosition(iconUnit, x,y,z)
		Spring.MoveCtrl.SetVelocity(iconUnit, vx, vy, vz)
		GG.Delay.DelayCall(NukeIcon, {proID, teamID, iconUnit}, 5)
	else -- Nuke went off, kill the unit
		Spring.DestroyUnit(iconUnit)
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	if weaponID == CRUISE_MISSILE_ID then
		Spring.SetProjectileAlwaysVisible(proID, true)
		NukeIcon(proID, Spring.GetUnitTeam(proOwnerID))
	elseif weaponID == MELTDOWN_WDID then
		Spring.SetProjectileAlwaysVisible(proID, true)
	end
end

function gadget:ProjectileDestroyed(proID)
	CMs[proID] = nil
end

function gadget:Initialize()
	Script.SetWatchProjectile(CRUISE_MISSILE_ID, true)
	Script.SetWatchExplosion(MELTDOWN_WDID, true)
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED
return false end