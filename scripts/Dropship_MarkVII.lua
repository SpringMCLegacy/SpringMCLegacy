--pieces
local body = piece ("body")
local link, pad = piece ("cargo", "pad")
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
local HOVER_HEIGHT = 43 + 12.5
local DROP_HEIGHT = 10000 + HOVER_HEIGHT
local GRAVITY = 120 / Game.gravity
local TX, TY, TZ = Spring.GetUnitPosition(unitID)
local RADIAL_DIST = 2500
local ANGLE = math.rad(math.random(0, 5) * 60 + 30)

local UX --= math.cos(ANGLE) * RADIAL_DIST
local UZ --= math.sin(ANGLE) * RADIAL_DIST

-- Variables
local stage = 0
local touchDown = false
local cargoID
local beaconID

local cargo = {}
local numCargo = 0

function LoadCargo(cargoID, callerID)
	beaconID = callerID
	--Spring.Echo("Loading", outpostID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	Spring.UnitScript.AttachUnit(-1, cargoID)
	numCargo = numCargo + 1
	cargo[numCargo] = cargoID
end


function UnloadCargo()
	for i, cargoID in ipairs(cargo) do
		Move(link, z_axis, 0)
		Move(pad, z_axis, 0)
		Turn(link, x_axis, 0)
		Sleep(30)
		
		-- start cargo moving anim
		env = Spring.UnitScript.GetScriptEnv(cargoID)
		if env and env.script and env.script.StartMoving then -- TODO: shouldn't be required, maybe if cargo died?
			Spring.UnitScript.CallAsUnit(cargoID, env.script.StartMoving, false)
		end
		
		Spring.UnitScript.AttachUnit(pad, cargoID)
		Move(link, z_axis, 90, UnitDefs[Spring.GetUnitDefID(cargoID)].speed / 2) -- 50
		WaitForMove(link, z_axis)
		if not UnitDefs[Spring.GetUnitDefID(cargoID)].canFly then
			Turn(link, x_axis, math.rad(20), math.rad(20))
			WaitForTurn(link, x_axis)
			Move(pad, z_axis, 30, UnitDefs[Spring.GetUnitDefID(cargoID)].speed / 2)
			WaitForMove(pad, z_axis)
		end
		Spring.UnitScript.DropUnit(cargoID)
	end
end

local function fx()
	Signal(fx)
	SetSignalMask(fx)

	if stage == 0 then
		GG.EmitLupsSfx(unitID, "dropship_hull_heat", body, {repeatEffect = 3})
		GG.EmitLupsSfx(unitID, "dropship_hull_heat", body, {repeatEffect = 3, delay = 10})
		GG.EmitLupsSfx(unitID, "dropship_hull_heat", body, {repeatEffect = 2, delay = 20})
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 40})
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust",  exhaust, {id = "hExhaustsJets", repeatEffect = true, width = 30, length = 150})
		end
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", width = 65, length = 115})
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets", width = 50, length = 95})
		end
	end
	while stage == 0 do
		Sleep(30)
	end
	if stage == 1 then
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		GG.RemoveLupsSfx(unitID, "hExhaustsJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust, {delay = 40})
			GG.BlendJet(99, unitID, exhaust, "hExhaustsJets", 7, 30)
		end
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", replace = true, width = 40, length = 90})
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets", width = 25, length = 70})
		end
	end
	while stage == 1 do
		Sleep(30)
	end
	if stage == 2 then
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.BlendJet(99, unitID, exhaust, "vExhaustsJets")
		end
	end
	while stage == 2 do
		Sleep(30)
	end
	if stage == 3 then
		--[[for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust",  exhaust, {id = "hExhaustsJets", repeatEffect = true, width = 7, length = 30})
		end]]
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets"})
		end
		GG.EmitLupsSfx(unitID, "exhaust_ground_winds", body, {repeatEffect = 4, delay = 125})
		GG.EmitLupsSfx(unitID, "exhaust_ground_winds", body, {repeatEffect = 4, delay = 125 + 80})
	end
	while stage == 3 do
		--SpawnCEG("dropship_heavy_dust", TX, TY, TZ)
		Sleep(30)
	end
	if stage == 4 then
		GG.RemoveLupsSfx(unitID, "hExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargeJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 40})
		end
		local time = 114
		for t = 0, (time/3) do
			local i = t / (time/3)
			for _, exhaust in ipairs(hExhausts) do
				if (i == 1) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", repeatEffect = true, delay = t*3, width = 110, length = 350})
				elseif (i > 0.33) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", life = 2, delay = t*3, width = i * 110, length = i * 350})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", life = 1, delay = t*3+2, width = i * 100, length = i * 300})
				else
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", life = 1, delay = t*3,   width = i * 110, length = i * 350})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", life = 2, delay = t*3+1, width = i * 80, length = i * 190})
				end
			end
		end
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", length = 80, width = 45})
		end
		for i, exhaust in ipairs(vExhausts) do
			if (i % 2 == 1) then
				GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets", length = 85, width = 55})
			else
				GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets"})
			end
		end
	end
	while stage == 4 do
		Sleep(30)
	end
	if stage == 5 then
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
	end
	while stage == 5 do
		for _, exhaust in ipairs(hExhausts) do
			EmitSfx(exhaust, SFX.CEG + 2)
			EmitSfx(exhaust, SFX.CEG + 3)
		end
		Sleep(30)
	end
end

