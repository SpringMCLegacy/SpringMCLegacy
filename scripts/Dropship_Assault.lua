--pieces
local body = piece ("body")
local cargo = piece ("cargo")
local cargoDoor1, cargoDoor2 = piece("cargodoor1", "cargodoor2")

local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
-- Constants
local HOVER_HEIGHT = 300
local DROP_HEIGHT = 10000 + HOVER_HEIGHT
local GRAVITY = 120 / Game.gravity
local TX, TY, TZ = Spring.GetUnitPosition(unitID)
local RADIAL_DIST = 2500
local ANGLE = math.floor(unitID / 100)
local UX = math.cos(ANGLE) * RADIAL_DIST
local UZ = math.sin(ANGLE) * RADIAL_DIST

-- Variables
local stage
local touchDown = false
local cargoID
local beaconID

function LoadCargo(callerID, outpostID)
	--Spring.Echo("Loading", outpostID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	beaconID = callerID
	cargoID = outpostID
	Spring.UnitScript.AttachUnit(cargo, cargoID)
end

function fx()

end

function script.Create()
	-- Move us up to the drop position
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX + UX, TY + DROP_HEIGHT, TZ + UZ)
	local newAngle = math.atan2(UX, UZ)
	Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
	Turn(body, x_axis, math.rad(-45))
	-- Begin the drop
	Turn(body, x_axis, 0, math.rad(5))
	Spring.MoveCtrl.SetVelocity(unitID, 0, -100, 0)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 10)
	Spring.MoveCtrl.SetGravity(unitID, -3.78 * GRAVITY)
	
	local x, y, z = Spring.GetUnitPosition(unitID)
	while y - TY > 150 + HOVER_HEIGHT do
		x, y, z = Spring.GetUnitPosition(unitID)
		local newAngle = math.atan2(x - TX, z - TZ)
		Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
		Sleep(100)
	end
	-- Descent complete, move over the target
	Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
	Spring.MoveCtrl.SetGravity(unitID, 0)
	local dist = GetUnitDistanceToPoint(unitID, TX, 0, TZ, false)
	while dist > 1 do
		dist = GetUnitDistanceToPoint(unitID, TX, 0, TZ, false)
		--Spring.Echo("dist", dist)
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, math.max(dist/50, 2))
		Sleep(30)
	end
	-- We're over the target area, reduce height!
	local DOOR_SPEED = math.rad(60)
	Turn(cargoDoor1, z_axis, math.rad(-90), DOOR_SPEED)
	Turn(cargoDoor2, z_axis, math.rad(90), DOOR_SPEED)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, -2, 0)
	Sleep(HOVER_HEIGHT / 2 * 33)
	-- We're in place. Halt and lower the cargo!
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 0)
	_, y, _ = Spring.GetUnitPosition(unitID)
	Move(cargo, y_axis, -(y - TY), 20)
	WaitForMove(cargo, y_axis)
	Spring.UnitScript.DropUnit(cargoID)
	-- Let the cargo know it is unloaded
	env = Spring.UnitScript.GetScriptEnv(cargoID)
	Spring.UnitScript.CallAsUnit(cargoID, env.Unloaded)
	-- Let the beacon know upgrade is ready
	env = Spring.UnitScript.GetScriptEnv(beaconID)
	Spring.UnitScript.CallAsUnit(beaconID, env.ChangeType, true)
	-- Cargo is down, close the doors!
	--[[for legPiece in pairs(legs) do
		Move(legPiece, y_axis, 0, LEG_SPEED)
	end
	WaitForMove(legs[8], y_axis)]]
	Turn(cargoDoor1, z_axis, 0, DOOR_SPEED)
	Turn(cargoDoor2, z_axis, 0, DOOR_SPEED)
	WaitForTurn(cargoDoor2, z_axis)
	-- Take off!
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetGravity(unitID, -0.75 * GRAVITY)
	Turn(body, x_axis, math.rad(-80), math.rad(15))
	WaitForTurn(body, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
	Sleep(1500)
	Spin(body, z_axis, math.rad(180), math.rad(45))
	Sleep(2000)
	StopSpin(body, z_axis, math.rad(45))
	Sleep(2000)
	-- We're out of the atmosphere, bye bye!
	Spring.DestroyUnit(unitID, false, true)
	Spring.Echo("toodlepip!")
end

function script.Killed(recentDamage, maxHealth)
end
