-- Test Mech Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad
local currUnitDef
local BUILD_FACING = Spring.GetUnitBuildFacing(unitID)

--piece defines
local hull, link, pad, beam, main_door, hanger_door, vtol_pad = piece ("hull", "link", "pad", "beam", "main_door", "hanger_door", "vtol_pad")
--Weapon 1 and 2, dual lasers
local turret1_joint, turret1, turret1_flare1, turret1_flare2 = piece ("turret1_joint", "turret1", "turret1_flare1", "turret1_flare2")
--Weapon 3 and 4, dual lasers
local turret2_joint, turret2, turret2_flare1, turret2_flare2 = piece ("turret2_joint", "turret2", "turret2_flare1", "turret2_flare2")
--Weapon 5 and 6, dual lasers
local turret3_joint, turret3, turret3_flare1, turret3_flare2 = piece ("turret3_joint", "turret3", "turret3_flare1", "turret3_flare2")
--Weapon 7 and 8, dual lasers
local turret4_joint, turret4, turret4_flare1, turret4_flare2 = piece ("turret4_joint", "turret4", "turret4_flare1", "turret4_flare2")
--Weapon 9, PPC
local ppc1_platform, ppc1_turret, ppc1_mantlet, ppc1_barrel, ppc1_flare = piece ("ppc1_platform", "ppc1_turret", "ppc1_mantlet", "ppc1_barrel", "ppc1_flare")
--Weapon 10, PPC
local ppc2_platform, ppc2_turret, ppc2_mantlet, ppc2_barrel, ppc2_flare = piece ("ppc2_platform", "ppc2_turret", "ppc2_mantlet", "ppc2_barrel", "ppc2_flare")
--Weapon 11, PPC
local ppc3_platform, ppc3_turret, ppc3_mantlet, ppc3_barrel, ppc3_flare = piece ("ppc3_platform", "ppc3_turret", "ppc3_mantlet", "ppc3_barrel", "ppc3_flare")
--Weapon 12, PPC
local ppc4_platform, ppc4_turret, ppc4_mantlet, ppc4_barrel, ppc4_flare = piece ("ppc4_platform", "ppc4_turret", "ppc4_mantlet", "ppc4_barrel", "ppc4_flare")
--Weapon 13, LRM
local launcher1_joint, launcher1 = piece ("launcher1_joint", "launcher1")
--Weapon 14, LRM
local launcher2_joint, launcher2 = piece ("launcher2_joint", "launcher2")
--Weapon 15, LRM
local launcher3_joint, launcher3 = piece ("launcher3_joint", "launcher3")
--Weapon 16, LRM
local launcher4_joint, launcher4 = piece ("launcher4_joint", "launcher4")
--ERMBLs
local laser1, laser2, laser3, laser4, laser5, laser6, laser7, laser8 = piece ("laser1", "laser2", "laser3", "laser4", "laser5", "laser6", "laser7", "laser8")
--LBLs
local laser9, laser10, laser11, laser12 = piece ("laser9", "laser10", "laser11", "laser12")
--Anti-Missile System
local ams = piece ("ams")


-- Landing Gear Pieces
local gear1_door = piece("gear1_door")
local gear2_door = piece("gear2_door")
local gear3_door = piece("gear3_door")
local gear4_door = piece("gear4_door")

local gear1_joint = piece("gear1_joint")
local gear2_joint = piece("gear2_joint")
local gear3_joint = piece("gear3_joint")
local gear4_joint = piece("gear4_joint")

local gear1 = piece("gear1")
local gear2 = piece("gear2")
local gear3 = piece("gear3")
local gear4 = piece("gear4")

-- Exhaust Pieces
local exhaustlarge = piece("exhaustlarge")
local exhausts = {}
for i = 1,4 do
	exhausts[i] = piece("exhaust" .. i)
end

-- Constants
local DROP_HEIGHT = 10000
local GRAVITY = 1.2

-- Variables
local stage
local touchDown = false

function TouchDown()
	touchDown = true
end

local function LandingGear()
	SPEED = math.rad(15)
	-- Landing--
	--Open Landing Gear Doors--
	Spring.Echo("GEAR DEPLOYING...")
	Turn(gear1_door, x_axis, rad(-50), SPEED)
	Turn(gear2_door, x_axis, rad(50), SPEED)
	Turn(gear3_door, x_axis, rad(50), SPEED)
	Turn(gear4_door, x_axis, rad(-50), SPEED)
	SPEED = math.rad(25)
	--Legs Come Out--
	Turn(gear1_joint, x_axis, rad(125), SPEED)
	Turn(gear1, x_axis, rad(-160), SPEED)
	Turn(gear2_joint, x_axis, rad(-125), SPEED)
	Turn(gear2, x_axis, rad(160), SPEED)
	Turn(gear3_joint, x_axis, rad(-125), SPEED)
	Turn(gear3, x_axis, rad(160), SPEED)
	Turn(gear4_joint, x_axis, rad(125), SPEED)
	Turn(gear4, x_axis, rad(-160), SPEED)
	
	WaitForTurn(gear4, x_axis)
	Spring.Echo("GEAR DEPLOYED.")
end

