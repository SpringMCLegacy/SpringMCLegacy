-- $Id: unit_jumpjets.lua 4056 2009-03-11 02:59:18Z quantum $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Jumpjets",
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

local CMD_JUMP = 38521
-- needed for checks
local CMD_MORPH = 31210

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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local jumpDefNames  = VFS.Include"LuaRules/Configs/jump_defs.lua"

local jumpDefs = {}
for name, data in pairs(jumpDefNames) do
  jumpDefs[UnitDefNames[name].id] = data
end
GG.jumpDefs = jumpDefs

local jumpCmdDesc = {
  id      = CMD_JUMP,
  type    = CMDTYPE.ICON_MAP,
  name    = 'Jump',
  cursor  = 'Attack',  -- add with LuaUI?
  action  = 'jump',
  tooltip = 'Jump to selected position.',
}

  
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

local function Jump(unitID, goal, cmdTag)
  goal[2]             = spGetGroundHeight(goal[1],goal[3])
  local start         = {spGetUnitBasePosition(unitID)}

  local fakeUnitID
  local unitDefID     = spGetUnitDefID(unitID)
  local jumpDef       = jumpDefs[unitDefID]
  local speed         = jumpDef.speed
  local delay    	  = jumpDef.delay
  local height        = jumpDef.height
  local reloadTime    = (jumpDef.reload or 0)*30
  local teamID        = spGetUnitTeam(unitID)
  
  local rotateMidAir  = jumpDef.rotateMidAir
  local cob 	 	  = jumpDef.cobscript
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
		spCallCOBScript( unitID, "BeginJump", 0)
      else
	    Spring.UnitScript.CallAsUnit(unitID,env.beginJump)
	  end
	if rotateMidAir then
	  mcSetRotation(unitID, 0, (startHeading - 2^15)/rotUnit, 0) -- keep current heading
      mcSetRotationVelocity(unitID, 0, turn/rotUnit*step, 0)
	end
  else
	if cob then
		spCallCOBScript( unitID, "PreJump", 0)
      else
		--Spring.UnitScript.CallAsUnit(unitID,env.preJump,turn,lineDist)
	  end
  end
  spSetUnitRulesParam(unitID,"jumpReload",0)

  local function JumpLoop()
  
    if delay > 0 then
      for i=delay, 1, -1 do
	    Sleep()
	  end
	  
	  if cob then
		spCallCOBScript( unitID, "BeginJump", 0)
      else
		Spring.UnitScript.CallAsUnit(unitID,env.beginJump)
	  end

	  if rotateMidAir then
	    mcSetRotation(unitID, 0, (startHeading - 2^15)/rotUnit, 0) -- keep current heading
        mcSetRotationVelocity(unitID, 0, turn/rotUnit*step, 0)
	  end
	  
	  --[[fakeUnitID = spCreateUnit(
	  "fakeunit_aatarget", start[1], start[2], start[3], "n", teamID)
	  mcEnable(fakeUnitID)
	  spSetUnitNoSelect(fakeUnitID, true)
	  spSetUnitBlocking(fakeUnitID, false)
	  spSetUnitNoDraw(fakeUnitID, true)
	  spSetUnitNoMinimap(fakeUnitID, true)]]
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
		--Spring.UnitScript.CallAsUnit(unitID,env.jumping)
	  end
	  
	  if (fakeUnitID) then mcSetPosition(fakeUnitID, x, y, z) end
      if (not halfJump and i > 0.5) then
		  if cob then
			spCallCOBScript( unitID, "HalfJump", 0)
		  else
		   -- Spring.UnitScript.CallAsUnit(unitID,env.halfJump)
		  end
        halfJump = true
      end
      Sleep()
    end

    if (fakeUnitID) then spDestroyUnit(fakeUnitID, false, true) end
    if cob then
	  spCallCOBScript( unitID, "EndJump", 0)
	else
	   Spring.UnitScript.CallAsUnit(unitID,env.endJump)
	end
    lastJump[unitID] = spGetGameSeconds()
    jumping[unitID] = false
	mcDisable(unitID)
	
		--mcSetPosition(unitID, start[1] + vector[1],start[2] + vector[2]-6,start[3] + vector[3])
    local oldQueue = spGetCommandQueue(unitID)
	
    ReloadQueue(unitID, oldQueue, cmdTag)
	
    local reloadTimeInv = 1/reloadTime
    for i=1, reloadTime do
      spSetUnitRulesParam(unitID,"jumpReload",i*reloadTimeInv)
      Sleep()
    end
  end
  
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


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:Initialize()
  Spring.SetCustomCommandDrawData(CMD_JUMP, "Attack", {0, 1, 0, 1})
  Spring.SendCommands({"bind j jump"})
  gadgetHandler:RegisterCMDID(CMD_JUMP)
  for _, unitID in pairs(Spring.GetAllUnits()) do
    gadget:UnitCreated(unitID, Spring.GetUnitDefID(unitID))
  end
end


function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  if (not jumpDefs[unitDefID]) then
    return
  end 
  local t = spGetGameSeconds()
  lastJump[unitID] = t
  spInsertUnitCmdDesc(unitID, jumpCmdDesc)
  spSetUnitRulesParam(unitID,"jumpReload",1)
end


function gadget:UnitDestroyed(unitID, unitDefID)
  lastJump[unitID]  = nil
end


function gadget:AllowCommand(unitID, unitDefID, teamID,
                             cmdID, cmdParams, cmdOptions)
  if (cmdID == CMD_JUMP and
      spTestBuildOrder(
          unitDefID, cmdParams[1], cmdParams[2], cmdParams[3], 1) == 0) then
      return true --false FIX ME!
  end
  -- do no allow morphing while jumping
  if (jumping[unitID] and GG.MorphInfo and cmdID >= CMD_MORPH and cmdID < CMD_MORPH+GG.MorphInfo["MAX_MORPH"]) then
    -- allow to queue
    if cmdOptions.shift then
      return true
    else
      return false
    end
  end
  return true -- allowed
end


function gadget:CommandFallback(unitID, unitDefID, teamID,    -- keeps getting 
                                cmdID, cmdParams, cmdOptions) -- called until
  if (not jumpDefs[unitDefID]) then
	return false
  end
  if (cmdID ~= CMD_JUMP) then      -- you remove the
	goalSet[unitID] = false
	return false  -- command was not used                     -- order
  end
  if (jumping[unitID]) then
    return true, false -- command was used but don't remove it
  end
  local x, y, z = spGetUnitBasePosition(unitID)
  local distSqr = GetDist2Sqr({x, y, z}, cmdParams)
  local jumpDef = jumpDefs[unitDefID]
  local range   = jumpDef.range
  local reload  = jumpDef.reload or 0
  local t       = spGetGameSeconds()

  if (distSqr < (range*range)) then
    local cmdTag = spGetCommandQueue(unitID,1)[1].tag
    if ((t - lastJump[unitID]) >= reload) then
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
  else
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
