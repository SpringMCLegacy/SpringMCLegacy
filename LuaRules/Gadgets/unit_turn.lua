function gadget:GetInfo()
	return {
		name      = "Unit - Turn Command",
		desc      = "Implements Turn command for vehicles",
		author    = "FLOZi, yuritch", -- yuritch is magical
		date      = "5/02/10",
		license   = "PD",
		layer     = -5,
		enabled   = true  --  loaded by default?
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
local turning = {} -- structure: turning = {unitID={turnRate=number COB units to rotate per frame, numFrames=number of frames left to rotate in, currHeading= current heading}}
GG.turning = {} -- GG.turning[unitID] = true

if (gadgetHandler:IsSyncedCode()) then
-- SYNCED
local DelayCall = GG.Delay.DelayCall

local unitTurnRates = {} -- unitID = turnRate

local function SetUnitTurnRate(unitID, mult)
	unitTurnRates[unitID] = unitTurnRates[unitID] * mult
end
GG.SetUnitTurnRate = SetUnitTurnRate

local function StartTurn(unitID, unitDefID, tx, tz)
	local ud = UnitDefs[unitDefID]
	local turnRate = unitTurnRates[unitID]
	local ux, uy, uz = GetUnitPosition(unitID)
	local dx, dz = tx - ux, tz - uz

	local newHeading = math.deg(math.atan2(dx, dz)) * COB_ANGULAR	
	local currHeading = GetUnitCOBValue(unitID, COB.HEADING)
	local deltaHeading = newHeading - currHeading
	if math.abs(deltaHeading) < MINIMUM_TURN then return false end -- turn command was too small
	
	-- Make sure we stop first and know we don't want to travel anywhere else
	--SetUnitMoveGoal(unitID, ux, uy, uz)
	--SetUnitVelocity(unitID, 0,0,0)
	Spring.MoveCtrl.Enable(unitID)
	
	--  find the direction for shortest turn
	if deltaHeading > (180 * COB_ANGULAR) then deltaHeading = deltaHeading - (360 * COB_ANGULAR) end
	if deltaHeading < (-180 * COB_ANGULAR) then deltaHeading = deltaHeading + (360 * COB_ANGULAR) end
	-- how many frames the turn should take
	local numFrames = math.ceil(deltaHeading / turnRate)
	if numFrames < 0 then
		numFrames = -numFrames
		turnRate = - turnRate
	end
	env = Spring.UnitScript.GetScriptEnv(unitID)
	if env and env.StartTurn then
		-- SetUnitVelocity above calls StartMoving in LUS after 1 frame, StopMoving after 2, so call turn anim after 3 (FU, Spring)
		DelayCall(Spring.UnitScript.CallAsUnit,{unitID, env.StartTurn, turnRate < 0}, 3) -- clockwise from +ve y
	end
	local turnTable = {}
	turnTable["turnRate"] = turnRate
	turnTable["numFrames"] = numFrames
	turnTable["currHeading"] = currHeading
	turning[unitID] = turnTable
	GG.turning[unitID] = true
	Spring.SetUnitRulesParam(unitID, "turning", turnRate)
	return true -- successful turn command
end


local function StopTurn(unitID)
	if turning[unitID].numFrames then -- only attempt to stop if we are actually turning
		turning[unitID] = {} -- not nil here or gets started again by CommandFallback
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
			elseif turnTable.numFrames then -- only stop the first time, not when turnTable has become {}
				StopTurn(unitID)
			end
		else
			turning[unitID] = nil
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
end

local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")
function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local ud = UnitDefs[unitDefID]
	if cmdID ~= CMD.SET_WANTED_MAX_SPEED and cmdID ~= CMD_JUMP and cmdID ~= CMD.INSERT and turning[unitID] and turning[unitID].numFrames then
		--Spring.Echo("T1", cmdID)
		if not cmdOptions["shift"] then
			--Spring.Echo("T2")
			StopTurn(unitID) -- Abort turn if another command issued directly (not queued)
		end
	elseif cmdID == CMD_TURN then
		--Spring.Echo("CMD_TURN Allow")
		return ud.customParams.hasturnbutton
	end
	return true
end

function gadget:CommandFallback(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
	local ud = UnitDefs[unitDefID]
	if cmdID == CMD_TURN then
		--Spring.Echo("CMD_TURN Fallback")
		if turning[unitID] == nil then
			local tx, _, tz = cmdParams[1], cmdParams[2], cmdParams[3]
			local canTurn = StartTurn(unitID, unitDefID, tx, tz)
			return canTurn, false -- start turn and continue
		else
			if turning[unitID].numFrames and turning[unitID].numFrames > 0 then
				return true, false -- still turning
			else
				StopTurn(unitID)
				--Spring.Echo("Deleting turn data")
				turning[unitID] = nil
				GG.turning[unitID] = false
				return true, true -- turn finished
			end
		end
	end
	return false
end

else
-- UNSYNCED

function gadget:Initialize()
	Spring.SetCustomCommandDrawData(SYNCED.CustomCommandIDs["CMD_TURN"], "Patrol", {0,1,0,.8})
	--Spring.SendCommands({"bind r turn"})
end

end
