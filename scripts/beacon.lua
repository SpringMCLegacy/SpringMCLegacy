--pieces
local base = piece ("base")
local dirt = piece ("dirt")
local rocket = piece("rocket")
local blink = piece("blink")

local flaps = {}
for i = 1, 4 do
	flaps[i] = piece("flap" .. i)
end

local antenna1 = piece("antenna1")
local antenna2 = piece("antenna2")
local antenna3 = piece("antenna3")
-- includes
local stage


function fx()
	while stage == 3 do
		EmitSfx(rocket, SFX.CEG)
		Sleep(5)
	end
	local t = 1
	while stage == 2 do
		EmitSfx(rocket, SFX.BLACK_SMOKE)
		Sleep(20 * t)
		t = t + 5
	end
	while stage == 0 do
		Sleep(1000)
		PlaySound("NavBeacon_Beep")
		EmitSfx(blink, SFX.CEG + 2)
	end
end

function script.Create()
	Hide(dirt)
	Move(base, y_axis, 3750, 0)
	WaitForMove(base, y_axis)
	Sleep(unitID / 10) -- lolhack
	Spin(base, y_axis, math.rad(360), -math.rad(40))
	Move(base, y_axis, 0, 875)
	stage = 3
	PlaySound("NavBeacon_Descend") -- currently played at base
	StartThread(fx)
	WaitForMove(base, y_axis)
	stage = 2
	EmitSfx(base, SFX.CEG + 1)
	Show(dirt)
	StopSpin(base, y_axis)
	PlaySound("NavBeacon_Land", 30)
	Sleep(5400)
	stage = 1
	Hide(rocket)
	PlaySound("NavBeacon_Pop")
	Explode(rocket, SFX.FIRE + SFX.SMOKE)
	Sleep(3500)
	Turn(flaps[1], x_axis, -math.rad(60), math.rad(20))
	Turn(flaps[2], z_axis, -math.rad(60), math.rad(20))
	Turn(flaps[3], x_axis, math.rad(60), math.rad(20))
	Turn(flaps[4], z_axis, math.rad(60), math.rad(20))
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
end

function script.Killed(recentDamage, maxHealth)
end
