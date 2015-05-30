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
	name = '  MASC  ',
	tooltip = 'Activate MASC sprinting',
}
local mascUnitDefs = {}


local CMD_FLUSH = GG.CustomCommands.GetCmdID("CMD_FLUSH")
local CoolantCmdDesc = {
	id = CMD_FLUSH,
	action = 'flush',
	name = ' Flush\n Coolant ',
	tooltip = 'Rapidly cool the mech heatsinks.',
}
local coolantUnitDefs = {}

-- Variables

local function MascMoveData(unitDefID, masc, mult)
	local ud = UnitDefs[unitDefID]
	if masc then
		return {
			turnRate = ud.turnRate * mult,
			accRate = ud.maxAcc * mult,
			decRate = ud.maxDec * mult,
			maxSpeed = ud.speed * mult,
			maxReverseSpeed = ud.speed * mult / 1.5, -- no mRS in lua unitdefs table?
			maxWantedSpeed = ud.speed * mult, -- TODO: doesn't work in 96, enable in 97+
		}
	else
		return {
			turnRate = ud.turnRate,
			accRate = ud.maxAcc,
			decRate = ud.maxDec,
			maxSpeed = ud.speed,
			maxReverseSpeed = ud.speed / 1.5, -- no mRS in lua unitdefs table?
			maxWantedSpeed = ud.speed, -- TODO: doesn't work in 96, enable in 97+
		}		
	end
end

function StartMASC(unitID, unitDefID, mult)
	--Spring.Echo("MASC ACTIVATED!")
	local hasMASC = FindUnitCmdDesc(unitID, CMD_MASC)
	if hasMASC then
		EditUnitCmdDesc(unitID, hasMASC, {disabled = true})
	end
	Spring.MoveCtrl.SetGroundMoveTypeData(unitID, MascMoveData(unitDefID, true, mult or 2))
end
GG.StartMASC = StartMASC

function FinishMASC(unitID, unitDefID)
	--Spring.Echo("MASC DEACTIVATED!")
	Spring.MoveCtrl.SetGroundMoveTypeData(unitID, MascMoveData(unitDefID, false))
end
GG.FinishMASC = FinishMASC

function ReadyMASC(unitID)
	EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_MASC), {disabled = false})
end
GG.ReadyMASC = ReadyMASC

function gadget:Initialize()
	-- Support /luarules reload
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end
	

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_MASC then
		if mascUnitDefs[unitDefID] then
			env = Spring.UnitScript.GetScriptEnv(unitID)
			Spring.UnitScript.CallAsUnit(unitID, env.MASC, true)
			return true
		else return false end
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
	if cp and cp.unittype == "mech" then
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
