-- Unit-specific pieces only declared here, generic dropship pieces in main script
local hull = piece("hull")

-- dust emitters
local dusts = {}
for i = 1,info.numDusts do
	dusts[i] = piece("dust" .. i)
end

local sniperCanFire = false
function WeaponCanFire(weaponID)
	if missileWeaponIDs[weaponID] then return stage == 4
	elseif weaponID == 1 then return sniperCanFire
	else return true
	end
end


function Setup()
	-- Put pieces into starting pos
	Move(piece("barrel_1"), z_axis, -58, 20)
	Turn(vExhaustLarges[1], x_axis, math.rad(90), 0)
	for i = 1, info.numVExhausts do
		Turn(vExhausts[i], x_axis, math.rad(90), 0)
	end
	-- Legs Setup

	for i = 1,info.numGears do
		local angle = i < 5 and i * rad(45) or (8 - i) * rad(45)
		local angleDir = i < 4 and -angle or angle
		local angle2 = rad(80)
		Turn(gears[i].door, y_axis, angleDir)
		Turn(gears[i].door, x_axis, angle2)
		Turn(gears[i].joint, y_axis, angleDir)
	end
	-- weapon pieces too
	Turn(turrets[2], y_axis, math.rad(-45))
	Turn(turrets[4], y_axis, math.rad(135))
	-- 6, 10, 14, 18 -> 4n + 2, .'. (id - 2)/4
	for id, trackEmitter in pairs(trackEmitters) do
		Turn(trackEmitter, y_axis, math.rad(90 * ((id - 2)/4 - 1)))
	end
end

function LandingGearDown()
	SPEED = math.rad(40)
	for i = 1, 7 do -- Doors open
		Turn(gears[i].door, x_axis, math.rad(1), SPEED * 5)
	end
	WaitForTurn(gears[7].door, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -4.2 * GRAVITY) -- -3.72
	Sleep(2000)
	for i = 1, 7 do -- feet into deploy position
		Turn(gears[i].joint, x_axis, math.rad(5), SPEED)
	end
	WaitForTurn(gears[7].joint, x_axis)
	for i = 1, 7 do -- joint and feet rotate out
		Turn(gears[i].joint, x_axis, math.rad(90), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(-110), SPEED)
	end
	WaitForTurn(gears[7].joint, x_axis)
	for i = 1, 7 do -- joint raises and locks into position
		Move(gears[i].joint, y_axis, -5, 15)
	end
	WaitForMove(gears[7].joint, y_axis)
	Turn(piece("missile_doors"), y_axis, math.rad(16), math.rad(4))
end

local function SniperOut(out)
	local mantlet = piece("mantlet_1")
	local barrel = piece("barrel_1")
	Move(mantlet, z_axis, out and 40 or 0, 20)
	Move(barrel, z_axis, out and 0 or -58, 20)
	WaitForMove(mantlet, z_axis)
	WaitForMove(barrel, z_axis)
	sniperCanFire = out
end

function TouchDown()
	landed = true
	PlaySound("dropship_stomp")
	if crashing then
		Spring.DestroyUnit(unitID, true)
	else
		stage = 4
		for i = 1, 4 do
			GG.EmitSfxName(unitID, dusts[i], "mech_jump_dust")
		end
		StartThread(SniperOut, true)
	end
end

function LandingGearUp()
	Turn(piece("missile_doors"), y_axis, 0, math.rad(4))
	Move(piece("mantlet_1"), z_axis, 0, 20)
	Move(piece("barrel_1"), z_axis, -58, 20)
	SPEED = math.rad(40)

	for i = 1, 7 do -- joint lowers and unlocks
		Move(gears[i].joint, y_axis, 0, 15)
		--Turn(gears[i].joint, x_axis, math.rad(-80), SPEED)
		--Turn(gears[i].gear, x_axis, math.rad(50), SPEED)
	end
	--WaitForTurn(gears[7].gear, x_axis)
	WaitForMove(gears[7].joint, y_axis)
	for i = 1, 7 do -- joint and feet rotate in
		Turn(gears[i].joint, x_axis, math.rad(5), SPEED)
		Turn(gears[i].gear, x_axis, 0, SPEED)
	end
	WaitForTurn(gears[7].joint, x_axis)
	for i = 1, 7 do -- feet into stowed position
		Turn(gears[i].joint, x_axis, 0, SPEED)
	end	
	for i = 1, 7 do -- Doors close
		Turn(gears[i].door, x_axis, math.rad(80), SPEED)
	end
	WaitForTurn(gears[7].door, x_axis)
	
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
	PlaySound("dropship_entry")
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
		for i = 1, 7 do
			Move(gears[i].joint, y_axis, -5 + REST, 2 * REST)
		end
		WaitForMove(gears[7].joint, y_axis)
		Move(hull, y_axis, -RETURN, RETURN)
		for i = 1, 7 do
			Move(gears[i].joint, y_axis, -5 + RETURN, RETURN)
		end
		WaitForMove(gears[7].joint, y_axis)
		StartThread(UnloadCargo)
	end
	if stage == 5 then -- blast off
		PlaySound("dropship_liftoff")
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

