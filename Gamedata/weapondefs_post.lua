VFS.Include("LuaRules/Includes/utilities.lua", nil, VFS.ZIP)

local UnitDefs = DEFS.unitDefs
local FeatureDefs = DEFS.featureDefs

local FUNCTIONS_TO_REMOVE = {"new", "clone", "append"}

local cegCache = {}

local modOptions = Spring.GetModOptions()
if not modOptions.startmetal then -- load via file
	local raw = VFS.Include("modoptions.lua", nil, VFS.ZIP)
	for i, v in ipairs(raw) do
		if v.type ~= "section" then
			modOptions[v.key] = v.def
		end
	end
	raw = VFS.Include("engineoptions.lua", nil, VFS.ZIP)
	for i, v in ipairs(raw) do
		if v.type ~= "section" then
			modOptions[v.key:lower()] = v.def
		end
	end
end

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

local function FloatTo128(num)
	return string.char(string.format("%03d",math.max(num * 255, 1)))
end

local function RGBtoString(rgbstring)
	local rgb = {}
	for i in string.gmatch(rgbstring, "%S+") do
		table.insert(rgb, i)
	end
	return '\255' .. FloatTo128(rgb[1]) .. FloatTo128(rgb[2]) .. FloatTo128(rgb[3])
end

local function WeaponColour(weapName)
	weapName = weapName:lower()
	local colour = WeaponDefs[weapName].rgbcolor
	if not colour then 
		if weapName:find("arrow") then -- black
			colour = "\255\001\001\001"
		elseif weapName:find("srm") then -- dark grey
			colour = "\255\064\064\064"
		elseif weapName:find("mrm") then -- mid grey
			colour = "\255\128\128\128"
		elseif weapName:find("lrm") then -- light grey
			colour = "\255\192\192\192"
		else
			colour = "\255\255\255\255"
		end
	else
		colour = RGBtoString(colour)
	end
	return colour
end

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
	else
		cp = {}
	end
	
	-- Apply damage multipliers
	local damage = wd.damage or {}
	local default = damage.default or 0
	for unitType, multiplier in pairs(damageMults) do
		if not damage[unitType] then -- don't override weaponDefs
			damage[unitType] = default * damageMults[unitType] * (modOptions.damagemult or 1)
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
	cp.textcolour = WeaponColour(weapName)
	-- remove the functions so Spring doesn't complain about invalid tags
	for _, f in pairs(FUNCTIONS_TO_REMOVE) do
		wd[f] = nil
	end
end

for unitName, ud in pairs(UnitDefs) do
	local weapons = ud.weapons
	if weapons or ud.canreclaim then -- TODO: remove stupid hack for BRVs
		if not ud.sfxtypes then
			ud.sfxtypes = { explosiongenerators = {} }
		end
		-- for now all untis have jumpjet CEG as 1 (SFX.CEG)
		table.insert(ud.sfxtypes.explosiongenerators, 1, "custom:heavy_jumpjet_trail_blue")
		local cp = ud.customparams
		if weapons then
			for weaponID = 1, #weapons - (cp.baseclass == "mech" and 1 or 0) do -- SFX.CEG + weaponID
				local cegFlare = cegCache[string.lower(weapons[weaponID].name)]
				if cegFlare then
					--Spring.Echo("cegFlare: " .. cegFlare)
					--if not table.contains(ud.sfxtypes.explosiongenerators, "custom:" .. cegFlare) then
						table.insert(ud.sfxtypes.explosiongenerators, weaponID + 1, "custom:" .. cegFlare)
					--end
				end
			end
		end
		if cp.baseclass == "mech" or cp.baseclass == "vehicle" or cp.baseclass == "vtol" or cp.baseclass == "aero" then
			table.insert(ud.sfxtypes.explosiongenerators, "custom:HE_Large")
			table.insert(ud.sfxtypes.explosiongenerators, "custom:BlackSmoke")
			table.insert(ud.sfxtypes.explosiongenerators, "custom:Sparks")
			if ud.corpse then
				--Spring.Echo("[WeaponDefs_post.lua]:" .. unitName .. " has a corpse (" .. ud.corpse .. ")")
				local modelPath = ud.objectname:sub(1, -(string.len(unitName .. ".s3o")+1))
				-- First level corpse
				FeatureDefs[ud.corpse] = Feature:New{
					damage = ud.maxdamage * 0.5,
					description = "Wrecked " .. ud.name,
					mass = ud.mass,
					metal = (cp.price or 200) * 0.5,
					featuredead = ud.corpse .. "x",
					footprintx = ud.footprintx,
					footprintz = ud.footprintz,
					object = cp.baseclass == "mech" and ud.objectname or modelPath .. "corpse/" .. unitName .. "_x.s3o",
					customparams = {["was"] = ud.name},
					reclaimable = true,
					upright = cp.baseclass == "mech",
				}
				-- Second level corpse
				FeatureDefs[ud.corpse .. "x"] = Feature:New{
					damage = ud.maxdamage * 0.5,
					description = "Destroyed " .. ud.name,
					mass = ud.mass,
					metal = (cp.price or 200) * 0.25,
					featuredead = "wreck_x",
					footprintx = ud.footprintx,
					footprintz = ud.footprintz,
					object = cp.baseclass == "mech" and ud.objectname or modelPath .. "corpse/" .. unitName .. "_x.s3o",
					customparams = {["was"] = ud.name},
					reclaimable = true,
					upright = cp.baseclass == "mech",
				}
				if not VFS.FileExists("objects3d/" .. modelPath .. "corpse/" .. unitName .. "_x.s3o") then
					--Spring.Echo("[WeaponDefs_post.lua]: Missing corpse object; " .. modelPath .. "corpse/" .. unitName .. "_x.s3o")
				end
			else
				--Spring.Echo("[WeaponDefs_post.lua]:" .. unitName .. " has no corpse!")
			end
			local weapString = "\t\t\255\255\255\255Weapons: "
			for weapName, count in pairs(table.unserialize(cp.weaponCounts)) do
				if weapName:lower() ~= "sight" then
					weapString = weapString .. WeaponColour(weapName) .. weapName .. " \255\255\255\255x" .. count .. ", "
				end
			end
			ud.description = (ud.description or "") .. weapString
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

for featureName, fd in pairs(FeatureDefs) do
	local cp = fd.customparams
	if not (cp and cp.was) then
		fd.reclaimable = false -- force all non corpses to be non salvageable
	end
end