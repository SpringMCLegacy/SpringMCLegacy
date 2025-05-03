-- Unit-specific pieces only declared here, generic dropship pieces in main script
local body = piece("body")
local cargoDoor1, cargoDoor2 = piece("cargodoor1", "cargodoor2")
local attachment = piece("attachment")
local DOOR_SPEED = math.rad(60)
local BOOM_SPEED = 25

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
	-- Put pieces into starting pos
	for _, exhaust in ipairs(hExhaustLarges) do
		Turn(exhaust, x_axis, math.rad(180))
	end	
	for _, exhaust in ipairs(vExhausts) do
		Turn(exhaust, x_axis, math.rad(89))
	end	
	for _, exhaust in ipairs(hExhausts) do
		Turn(exhaust, y_axis, math.rad(180))
	end	
end

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
	Spring.DestroyUnit(unitID, true, false)
end

function TouchDown()
	PlaySound("dropship_stomp")
	StartThread(Crashed)
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
		for _, exhaust in ipairs(hExhaustLarges) do
			--GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", width = 65, length = 115})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 40})
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust",  exhaust, {id = "hExhaustsJets", repeatEffect = true, width = 30, length = 150})
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets", width = 50, length = 95})
		end
	end
	while stage == 0 do
		Sleep(30)
	end
	if stage == 1 then
		--Spring.Echo("Enter stage 1")
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		GG.RemoveLupsSfx(unitID, "hExhaustsJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust, {delay = 40})
			GG.BlendJet(99, unitID, exhaust, "hExhaustsJets", 7, 30)
		end
		for _, exhaust in ipairs(hExhaustLarges) do
			--GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", replace = true, width = 40, length = 90})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust, {delay = 40})
			GG.BlendJet(99, unitID, exhaust, "hExhaustsJets", 7, 30)
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets", width = 25, length = 70})
		end
	end
	while stage == 1 do
		Sleep(30)
	end
	if stage == 2 then
		--Spring.Echo("Enter stage 2")
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.BlendJet(99, unitID, exhaust, "vExhaustsJets")
		end
	end
	while stage == 2 do
		Sleep(30)
	end
	if stage == 3 then
		--Spring.Echo("Enter stage 3")
		for _, exhaust in ipairs(hExhaustLarges) do
			GG.BlendJet(99, unitID, exhaust, "hExhaustsJets", 7, 30)
		end
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		for _, exhaust in ipairs(hExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust",  exhaust, {id = "hExhaustsJets", repeatEffect = true, width = 7, length = 30})
		end
--[[		for _, exhaust in ipairs(hExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets"})
		end]]
		GG.EmitLupsSfx(unitID, "exhaust_ground_winds", body, {repeatEffect = 4, delay = 125})
		GG.EmitLupsSfx(unitID, "exhaust_ground_winds", body, {repeatEffect = 4, delay = 125 + 80})
	end
	while stage == 3 do
		--SpawnCEG("dropship_heavy_dust", TX, TY, TZ)
		Sleep(30)
	end
	if stage == 4 then
		--Spring.Echo("Enter stage 4")
		GG.RemoveLupsSfx(unitID, "hExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargeJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 40})
		end
		for _, exhaust in ipairs(hExhaustLarges) do
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
			for _, exhaust in ipairs(hExhaustLarges) do
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
		--[[for _, exhaust in ipairs(hExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", length = 80, width = 45})
		end]]
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
		--Spring.Echo("Enter stage 5")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
	end
	while stage == 5 do
		for _, exhaust in ipairs(hExhaustLarges) do
			EmitSfx(exhaust, SFX.CEG + 2)
			EmitSfx(exhaust, SFX.CEG + 3)
		end
		Sleep(30)
	end	
end

function TakeOff()
	if stage > 3 then return end -- in case we are told to BugOut, ignore it if already exiting
	if booms[2] then
		for i = 2, 3 do
			Move(booms[i], y_axis, 0, BOOM_SPEED * 2)
		end
		WaitForMove(booms[3], y_axis)
		local lwing, rwing = piece("lwing", "rwing")
		Turn(lwing, x_axis, math.rad(0), DOOR_SPEED/3)
		Turn(rwing, x_axis, math.rad(0), DOOR_SPEED/3)
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
	PlaySound("dropship_burn")
	--Spring.Echo("BURRRRRN!")
	Sleep(1500)
	--Spin(body, z_axis, math.rad(180), math.rad(45))
	Sleep(2000)
	--StopSpin(body, z_axis, math.rad(45))
	Sleep(2000)
	-- We're out of the atmosphere, bye bye!
	Spring.DestroyUnit(unitID, false, true)
end


function Drop()
	Signal(Drop)
	SetSignalMask(Drop)
	-- Move us up to the drop position
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX + UX, TY + DROP_HEIGHT, TZ + UZ)
	local newAngle = math.atan2(UX, UZ)
	Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
	Turn(body, x_axis, math.rad(-50))
	-- Begin the drop
	PlaySound("dropship_entry")
	GG.PlaySoundForTeam(teamID, "BB_Dropship_Inbound", 1)
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
			Turn(piece("lwing"), x_axis, -math.rad(89), DOOR_SPEED/2)
			Turn(piece("rwing"), x_axis, -math.rad(89), DOOR_SPEED/2)
			StartThread(fx)
		elseif (y - TY) < 3 * HOVER_HEIGHT and stage == 1 then
			stage = 2
		end
		Sleep(100)
	end
	-- Descent complete, move over the target
	PlaySound("dropship_rumble")
	Turn(body, x_axis, 0, math.rad(3.5))
	Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
	Spring.MoveCtrl.SetGravity(unitID, 0)
	local dist = GetUnitDistanceToPoint(unitID, TX, 0, TZ, false)
	while dist > 10 do
		dist = GetUnitDistanceToPoint(unitID, TX, 0, TZ, false)
		--Spring.Echo("dist", dist)
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, math.max(dist/50, 2))
		Sleep(30)
	end
	-- only proceed if the beacon is still ours and is secure
	if beaconID and Spring.GetUnitTeam(beaconID) == teamID and Spring.GetUnitRulesParam(beaconID, "secure") == 1 then
		-- We're over the target area, reduce height!
		PlaySound("dropship_rumble")
		stage = 3
		local DOOR_SPEED = math.rad(60)
		PlaySound("dropship_dooropen")
		Spring.UnitScript.AttachUnit(cargoPieces[1], cargo[1])
		Turn(cargoDoor1, z_axis, math.rad(-90), DOOR_SPEED)
		Turn(cargoDoor2, z_axis, math.rad(90), DOOR_SPEED)
		local vertSpeed = 4
		local wantedHeight = select(2, Spring.GetUnitPosition(unitID)) - HOVER_HEIGHT
		local dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
		while (dist > 0) do
			Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, -math.max(0.33, vertSpeed * (dist/HOVER_HEIGHT)), 0)
			Sleep(10)
			dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
		end
		-- We're in place. Halt and lower the cargo!
		PlaySound("dropship_rumble")
		UnloadCargo()
	else -- bugging out, refund
		Spring.AddTeamResource(teamID, "metal", UnitDefs[Spring.GetUnitDefID(cargo[1])].metalCost)
	end
	-- Take off!
	TakeOff()
end

function UnloadCargo()
	local cargoID = cargo[1]
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 0)
	_, y, _ = Spring.GetUnitPosition(unitID)
	local BOOM_LENGTH = y - TY - 56
	local BOOM_SPEED = 15
	Move(attachment, y_axis, -56, BOOM_SPEED)
	WaitForMove(attachment, y_axis)
	for i = 2, 3 do
		Move(booms[i], y_axis, -BOOM_LENGTH / 2, BOOM_SPEED)
	end
	WaitForMove(booms[3], y_axis)
	PlaySound("stomp")
	Sleep(1500)
	if Spring.ValidUnitID(cargoID) and not Spring.GetUnitIsDead(cargoID) then -- might be empty on /give testing
		Spring.UnitScript.DropUnit(cargoID)
		Spring.SetUnitBlocking(cargoID, true, true, true, true, true, true, true)
		-- Let the cargo know it is unloaded
		env = Spring.UnitScript.GetScriptEnv(cargoID)
		if env then
			Spring.UnitScript.CallAsUnit(cargoID, env.Unloaded)
			-- Let the beacon know outpost is ready
			env = Spring.UnitScript.GetScriptEnv(callerID)
			if env then -- there was a crash here, beacon point died by DFA, should not happen now but just in case!
				Spring.UnitScript.CallAsUnit(callerID, env.ChangeType, true)
			end
		end
	end
	-- Cargo is down, close the doors!
	PlaySound("dropship_doorclose")
	for i = 2, 3 do
		Move(booms[i], y_axis, 0, BOOM_SPEED * 2)
	end
	WaitForMove(booms[3], y_axis)
	Turn(cargoDoor1, z_axis, 0, DOOR_SPEED)
	Turn(cargoDoor2, z_axis, 0, DOOR_SPEED)
	WaitForTurn(cargoDoor2, z_axis)
end