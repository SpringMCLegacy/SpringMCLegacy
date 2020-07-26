function gadget:GetInfo()
	return {
		name		= "Game - Income",
		desc		= "Damage, Insurance and Sell Income",
		author		= "FLOZi (C. Lawrence)",
		date		= "26/07/20",
		license 	= "GNU GPL v2",
		layer		= 3,
		enabled	= true,
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()

-- localisations
local SetUnitRulesParam		= Spring.SetUnitRulesParam
--SyncedRead
local AreTeamsAllied		= Spring.AreTeamsAllied
--SyncedCtrl
local AddTeamResource 		= Spring.AddTeamResource
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc

-- Constants
local CBILLS_PER_SEC = (modOptions and tonumber(modOptions.income)) or 10
local BEACON_ID = UnitDefNames["beacon"].id

local DAMAGE_REWARD_MULT = (modOptions and tonumber(modOptions.income_damage)) or 0.1
Spring.SetGameRulesParam("damage_reward_mult", DAMAGE_REWARD_MULT)
local INSURANCE_MULT = (modOptions and tonumber(modOptions.insurance)) or 0.1
Spring.SetGameRulesParam("insurance_mult", INSURANCE_MULT)
local SELL_MULT = (modOptions and tonumber(modOptions.sell)) or 0.75
Spring.SetGameRulesParam("sell_mult", SELL_MULT)

local SELL_DISTANCE = 460 -- TODO: flagCapradius, grab from GG or game rules?
local CMD_SELL = GG.CustomCommands.GetCmdID("CMD_SELL")
local sellOrderCmdDesc = {
	id = CMD_SELL,
	type   = CMDTYPE.ICON,
	name   = "  Sell   \n  Unit  ",
	action = 'sell_mech',
	tooltip = "Calls a dropship to sell the unit (" .. SELL_MULT * 100 .. "% return)",
}
	

local function SellUnit(unitID, unitDefID, teamID, unitType)
	Spring.SendMessageToTeam(teamID, "Selling " .. unitType .. "!")
	AddTeamResource(teamID, "metal", UnitDefs[unitDefID].metalCost * SELL_MULT)
	-- TODO: wait around and get in dropship
	Spring.SetUnitRulesParam(unitID, "sold", 1)
	Spring.DestroyUnit(unitID, false, true)
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if GG.mechCache[unitDefID] then
		if cmdID == CMD_SELL then
			local dropZone = GG.teamDropZones[teamID]
			if dropZone then -- need to have a dropzone set and be close to it
				local dist = Spring.GetUnitSeparation(unitID, dropZone)
				if dist < SELL_DISTANCE then
					SellUnit(unitID, unitDefID, teamID, "mech")
				else
					Spring.SendMessageToTeam(teamID, "Cannot sell mech; not within range of Dropzone!")
				end
			else
				Spring.SendMessageToTeam(teamID, "Cannot sell mech; you have no Dropzone!")
			end
		end
		return true -- allow all other commands through here
	elseif GG.outpostDefs[unitDefID] then -- an outpost
		if cmdID == CMD_SELL then
			SellUnit(unitID, unitDefID, teamID, "outpost")
		else
			return true -- allow all other commands through here
		end
	end
	return true
end


function gadget:UnitCreated(unitID, unitDefID, teamID)
	if GG.mechCache[unitDefID] then
		InsertUnitCmdDesc(unitID, sellOrderCmdDesc)
	elseif GG.outpostDefs[unitDefID] then -- an outpost
		InsertUnitCmdDesc(unitID, sellOrderCmdDesc)
	end
end

local MELTDOWN = WeaponDefNames["meltdown"].id

function gadget:UnitDamaged(unitID, unitDefID, teamID, damage, paralyzer, weaponID,  projectileID, attackerID, attackerDefID, attackerTeam)
	if attackerID and attackerDefID and attackerTeam and not AreTeamsAllied(teamID, attackerTeam) then
		if GG.mechCache[attackerDefID] then -- only mechs generate income
			-- don't allow income from nukes
			if not (weaponID and weaponID == MELTDOWN) then		
				AddTeamResource(attackerTeam, "metal", damage * DAMAGE_REWARD_MULT)
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	-- Insurance income
	if attackerID and not AreTeamsAllied(teamID, attackerTeam) and GG.mechCache[unitDefID] then
		AddTeamResource(teamID, "metal", UnitDefs[unitDefID].metalCost * INSURANCE_MULT)
	end
end

function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		-- Beacon Income
		for _, teamID in pairs(Spring.GetTeamList()) do
			AddTeamResource(teamID, "metal", CBILLS_PER_SEC * Spring.GetTeamUnitDefCount(teamID, BEACON_ID))
		end
	end
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
