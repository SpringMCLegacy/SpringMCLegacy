-- Unit-specific pieces only declared here, generic dropship pieces in main script
local hull = piece("hull")

-- dust emitters
local dusts = {}
for i = 1,info.numDusts do
	dusts[i] = piece("dust" .. i)
end

function WeaponCanFire(weaponID)
	if missileWeaponIDs[weaponID] then return stage == 4
	else return true
	end
end


function Setup()
	-- Put pieces into starting pos
	Turn(vExhaustLarges[1], x_axis, math.rad(90), 0)
	for i = 1, info.numVExhausts do
		Turn(vExhausts[i], x_axis, math.rad(90), 0)
	end
	-- Legs Setup
	for i = 1,info.numGears do
		local angle = (i == 2 or i == 3) and rad(45) or rad(225)
		local angleDir = i % 2 == 0 and angle or -angle
		local angle2 = rad(80)
		Turn(gears[i].door, y_axis, angleDir)
		Turn(gears[i].joint, y_axis, angleDir)
		Turn(gears[i].joint, x_axis, angle2)
		Move(gears[i].joint, y_axis, -13)
	end
	-- weapon pieces too
	for id, turret in pairs(turrets) do
		Turn(turret, y_axis, math.rad(-45 * id))
	end
	-- 1, 3, 5, 7 -> 2n - 1, .'. (id + 1)/2
	for id, trackEmitter in pairs(trackEmitters) do
		Turn(trackEmitter, y_axis, math.rad(90 * ((id + 1)/2 - 1)))
	end
end

function LandingGearDown()
	SPEED = math.rad(60) -- 40
	for i = 1, 4 do -- Doors open
		Turn(gears[i].door, x_axis, math.rad(60), SPEED * 5)
	end
	WaitForTurn(gears[4].door, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -6 * GRAVITY) -- -3.72, -4
	Sleep(2500)
	for i = 1, 4 do -- feet into deploy position
		Turn(gears[i].joint, x_axis, math.rad(5), SPEED)
	end
	WaitForTurn(gears[4].joint, x_axis)
	for i = 1, 4 do -- joint and feet rotate out
		Turn(gears[i].joint, x_axis, math.rad(-80), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(50), SPEED)
	end
	WaitForTurn(gears[4].joint, x_axis)
	for i = 1, 4 do -- joint raises and locks into position
		Move(gears[i].joint, y_axis, 0, 15)
		Turn(gears[i].joint, x_axis, math.rad(-115), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(85), SPEED)
	end
	WaitForTurn(gears[4].gear, x_axis)
	Turn(piece("missile_doors"), y_axis, math.rad(16), math.rad(4))
end

function TouchDown()
	if crashing then
		Spring.DestroyUnit(unitID, true)
	else
		stage = 4
		for i = 1, 4 do
			GG.EmitSfxName(unitID, dusts[i], "mech_jump_dust")
		end
	end
end

function LandingGearUp()
	Turn(piece("missile_doors"), y_axis, 0, math.rad(4))
	SPEED = math.rad(40)

	for i = 1, 4 do -- joint lowers and unlocks
		Move(gears[i].joint, y_axis, -13, 15)
		Turn(gears[i].joint, x_axis, math.rad(-80), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(50), SPEED)
	end
	WaitForTurn(gears[4].gear, x_axis)
	for i = 1, 4 do -- joint and feet rotate in
		Turn(gears[i].joint, x_axis, math.rad(5), SPEED)
		Turn(gears[i].gear, x_axis, 0, SPEED)
	end
	WaitForTurn(gears[4].joint, x_axis)
	for i = 1, 4 do -- feet into stowed position
		Turn(gears[i].joint, x_axis, math.rad(80), SPEED)
	end	
	for i = 1, 4 do -- Doors close
		Turn(gears[i].door, x_axis, 0, SPEED)
	end
	WaitForTurn(gears[4].door, x_axis)
	
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
end

