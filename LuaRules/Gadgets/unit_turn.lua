function gadget:GetInfo()
	return {
		name      = "Unit - Turn Command r1",
		desc      = "Implements Turn command for vehicles; exposes current turn-rate authority",
		author    = "FLOZi, yuritch; direct-control integration by SpringMCLegacy",
		date      = "5/02/10; direct-control integration 2026",
		license   = "PD",
		layer     = -5,
		enabled   = true
	}
end

-- SyncedCtrl
local SetUnitCOBValue = Spring.SetUnitCOBValue
local SetUnitMoveGoal = Spring.SetUnitMoveGoal
local SetUnitVelocity = Spring.SetUnitVelocity
-- SyncedRead
local GetUnitCOBValue = Spring.GetUnitCOBValue
local GetUnitPosition = Spring.GetUnitPosition
-- Constants
local CMD_TURN = GG.CustomCommands.GetCmdID("CMD_TURN")
local COB_ANGULAR = 182
local MINIMUM_TURN = 5 * COB_ANGULAR

-- Variables
local turning = {}
GG.turning = {}

if (gadgetHandler:IsSyncedCode()) then
-- SYNCED
local DelayCall = GG.Delay.DelayCall

local unitTurnRates = {}

local function SetUnitTurnRate(unitID, mult)
	if
		not unitTurnRates[unitID]
		or not mult
	then
		return false
	end

	unitTurnRates[unitID] =
		unitTurnRates[unitID] *
		mult

	return true
end
GG.SetUnitTurnRate = SetUnitTurnRate

-- r1 addition: read the already-modified chassis turn rate. Direct control uses
-- this instead of reconstructing Pilot perks, equipment or damage modifiers.
local function GetUnitTurnRate(unitID)
	return
		unitTurnRates[unitID]
end
GG.GetUnitTurnRate = GetUnitTurnRate

local function StartTurn(unitID, unitDefID, tx, tz)
	local ud = UnitDefs[unitDefID]
	local turnRate = unitTurnRates[unitID]

	if
		not turnRate
		or turnRate == 0
	then
		return false
	end

	local ux, uy, uz = GetUnitPosition(unitID)
	local dx, dz = tx - ux, tz - uz
	local newHeading = math.deg(math.atan2(dx, dz)) * COB_ANGULAR
	local currHeading = GetUnitCOBValue(unitID, COB.HEADING)
	local deltaHeading = newHeading - currHeading
	if math.abs(deltaHeading) < MINIMUM_TURN then return false end

	Spring.MoveCtrl.Enable(unitID)

	if deltaHeading > (180 * COB_ANGULAR) then deltaHeading = deltaHeading - (360 * COB_ANGULAR) end
	if deltaHeading < (-180 * COB_ANGULAR) then deltaHeading = deltaHeading + (360 * COB_ANGULAR) end

	local numFrames = math.ceil(deltaHeading / turnRate)
	if numFrames < 0 then
		numFrames = -numFrames
		turnRate = - turnRate
	end

	env = Spring.UnitScript.GetScriptEnv(unitID)
	if env and env.StartTurn then
		DelayCall(Spring.UnitScript.CallAsUnit,{unitID, env.StartTurn, turnRate < 0}, 3)
	end

	local turnTable = {}
	turnTable["turnRate"] = turnRate
	turnTable["numFrames"] = numFrames
	turnTable["currHeading"] = currHeading
	turning[unitID] = turnTable
	GG.turning[unitID] = true
	Spring.SetUnitRulesParam(unitID, "turning", turnRate)
	return true
end

local function StopTurn(unitID)
	if turning[unitID] and turning[unitID].numFrames then
		turning[unitID] = {}
		env = Spring.UnitScript.GetScriptEnv(unitID)
		if env and env.StopTurn then
			Spring.UnitScript.CallAsUnit(unitID,env.StopTurn)
		end
	end
	GG.turning[unitID] = false
	Spring.SetUnitRulesParam(unitID, "turning", 0)
	Spring.MoveCtrl.Disable(unitID)
end

function gadget:GameFrame(n)
	for unitID, turnTable in pairs(turning) do
		if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
			if turnTable.numFrames and turnTable.numFrames > 0 then
				turnTable.currHeading = turnTable.currHeading + turnTable.turnRate
				if turnTable.currHeading < -180 * COB_ANGULAR then turnTable.currHeading = turnTable.currHeading + 360 * COB_ANGULAR end
				if turnTable.currHeading > 180 * COB_ANGULAR then turnTable.currHeading = turnTable.currHeading - 360 * COB_ANGULAR end
				turnTable.numFrames = turnTable.numFrames - 1
				SetUnitCOBValue(unitID, COB.HEADING, turnTable.currHeading)
			elseif turnTable.numFrames then
				StopTurn(unitID)
			end
		else
			turning[unitID] = nil
			GG.turning[unitID] = nil
			unitTurnRates[unitID] = nil
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	local ud = UnitDefs[unitDefID]
	if ud.customParams.hasturnbutton then
		unitTurnRates[unitID] = ud.turnRate
	end
end

function gadget:UnitDestroyed(unitID)
	turning[unitID] = nil
	GG.turning[unitID] = nil
	unitTurnRates[unitID] = nil
end

local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")
function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local ud = UnitDefs[unitDefID]
	if cmdID ~= CMD.SET_WANTED_MAX_SPEED and cmdID ~= CMD_JUMP and cmdID ~= CMD.INSERT and turning[unitID] and turning[unitID].numFrames then
		if not cmdOptions["shift"] then
			StopTurn(unitID)
		end
	elseif cmdID == CMD_TURN then
		return ud.customParams.hasturnbutton
	end
	return true
end

function gadget:CommandFallback(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
	local ud = UnitDefs[unitDefID]
	if cmdID == CMD_TURN then
		if turning[unitID] == nil then
			local tx, _, tz = cmdParams[1], cmdParams[2], cmdParams[3]
			local canTurn = StartTurn(unitID, unitDefID, tx, tz)
			return canTurn, false
		else
			if turning[unitID].numFrames and turning[unitID].numFrames > 0 then
				return true, false
			else
				StopTurn(unitID)
				turning[unitID] = nil
				GG.turning[unitID] = false
				return true, true
			end
		end
	end
	return false
end

function gadget:Initialize()
	Spring.AssignMouseCursor("turn", "cursorturn")
	Spring.SetCustomCommandDrawData(CMD_TURN, "turn", {0,1,0,.8})

	-- Preserve turn-rate availability across /luarules reloads.
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		if unitDefID then
			gadget:UnitCreated(unitID, unitDefID, Spring.GetUnitTeam(unitID))
		end
	end
end

function gadget:Shutdown()
	if GG.GetUnitTurnRate == GetUnitTurnRate then
		GG.GetUnitTurnRate = nil
	end

	if GG.SetUnitTurnRate == SetUnitTurnRate then
		GG.SetUnitTurnRate = nil
	end
end

else
-- UNSYNCED
return false end
