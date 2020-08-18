-- $Id: unit_jumpjets.lua 4056 2009-03-11 02:59:18Z quantum $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Unit - Jumpjets",
    desc      = "Gives units the jump ability",
    author    = "quantum",
    date      = "May 14, 2008",
    license   = "GNU GPL, v2 or later",
    layer     = -2, --load before lusHelper
    enabled   = true  --  loaded by default?
  }
end

if (not gadgetHandler:IsSyncedCode()) then
  return false -- no unsynced code
end

Spring.SetGameRulesParam("jumpJets",1)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Proposed Command ID Ranges:
--
--    all negative:  Engine (build commands)
--       0 -   999:  Engine
--    1000 -  9999:  Group AI
--   10000 - 19999:  LuaUI
--   20000 - 29999:  LuaCob
--   30000 - 39999:  LuaRules
--

local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")
local CMD_TURN = GG.CustomCommands.GetCmdID("CMD_TURN")
-- needed for checks
--local CMD_MORPH = 31210

local Spring      = Spring
local MoveCtrl    = Spring.MoveCtrl
local coroutine   = coroutine
local Sleep       = coroutine.yield
local pairs       = pairs
local assert      = assert
local ipairs      = ipairs

local pi2    = math.pi*2
local random = math.random

local CMD_STOP = CMD.STOP

local AreTeamsAllied 	= Spring.AreTeamsAllied
local spGetHeadingFromVector = Spring.GetHeadingFromVector
local spGetUnitBasePosition  = Spring.GetUnitBasePosition
local spInsertUnitCmdDesc  = Spring.InsertUnitCmdDesc
local spSetUnitRulesParam  = Spring.SetUnitRulesParam
local spSetUnitNoMinimap   = Spring.SetUnitNoMinimap
local spGetCommandQueue    = Spring.GetCommandQueue
local spGiveOrderToUnit    = Spring.GiveOrderToUnit
local spSetUnitNoSelect    = Spring.SetUnitNoSelect
local spSetUnitBlocking    = Spring.SetUnitBlocking
local spSetUnitMoveGoal    = Spring.SetUnitMoveGoal
local spGetGroundHeight    = Spring.GetGroundHeight
local spTestBuildOrder     = Spring.TestBuildOrder
local spGetGameSeconds     = Spring.GetGameSeconds
local spGetUnitHeading     = Spring.GetUnitHeading
local spSetUnitNoDraw      = Spring.SetUnitNoDraw
local spCallCOBScript      = Spring.CallCOBScript
local spSetUnitNoDraw      = Spring.SetUnitNoDraw
local spGetUnitDefID       = Spring.GetUnitDefID
local spGetUnitTeam        = Spring.GetUnitTeam
local spDestroyUnit        = Spring.DestroyUnit
local spCreateUnit         = Spring.CreateUnit
local spSetUnitLeaveTracks = Spring.SetUnitLeaveTracks

-- added for BTL
local spGetUnitRulesParam  = Spring.GetUnitRulesParam

local jumpers = {} -- jumpers[unitDefID] = {range = number, height = number, speed = number}  
GG.jumpers = jumpers
local BASE_RELOAD = 10
local BASE_RANGE = 600
local BASE_HEIGHT = BASE_RANGE / 3
local DFA_ID = WeaponDefNames["dfa"].id

local mcSetRotationVelocity = MoveCtrl.SetRotationVelocity
local mcSetPosition         = MoveCtrl.SetPosition
local mcSetRotation         = MoveCtrl.SetRotation
local mcDisable             = MoveCtrl.Disable
local mcEnable              = MoveCtrl.Enable

local emptyTable = {}

local coroutines  = {}
local lastJump    = {}
local landBoxSize = 60
local jumps       = {}
local jumping     = {}
local goalSet	  = {}

-- Perk and Mods
local unitJumpDelays = {} -- unitID = delayTime
local unitDFADamages = {} -- unitID = mult
local unitJumpInstant = {} -- unitID = true
local unitMechanicalJumps = {} -- unitID = true
GG.unitMechanicalJumps = unitMechanicalJumps
local unitReinforcedLegs = {} -- unitID = true
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--local jumpDefNames  = VFS.Include("LuaRules/Configs/jump_defs.lua")

--[[local jumpDefs = {}
for name, data in pairs(jumpDefNames) do
  jumpDefs[UnitDefNames[name].id] = data
end]]
--GG.jumpDefs = jumpDefs

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function GetDist3(a, b)
  local x, y, z = (a[1] - b[1]), (a[2] - b[2]), (a[3] - b[3])
  return (x*x + y*y + z*z)^0.5
