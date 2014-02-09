--pieces
local body = piece ("body")
local cargo = piece ("cargo")
local cargoDoor1, cargoDoor2 = piece("cargodoor1", "cargodoor2")
local booms = {}
for i = 1, 3 do
	booms[i] = piece("boom" .. i)
end
local attachment = piece("attachment")
-- FX pieces
local vExhaustLarges = {}
for i = 1,2 do
	vExhaustLarges[i] = piece("vexhaustlarge" .. i)
end
local vExhausts = {}
for i = 1,4 do
	vExhausts[i] = piece("vexhaust" .. i)
end
local hExhausts = {}
for i = 1,3 do
	hExhausts[i] = piece("hexhaust" .. i)
end

-- Localisations
local SpawnCEG = Spring.SpawnCEG
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
local stage = 0
local touchDown = false
local cargoID
local beaconID

function LoadCargo(outpostID, callerID)
	--Spring.Echo("Loading", outpostID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	beaconID = callerID
	cargoID = outpostID
	Spring.UnitScript.AttachUnit(cargo, cargoID)
end

function fx()
	if stage == 0 then
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust2", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust2", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust",  exhaust, {repeatEffect = true, width = 30, length = 150, distortion = 0})
		end
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {replace = true, width = 65, length = 115, distortion = 0})
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {replace = true, width = 50, length = 95, distortion = 0})
		end
	end
	Sleep(30)
	if stage == 1 then
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {replace = true, width = 40, length = 90, distortion = 0})
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {replace = true, width = 25, length = 70, distortion = 0})
		end
	end
	while stage == 1 do
		Sleep(30)
	end
	if stage == 2 then
		for _, exhaust in ipairs(hExhausts) do
			GG.RemoveLupsSfx(unitID, exhaust)
		end
		local time = 99
		for t = 0, (time/3) do
			local i = 1 - t / (time/3)
			for _, exhaust in ipairs(hExhausts) do
				if (i == 0) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {repeatEffect = true, delay = t*3, width = 20, length = 60, distortion = 0})
				elseif (i > 0.33) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {life = 3, delay = t*3, width = 20 + i * 60, length = 60 + i * 190, distortion = 0})
				else
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {life = 1, delay = t*3,   width = 20 + i * 60, length = 60 + i * 190, distortion = 0})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {life = 2, delay = t*3+1, width = 20 + i * 40, length = 60 + i * 90, distortion = 0})
				end
			end
		end
	end
	while stage == 2 do
		Sleep(30)
	end
	if stage == 3 then
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.RemoveLupsSfx(unitID, exhaust)
		end
		for i, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {replace = true, distortion = 0})
		end
		GG.EmitLupsSfx(unitID, "exhaust_ground_winds", body, {repeatEffect = 4, delay = 135})
		GG.EmitLupsSfx(unitID, "exhaust_ground_winds", body, {repeatEffect = 4, delay = 135 + 80})
	end
	while stage == 3 do
		--SpawnCEG("dropship_heavy_dust", TX, TY, TZ)
		Sleep(30)
	end
	if stage == 4 then
		for _, exhaust in ipairs(hExhausts) do
			GG.RemoveLupsSfx(unitID, exhaust)
		end
		local time = 114
		for t = 0, (time/3) do
			local i = t / (time/3)
			for _, exhaust in ipairs(hExhausts) do
				if (i == 1) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {repeatEffect = true, delay = t*3, width = 110, length = 350, distortion = 0})
				elseif (i > 0.33) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {life = 2, delay = t*3, width = i * 110, length = i * 350, distortion = 0})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {life = 1, delay = t*3+2, width = i * 100, length = i * 300, distortion = 0})
				else
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {life = 1, delay = t*3,   width = i * 110, length = i * 350, distortion = 0})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {life = 2, delay = t*3+1, width = i * 80, length = i * 190, distortion = 0})
				end
			end
		end
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {replace = true, distortion = 0, length = 80, width = 45})
		end
		for i, exhaust in ipairs(vExhausts) do
			if (i % 2 == 1) then
				GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {replace = true, distortion = 0, length = 85, width = 55})
			end
		end
	end
	while stage == 4 do
		Sleep(30)
	end
	if stage == 5 then
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.RemoveLupsSfx(unitID, exhaust)
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.RemoveLupsSfx(unitID, exhaust)
		end
	end
	while stage == 5 do
		for _, exhaust in ipairs(hExhausts) do
			EmitSfx(exhaust, SFX.CEG + 2)
			EmitSfx(exhaust, SFX.CEG + 3)
		end
		GG.Delay.DelayCall(GG.LUPS.FlameShot, {unitID, unitDefID, _, nil}, 0)
		Sleep(30)
	end
