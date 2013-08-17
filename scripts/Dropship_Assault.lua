--pieces
local body = piece ("body")
local cargo = piece ("cargo")

-- Constants
local DROP_HEIGHT = 10000
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

function LoadCargo(outpostID)
	Spring.Echo("Loading", outpostID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	cargoID = outpostID
	Spring.UnitScript.AttachUnit(cargo, cargoID)
end

function fx()

end

function script.Create()
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX + UX, TY + DROP_HEIGHT, TZ + UZ)
	local newAngle = math.atan2(UX, UZ)
	Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
	
	Turn(body, x_axis, math.rad(-45))
	Turn(body, x_axis, 0, math.rad(5))
	Spring.MoveCtrl.SetVelocity(unitID, 0, -100, 0)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 10)
	
	Spring.MoveCtrl.SetGravity(unitID, -3.80 * GRAVITY)
	
	local x, y, z = Spring.GetUnitPosition(unitID)
	while y - TY > 200 do
		x, y, z = Spring.GetUnitPosition(unitID)
		Sleep(100)
	end
	--Spring.Echo("At 500?", y - TY)
	Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
	Spring.MoveCtrl.SetGravity(unitID, 0)
	local x, _, _ = Spring.GetUnitPosition(unitID)
	local dist = math.abs(x - TX)
	while dist > 1 do
		--Spring.Echo("dist", dist)
		x, _, z = Spring.GetUnitPosition(unitID)
		dist = math.abs(x - TX)
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, math.max(dist/50, 2))
		Sleep(30)
	end
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 0)
	_, y, _ = Spring.GetUnitPosition(unitID)
	Move(cargo, y_axis, -(y - TY), 20)
	WaitForMove(cargo, y_axis)
	Spring.UnitScript.DropUnit(cargoID)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 1, 4)
	Turn(body, x_axis, math.rad(-80), math.rad(15))
	WaitForTurn(body, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
	Sleep(2500)
	Spin(body, z_axis, math.rad(360), math.rad(90))
	Sleep(1000)
	StopSpin(body, z_axis, math.rad(90))
end

function script.Killed(recentDamage, maxHealth)
end