end


local function GetDist2Sqr(a, b)
  local x, z = (a[1] - b[1]), (a[3] - b[3])
  return (x*x + z*z)
end


local function Approach(unitID, cmdParams, range)
	spSetUnitMoveGoal(unitID, cmdParams[1],cmdParams[2],cmdParams[3], range)
end


local function StartScript(fn)
  local co = coroutine.create(fn)
  coroutines[#coroutines + 1] = co
end


local function ReloadQueue(unitID, queue, cmdTag)
  if (not queue) then
    return
  end

    local re = Spring.GetUnitStates(unitID)["repeat"]
	local storeParams
  --// remove finished command
	local start = 1
	if (queue[1])and(cmdTag == queue[1].tag) then
		start = 2 
		 if re then
			storeParams = queue[1].params
		end
	end

  spGiveOrderToUnit(unitID, CMD_STOP, emptyTable, emptyTable)
  for i=start,#queue do
    local cmd = queue[i]
    local cmdOpt = cmd.options
    local opts = {"shift"} -- appending
    if (cmdOpt.alt)   then opts[#opts+1] = "alt"   end
    if (cmdOpt.ctrl)  then opts[#opts+1] = "ctrl"  end
    if (cmdOpt.right) then opts[#opts+1] = "right" end
    spGiveOrderToUnit(unitID, cmd.id, cmd.params, opts)
  end
  
  if re and start == 2 then
	spGiveOrderToUnit(unitID, CMD_JUMP, {storeParams[1],Spring.GetGroundHeight(storeParams[1],storeParams[3]),storeParams[3]}, {"shift"} )
  end
  
end

-- Perk and Mod functions
local function SetUnitJumpDelay(unitID, delta)
	unitJumpDelays[unitID] = unitJumpDelays[unitID] + delta
end
GG.SetUnitJumpDelay = SetUnitJumpDelay

local function SetUnitJumpInstant(unitID, tOrF)
	unitJumpInstant[unitID] = tOrF
end
GG.SetUnitJumpInstant = SetUnitJumpInstant

local function SetUnitReinforcedLegs(unitID, tOrF)
	unitReinforcedLegs[unitID] = tOrF
end
GG.SetUnitReinforcedLegs = SetUnitReinforcedLegs

local function SetUnitMechanicalJump(unitID, tOrF)
	local jumpDef = jumpers[Spring.GetUnitDefID(unitID)]
	local range   = spGetUnitRulesParam(unitID, "jumpRange") or jumpDef.range
	local reload  = spGetUnitRulesParam(unitID, "jumpReload") or BASE_RELOAD
	Spring.SetUnitRulesParam(unitID, "jumpRange", tOrF and range/2 or 2*range)
	Spring.SetUnitRulesParam(unitID, "jumpReload", tOrF and 0.1 or BASE_RELOAD)
	unitMechanicalJumps[unitID] = tOrF
end
GG.SetUnitMechanicalJump = SetUnitMechanicalJump

local function Jump(unitID, goal, cmdTag)
  goal[2]             = spGetGroundHeight(goal[1],goal[3])
  local start         = {spGetUnitBasePosition(unitID)}

  local fakeUnitID
  local unitDefID     = spGetUnitDefID(unitID)
  local jumpDef       = jumpers[unitDefID]
  local speed         = Spring.GetUnitRulesParam(unitID, "jumpSpeed") or 10
  local delay    	  = unitJumpDelays[unitID] --how long unit stays crouched after anim_PreJump
  local height        = jumpDef.height
  local reloadTime    = (Spring.GetUnitRulesParam(unitID, "jumpReload") or (BASE_RELOAD))*30
  local teamID        = spGetUnitTeam(unitID)
  
  local rotateMidAir  = unitJumpInstant[unitID] --jumpDef.rotateMidAir Should be true for Perk to remove need to turn and face direction
  local cob 	 	  = false --jumpDef.cobscript
  local env

  local vector        = {goal[1] - start[1],
                         goal[2] - start[2],
                         goal[3] - start[3]}
  
  -- vertex of the parabola
  local vertex        = {start[1] + vector[1]*0.5,
                         start[2] + vector[2]*0.5 + (1-(2*0.5-1)^2)*height,
                         start[3] + vector[3]*0.5}
  
  local lineDist      = GetDist3(start, goal)
  if lineDist == 0 then lineDist = 0.00001 end
  local flightDist    = GetDist3(start, vertex) + GetDist3(vertex, goal)
  
  local speed         = speed * lineDist/flightDist
  local step          = speed/lineDist
  
  -- check if there is no wall in between
  local x,z = start[1],start[3]
  for i=0, 1, step do
    x = x + vector[1]*step
    z = z + vector[3]*step
    if ( (spGetGroundHeight(x,z) - 30) > (start[2] + vector[2]*i + (1-(2*i-1)^2)*height)) then
      return false -- FIXME: should try to use SetMoveGoal instead of jumping!
    end
  end

  -- pick shortest turn direction
  local rotUnit       = 2^16 / (pi2)
  local startHeading  = spGetUnitHeading(unitID) + 2^15
  local goalHeading   = spGetHeadingFromVector(vector[1], vector[3]) + 2^15
  if (goalHeading  >= startHeading + 2^15) then
    startHeading = startHeading + 2^16
  elseif (goalHeading  < startHeading - 2^15)  then
    goalHeading  = goalHeading  + 2^16
  end
  local turn = goalHeading - startHeading
  
  jumping[unitID] = true

  mcEnable(unitID)
  spSetUnitLeaveTracks(unitID, false)

  if not cob then
    env = Spring.UnitScript.GetScriptEnv(unitID)
  end
  
  if (delay == 0) then
	if cob then
		spCallCOBScript( unitID, "StartJump", 0)
      else
	    Spring.UnitScript.CallAsUnit(unitID,env.StartJump)
	  end
	if rotateMidAir then
	  mcSetRotation(unitID, 0, (startHeading - 2^15)/rotUnit, 0) -- keep current heading
      mcSetRotationVelocity(unitID, 0, turn/rotUnit*step, 0)
	end
  else
	if cob then
		spCallCOBScript( unitID, "PreJump", 0)
      else
		Spring.UnitScript.CallAsUnit(unitID,env.PreJump,delay,turn,lineDist)
	  end
  end
  spSetUnitRulesParam(unitID,"jump_reload_bar",0)
---------------------------------------------------------------
  local function JumpLoop()
  
    if delay > 0 then
      for i=delay, 1, -1 do
	    Sleep()
	  end
	  
	  if cob then
		spCallCOBScript( unitID, "StartJump", 0)
      else
		Spring.UnitScript.CallAsUnit(unitID,env.StartJump)
	  end

	  if rotateMidAir then
	    mcSetRotation(unitID, 0, (startHeading - 2^15)/rotUnit, 0) -- keep current heading
        mcSetRotationVelocity(unitID, 0, turn/rotUnit*step, 0)
	  end
	end
  
    local halfJump
    for i=0, 1, step do
      if ((not spGetUnitTeam(unitID)) and fakeUnitID) then
        spDestroyUnit(fakeUnitID, false, true)
        return -- unit died
      end
      local x = start[1] + vector[1]*i
      local y = start[2] + vector[2]*i + (1-(2*i-1)^2)*height -- parabola
      local z = start[3] + vector[3]*i
      mcSetPosition(unitID, x, y, z)
	  
	  if cob then
		spCallCOBScript(unitID, "Jumping", 1, i * 100)
	  else
		Spring.UnitScript.CallAsUnit(unitID,env.Jumping)
	  end
	  
	  if (fakeUnitID) then mcSetPosition(fakeUnitID, x, y, z) end
      if (not halfJump and i > 0.5) then
		  if cob then
			spCallCOBScript( unitID, "HalfJump", 0)
		  else
		    Spring.UnitScript.CallAsUnit(unitID,env.HalfJump)
		  end
        halfJump = true
      end
      Sleep()
    end

	lastJump[unitID] = spGetGameSeconds()
    jumping[unitID] = false
	mcDisable(unitID) -- need to disable ScriptMoveType before calling StopJump, 
	-- so that SetGroundMoveTypeData is called once regular movetype is restored
	
    if (fakeUnitID) then spDestroyUnit(fakeUnitID, false, true) end
    if cob then
	  spCallCOBScript( unitID, "StopJump", 0)
	else
	   Spring.UnitScript.CallAsUnit(unitID,env.StopJump)
	end
	
		--mcSetPosition(unitID, start[1] + vector[1],start[2] + vector[2]-6,start[3] + vector[3])
    local oldQueue = spGetCommandQueue(unitID, -1)
	
    ReloadQueue(unitID, oldQueue, cmdTag)
	
    local reloadTimeInv = 1/reloadTime
    for i=1, reloadTime do
      spSetUnitRulesParam(unitID,"jump_reload_bar",100*i*reloadTimeInv)
      Sleep()
    end
  end
---------------------------------------------------------------
  
  StartScript(JumpLoop)
  return true
end


-- a bit convoluted for this but might be           
-- useful for lua unit scripts
local function UpdateCoroutines()
  local newCoroutines = {} 
  for i=1, #coroutines do 
    local co = coroutines[i] 
    if (coroutine.status(co) ~= "dead") then 
      newCoroutines[#newCoroutines + 1] = co 
    end 
  end 
  coroutines = newCoroutines 
  for i=1, #coroutines do 
    assert(coroutine.resume(coroutines[i]))
  end
end

local function SetUnitDFADamage(unitID, mult)
	unitDFADamages[unitID] = unitDFADamages[unitID] * mult
end
GG.SetUnitDFADamage = SetUnitDFADamage

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
	-- DFA
	if weaponID == DFA_ID then
		--Spring.Echo("We got DFA", damage)
		if attackerID == unitID or AreTeamsAllied(attackerTeam, unitTeam) then return 0 end -- don't deal self damage via the engine
		local attackerDef = UnitDefs[attackerDefID]
		local applied = damage * attackerDef.health * 0.1 * unitDFADamages[attackerID] -- 10% of max HP
		local self = applied / (unitReinforcedLegs[attackerID] and 4 or 2)
		--Spring.Echo("We got DFA applied", damage, applied, self)
		local env = Spring.UnitScript.GetScriptEnv(attackerID)
		Spring.UnitScript.CallAsUnit(attackerID, env.script.HitByWeapon, 0, 0, DFA_ID, self, "llowerleg")
		Spring.UnitScript.CallAsUnit(attackerID, env.script.HitByWeapon, 0, 0, DFA_ID, self, "rlowerleg")
		return applied
	else
		return damage, 1
	end
end
		
		
function gadget:Initialize()
  Spring.AssignMouseCursor("Jump", "cursorjump", true, false)
  Spring.SetCustomCommandDrawData(CMD_JUMP, "Jump", {0, 1, 0, 1})
  --Spring.SendCommands({"bind j jump"})
  --gadgetHandler:RegisterCMDID(CMD_JUMP) -- auto-registered by GetCmdID()
  for _, unitID in pairs(Spring.GetAllUnits()) do
    gadget:UnitCreated(unitID, Spring.GetUnitDefID(unitID))
  end
  for unitDefID, unitDef in pairs(UnitDefs) do
	local jumpjets = unitDef.customParams.jumpjets
    if jumpjets then
		jumpers[unitDefID] = {range = 100 * jumpjets, height = 33 * jumpjets, speed = 6, reload = BASE_RELOAD}
	end
  end
  GG.jumpDefs = jumpers
end


function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  if (not jumpers[unitDefID]) then
    return
  end 
  local t = spGetGameSeconds()
  lastJump[unitID] = t - BASE_RELOAD
  unitJumpInstant[unitID] = false
  unitJumpDelays[unitID] = 40
  unitDFADamages[unitID] = 1

  spSetUnitRulesParam(unitID,"jump_reload_bar",100)
  spSetUnitRulesParam(unitID,"jumpReload", BASE_RELOAD)
  spSetUnitRulesParam(unitID,"jumpSpeed", jumpers[unitDefID].speed)
  spSetUnitRulesParam(unitID,"jumpRange", jumpers[unitDefID].range)
end


function gadget:UnitDestroyed(unitID, unitDefID)
  lastJump[unitID]  = nil
  unitJumpInstant[unitID] = nil
  unitJumpDelays[unitID] = nil
  unitDFADamages[unitID] = nil 
  unitMechanicalJumps[unitID] = nil
  unitReinforcedLegs[unitID] = nil
end


function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
  -- don't allow jumping if at/above critical heat
  if (cmdID == CMD_JUMP) then
    if (spGetUnitRulesParam(unitID, "heat") or 0) >= 50 then 
		Spring.SendMessageToTeam(teamID, "Can't jump - too hot!")
		return false 
	end -- can't jump if too hot
	if (unitMechanicalJumps[unitID] and spGetUnitRulesParam(unitID, "lostlegs") or 0) > 0 then 
		Spring.SendMessageToTeam(teamID, "Can't jump - leg disabled!")
		return false 
	end -- can't jump if a leg is disabled if we are using mechanical jump system mod
	
    local test = spTestBuildOrder(unitDefID, cmdParams[1], cmdParams[2], cmdParams[3], 1)
	if test < 1 then 
		Spring.SendMessageToTeam(teamID, "Can't jump - Invalid target destination!", test)
	end
    return test > 0
  else -- any other command
    if not cmdOptions.shift then goalSet[unitID] = false end
    return true
  end
end

--[[local function PrintCommands(unitID)
  for pos, command in pairs(Spring.GetUnitCommands(unitID)) do
     Spring.Echo("Command: " .. pos .. " is ID " .. command.id)
   end
end]]


local function TurnOrder(unitID, x, y, z)
	if (not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID) then return false end -- unit died
   --[[Spring.GiveOrderArrayToUnitArray(
     { unitID },
	 {
	   { CMD_JUMP, {x, y, z}, {"alt", "shift"} },
	   { CMD_TURN, {x, y, z}, {"alt", "shift"} },
	 }
   )]]
   --[[Spring.Echo("TurnOrder before inserting")
   PrintCommands(unitID)
   
   Spring.Echo("Now insert TURN")]]
   Spring.GiveOrderToUnit(unitID, CMD.INSERT, {0, CMD_TURN, CMD.OPT_ALT, x, y, z}, {"alt"})
   
   --Spring.Echo("Now insert JUMP")
   Spring.GiveOrderToUnit(unitID, CMD.INSERT, {1, CMD_JUMP, CMD.OPT_SHIFT, x, y, z}, {"alt"}) --options.ALT     -> treat param0 as a position instead of a tag 
   --[[PrintCommands(unitID)
   
   Spring.Echo("CMD_TURN: " .. CMD_TURN .. " CMD_JUMP: " .. CMD_JUMP)
   PrintCommands(unitID)]]
end


function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if (not jumpers[unitDefID]) then
		return false
	end
	if (cmdID ~= CMD_JUMP) then      -- you remove the
		goalSet[unitID] = false
		return false  -- command was not used                     -- order
	end
	if (jumping[unitID]) then
		return true, false -- command was used but don't remove it
	end
	if GG.turning[unitID] then
		return true, false
	end
	if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then return false, true end

	local x, y, z = spGetUnitBasePosition(unitID)
	local distSqr = GetDist2Sqr({x, y, z}, cmdParams)
	local jumpDef = jumpers[unitDefID]
	local range   = spGetUnitRulesParam(unitID, "jumpRange") or jumpDef.range
	local reload  = spGetUnitRulesParam(unitID, "jumpReload") or BASE_RELOAD
	local barFull = math.ceil(tonumber(spGetUnitRulesParam(unitID, "jump_reload_bar") or 100)) >= 100
	local t       = spGetGameSeconds()
  
	if (distSqr < (range*range)) then -- we are within jumping range
		-- Extra FLOZi code
		local dx, dz = cmdParams[1] - x, cmdParams[3] - z
		local MINIMUM_TURN = 10 * 182 -- How off-angle can mech be to still initiate a jump, Change to 360 for PERKIFY
		local newHeading = math.deg(math.atan2(dx, dz)) * 182 -- COB_ANGULAR	
		local currHeading = Spring.GetUnitCOBValue(unitID, COB.HEADING)
		local deltaHeading = newHeading - currHeading
		if math.abs(deltaHeading) < MINIMUM_TURN or unitJumpInstant[unitID] then
			-- don't have to turn, continue as normal
			local cmdTag = spGetCommandQueue(unitID,1)[1].tag
			-- reload perk can change reload before bar is full so check both
			if ((t - lastJump[unitID]) >= reload) and barFull then
				local coords = table.concat(cmdParams)
				if (not jumps[coords]) then
					if (not Jump(unitID, cmdParams, cmdTag)) then
						return true, true -- command was used, remove it 
					end
					jumps[coords] = 1
					return true, false -- command was used, remove it 
				else
					local r = landBoxSize*jumps[coords]^0.5/2
					local randpos = {
						cmdParams[1] + random(-r, r),
						cmdParams[2],
						cmdParams[3] + random(-r, r)}
					if (not Jump(unitID, randpos, cmdTag)) then
						return true, true -- command was used, remove it 
					end
					jumps[coords] = jumps[coords] + 1
					return true, false -- command was used, remove it 
				end
			end
		else -- need to turn
			if not GG.turning[unitID] then
				--Spring.Echo("not GG.turning")
				GG.Delay.DelayCall(TurnOrder, {unitID, cmdParams[1], cmdParams[2], cmdParams[3]}, 1)
			end
			return true, true
		end
	else -- out of range
		if not goalSet[unitID] then
			Approach(unitID, cmdParams, range)
			goalSet[unitID] = true
		end
	end
	return true, false -- command was used but don't remove it
end


function gadget:GameFrame(n)
  UpdateCoroutines()
end