function script.Create()
	Spring.SetUnitNoSelect(unitID, true)
	StartThread(fx)
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
	Spring.MoveCtrl.SetPosition(unitID, TX, TY + DROP_HEIGHT, TZ)
	while not beaconID do Sleep(30) end
	local x,y,z = Spring.GetUnitDirection(beaconID)
	local x1,y1,z1 = Spring.GetUnitRotation(beaconID)
	--Spring.Echo("VPad angle is", math.deg(math.atan(x,z)), math.deg(y1))
	ANGLE = --[[ANGLE + math.atan(x,z)]] y1 + math.rad(30)--+ math.rad((math.floor(math.random(0, 5)) * 60) + 30)
	ANGLE = ANGLE + math.rad(math.random(0, 5) * 60)
	--Spring.Echo("My angle is", math.deg(ANGLE))
	UX = math.cos(ANGLE) * RADIAL_DIST
	UZ = math.sin(ANGLE) * RADIAL_DIST
	TX = TX + math.cos(ANGLE) * 73
	TZ = TZ + math.sin(ANGLE) * 73
	Spring.MoveCtrl.SetPosition(unitID, TX + UX, TY + DROP_HEIGHT, TZ + UZ)
	local newAngle = math.atan2(UX, UZ)
	Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
	Turn(body, x_axis, math.rad(-50))
	-- Begin the drop
	Turn(body, x_axis, math.rad(-10), math.rad(5))
	Spring.MoveCtrl.SetVelocity(unitID, 0, -100, 0)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 10)
	Spring.MoveCtrl.SetGravity(unitID, -3.78 * GRAVITY)
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
		--Spring.Echo(y - TY, 50 + HOVER_HEIGHT)
	end
	-- Descent complete, move over the target
	Turn(body, x_axis, 0, math.rad(3.5))
	if not cargoDoor1 then
		local lwing, rwing = piece("lwing", "rwing")
		Turn(lwing, z_axis, math.rad(100), math.rad(30))
		Turn(rwing, z_axis, math.rad(-100), math.rad(30))
		--WaitForTurn(rwing, z_axis)
	end
	Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
	Spring.MoveCtrl.SetGravity(unitID, 0)
	local dist = GetUnitDistanceToPoint(unitID, TX, GZ, TZ, false)
	while dist > 1 do
		dist = GetUnitDistanceToPoint(unitID, TX, GZ, TZ, false)
		--Spring.Echo("dist", dist)
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, math.max(dist/50, 2))
		Sleep(30)
	end
	-- We're over the target area, reduce height!
	stage = 3
	local DOOR_SPEED = math.rad(60)
	if cargoDoor1 then
		Turn(cargoDoor1, z_axis, math.rad(-90), DOOR_SPEED)
		Turn(cargoDoor2, z_axis, math.rad(90), DOOR_SPEED)
	end
	local vertSpeed = 1
	local wantedHeight = TY + HOVER_HEIGHT
	local dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
	while (dist > 0) do
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, -math.max(0.33, vertSpeed * (dist/HOVER_HEIGHT)), 0)
		Sleep(10)
		dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
	end
	-- We're in place. Halt and lower the cargo!
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 0)
	_, y, _ = Spring.GetUnitPosition(unitID)
	local BOOM_LENGTH = y - TY - 56
	local BOOM_SPEED = 15
	Move(attachment, y_axis, -(cargoDoor1 and 56 or 30), BOOM_SPEED)
	WaitForMove(attachment, y_axis)
	if #cargo > 0 then -- might be empty on /give testing
		UnloadCargo()
	else
		Sleep(2000)
	end
	-- Cargo is down, close the doors!
	Move(attachment, y_axis, 0, BOOM_SPEED)
	--WaitForMove(attachment, y_axis)

	while (dist < HOVER_HEIGHT + 20) do
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, math.max(0.33, vertSpeed * (dist/HOVER_HEIGHT)), 0)
		Sleep(10)
		dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
	end
	if booms[2] then
		for i = 2, 3 do
			Move(booms[i], y_axis, 0, BOOM_SPEED * 2)
		end
		WaitForMove(booms[3], y_axis)
	else
		local lwing, rwing = piece("lwing", "rwing")
		Turn(lwing, z_axis, math.rad(0), DOOR_SPEED/3)
		Turn(rwing, z_axis, math.rad(0), DOOR_SPEED/3)
		WaitForTurn(rwing, z_axis)
	end
	if cargoDoor1 then
		Turn(cargoDoor1, z_axis, 0, DOOR_SPEED)
		Turn(cargoDoor2, z_axis, 0, DOOR_SPEED)
		WaitForTurn(cargoDoor2, z_axis)
	end
	-- Take off!
	stage = 4
	--Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetGravity(unitID, -0.75 * GRAVITY)
	Turn(body, x_axis, math.rad(-30), math.rad(10))
	WaitForTurn(body, x_axis)
	Turn(body, x_axis, math.rad(-70), math.rad(15))
	WaitForTurn(body, x_axis)
	Turn(body, x_axis, math.rad(-80), math.rad(5))
	WaitForTurn(body, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
	stage = 5
	Sleep(1500)
	Spin(body, z_axis, math.rad(180), math.rad(45))
	Sleep(2000)
	StopSpin(body, z_axis, math.rad(45))
	Sleep(2000)
	-- We're out of the atmosphere, bye bye!
	GG.LCLeft(beaconID, teamID) -- let the world know
	Spring.DestroyUnit(unitID, false, true)
end

function script.Killed(recentDamage, maxHealth)
end
