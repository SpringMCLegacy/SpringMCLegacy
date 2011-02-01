function gadget:GetInfo()
	return {
		name      = "NARC Beacon!",
		desc      = "Lets pew happen via the sight of seeing things",
		author    = "Nemo, Spikedhelmet",
		date      = "17 Aug 2010, 1 Feb 2011",
		license   = "LGPL v2",
		layer     = 0,
		enabled   = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
-- SYNCED

function gadget:Explosion(weaponId, px, py, pz, ownerID)
	local weapDef = WeaponDefs[weaponId]
	if not weapDef.customParams.narc or weapDef.customParams.narc ~= "1" or ownerID == nil then
		--Spring.Echo("not a narc sadface.jpg")
		return false
	else
		local team = Spring.GetUnitTeam(ownerID)
		--Spring.Echo("Made a NARC Beacon!!")
		Spring.CreateUnit("narcspot", px, py, pz, 0, team)
	end
	
end

function gadget:UnitCreated(unitID, unitDefID)
	local ud = UnitDefs[unitDefID]
	if ud.name == "narcspot" then
		Spring.SetUnitNoSelect(unitID, true)
	end
end

function gadget:Initialize()
	for weaponId, weaponDef in pairs (WeaponDefs) do
		if weaponDef.customParams.narc then
			Script.SetWatchWeapon(weaponId, true)
		end
	end
end

end