-- Custom anims & functions for Union
local numGears = #gears

function WeaponCanFire(weaponID)
	if missileWeaponIDs[weaponID] then return stage == 4
	else return true
	end
end

function Setup()
	-- Put pieces into starting pos
	Turn(vExhaustLarges[1], x_axis, math.rad(90), 0)
	for i = 1, info.numVExhausts do
		Turn(vExhausts[i], x_axis, math.rad(90), 0)
	end
	-- Legs Setup
	for i = 1,info.numGears do
		local angle = (i == 2 or i == 3) and rad(45) or rad(225)
		local angleDir = i % 2 == 0 and angle or -angle
		local angle2 = rad(80)
		Turn(gears[i].door, y_axis, angleDir)
		Turn(gears[i].joint, y_axis, angleDir)
		Turn(gears[i].joint, x_axis, angle2)
		Move(gears[i].joint, y_axis, -13)
	end
	-- weapon pieces too
	for id, turret in pairs(turrets) do
		Turn(turret, y_axis, math.rad(-45 * id))
	end
	-- 1, 3, 5, 7 -> 2n - 1, .'. (id + 1)/2
	for id, trackEmitter in pairs(trackEmitters) do
		Turn(trackEmitter, y_axis, math.rad(90 * ((id + 1)/2 - 1)))
	end
end

function LandingGearDown() 
	-- anims are similar to Overload, numGears easily parameterised but...
	-- but angles and speeds differ as well
	SPEED = math.rad(60) -- 40
	for i = 1, numGears do -- Doors open
		Turn(gears[i].door, x_axis, math.rad(60), SPEED * 5)
	end
	WaitForTurn(gears[numGears].door, x_axis)
	Sleep(2500)
	for i = 1, numGears do -- feet into deploy position
		Turn(gears[i].joint, x_axis, math.rad(5), SPEED)
	end
	WaitForTurn(gears[numGears].joint, x_axis)
	for i = 1, numGears do -- joint and feet rotate out
		Turn(gears[i].joint, x_axis, math.rad(-80), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(50), SPEED)
	end
	WaitForTurn(gears[numGears].joint, x_axis)
	for i = 1, numGears do -- joint raises and locks into position
		Move(gears[i].joint, y_axis, 0, 15)
		Turn(gears[i].joint, x_axis, math.rad(-115), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(85), SPEED)
	end
	WaitForTurn(gears[numGears].gear, x_axis)
	Turn(piece("missile_doors"), y_axis, math.rad(16), math.rad(4))
end

function DeployWeapons(out)
	-- no-op for Union
end

function LandingGearUp()
	-- custom for same reason as LandingGearDown
	Turn(piece("missile_doors"), y_axis, 0, math.rad(4))
	SPEED = math.rad(40)

	for i = 1, numGears do -- joint lowers and unlocks
		Move(gears[i].joint, y_axis, -13, 15)
		Turn(gears[i].joint, x_axis, math.rad(-80), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(50), SPEED)
	end
	WaitForTurn(gears[numGears].gear, x_axis)
	for i = 1, numGears do -- joint and feet rotate in
		Turn(gears[i].joint, x_axis, math.rad(5), SPEED)
		Turn(gears[i].gear, x_axis, 0, SPEED)
	end
	WaitForTurn(gears[numGears].joint, x_axis)
	for i = 1, numGears do -- feet into stowed position
		Turn(gears[i].joint, x_axis, math.rad(80), SPEED)
	end	
	for i = 1, numGears do -- Doors close
		Turn(gears[i].door, x_axis, 0, SPEED)
	end
	WaitForTurn(gears[numGears].door, x_axis)
	--Spring.Echo("ROCKET FULL ASCENT BURN NOW!")
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
end

-- Global to be picked up by functions in the include, what could go wrong?
-- (Sorry hokomoko)
BURN_HEIGHT = 3500
APPROACH_HEIGHT = 925
V_START = -60
V_BURNSTART = -40
V_BURNEND = -1
CONVERSION = 30 * 30 / 130
include ("anims/dropships/common.lua")

-- CARGO CODE
local link, pad, main_door, hanger_door, vtol_pad = piece ("link", "pad", "main_door", "hanger_door", "vtol_pad")

local WAIT_TIME = 10000
local DOOR_SPEED = math.rad(90)
local x, _ ,z = Spring.GetUnitPosition(unitID)
--local dx, _, dz = Spring.GetUnitDirection(unitID)
local dirAngle = HEADING / 2^16 * 2 * math.pi
local dx = math.sin(dirAngle)
local dz = math.cos(dirAngle)
local UNLOAD_X = x + 300 * dx
local UNLOAD_Z = z + 300 * dz

function UnloadCargo()
	-- has some custom moves and turns so for not common for now
	-- but should be doable later without too much hassle
	PlaySound("dropship_dooropen")
	Turn(main_door, x_axis, math.rad(110), DOOR_SPEED)
	Turn(hanger_door, y_axis, math.rad(90), DOOR_SPEED * 0.5)
	Turn(link, x_axis, math.rad(35), DOOR_SPEED * 10)
	Turn(vtol_pad, y_axis, math.rad(90), DOOR_SPEED * 10)
	WaitForTurn(main_door, x_axis)
	
	for i, cargoID in ipairs(cargo) do
		Move(link, z_axis, 0)
		Move(pad, z_axis, 0)
		Turn(pad, x_axis, math.rad(-35))
		Move(vtol_pad, x_axis, 0)

		WaitForMove(link, z_axis)
		WaitForMove(pad, z_axis)
		
		-- start cargo moving anim
		env = Spring.UnitScript.GetScriptEnv(cargoID)
		if env and env.script and env.script.StartMoving then -- TODO: shouldn't be required, maybe if cargo died?
			Spring.UnitScript.CallAsUnit(cargoID, env.script.StartMoving, false)
		end
		
		-- attach and move
		local currUnitDef = UnitDefs[Spring.GetUnitDefID(cargoID)]
		local buildTime = currUnitDef.buildTime

		if currUnitDef.canFly then
			Spring.UnitScript.AttachUnit(vtol_pad, cargoID)
			Move(vtol_pad, x_axis, 128, 64)
			WaitForMove(vtol_pad, x_axis)
			Spring.SetUnitVelocity(cargoID, 8, 4, 0)
		else
			Spring.UnitScript.AttachUnit(pad, cargoID)
			local moveSpeed = currUnitDef.speed * 0.8 -- 1.2
			Move(link, z_axis, 73, moveSpeed)
			WaitForMove(link, z_axis)
			Move(pad, z_axis, 100, moveSpeed)
			WaitForMove(pad, z_axis)
		end
		Spring.UnitScript.DropUnit(cargoID)
		Spring.SetUnitBlocking(cargoID, true, true, true, true, true, true, true)
		if currUnitDef.canFly then
			Spring.GiveOrderToUnit(cargoID, CMD.MOVE, {TX + 256, 0, Z}, {})
		else
			Spring.SetUnitMoveGoal(cargoID, UNLOAD_X +  math.random(-100, 100), 0, UNLOAD_Z +  math.random(-100, 100), 25) -- bug out over here
		end
		Sleep(2000)
	end
	StartThread(DeployWeapons, false)
	PlaySound("dropship_doorclose")
	Turn(main_door, x_axis, 0, DOOR_SPEED/2)
	Turn(hanger_door, y_axis, 0, DOOR_SPEED/2)
	WaitForTurn(hanger_door, y_axis)
	WaitForTurn(main_door, x_axis)
	Sleep(WAIT_TIME)
	TakeOff()
end