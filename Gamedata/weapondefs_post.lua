function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local UnitDefs = DEFS.unitDefs

local cegCache = {}

local damageMults = {
	beacons		= 0,
	light		= 1,   --100% default
	medium		= 0.9, --80% default
	heavy		= 0.8, --60% default
	assault		= 0.6, --40% default
	vehicle		= 1.25, --150% default
	vtol		= 1.25, --150% default
	walls		= 0.8, -- 80% default
}

for weapName, wd in pairs(WeaponDefs) do 
	local cp = wd.customparams
	if cp then
		if cp.cegflare then
			cegCache[weapName] = cp.cegflare
		end
	end
	
	-- Apply damage multipliers
	local damage = wd.damage or {}
	local default = damage.default or 0
	for unitType, multiplier in pairs(damageMults) do
		if not damage[unitType] then -- don't override weaponDefs
			damage[unitType] = default * damageMults[unitType]
		end
	end
	if wd.weapontype == "MissileLauncher" or wd.weapontype == "StarburstLauncher" then
		wd.targetable = 1
		local jammable = cp.jammable
		if jammable == nil then -- nil check required due to bools
			wd.customparams.jammable = true
			--Spring.Echo(weapName .. " is a jammable missile")
		end
	elseif wd.weapontype == "BeamLaser" or cp and cp.ammotype == "gauss" then -- lasers and gauss are impactOnly
		wd.impactonly = true
	end
end

for unitName, ud in pairs(UnitDefs) do
	local weapons = ud.weapons
	if weapons then
		if not ud.sfxtypes then
			ud.sfxtypes = { explosiongenerators = {} }
		end
		-- for now all untis have jumpjet CEG as 1 (SFX.CEG)
		table.insert(ud.sfxtypes.explosiongenerators, 1, "custom:heavy_jumpjet_trail_blue")
		for weaponID = 1, #weapons do -- SFX.CEG + weaponID
			local cegFlare = cegCache[string.lower(weapons[weaponID].name)]
			if cegFlare then
				--Spring.Echo("cegFlare: " .. cegFlare)
				--if not table.contains(ud.sfxtypes.explosiongenerators, "custom:" .. cegFlare) then
					table.insert(ud.sfxtypes.explosiongenerators, weaponID + 1, "custom:" .. cegFlare)
				--end
			end
		end
		if ud.customparams.unittype then
			table.insert(ud.sfxtypes.explosiongenerators, "custom:HE_Large")
			table.insert(ud.sfxtypes.explosiongenerators, "custom:BlackSmoke")
			table.insert(ud.sfxtypes.explosiongenerators, "custom:Sparks")
		end
		--[[Spring.Echo("UNIT: " .. unitName)
		for _, i in pairs(ud.sfxtypes.explosiongenerators) do
			Spring.Echo(i)
		end
		Spring.Echo("~~~~~~")]]
	elseif unitName == "beacon" then
		ud.sfxtypes = { explosiongenerators = {} }
		table.insert(ud.sfxtypes.explosiongenerators, "custom:reentry_fx")
		table.insert(ud.sfxtypes.explosiongenerators, "custom:ROACHPLOSION")
		table.insert(ud.sfxtypes.explosiongenerators, "custom:beacon")
	elseif unitName:find("dropzone") then
		ud.sfxtypes = { explosiongenerators = {} }
		table.insert(ud.sfxtypes.explosiongenerators, "custom:beacon")
	end
end