--pieces
local crate_base, crate_top, crate_right, crate_left, crate_front, crate_back = piece ("crate_base", "crate_top", "crate_right", "crate_left", "crate_front", "crate_back")

local rad = math.rad
local CRATE_SPEED = math.rad(50)

function Unloaded(ry)
	StartThread(Unpack, ry)
end

function Sands()
	StartThread(BowOut)
end

function BowOut()
	-- Let the sands of time cover the crate
	Sleep(1500)
	local i = 1
	while Spring.GetUnitHealth(unitID) > 100 do
		Spring.AddUnitDamage(unitID, 50)
		Move(crate_base, y_axis, -i * 10 / 900, CRATE_SPEED * 2)
		i = i + 1
		Sleep(200)
	end
	Spring.DestroyUnit(unitID, false, true)
end

function Unpack(ry)
	Turn(crate_base, y_axis, (ry and ry - math.pi/2) or 0)
	-- Wait for delivery van to bug out
	Sleep(2000)
	-- Unpack the crate
	PlaySound("outpost_unbox")
	Turn(crate_front, x_axis, rad(45), CRATE_SPEED)
	Turn(crate_back, x_axis, rad(-45), CRATE_SPEED)
	Turn(crate_left, z_axis, rad(45), CRATE_SPEED)
	Turn(crate_right, z_axis, rad(-45), CRATE_SPEED)
	WaitForTurn(crate_right, z_axis)
	WaitForTurn(crate_left, z_axis)
	WaitForTurn(crate_back, x_axis)
	WaitForTurn(crate_front, x_axis)
	Turn(crate_front, x_axis, rad(90), CRATE_SPEED * 2)
	Turn(crate_back, x_axis, rad(-90), CRATE_SPEED * 2)
	Turn(crate_left, z_axis, rad(90), CRATE_SPEED * 2)
	Turn(crate_right, z_axis, rad(-90), CRATE_SPEED * 2)
	WaitForTurn(crate_right, z_axis)
	WaitForTurn(crate_left, z_axis)
	WaitForTurn(crate_back, x_axis)
	WaitForTurn(crate_front, x_axis)
	Turn(crate_top, z_axis, rad(-45), CRATE_SPEED)
	WaitForTurn(crate_top, z_axis)
	Turn(crate_top, z_axis, rad(-90), CRATE_SPEED * 2)
	--Sands()
end

function script.Create()
	--[[if not Spring.GetUnitTransporter(unitID) then
		Unloaded()
	end]]
end

function script.Killed(recentDamage, maxHealth)
end
