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

for weapName, wd in pairs(WeaponDefs) do 
	local cp = wd.customparams
	if cp then
		if cp.cegflare then
			cegCache[weapName] = cp.cegflare
		end
	end
end

for unitName, ud in pairs(UnitDefs) do
	local weapons = ud.weapons
	if weapons then
		if not ud.sfxtypes then
			ud.sfxtypes = { explosiongenerators = {} }
		end
		for weaponID = 1, #weapons do
			local cegFlare = cegCache[string.lower(weapons[weaponID].name)]
			if cegFlare then
				--Spring.Echo("cegFlare: " .. cegFlare)
				--if not table.contains(ud.sfxtypes.explosiongenerators, "custom:" .. cegFlare) then
					table.insert(ud.sfxtypes.explosiongenerators, "custom:" .. cegFlare)
				--end
			end
		end
		table.insert(ud.sfxtypes.explosiongenerators, "custom:JumpJetTrail")
		Spring.Echo("UNIT: " .. unitName)
		for _, i in pairs(ud.sfxtypes.explosiongenerators) do
			Spring.Echo(i)
		end
		Spring.Echo("~~~~~~")
	end
end