end

function script.Create()
	Spring.SetUnitNoSelect(unitID, true)
	-- setup fx pieces
	for _, exhaust in ipairs(vExhaustLarges) do
		Turn(exhaust, x_axis, math.rad(89))
	end	
	for _, exhaust in ipairs(vExhausts) do
		Turn(exhaust, x_axis, math.rad(89))
	end	
	for _, exhaust in ipairs(hExhausts) do
		Turn(exhaust, y_axis, math.rad(180))
	end	
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
	StartThread(fx)
	local x, y, z = Spring.GetUnitPosition(unitID)
	while y - TY > 150 + HOVER_HEIGHT do
		x, y, z = Spring.GetUnitPosition(unitID)
		local newAngle = math.atan2(x - TX, z - TZ)
		Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
		if (y - TY) < 4 * HOVER_HEIGHT and stage == 0 then
			stage = 1
			StartThread(fx)
		elseif (y - TY) < 3 * HOVER_HEIGHT and stage == 1 then
			stage = 2
		end
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
	stage = 3
	local DOOR_SPEED = math.rad(60)
	Turn(cargoDoor1, z_axis, math.rad(-90), DOOR_SPEED)
	Turn(cargoDoor2, z_axis, math.rad(90), DOOR_SPEED)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, -2, 0)
	Sleep(HOVER_HEIGHT / 2 * 33)
	-- We're in place. Halt and lower the cargo!
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 0)
	_, y, _ = Spring.GetUnitPosition(unitID)
	local BOOM_LENGTH = y - TY - 56
	local BOOM_SPEED = 10
	Move(attachment, y_axis, -56, BOOM_SPEED)
	WaitForMove(attachment, y_axis)
	for i = 2, 3 do
		Move(booms[i], y_axis, -BOOM_LENGTH / 2, BOOM_SPEED)
	end
	WaitForMove(booms[3], y_axis)
	Sleep(1500)
	if cargoID then -- might be empty on /give testing
		Spring.UnitScript.DropUnit(cargoID)
		-- Let the cargo know it is unloaded
		env = Spring.UnitScript.GetScriptEnv(cargoID)
		Spring.UnitScript.CallAsUnit(cargoID, env.Unloaded)
		-- Let the beacon know upgrade is ready
		env = Spring.UnitScript.GetScriptEnv(beaconID)
		Spring.UnitScript.CallAsUnit(beaconID, env.ChangeType, true)
	end
	-- Cargo is down, close the doors!
	for i = 2, 3 do
		Move(booms[i], y_axis, 0, BOOM_SPEED * 2)
	end
	WaitForMove(booms[3], y_axis)
	Turn(cargoDoor1, z_axis, 0, DOOR_SPEED)
	Turn(cargoDoor2, z_axis, 0, DOOR_SPEED)
	WaitForTurn(cargoDoor2, z_axis)
	-- Take off!
	stage = 4
	--Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetGravity(unitID, -0.75 * GRAVITY)
	Turn(body, x_axis, math.rad(-80), math.rad(15))
	WaitForTurn(body, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
	stage = 5
	Sleep(1500)
	Spin(body, z_axis, math.rad(180), math.rad(45))
	Sleep(2000)
	StopSpin(body, z_axis, math.rad(45))
	Sleep(2000)
	-- We're out of the atmosphere, bye bye!
	Spring.DestroyUnit(unitID, false, true)
end

function script.Killed(recentDamage, maxHealth)
end
