--pieces
local base = piece ("base")
local dirt = piece ("dirt")
local rocket = piece("rocket")
local blink = piece("blink")

Spring.SetUnitNanoPieces(unitID, {base})

local flaps = {}
for i = 1, 4 do
	flaps[i] = piece("flap" .. i)
end

local antenna1 = piece("antenna1")
local antenna2 = piece("antenna2")
local antenna3 = piece("antenna3")

-- Constants
local DROP_HEIGHT = 12000
local X, _, Z = Spring.GetUnitPosition(unitID)
local GY = Spring.GetGroundHeight(X, Z)

-- Variables
local stage
local touchDown = false


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

function TouchDown()
	touchDown = true
	-- check if we're the first beacon on a non-gaia team -> start unit
	local teamID = Spring.GetUnitTeam(unitID)
	if teamID ~= Spring.GetGaiaTeamID() then
		local count = Spring.GetTeamUnitDefCount(teamID, Spring.GetUnitDefID(unitID))
		if count == 1 then
			Spring.GiveOrderToUnit(unitID, GG.CustomCommands.GetCmdID("CMD_DROPZONE"), {}, {})
		end
	end
	Spring.SetUnitNoSelect(unitID, false)
end

function ChangeType(upgrade)
	if upgrade then
		stage = -1
		Spring.SetUnitNoDraw(unitID, true)
	else
		Spring.SetUnitNoDraw(unitID, false)
		stage = 0
		StartThread(fx)
	end
end

function script.Create()
	Hide(dirt)
	Spring.SetUnitNoSelect(unitID, true)
	Spring.MoveCtrl.Enable(unitID)
	local x,y,z = Spring.GetUnitPosition(unitID)
	Spring.MoveCtrl.SetPosition(unitID, x, GY + DROP_HEIGHT, z)
	Turn(base, y_axis, unitID, 0) -- get a random facing
	
	Sleep(unitID / 10) -- lolhack
	Spring.MoveCtrl.SetVelocity(unitID, 0, -50, 0)
	Spring.MoveCtrl.SetGravity(unitID, Game.gravity / 75)
	Spring.MoveCtrl.SetCollideStop(unitID, true)
	Spring.MoveCtrl.SetTrackGround(unitID, true)
	
	stage = 3
	StartThread(fx)
	-- TODO: Fix and re-implement rocket whoosh sound
	--[[for i = 1, 4 do
		local _, sy, _ = Spring.GetUnitVelocity(unitID)
		PlaySound("NavBeacon_Descend", 10, 0,sy,0)
		Sleep(2500)
	end]]
	while not touchDown do
		Sleep(50)
	end
	
	stage = 2
	EmitSfx(dirt, SFX.CEG + 1)
	Show(dirt)
	StopSpin(base, y_axis)
	PlaySound("NavBeacon_Land", 30)
	Sleep(5400)
	
	stage = 1
	Hide(rocket)
	PlaySound("NavBeacon_Pop", 15)
	Explode(rocket, SFX.FIRE + SFX.SMOKE)
	Sleep(3500)
	Turn(flaps[1], x_axis, -math.rad(80), math.rad(20))
	Turn(flaps[2], z_axis, -math.rad(80), math.rad(20))
	Turn(flaps[3], x_axis, math.rad(80), math.rad(20))
	Turn(flaps[4], z_axis, math.rad(80), math.rad(20))
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
	SetUnitValue(COB.INBUILDSTANCE, 1)
end

function script.Killed(recentDamage, maxHealth)
end
