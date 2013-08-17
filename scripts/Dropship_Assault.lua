--pieces
local body = piece ("body")

-- Constants
local DROP_HEIGHT = 10000
local GRAVITY = 120 / Game.gravity
local TX, TY, TZ = Spring.GetUnitPosition(unitID)
local RADIAL_DIST = 2000
local ANGLE = unitID / 100
local UX = math.cos(ANGLE) * RADIAL_DIST
local UZ = math.sin(ANGLE) * RADIAL_DIST

-- Variables
local stage
local touchDown = false


function fx()

end


function script.Create()
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX + UX, TY + DROP_HEIGHT, TZ + UZ)

	local newHeading = math.deg(math.atan2(UX, UZ)) * 182 --COB_ANGULAR	
	Spring.SetUnitCOBValue(unitID, COB.HEADING, newHeading + 180 * 182)
	
	Turn(body, x_axis, math.rad(-45))
	Turn(body, x_axis, 0, math.rad(5))
	Spring.MoveCtrl.SetVelocity(unitID, 0, -100, 0)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 10)
	
	Spring.MoveCtrl.SetGravity(unitID, -3.75 * GRAVITY)
	--[[[Spring.MoveCtrl.SetCollideStop(unitID, true)
	Spring.MoveCtrl.SetTrackGround(unitID, true)
	
	stage = 3
	StartThread(fx)
	for i = 1, 4 do
		local _, sy, _ = Spring.GetUnitVelocity(unitID)
		PlaySound("NavBeacon_Descend", 10, 0,sy,0)
		Sleep(2500)
	end
	while not touchDown do
		Sleep(50)
	end
	
	stage = 2
	EmitSfx(dirt, SFX.CEG + 1)
	Show(dirt)
	StopSpin(base, y_axis)
	PlaySound("NavBeacon_Land", 30)
	Sleep(5400)
	
	stage = 1
	Hide(rocket)
	PlaySound("NavBeacon_Pop", 15)
	Explode(rocket, SFX.FIRE + SFX.SMOKE)
	Sleep(3500)
	Turn(flaps[1], x_axis, -math.rad(80), math.rad(20))
	Turn(flaps[2], z_axis, -math.rad(80), math.rad(20))
	Turn(flaps[3], x_axis, math.rad(80), math.rad(20))
	Turn(flaps[4], z_axis, math.rad(80), math.rad(20))
	WaitForTurn(flaps[4], z_axis)
	Sleep(800)
	Move(antenna1, y_axis, 4, 2)
	WaitForMove(antenna1, y_axis)
	Move(antenna2, y_axis, 4, 2)
	WaitForMove(antenna2, y_axis)
	Sleep(500)
	Move(antenna3, y_axis, 12, 48)
	WaitForMove(antenna3, y_axis)
	
	stage = 0
	StartThread(fx) -- restart for blink
	SetUnitValue(COB.INBUILDSTANCE, 1)]]
end

function script.Killed(recentDamage, maxHealth)
end
