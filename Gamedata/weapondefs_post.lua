VFS.Include("LuaRules/Includes/utilities.lua", nil, VFS.ZIP)

local UnitDefs = DEFS.unitDefs
local FeatureDefs = DEFS.featureDefs

local FUNCTIONS_TO_REMOVE = {"new", "clone", "append"}

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
		for k, v in pairs (cp) do
			if type(v) == "table" or type(v) == "boolean" then
				wd.customparams[k] = table.serialize(v)
			end
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
	if (wd.weapontype ~= nil) and (string.lower(wd.weapontype) == "missilelauncher" or string.lower(wd.weapontype) == "starburstlauncher") then
		wd.targetable = 1
		--Spring.Echo(weapName .. " is a targetable missile")
		local jammable = cp.jammable
		if jammable == nil then -- nil check required due to bools
			wd.customparams.jammable = true
			--Spring.Echo(weapName .. " is a jammable missile")
		end
	elseif (wd.weapontype ~= nil) and (string.lower(wd.weapontype) == "beamlaser" or cp and cp.ammotype == "gauss") then -- lasers and gauss are impactOnly
		wd.impactonly = true
		wd.minintensity = 1.0
	end
	
	-- remove the functions so Spring doesn't complain about invalid tags
	for _, f in pairs(FUNCTIONS_TO_REMOVE) do
		wd[f] = nil
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
			if ud.corpse then
				--Spring.Echo("[WeaponDefs_post.lua]:" .. unitName .. " has a corpse (" .. ud.corpse .. ")")
				-- First level corpse
				FeatureDefs[ud.corpse] = Feature:New{
					damage = ud.maxdamage * 0.5,
					description = "Wrecked " .. ud.name,
					mass = ud.mass,
					metal = (ud.buildcostmetal or 200) * 0.5,
					featuredead = ud.corpse .. "x",
					footprintx = ud.footprintx,
					footprintz = ud.footprintz,
					object = ud.objectname,
				}
				-- Second level corpse
				local modelPath = ud.objectname:sub(1, -(string.len(unitName .. ".s3o")+1))
				FeatureDefs[ud.corpse .. "x"] = Feature:New{
					damage = ud.maxdamage * 0.5,
					description = "Destroyed " .. ud.name,
					mass = ud.mass,
					metal = (ud.buildcostmetal or 200) * 0.25,
					featuredead = "wreck_x",
					footprintx = ud.footprintx,
					footprintz = ud.footprintz,
					object = modelPath .. "corpse/" .. unitName .. "_x.s3o",
				}
				if not VFS.FileExists("objects3d/" .. modelPath .. "corpse/" .. unitName .. "_x.s3o") then
					Spring.Echo("[WeaponDefs_post.lua]: Missing corpse object; " .. modelPath .. "corpse/" .. unitName .. "_x.s3o")
				end
			else
				--Spring.Echo("[WeaponDefs_post.lua]:" .. unitName .. " has no corpse!")
			end
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
	elseif unitName:find("dropzone") or unitName:find("vehiclepad") then
		ud.sfxtypes = { explosiongenerators = {} }
		table.insert(ud.sfxtypes.explosiongenerators, "custom:beacon")
	end
end