-- Fake units and decals
function script.Create()
	if unitDef.name == "nuke_meltdown" then
		local EMIT_HEIGHT = 8
		--Spring.Echo("omg I am having a total meltdown!")
		local x,y,z = Spring.GetUnitBasePosition(unitID)
		PlaySound("meltdown")
		for i = 1, 30 * 5 do
			--GG.EmitSfxName(unitID, 1, "magnetar")
			--GG.EmitSfxName(unitID, 1, "magnetaraura")
			Spring.SpawnCEG("magnetar", x,y+EMIT_HEIGHT,z, 0,1,0, i * 10, 10)
			Spring.SpawnCEG("magnetaraura", x,y+EMIT_HEIGHT,z, 0,1,0, i * 10, 10)
			Sleep(30)
		end
		local nukeID = Spring.SpawnProjectile(WeaponDefNames["meltdown"].id, {pos = {x,y+EMIT_HEIGHT,z}, owner = unitID, team = teamID, ttl = 20})
		local wrecks = Spring.GetFeaturesInCylinder(x, z, 150)
		for _, wreckID in pairs(wrecks) do
			Spring.DestroyFeature(wreckID)
		end
		PlaySound("meltdown_boom")
		Spring.SetProjectileAlwaysVisible(nukeID, true)
		Sleep(3000)
		Spring.DestroyUnit(unitID)
	elseif unitDef.name == "naval_laser" then
		local TIME_TO_LIVE = 10
		local LASER_HEIGHT = 5000
		local MAX_SPEED = 15
		local x,y,z = Spring.GetUnitBasePosition(unitID)
		Spring.MoveCtrl.Enable(unitID)
		Spring.MoveCtrl.SetPosition(unitID, x, y + LASER_HEIGHT, z)
		--local sign = (-1)^math.random(1,2)
		--Spring.MoveCtrl.SetVelocity(unitID, sign * MAX_SPEED * math.random(), 0, sign * MAX_SPEED * math.random())
		GG.Delay.DelayCall(Spring.DestroyUnit, {unitID}, 30 * TIME_TO_LIVE)
	elseif unitDef.name == "noise" then
		StartThread(Noise)
	end
end

function Noise()
	while true do 
		--[[Spring.Echo("I'm alive!")
		local x,y,z = Spring.GetUnitBasePosition(unitID)
		Spring.MarkerAddPoint(x,y,z)]]
		Spring.AddUnitSeismicPing(unitID, math.random(3, 10))
		Sleep(500)
	end
end

function SetDir(dx, dy, dz)
	local MAX_SPEED = 5
	Spring.MoveCtrl.SetVelocity(unitID, dx * MAX_SPEED, 0, dz * MAX_SPEED)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(2^weaponID)
	SetSignalMask(2^weaponID)
	return true
end

function script.AimFromWeapon(weaponID)
	return 1
end

function script.QueryWeapon(weaponID)
	return 1
end

function script.TargetWeight(weaponID, targetID)
	local targetDefID = Spring.GetUnitDefID(targetID)
	local transported = Spring.GetUnitTransporter(targetID)
	return transported and 1000000 or GG.outpostDefs[targetDefID] and 0.01 or GG.mechCache[targetDefID] and 100 or 10000
end