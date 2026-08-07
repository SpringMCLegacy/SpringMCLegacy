-- Common pieces
base = piece ("base")
crateLink = piece("cratelink")
legs = {}
for i = 1, 4 do
	legs[i] = piece("leg" .. i)
end

-- Constants
local name = unitDef.name
local isDZ = name:find("dropzone")
local rad = math.rad
CRATE_SPEED = math.rad(50)

local animString = isDZ and "outpost_dropzone" or unitDef.name
include ("anims/outposts/" .. animString .. ".lua")

---------------------------------------------------------------------
-- Common functions
---------------------------------------------------------------------
crateID = nil
pointID = nil
beaconID = nil
function ParentBeacon(callingPointID, parentBeaconID)
	pointID = callingPointID
	beaconID = parentBeaconID
	Spring.SetUnitRulesParam(unitID, "beaconID", beaconID)
end

function Upgrade(level)
	if level == 2 and Upgrade2 then
		StartThread(Upgrade2)
	elseif level == 3 and Upgrade3 then
		StartThread(Upgrade3)
	end
end

function EnCrate()
	if crateLink then
		local x,y,z = Spring.GetUnitBasePosition(unitID)
		crateID = Spring.CreateUnit("crate", x,y,z, 0, teamID, false, false)
		Spring.UnitAttach(unitID, crateID, crateLink, true)
	end
end

function script.Create()
	if Setup then
		StartThread(Setup)
	end
	Sleep(100) -- wait a few frames
	if not Spring.GetUnitTransporter(unitID) then
		Spring.SetUnitRulesParam(unitID, "beaconID", unitID)
		Unloaded()
	end
end

function Unloaded(ry)
	if crateID then
		env = Spring.UnitScript.GetScriptEnv(crateID)
		Spring.UnitScript.CallAsUnit(crateID, env.Unloaded, unitDef.isFactory and ry or nil)
		GG.Delay.DelayCall(Spring.UnitDetach, {crateID}, 1)
	end
	StartThread(Unpack, ry)
end

function Unpack(ry)
	if unitDef.isFactory then
		-- AirCon and Vehiclepad are actual structure with yardmap as it needs factory buildoptions / commands
		-- Engine forces it to grid on unload, so turn model instead
		Turn(base, y_axis, (ry and ry - math.pi/2) or 0)
	end
	-- Wait for delivery van to bug out
	Sleep(2000)
	if crateID then
		-- Wait a little longer for the crate anim to play
		Sleep(2000)	
	end
	-- Begin outpost-specific anims
	if not isDZ then
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_" .. name .. "_deployed", 1)
	end
	if Deploy then
		StartThread(Deploy)
	end
end

function script.Killed(recentDamage, maxRepairth)
	if not Spring.GetUnitTransporter(unitID) and not isDZ then
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_" .. name .. "_destroyed", 1)
	end
	if crateID and not Spring.GetUnitIsDead(crateID) then
		Spring.DestroyUnit(crateID, false, true)
	end
end

---------------------------------------------------------------------
-- Weapon functions
---------------------------------------------------------------------
if unitDef.weapons[1] then

	-- Weapon pieces
	local flares = {}
	local barrels = {}
	local turrets = {}
	local mantlets = {}

	for i = 1, #unitDef.weapons do
		flares[i] = piece("flare_" .. i)
	end

	for i = 1,#unitDef.weapons do
		barrels[i] = piece("barrel_" .. i)
	end

	for i = 1,#unitDef.weapons do
		turrets[i] = piece("turret_" .. i)
		mantlets[i] = piece("mantlet_" .. i)
	end

	screws = {}
	for i = 1, 4 do
		screws[i] = piece("screw" .. i)
	end

	screwheads = {}
	for i = 1, 4 do
		screwheads[i] = piece("screwhead" .. i)
	end

	function script.AimWeapon(weaponID, heading, pitch)
		if noFiring then return false end
		Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
		SetSignalMask(2 ^ weaponID)
		if turrets[weaponID] then
			Turn(turrets[weaponID], y_axis, heading, CRATE_SPEED / 4)
			WaitForTurn(turrets[weaponID], y_axis)
			Turn(mantlets[weaponID], x_axis, -pitch, CRATE_SPEED / 4)
			WaitForTurn(mantlets[weaponID], x_axis)
		elseif 	name == "outpost_launcher" then
			local launcher, launchdoor1, launchdoor2, gantry, projectile = piece ("launcher", "launchdoor1", "launchdoor2", "gantry", "projectile")
			Move(launchdoor1, x_axis, 7, CRATE_SPEED * 8)
			Move(launchdoor2, x_axis, -7, CRATE_SPEED * 8)
			PlaySound("Whir_Small")
			WaitForMove(launchdoor1, x_axis)
			WaitForMove(launchdoor2, x_axis)
			Move(gantry, y_axis, 10, CRATE_SPEED * 8)
			PlaySound("Hydraulic")
			WaitForMove(gantry, y_axis)
		else
			Turn(flares[weaponID], y_axis, heading)
			Turn(flares[weaponID], x_axis, -pitch)
		end
		return true
	end

	function script.Shot(weaponID)
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
		if name == "outpost_artillery" then 
			Move(barrels[weaponID], z_axis, -25, CRATE_SPEED * 175)
			GG.EmitSfxName(unitID, base, "dust_bloom_big")
			Spring.AddUnitSeismicPing(unitID, 5)
			WaitForMove(barrels[weaponID], z_axis)
			Move(barrels[weaponID], z_axis, 0, CRATE_SPEED * 25)
			WaitForMove(barrels[weaponID], z_axis)
			for i = 1,25 do
				GG.EmitSfxName(unitID, piece("flare_1"), "barrelsmoke")
				Sleep(150)
			end
		end
		if Reload then
			StartThread(Reload)
		end
	end

	function script.AimFromWeapon(weaponID) 
		return flares[weaponID]
	end

	function script.QueryWeapon(weaponID) 
		return flares[weaponID]
	end

end