function TakeOff()
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
	Spring.DestroyUnit(unitID, false, true)
end

function Drop()
	Signal(Drop)
	SetSignalMask(Drop)
	Spring.SetTeamRulesParam(Spring.GetUnitTeam(unitID), "DROPSHIP_COOLDOWN", -1)
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX, GY + DROP_HEIGHT, TZ)
	Spring.MoveCtrl.SetHeading(unitID, HEADING)
	Spring.MoveCtrl.SetVelocity(unitID, 0, -55, 0)
	Spring.MoveCtrl.SetGravity(unitID, -0.4 * GRAVITY)
	
	local SPEED = 0

	stage = 1
	StartThread(fx)
	
	local _, y, _ = Spring.GetUnitPosition(unitID)
	while y - GY > 3500 do
		Sleep(30)
		_, y, _ = Spring.GetUnitPosition(unitID)
	end
	-- only proceed if the beacon is still ours --and is secure
	if Spring.GetUnitTeam(beaconID) == Spring.GetUnitTeam(unitID) then 
		stage = 2
		--Spring.Echo("ROCKET FULL BURN NOW!")


		StartThread(LandingGearDown)
		while y - GY > 925 do
			Sleep(30)
			_, y, _ = Spring.GetUnitPosition(unitID)
		end
		stage = 3
		Spring.MoveCtrl.SetGravity(unitID, -0.02 * GRAVITY)
		Spring.MoveCtrl.SetCollideStop(unitID, true)
		Spring.MoveCtrl.SetTrackGround(unitID, true)
	else
		TakeOff()
	end
end

-- CARGO CODE
local link, pad, main_door, door_struts, vtol_pad = piece ("link", "pad", "main_door", "door_struts", "vtol_pad")

local WAIT_TIME = 10000
local DOOR_SPEED = math.rad(60)
local x, _ ,z = Spring.GetUnitPosition(unitID)
--local dx, _, dz = Spring.GetUnitDirection(unitID)
local dirAngle = HEADING / 2^16 * 2 * math.pi
local dx = math.sin(dirAngle)
local dz = math.cos(dirAngle)
local UNLOAD_X = x + 300 * dx
local UNLOAD_Z = z + 300 * dz

function UnloadCargo()
	PlaySound("dropship_dooropen")
	Move(door_struts, z_axis, 25, 25)
	Turn(main_door, x_axis, math.rad(105), DOOR_SPEED)
	Turn(link, x_axis, math.rad(35), DOOR_SPEED * 10)
	WaitForTurn(main_door, x_axis)
	
	for i, cargoID in ipairs(cargo) do
		Move(link, z_axis, 0)
		Move(pad, z_axis, 0)
		Turn(pad, x_axis, math.rad(-35))
		--Move(vtol_pad, x_axis, 0)

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
			--[[Spring.UnitScript.AttachUnit(vtol_pad, cargoID)
			Move(vtol_pad, x_axis, 128, 64)
			WaitForMove(vtol_pad, x_axis)
			Spring.SetUnitVelocity(cargoID, 8, 4, 0)]]
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
	StartThread(SniperOut, false)
	PlaySound("dropship_doorclose")
	Turn(main_door, x_axis, 0, DOOR_SPEED/2)
	WaitForTurn(main_door, x_axis)
	Move(door_struts, z_axis, 0, 25)
	WaitForMove(door_struts, z_axis)
	Sleep(WAIT_TIME)
	TakeOff()
end