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
--SyncedCtrl
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local UseTeamResource 		= Spring.UseTeamResource

-- Constants
local COLOURS = GG.GameConstants.colours
local CRUISE_MISSILE_COST = 10000
local LAUNCHER_ID = UnitDefNames["outpost_launcher"].id
local CMD_STOCKPILE = CMD.STOCKPILE

-- Variables


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
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == LAUNCHER_ID then
		if cmdID == CMD_STOCKPILE then
			if GetTeamResources(teamID, "metal") > CRUISE_MISSILE_COST then
				UseTeamResource(teamID, "metal", CRUISE_MISSILE_COST)
				GG.PlaySoundForTeam(teamID, "bb_outpost_launcher_preparing", 1)
				return true
			else
				GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
				return false
			end
		end
		return true
	end
	-- let everything else through this gadget
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
