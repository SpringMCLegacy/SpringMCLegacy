-- Unit-specific pieces only declared here, generic dropship pieces in main script
local body = piece("body")
--local cargoDoor1, cargoDoor2 = piece("cargodoor1", "cargodoor2")
--local attachment = piece("attachment")
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
	stage = 3
	StartThread(fx)
	local x,y,z = Spring.GetUnitPosition(unitID)
	for i = 1, 5 do
		Spring.SpawnCEG("dropship_heavy_dust", x,y,z)
	end
	Spring.SpawnCEG("mech_jump_dust", x,y,z)
	--Sleep(3000)
	local engine1, engine2, engine3, engine4 = piece("engine1", "engine2", "engine3", "engine4")
	Explode(engine1, SFX.SHATTER)
	Explode(engine2, SFX.SHATTER)
	Explode(engine3, SFX.SHATTER)
	Explode(engine4, SFX.SHATTER)
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

local function Refund()
	if cargo[1] and not Spring.GetUnitIsDead(cargo[1]) then
		local cargoDefID = Spring.GetUnitDefID(cargo[1])
		if cargoDefID then
			Spring.AddTeamResource(teamID, "metal", UnitDefs[cargoDefID].metalCost)
			Spring.DestroyUnit(cargo[1], false, true)
			GG.PlaySoundForTeam(teamID, "bb_outpost_refund", 1)
		end
	end
end

function TakeOff(bugOut)
	if stage > 3 and cargo[1] and not Spring.GetUnitIsDead(cargo[1]) then  -- in case we are told to BugOut, ignore it if already exiting
		Refund()
		return 
	end
	if not bugout then
		stage = 3
		local vertSpeed = 12 --4
		local wantedHeight = 400
		local dist = wantedHeight - select(2, Spring.GetUnitPosition(unitID))
		while (dist > 0) do
			Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, math.max(0.275, vertSpeed / (dist/40 + 1)), 0)
			Sleep(10)
			dist = wantedHeight - select(2, Spring.GetUnitPosition(unitID))
		end
	end
	if not cargo[1] then -- Cargo is down, close the doors!
		PlaySound("dropship_doorclose")
		local LEG_SPEED = math.rad(15)
		for i = 1, 2 do
			Turn(piece("leg_" .. i), z_axis, -math.rad(65), LEG_SPEED * 4)
			Turn(piece("foot_" .. i), z_axis, -math.rad(25), LEG_SPEED * 2)
		end
		for i = 3, 4 do
			Turn(piece("leg_" .. i), z_axis, math.rad(65), LEG_SPEED * 4)
			Turn(piece("foot_" .. i), z_axis, math.rad(25), LEG_SPEED * 2)
		end
	end
	local engine1, engine2, engine3, engine4 = piece("engine1", "engine2", "engine3", "engine4")
	Turn(engine1, x_axis, math.rad(0), DOOR_SPEED/2)
	Turn(engine2, x_axis, math.rad(0), DOOR_SPEED/2)
	Turn(engine3, x_axis, math.rad(0), DOOR_SPEED/2)
	Turn(engine4, x_axis, math.rad(0), DOOR_SPEED/2)
	WaitForTurn(engine1, z_axis)

	-- Take off!
	PlaySound("dropship_liftoff")
	stage = 4
	Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetGravity(unitID, -0.75 * GRAVITY)
	Turn(body, x_axis, math.rad(-30), math.rad(20))
	WaitForTurn(body, x_axis)
	Turn(body, x_axis, math.rad(-70), math.rad(30))
	WaitForTurn(body, x_axis)
	Turn(body, x_axis, math.rad(-80), math.rad(10))
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
	if bugOut and cargo[1] and not Spring.GetUnitIsDead(cargo[1]) then
		Refund()
	end
	Spring.DestroyUnit(unitID, false, true)
end