local fxStages = {
	[1] = {
		{1, "dropship_hull_heat", {count = 70, pos = {0,0,0}, repeatEffect = 4}},
		{1, "dropship_hull_heat", {count = 90, pos = {0,0,0}, repeatEffect = 3, delay = 10}},
		{1, "dropship_hull_heat", {count = 90, pos = {0,0,0}, repeatEffect = 3, delay = 20}},
		{vExhausts, "dropship_vertical_exhaust",  {id = "smallExhaustJets", repeatEffect = true, width = 30, length = 150}},
		{vExhaustlarges, "dropship_vertical_exhaust",  {id = "largeExhaustJet", repeatEffect = true, width = 190, length = 250}},
	},
	[2] = {
		--{1, "engine_sound"},
	},
	[3] = {
		{"remove", "largeExhaustJet"},
		{"remove", "smallExhaustJets"},
	},
	[4] = {
		{"remove", "smallExhaustJets"},
		{1, "valve_release", {pos = { 80,100, 80}, emitVector = { 1,0, 1}} },
		{1, "valve_release", {pos = {-80,100, 80}, emitVector = {-1,0, 1}} },
		{1, "valve_release", {pos = { 80,100,-80}, emitVector = { 1,0,-1}} },
		{1, "valve_release", {pos = {-80,100,-80}, emitVector = {-1,0,-1}} },
		{1, "valve_sound"},
		{1, "land_sound"},
		{1, "exhaust_ground_winds", {pos = {0,0,0}, repeatEffect = false}},
		{1, "exhaust_ground_winds", {pos = {0,0,0}, repeatEffect = false, delay = 80}},
	},
	[5] = {
		{1, "exhaust_ground_winds", {pos = {0,0,0}, repeatEffect = false}},
		{1, "exhaust_ground_winds", {pos = {0,0,0}, repeatEffect = false, delay = 80}},
		--{exhaustlarge, "plume", {worldpos=true}},
		--{exhaustlarge, "plume", {worldpos=true}},
		--{exhaustlarge, "plume", {worldpos=true}},
		--{exhaustlarge, "plume", {worldpos=true}},
		--{exhaustlarge, "plume", {worldpos=true}},
	},
}

function fx()
	-- Free fall
	if stage == 1 then
		GG.EmitLupsSfxArray(unitID, fxStages[stage])
	end
	while stage == 1 do
		Sleep(32)
	end
	-- Rocket Burn
	if stage == 2 then
		GG.EmitLupsSfxArray(unitID, fxStages[stage])
		local time = 114
		for t = 0, (time/3) do
			local i = t / (time/3)
			for _, exhaust in ipairs(vExhausts) do
				if (i == 1) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", repeatEffect = true, delay = t*3, width = 110, length = 350})
				elseif (i > 0.33) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", life = 2, delay = t*3, width = i * 110, length = i * 350})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", life = 1, delay = t*3+2, width = i * 100, length = i * 300})
				else
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", life = 1, delay = t*3,   width = i * 110, length = i * 350})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", life = 2, delay = t*3+1, width = i * 80, length = i * 190})
				end
			end
		end
	end
	while stage == 2 do
		if up then
			EmitSfx(vExhaustLarges[1], CEG + 1)
			EmitSfx(vExhaustLarges[1], CEG + 3)
		end
		Sleep(32)
	end
	-- Final descent
	if stage == 3 then
		GG.EmitLupsSfxArray(unitID, fxStages[stage])
		for _, exhaust in ipairs(vExhausts) do
			GG.BlendJet(99, unitID, exhaust, "smallExhaustJets")
		end
	end
	while stage == 3 do
		Sleep(32)
	end
	if stage == 4 then
		GG.EmitLupsSfxArray(unitID, fxStages[stage])

		local REST = 10
		local RETURN = 6
		Move(hull, y_axis, -REST, 2 * REST)
		for i = 1, 4 do
			Move(gears[i].joint, y_axis, REST, 2 * REST)
		end
		WaitForMove(gears[4].joint, y_axis)
		Move(hull, y_axis, -RETURN, RETURN)
		for i = 1, 4 do
			Move(gears[i].joint, y_axis, RETURN, RETURN)
		end
		WaitForMove(gears[4].joint, y_axis)
		StartThread(UnloadCargo)
	end
	if stage == 5 then -- blast off
		GG.EmitLupsSfxArray(unitID, fxStages[stage])
		for _, exhaust in ipairs(vExhausts) do
			GG.BlendJet(33, unitID, exhaust, "smallExhaustJets", 20, 30)
		end

		GG.RemoveGrassCircle(TX, TZ, 230)
		GG.SpawnDecal("decal_drop", TX, GY + 1, TZ, teamID, false, 30 * 2, 30 * 120)
		up = true
	end
	while stage == 5 do
		EmitSfx(vExhaustLarges[1], CEG + 2)
		EmitSfx(vExhaustLarges[1], CEG + 3)
		Sleep(32)
	end
end

