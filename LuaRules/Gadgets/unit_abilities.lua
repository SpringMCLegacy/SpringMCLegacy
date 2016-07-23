function gadget:GetInfo()
	return {
		name = "Unit Abilities",
		desc = "Unit Special Abilities",
		author = "FLOZi (C. Lawrence)",
		date = "01/08/2014",
		license = "GNU GPL v2",
		layer = 2, -- run after game_radar
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations
local activeMASCs = {}

-- Synced Read
local GetUnitCmdDescs 		= Spring.GetUnitCmdDescs

-- Synced Ctrl
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc

-- Unsynced Ctrl

-- Constants

local CMD_MASC = GG.CustomCommands.GetCmdID("CMD_MASC")
local MascCmdDesc = {
	id = CMD_MASC,
	action = 'masc',
	--name = '  MASC Off  ',
	tooltip = 'Activate MASC sprinting',
	type	= CMDTYPE.ICON_MODE,
	params	= {0, '  MASC Off  ', '  MASC On   '},
}
local mascUnitDefs = {}


local CMD_FLUSH = GG.CustomCommands.GetCmdID("CMD_FLUSH")
local CoolantCmdDesc = {
	id = CMD_FLUSH,
	action = 'flush',
	name = ' Flush\n Coolant ',
	tooltip = 'Rapidly cool the mech heatsinks.',
	queueing = false,
}
local coolantUnitDefs = {}

-- Variables

local function ChangeMoveData(unitDefID, mult)
	local ud = UnitDefs[unitDefID]
	return {
		turnRate = ud.turnRate * mult,
		accRate = ud.maxAcc * mult,
		decRate = ud.maxDec * mult,
		maxSpeed = ud.speed * mult,
		maxReverseSpeed = ud.speed * mult / 1.5, -- 98.0 no ud.rSpeed
		maxWantedSpeed = ud.speed * mult,
	}
end

function SpeedChange(unitID, unitDefID, mult, masc)
	Spring.MoveCtrl.SetGroundMoveTypeData(unitID, ChangeMoveData(unitDefID, mult or masc and 2))
end
GG.SpeedChange = SpeedChange

function gadget:Initialize()
	-- Support /luarules reload
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	-- centralise key bindings
	Spring.SendCommands({"bind c flush"})
	Spring.SendCommands({"bind v masc"})
	Spring.SendCommands({"bind j jump"})
	Spring.SendCommands({"bind t turn"})
	Spring.SendCommands({"bind r onoff"})
end
	

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_MASC then
		if mascUnitDefs[unitDefID] then
			env = Spring.UnitScript.GetScriptEnv(unitID)
			if cmdParams[1] == 1 and not activeMASCs[unitID] then -- toggle on
				if (Spring.GetUnitRulesParam(unitID, "excess_heat") or 0) > 0 then
					return false -- don't allow overheated mechs to toggle on
				end
				activeMASCs[unitID] = true
				Spring.UnitScript.CallAsUnit(unitID, env.MASC, true)
			elseif activeMASCs[unitID] then -- toggle off
				activeMASCs[unitID] = false
				Spring.UnitScript.CallAsUnit(unitID, env.MASC, false)
			end
			MascCmdDesc.params[1] = cmdParams[1]
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_MASC), { params = MascCmdDesc.params})
			return true
		else 
			return false 
		end
	elseif cmdID == CMD_FLUSH then 
		if coolantUnitDefs[unitDefID] then
			env = Spring.UnitScript.GetScriptEnv(unitID)
			Spring.UnitScript.CallAsUnit(unitID, env.FlushCoolant)
		else return false end
	end
	return true
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp and cp.masc then
		InsertUnitCmdDesc(unitID, MascCmdDesc)
		Spring.SetUnitRulesParam(unitID, "masc", 100)
		mascUnitDefs[unitDefID] = true
	end
	if cp and cp.baseclass == "mech" then
		InsertUnitCmdDesc(unitID, CoolantCmdDesc)
		Spring.SetUnitRulesParam(unitID, "ammo_coolant", 100)
		coolantUnitDefs[unitDefID] = true
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	
end

else

-- UNSYNCED

end
