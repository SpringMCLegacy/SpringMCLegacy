-- Unit-specific pieces only declared here, generic dropship pieces in main script
local body = piece("body")
local DOOR_SPEED = math.rad(60)
local BOOM_SPEED = 15

function WeaponCanFire(weaponID)
	return not noFiring
end

function GetAngleFromTarget()
	if beaconID then
		ANGLE = select(2, Spring.GetUnitRotation(beaconID)) + math.rad(30) + math.rad(math.random(0, 5) * 60)
		UX = math.cos(ANGLE) * RADIAL_DIST
		UZ = math.sin(ANGLE) * RADIAL_DIST
	end
end

function Setup()
	--[[GetAngleFromTarget()
	-- Put pieces into starting pos
	Turn(vExhaustLarges[1], x_axis, math.rad(90), 0)
	for i = 1, info.numVExhausts do
		Turn(vExhausts[i], x_axis, math.rad(90), 0)
	end
]]
end

--[[function LandingGearDown()
end]]

function Crashed()
	local x,y,z = Spring.GetUnitPosition(unitID)
	for i = 1, 5 do
		Spring.SpawnCEG("dropship_heavy_dust", x,y,z)
	end
	Spring.SpawnCEG("mech_jump_dust", x,y,z)
	Sleep(3000)
	-- This is a really awful hack , built on top of another hack. 
	-- There's some issue with alwaysVisible not working (http://springrts.com/mantis/view.php?id=4483)
	-- So instead make the owner the decal unit spawned by the teams starting beacon, as it can never die
	local ownerID = Spring.GetTeamUnitsByDefs(teamID, UnitDefNames["decal_beacon"].id)[1] or unitID
	local nukeID = Spring.SpawnProjectile(WeaponDefNames["meltdown"].id, {pos = {x,y,z}, owner = ownerID, team = teamID, ttl = 20})
	Sleep(500)
	local lwing, rwing = piece("lwing", "rwing")
	Explode(lwing, SFX.FIRE + SFX.FALL)
	Explode(rwing, SFX.FIRE + SFX.FALL)
	Explode(body, SFX.SHATTER)
	-- delay next dropship by extra 60 seconds
	GG.LCLeft(beaconID, callerID, teamID, true)
	Spring.DestroyUnit(unitID, true, false)
end

function TouchDown()
	StartThread(Crashed)
	PlaySound("dropship_stomp")
end

--[[function LandingGearUp()
end]]

local fxStages = {

}

function fx()
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
			EmitSfx(exhaust, SFX.CEG)
			--EmitSfx(exhaust, SFX.CEG + 3)
		end
		Sleep(30)
	end	
end

function TakeOff()
	Signal(Drop)
	Signal(UnloadCargo)
	if stage > 3 then return end -- in case we are told to BugOut, ignore it if already exiting
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
	PlaySound("dropship_liftoff")
	stage = 4
	--Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
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
	--Spin(body, z_axis, math.rad(180), math.rad(45))
	Sleep(2000)
	--StopSpin(body, z_axis, math.rad(45))
	Sleep(2000)
	-- We're out of the atmosphere, bye bye!
	GG.LCLeft(beaconID, callerID, teamID) -- let the world know
	Spring.DestroyUnit(unitID, false, true)
end

function BugOut()
	StartThread(TakeOff)
end

function Drop()
	Signal(Drop)
	SetSignalMask(Drop)
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
	local lflap, rflap = piece("lflap", "rflap")
	Turn(lflap, x_axis, math.rad(45))
	Turn(rflap, x_axis, math.rad(45))
	-- Move us up to the drop position
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX, TY + DROP_HEIGHT, TZ)
	while not beaconID do Sleep(30) end
	GetAngleFromTarget()
	--Spring.Echo("My angle is", math.deg(ANGLE))
	TX = TX + math.cos(ANGLE) * 73
	TZ = TZ + math.sin(ANGLE) * 73
	Spring.MoveCtrl.SetPosition(unitID, TX + UX, TY + DROP_HEIGHT, TZ + UZ)
	local newAngle = math.atan2(UX, UZ)
	Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
	Turn(body, x_axis, math.rad(-50))
	-- Begin the drop
	PlaySound("dropship_entry")
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
		Turn(lflap, x_axis, 0, math.rad(5))
		Turn(rflap, x_axis, 0, math.rad(5))
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
	if #cargo > 0 then -- might be empty on /give testing
		UnloadCargo()
	else
		Sleep(2000)
	end
	-- Cargo is down, close the doors!
	while (dist < HOVER_HEIGHT + 20) do
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, math.max(0.33, vertSpeed * (dist/HOVER_HEIGHT)), 0)
		Sleep(10)
		dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
	end
	TakeOff()