function Drop()
	Signal(Drop)
	SetSignalMask(Drop)
	-- Move us up to the drop position
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX + UX, TY + DROP_HEIGHT, TZ + UZ)
	Sleep(60)
	local cargoID = cargo[1]
	if not cargoID then return end -- weird bug at endgame
	Spring.UnitScript.AttachUnit(cargoPieces[1], cargoID)
	local newAngle = math.atan2(UX, UZ)
	Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
	Turn(body, x_axis, math.rad(-50))
	-- Begin the drop
	PlaySound("dropship_entry")
	--GG.PlaySoundForTeam(teamID, "BB_Dropship_Inbound", 1)
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
			Turn(piece("engine1"), x_axis, -math.rad(89), DOOR_SPEED/1)
			Turn(piece("engine2"), x_axis, -math.rad(89), DOOR_SPEED/1)
			Turn(piece("engine3"), x_axis, -math.rad(89), DOOR_SPEED/1)
			Turn(piece("engine4"), x_axis, -math.rad(89), DOOR_SPEED/1)
			StartThread(fx)
		elseif (y - TY) < 3 * HOVER_HEIGHT and stage == 1 then
			stage = 2
		end
		Sleep(100)
	end
	-- Descent complete, move over the target
	local bugOut = false
	PlaySound("dropship_rumble")
	Turn(body, x_axis, 0, math.rad(8))
	Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
	Spring.MoveCtrl.SetGravity(unitID, 0)
	local dist = GetUnitDistanceToPoint(unitID, TX, 0, TZ, false)
	while dist > 10 and not bugOut do
		dist = GetUnitDistanceToPoint(unitID, TX, 0, TZ, false)
		--Spring.Echo("dist", dist)
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, math.max(dist/50, 2))
		bugOut = cargoID and Spring.GetUnitIsDead(cargoID)
		Sleep(30)
	end
	-- only proceed if the beacon is still ours and is secure
	if not bugOut and beaconID and Spring.GetUnitTeam(beaconID) == teamID and tonumber(Spring.GetUnitRulesParam(beaconID, "secure")) == 1 then
		-- We're over the target area, reduce height!
		PlaySound("dropship_rumble")
		stage = 3
		local DOOR_SPEED = math.rad(60)
		PlaySound("dropship_dooropen")
		--Turn(cargoDoor1, z_axis, math.rad(-90), DOOR_SPEED)
		--Turn(cargoDoor2, z_axis, math.rad(90), DOOR_SPEED)
		local vertSpeed = 4
		local wantedHeight = GY + 15
		local dist = select(2, Spring.GetUnitPosition(unitID)) - GY
		while dist > 0 and not bugOut do
			Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, -math.max(2, vertSpeed * dist/300), 0)
			Sleep(10)
			dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
			bugOut = (cargoID and Spring.GetUnitIsDead(cargoID)) or not (Spring.GetUnitTeam(beaconID) == teamID and tonumber(Spring.GetUnitRulesParam(beaconID, "secure")) == 1)
			--Spring.Echo("derp", dist, bugOut)
		end
		-- We're in place. Halt and lower the cargo!
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 0)
		if not bugOut then -- one last check
			-- We're in place. Halt and lower the cargo!
			PlaySound("dropship_rumble")
			UnloadCargo()
		end
	end
	-- Take off!
	TakeOff(bugOut)
end

function UnloadCargo()
	local cargoID = cargo[1]
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 0)
	_, y, _ = Spring.GetUnitPosition(unitID)
	local LEG_SPEED = math.rad(15)
	for i = 1, 2 do
		Turn(piece("leg_" .. i), z_axis, math.rad(20), LEG_SPEED)
	end
	for i = 3, 4 do
		Turn(piece("leg_" .. i), z_axis, -math.rad(20), LEG_SPEED)
	end
	--WaitForTurn(piece("leg_4"), z_axis)
	if Spring.ValidUnitID(cargoID) and not Spring.GetUnitIsDead(cargoID) then -- might be empty on /give testing
		PlaySound("stomp")
		local nearCorpses = Spring.GetFeaturesInCylinder(TX, TZ, 50)
		for i, fID in pairs(nearCorpses) do
			local fx,fy,fz = Spring.GetFeaturePosition(fID)
			SpawnCEG("he_medium", fx, fy, fz)
			Spring.DestroyFeature(fID)
		end
		local front, up, right = Spring.GetUnitVectors(unitID)
		GG.SpawnDecal("decal_outpost", TX, TZ, nil, ANGLE)--math.atan2(front[1], front[3]))
		for i = 1, 5 do
			SpawnCEG("mech_jump_dust", TX,TY,TZ)
			Sleep(60)
		end
		Spring.UnitScript.DropUnit(cargoID)
		cargo[1] = nil
		Spring.SetUnitBlocking(cargoID, true, true, true, true, true, true, true)
		-- Let the cargo know it is unloaded
		env = Spring.UnitScript.GetScriptEnv(cargoID)
		if env then
			Spring.UnitScript.CallAsUnit(cargoID, env.Unloaded, ANGLE)
			-- Let the beacon know outpost is ready
			env = Spring.UnitScript.GetScriptEnv(callerID)
			if env then -- there was a crash here, beacon point died by DFA, should not happen now but just in case!
				Spring.UnitScript.CallAsUnit(callerID, env.ChangeType, true)
			end
		end
	end
	Sleep(1500)

	--WaitForMove(booms[3], y_axis)
	--Turn(cargoDoor1, z_axis, 0, DOOR_SPEED)
	--Turn(cargoDoor2, z_axis, 0, DOOR_SPEED)
	--WaitForTurn(cargoDoor2, z_axis)
end