function script.Create()
	Spring.MoveCtrl.Enable(unitID)
	local x,y,z = Spring.GetUnitPosition(unitID)
	Spring.MoveCtrl.SetPosition(unitID, x, y + DROP_HEIGHT, z)
	--Spring.MoveCtrl.SetVelocity(unitID, 0, -100, 0)
	
	local SPEED = 0
	--Setups: Quickly do this before the dropship appears)
	--Legs Setup--
	Turn(gear1_door, y_axis, rad(-45), SPEED)
	Turn(gear1_joint, y_axis, rad(-45), SPEED)
	Turn(gear2_door, y_axis, rad(45), SPEED)
	Turn(gear2_joint, y_axis, rad(45), SPEED)
	Turn(gear3_door, y_axis, rad(-45), SPEED)
	Turn(gear3_joint, y_axis, rad(-45), SPEED)
	Turn(gear4_door, y_axis, rad(45), SPEED)
	Turn(gear4_joint, y_axis, rad(45), SPEED)
	--[[--Launcher Setup--
	Turn(launcher1, y_axis, rad(-45), SPEED)
	Turn(launcher1, x_axis, rad(-30), SPEED)
	Turn(launcher2, y_axis, rad(-135), SPEED)
	Turn(launcher2, x_axis, rad(-30), SPEED)
	Turn(launcher3, y_axis, rad(135), SPEED)
	Turn(launcher3, x_axis, rad(-30), SPEED)
	Turn(launcher4, y_axis, rad(-45), SPEED)
	Turn(launcher4, x_axis, rad(-30), SPEED)
	--Turret setup--
	Turn(turret1, x_axis, rad(30), SPEED)
	Turn(turret2, x_axis, rad(30), SPEED)
	Turn(turret2, y_axis, rad(-90), SPEED)
	Turn(turret3, x_axis, rad(30), SPEED)
	Turn(turret3, y_axis, rad(180), SPEED)
	Turn(turret4, x_axis, rad(30), SPEED)
	Turn(turret4, y_axis, rad(90), SPEED)]]
	
	Spring.MoveCtrl.SetGravity(unitID, GRAVITY)
	
	local x, y, z = Spring.GetUnitPosition(unitID)
	local gy = Spring.GetGroundHeight(x, z)
	while y - gy > 2500 do
		Sleep(100)
		x, y, z = Spring.GetUnitPosition(unitID)
	end
	Spring.Echo("ROCKET FULL BURN NOW!")
	Spring.MoveCtrl.SetGravity(unitID, 0)--Game.gravity / 10000)
	
	StartThread(LandingGear)
	while y - gy > 925 do
		Sleep(100)
		x, y, z = Spring.GetUnitPosition(unitID)
		local _, sy, _ = Spring.GetUnitVelocity(unitID)
		Spring.MoveCtrl.SetVelocity(unitID, 0, sy * 0.9, 0)
		--Spring.Echo(y - gy)
	end
	Spring.MoveCtrl.SetGravity(unitID, GRAVITY / 10)
	Spring.MoveCtrl.SetCollideStop(unitID, true)
	Spring.MoveCtrl.SetTrackGround(unitID, true)
end

	--PPCs come out--
	--[[Turn(ppcdoors, y_axis, 10, SPEED)
	Move(ppc1_platform, z_axis, 31, SPEED)
	Move(ppc2_platform, x_axis, -20, SPEED)
	Turn(ppc2_turret, x_axis, rad(-90), SPEED)
	Move(ppc3_platform, z_axis, -20, SPEED)
	Turn(ppc3_turret, x_axis, rad(180), SPEED)
	Move(ppc4_platform, x_axis, 20, SPEED)
	Turn(ppc4_turret, x_axis, rad(90), SPEED)
	--Turrets come out--
	Turn(laser_doors, y_axis, rad(25), SPEED)
	Move(turret1_joint, y_axis, 20, SPEED)
	Move(turret1_joint, z_axis, 10, SPEED)
	Turn(turret1, x_axis, rad(0), SPEED)
	Move(turret2_joint, y_axis, 20, SPEED)
	Move(turret2_joint, x_axis, 10, SPEED)
	Turn(turret2, x_axis, rad(0), SPEED)
	Move(turret3_joint, y_axis, 20, SPEED)
	Move(turret3_joint, z_axis, -10, SPEED)
	Turn(turret3, x_axis, rad(0), SPEED)
	Move(turret4_joint, y_axis, 20, SPEED)
	Move(turret4_joint, x_axis, -10, SPEED)
	Turn(turret4, x_axis, rad(0), SPEED)
	--Launcher come out--
	Turn(missile_doors, y_axis, rad(25), SPEED)
	Move(launcher1_joint, y_axis, 25, SPEED)
	Move(launcher1_joint, x_axis, 10, SPEED)
	Move(launcher1_joint, z_axis, 10, SPEED)
	Move(launcher2_joint, y_axis, 25, SPEED)
	Move(launcher2_joint, x_axis, 10, SPEED)
	Move(launcher2_joint, z_axis, -10, SPEED)
	Move(launcher3_joint, y_axis, 25, SPEED)
	Move(launcher3_joint, x_axis, -10, SPEED)
	Move(launcher3_joint, z_axis, -10, SPEED)
	Move(launcher4_joint, y_axis, 25, SPEED)
	Move(launcher4_joint, x_axis, 10, SPEED)
	Move(launcher4_joint, z_axis, -10, SPEED)
	Turn(launcher1, x_axis, rad(0), SPEED)
	Turn(launcher2, x_axis, rad(0), SPEED)
	Turn(launcher3, x_axis, rad(0), SPEED)
	Turn(launcher4, x_axis, rad(0), SPEED)]]--