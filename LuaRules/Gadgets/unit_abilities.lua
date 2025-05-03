function gadget:GetInfo()
	return {
		name = "Unit - Abilities",
		desc = "Unit Special Abilities",
		author = "FLOZi (C. Lawrence)",
		date = "01/08/2014",
		license = "GNU GPL v2",
		layer = -5,
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
local mascUnitDefs = {}
GG.mascUnitDefs = mascUnitDefs

local MascCmdDesc = {
	params	= {0, GG.Pad("MASC Off"), GG.Pad("MASC On")},
}

local CMD_FLUSH = GG.CustomCommands.GetCmdID("CMD_FLUSH")
local coolantUnitDefs = {}
local coolantUnits = {}
local autoCoolantUnits = {}
GG.autoCoolantUnits = autoCoolantUnits
-- Variables

local function EnableCoolantFlush(unitID, tOrF)
	coolantUnits[unitID] = tOrF
	EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_FLUSH), {disabled = not tOrF})
end
GG.EnableCoolantFlush = EnableCoolantFlush

local function EnableAutoCoolant(unitID, tOrF)
	autoCoolantUnits[unitID] = tOrF
end
GG.EnableAutoCoolant = EnableAutoCoolant

local CMD_RUN = GG.CustomCommands.GetCmdID("CMD_RUNFAST")
local runCmdDesc = {
	id = GG.CustomCommands.GetCmdID("CMD_RUNFAST"),
	name = 'run',
	action = 'run',
	type	= CMDTYPE.ICON_MAP,
	cursor	= "run",
}

local function ChangeMoveData(unitDefID, mult)
	local ud = UnitDefs[unitDefID]
	return {
		turnRate = ud.turnRate * mult,
		accRate = ud.maxAcc * mult,
		decRate = ud.maxDec * (mult > 1 and mult or 100), -- if we are slowing down, we need to force deceleration from our higher velocity
		maxSpeed = ud.speed * mult,
		maxReverseSpeed = ud.rSpeed * (mult > 1 and 1 or mult), -- allow reducing reverse speed for damage but not increasing it for running
		maxWantedSpeed = ud.speed * mult,
	}
end

function SpeedChange(unitID, unitDefID, mult, values)
	env = Spring.UnitScript.GetScriptEnv(unitID)
	if not env.jumping and Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
		-- It shouldn't happen, but, to really nail it:
		Spring.MoveCtrl.Disable(unitID)
		--Spring.Echo("debug SpeedChange:", UnitDefs[unitDefID].name)
		if not pcall(Spring.MoveCtrl.SetGroundMoveTypeData, unitID, values or ChangeMoveData(unitDefID, mult)) then
			Spring.Echo("unit_abilities debug:", unitDefID, unitDefID and UnitDefs[unitDefID].name) -- fw_spider_sdr7m, la_starslayer_sty3c called 6 times in a frame? JJ after perking?
		end
	end
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
	
	--Spring.AssignMouseCursor("run", "cursorrun", true, false)
	--Spring.SetCustomCommandDrawData(CMD_RUN, "run", {1,0.5,0,.8})
end
	

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if GG.mechCache[unitDefID] then
		if cmdID == CMD_RUN then
			--Spring.Echo("Tramps like us, baby we were borrrn to ruuun!")
			env = Spring.UnitScript.GetScriptEnv(unitID)
			Spring.UnitScript.CallAsUnit(unitID, env.Run, true)
			--SpeedChange(unitID, unitDefID, 1.5)
			--Spring.SetUnitMoveGoal(unitID, cmdParams[1], cmdParams[2], cmdParams[3], 50, 1.5)
			return false
		elseif cmdID == CMD.MOVE then
			--Spring.Echo("Harold Bishop power walk")
			env = Spring.UnitScript.GetScriptEnv(unitID)
			Spring.UnitScript.CallAsUnit(unitID, env.Run, false)
			--SpeedChange(unitID, unitDefID, 1)
			return true
		elseif cmdID == CMD_MASC then
			if mascUnitDefs[unitDefID] then
				env = Spring.UnitScript.GetScriptEnv(unitID)
				if cmdParams[1] == 1 and not activeMASCs[unitID] then -- toggle on
					--[[if (Spring.GetUnitRulesParam(unitID, "excess_heat") or 0) > 0 then
						return false -- don't allow overheated mechs to toggle on
					end]]	
					activeMASCs[unitID] = true
					Spring.UnitScript.CallAsUnit(unitID, env.EnableMASC, true)
				elseif activeMASCs[unitID] then -- toggle off
					activeMASCs[unitID] = false
					Spring.UnitScript.CallAsUnit(unitID, env.EnableMASC, false)
				end
				MascCmdDesc.params[1] = cmdParams[1]
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_MASC), { params = MascCmdDesc.params})
				return true
			else 
				return false 
			end
		elseif cmdID == CMD_FLUSH then 
			if coolantUnits[unitID] then
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.FlushCoolant)
			else return false end
		end
	end
	return true
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp and cp.masc then
		--InsertUnitCmdDesc(unitID, MascCmdDesc)
		Spring.SetUnitRulesParam(unitID, "masc", 100)
		mascUnitDefs[unitDefID] = true
	end
	if GG.mechCache[unitDefID] then
		--InsertUnitCmdDesc(unitID, CoolantCmdDesc)
		Spring.SetUnitRulesParam(unitID, "ammo_coolant", 100)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	
end

else

-- UNSYNCED

end