end

function UnloadCargo()
	Signal(UnloadCargo)
	SetSignalMask(UnloadCargo)
	local pad = piece("pad")
	local attachment = piece("attachment")
	local BOOM_SPEED = 15
	for i, cargoID in ipairs(cargo) do
		-- reset
		PlaySound("dropship_doorclose")
		Move(cargoPieces[1], z_axis, 0)
		Move(cargoPieces[1], y_axis, 0)
		Move(pad, z_axis, 0)
		Turn(cargoPieces[1], x_axis, 0)
		Sleep(30)
		if Spring.GetUnitIsDead(beaconID) or Spring.GetUnitTeam(beaconID) ~= teamID then return end
		if not (cargoID and Spring.ValidUnitID(cargoID)) or Spring.GetUnitIsDead(cargoID) then return end
		local cargoUDID = Spring.GetUnitDefID(cargoID)
		if not cargoUDID then return end
		local cargoUD = UnitDefs[cargoUDID]
		-- lower the tray
		PlaySound("dropship_dooropen")
		Spring.UnitScript.AttachUnit(pad, cargo[i])
		Move(cargoPieces[1], y_axis, -(cargoDoor1 and 56 or 30), BOOM_SPEED)
		Move(attachment, y_axis, -(cargoDoor1 and 56 or 30), BOOM_SPEED)
		WaitForMove(attachment, y_axis)
		
		-- start cargo moving anim
		env = Spring.UnitScript.GetScriptEnv(cargoID)
		if env and env.script and env.script.StartMoving then -- TODO: shouldn't be required, maybe if cargo died?
			Spring.UnitScript.CallAsUnit(cargoID, env.script.StartMoving, false)
			Spring.SetUnitCOBValue(cargoID, COB.ACTIVATION, 1)
		end
		-- roll out
		Move(cargoPieces[1], z_axis, 40, cargoUD.speed / 2) -- 50
		WaitForMove(cargoPieces[1], z_axis)
		Move(cargoPieces[1], y_axis, -31)
		Move(cargoPieces[1], z_axis, 90, cargoUD.speed / 2)
		WaitForMove(cargoPieces[1], z_axis)
		-- off the tray, raise it up for the next one
		Move(attachment, y_axis, 0, BOOM_SPEED * 1.5)
		-- only rollers need to deal with the ramp
		if cargoID and Spring.ValidUnitID(cargoID) and not Spring.GetUnitIsDead(cargoID) then
			if cargoUDID and not cargoUD.canFly then
				Turn(cargoPieces[1], x_axis, math.rad(12), math.rad(20))
				WaitForTurn(cargoPieces[1], x_axis)
				Move(pad, z_axis, 19, cargoUD.speed / 5)
				WaitForMove(pad, z_axis)
				Turn(cargoPieces[1], x_axis, math.rad(21), math.rad(20))
				WaitForTurn(cargoPieces[1], x_axis)
				Move(pad, z_axis, 30, cargoUD.speed / 5)
				WaitForMove(pad, z_axis)
				--Turn(cargoPieces[1], x_axis, math.rad(0), math.rad(20))
				--WaitForTurn(cargoPieces[1], x_axis)
				Move(pad, z_axis, 45, cargoUD.speed / 5)
				WaitForMove(pad, z_axis)
			end
			-- check AGAIN as there were some WaitFor's above and it might have died
			if cargoID and Spring.ValidUnitID(cargoID) and not Spring.GetUnitIsDead(cargoID) then
				Spring.UnitScript.DropUnit(cargoID)
				Spring.SetUnitBlocking(cargoID, true, true, true, true, true, true, true)
			end
		end
	end
end