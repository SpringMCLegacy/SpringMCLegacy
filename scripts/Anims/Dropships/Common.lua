-- includes need a comment on first line apparantly?
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
		local hull = piece("hull")
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

function TouchDown()
	landed = true
	PlaySound("dropship_stomp")
	if crashing then
		--Spring.Echo("crashing in touchdown")
		crashing = false
		Spring.DestroyUnit(unitID, true)
	else -- safely down
		stage = 4
		for i = 1, info.numDusts do
			GG.EmitSfxName(unitID, piece("dust" .. i), "mech_jump_dust")
		end
		StartThread(DeployWeapons, true)
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

GRAVITY = 130/Game.gravity -- TODO: this should be in main dropship
function FindA(s, u, v)
	return CONVERSION * GRAVITY * (v^2 - u^2) / (2*s)
end

function Drop()
	Signal(Drop)
	SetSignalMask(Drop)
	Spring.SetTeamRulesParam(Spring.GetUnitTeam(unitID), "DROPSHIP_COOLDOWN", -1)
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX, GY + DROP_HEIGHT, TZ)
	Spring.MoveCtrl.SetHeading(unitID, HEADING)
	Spring.MoveCtrl.SetVelocity(unitID, 0, V_START, 0)
	Spring.MoveCtrl.SetGravity(unitID, FindA(DROP_HEIGHT - BURN_HEIGHT, V_START, V_BURNSTART))
	--Spring.Echo("1st a", FindA(DROP_HEIGHT - BURN_HEIGHT, V_START, V_BURNSTART))
	local SPEED = 0
	
	stage = 1
	StartThread(fx)
	
	-- Wait whilst we fall
	local _, y, _ = Spring.GetUnitPosition(unitID)
	--Spring.Echo("1st Y", y, y - GY)
	local _,vy,_ = Spring.GetUnitVelocity(unitID)
	--Spring.Echo("1st V", vy)
	while y - GY > BURN_HEIGHT do
		Sleep(30)
		_, y, _ = Spring.GetUnitPosition(unitID) -- update
		--[[Spring.Echo("next Y", y, y - GY)
		local vx,vy,vz = Spring.GetUnitVelocity(unitID)
		Spring.Echo("next V", vy)]]
	end
	--Spring.Echo("2nd Y", y, y - GY)
	local _,vy,_ = Spring.GetUnitVelocity(unitID) -- use actual velocity & position rather than desired
	--[[Spring.Echo("2nd V", vy)
	Spring.Echo("ROCKET SUICIDE DESCENT BURN NOW!")--]]
	Spring.MoveCtrl.SetGravity(unitID, FindA(BURN_HEIGHT - APPROACH_HEIGHT, vy, V_BURNEND))
	--Spring.Echo("2nd a", FindA(BURN_HEIGHT - APPROACH_HEIGHT, vy, V_BURNEND))
	
	-- only proceed if the beacon is still ours --and is secure
	if Spring.GetUnitTeam(beaconID) == Spring.GetUnitTeam(unitID) then 
		stage = 2
		StartThread(LandingGearDown) -- this sets main slowdown at end
		_, y, _ = Spring.GetUnitPosition(unitID)
		while y - GY > APPROACH_HEIGHT do
			Sleep(30)
			_, y, _ = Spring.GetUnitPosition(unitID) -- update
			--[[Spring.Echo("next Y", y, y - GY)
			local _,vy,_ = Spring.GetUnitVelocity(unitID)
			Spring.Echo("next V", vy)--]]
		end
		stage = 3
		--[[Spring.Echo("3rd Y", y, y - GY)
		local _,vy,_ = Spring.GetUnitVelocity(unitID)
		Spring.Echo("3rd V", vy)--]]
		Spring.MoveCtrl.SetGravity(unitID, -0.02 * GRAVITY)
		Spring.MoveCtrl.SetCollideStop(unitID, true)
		Spring.MoveCtrl.SetTrackGround(unitID, true)
	else
		TakeOff()
	end
end