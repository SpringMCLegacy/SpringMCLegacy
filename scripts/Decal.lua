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
	end
end