function Drop()
	local s = DROP_HEIGHT - 925
	local u = -60
	local v = -50
	local a = (u^2 -v^2) / (2*s)
	Signal(Drop)
	SetSignalMask(Drop)
	Spring.SetTeamRulesParam(Spring.GetUnitTeam(unitID), "DROPSHIP_COOLDOWN", -1)
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX, GY + DROP_HEIGHT, TZ)
	Spring.MoveCtrl.SetHeading(unitID, HEADING)
	Spring.MoveCtrl.SetVelocity(unitID, 0, u, 0) -- -55
	Spring.MoveCtrl.SetGravity(unitID, -a)---1.8 * GRAVITY) -- -0.4
	
	local SPEED = 0

	stage = 1
	StartThread(fx)
	
	local _, y, _ = Spring.GetUnitPosition(unitID)
	while y - GY > 3500 do
		Sleep(30)
		_, y, _ = Spring.GetUnitPosition(unitID)
	end
	stage = 2
	--Spring.Echo("ROCKET FULL BURN NOW!")


	StartThread(LandingGearDown)
	while y - GY > 925 do
		Sleep(30)
		_, y, _ = Spring.GetUnitPosition(unitID)
	end
	stage = 3
	Spring.MoveCtrl.SetGravity(unitID, -0.02 * GRAVITY) -- -0.02
	Spring.MoveCtrl.SetCollideStop(unitID, true)
	Spring.MoveCtrl.SetTrackGround(unitID, true)
end

-- CARGO CODE
local link, pad, main_door, hanger_door, vtol_pad = piece ("link", "pad", "main_door", "hanger_door", "vtol_pad")

local WAIT_TIME = 10000
local DOOR_SPEED = math.rad(90)
local x, _ ,z = Spring.GetUnitPosition(unitID)
--local dx, _, dz = Spring.GetUnitDirection(unitID)
local dirAngle = HEADING / 2^16 * 2 * math.pi
local dx = math.sin(dirAngle)
local dz = math.cos(dirAngle)
local UNLOAD_X = x + 300 * dx
local UNLOAD_Z = z + 300 * dz

function UnloadCargo()
	Turn(main_door, x_axis, math.rad(110), DOOR_SPEED)
	Turn(hanger_door, y_axis, math.rad(90), DOOR_SPEED * 0.5)
	Turn(link, x_axis, math.rad(35), DOOR_SPEED * 10)
	Turn(vtol_pad, y_axis, math.rad(90), DOOR_SPEED * 10)
	WaitForTurn(main_door, x_axis)
	
	for i, cargoID in ipairs(cargo) do
		Move(link, z_axis, 0)
		Move(pad, z_axis, 0)
		Turn(pad, x_axis, math.rad(-35))
		Move(vtol_pad, x_axis, 0)

		WaitForMove(link, z_axis)
		WaitForMove(pad, z_axis)
		
		-- start cargo moving anim
		env = Spring.UnitScript.GetScriptEnv(cargoID)
		if env and env.script and env.script.StartMoving then -- TODO: shouldn't be required, maybe if cargo died?
			Spring.UnitScript.CallAsUnit(cargoID, env.script.StartMoving, false)
		end
		
		-- attach and move
		local currUnitDef = UnitDefs[Spring.GetUnitDefID(cargoID)]
		local buildTime = currUnitDef.buildTime

		if currUnitDef.canFly then
			Spring.UnitScript.AttachUnit(vtol_pad, cargoID)
			Move(vtol_pad, x_axis, 128, 64)
			WaitForMove(vtol_pad, x_axis)
			Spring.SetUnitVelocity(cargoID, 8, 4, 0)
		else
			Spring.UnitScript.AttachUnit(pad, cargoID)
			local moveSpeed = currUnitDef.speed * 1.2
			Move(link, z_axis, 73, moveSpeed)
			WaitForMove(link, z_axis)
			Move(pad, z_axis, 100, moveSpeed)
			WaitForMove(pad, z_axis)
		end
		Spring.UnitScript.DropUnit(cargoID)
		Spring.SetUnitBlocking(cargoID, true, true, true, true, true, true, true)
		if currUnitDef.canFly then
			Spring.GiveOrderToUnit(cargoID, CMD.MOVE, {TX + 256, 0, Z}, {})
		else
			Spring.SetUnitMoveGoal(cargoID, UNLOAD_X +  math.random(-100, 100), 0, UNLOAD_Z +  math.random(-100, 100), 25) -- bug out over here
		end
		Sleep(2000)
	end
	Turn(main_door, x_axis, 0, DOOR_SPEED/2)
	Turn(hanger_door, y_axis, 0, DOOR_SPEED/2)
	WaitForTurn(hanger_door, y_axis)
	WaitForTurn(main_door, x_axis)
	Sleep(WAIT_TIME)
	stage = 5 --3
	StartThread(fx)
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetGravity(unitID, -1 * GRAVITY)
	Sleep(2500)
	stage = 2
	StartThread(fx) -- need to restart here as we're going back up a step
	StartThread(LandingGearUp)
	Sleep(10000)
	-- We're out of the atmosphere, bye bye!
	GG.DropshipLeft(teamID) -- let the world know
	Spring.DestroyUnit(unitID, false, true)
end