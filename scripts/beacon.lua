--pieces
local base = piece ("base")
local dirt = piece ("dirt")
local rocket = piece("rocket")

local flap1 = piece("flap1")
local flap2 = piece("flap2")
local flap3 = piece("flap3")
local flap4 = piece("flap4")

local antenna1 = piece("antenna1")
local antenna2 = piece("antenna2")
local antenna3 = piece("antenna3")
-- includes
falling = false


function fx()
	while falling do
		EmitSfx(rocket, SFX.CEG)
		Sleep(5)
	end
end

function script.Create()
	Hide(dirt)
	Move(base, y_axis, 3750, 0)
	WaitForMove(base, y_axis)
	Spin(base, y_axis, math.rad(360), -math.rad(40))
	Move(base, y_axis, 0, 875)
	falling = true
	StartThread(fx)
	WaitForMove(base, y_axis)
	falling = false
	Show(dirt)
	StopSpin(base, y_axis)
	Hide(rocket)
	Explode(rocket, SFX.FIRE + SFX.SMOKE)
	Sleep(1500)
	Turn(flap1, x_axis, -math.rad(60), math.rad(45))
	Turn(flap2, z_axis, -math.rad(60), math.rad(45))
	Turn(flap3, x_axis, math.rad(60), math.rad(45))
	Turn(flap4, z_axis, math.rad(60), math.rad(45))
	WaitForTurn(flap4, z_axis)
	Sleep(800)
	Move(antenna1, y_axis, 4, 2)
	WaitForMove(antenna1, y_axis)
	Move(antenna2, y_axis, 4, 2)
	WaitForMove(antenna2, y_axis)
	Sleep(500)
	Move(antenna3, y_axis, 12, 48)
	WaitForMove(antenna3, y_axis)
end

function script.Killed(recentDamage, maxHealth)
end
