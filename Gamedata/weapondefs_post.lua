VFS.Include("LuaRules/Includes/utilities.lua", nil, VFS.ZIP)

local UnitDefs = DEFS.unitDefs
local FeatureDefs = DEFS.featureDefs

local FUNCTIONS_TO_REMOVE = {"new", "clone", "append"}

local cegCache = {}

local modOptions = Spring.GetModOptions()
if not modOptions.startcbills then -- load via file
	local raw = VFS.Include("modoptions.lua", nil, VFS.ZIP)
	for i, v in ipairs(raw) do
		if v.type ~= "section" then
			modOptions[v.key] = v.def
		end
	end
end

local GameConstants = VFS.Include("gamedata/GameConstants.lua", nil, VFS.ZIP)
local damageMults = GameConstants.damageMults

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
			if unitType == "vehicle" then
				damage[unitType] = damage[unitType] * (modOptions.vehdamagemult or 1)
			end
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
		if wd.impactonly == nil then -- explicitly check for nil as we don't want to override false
			wd.impactOnly = true
		end
		wd.minintensity = 1.0
	end
	cp.textcolour = WeaponColour(weapName)
	-- remove the functions so Spring doesn't complain about invalid tags
	for _, f in pairs(FUNCTIONS_TO_REMOVE) do
		wd[f] = nil
	end
	if wd.range then
		wd.range = wd.range * (modOptions.rangemult or 1)
		if cp and cp.minrange then
			cp.minrange = cp.minrange * (modOptions.rangemult or 1)
		end
	end
end

for unitName, ud in pairs(UnitDefs) do
	local weapons = ud.weapons
	if weapons or ud.canreclaim then -- TODO: remove stupid hack for BRVs
		if not ud.sfxtypes then
			ud.sfxtypes = { explosiongenerators = {} }
		end
		-- for now all units have jumpjet CEG as 1 (SFX.CEG)
		table.insert(ud.sfxtypes.explosiongenerators, 1, "custom:heavy_jumpjet_trail_blue")
		local cp = ud.customparams
		if weapons then
			local maxrange = 0
			for weaponID = 1, #weapons - (cp.sectorangle and 1 or 0) do -- SFX.CEG + weaponID
				local cegFlare = cegCache[string.lower(weapons[weaponID].name)]
				if cegFlare then
					--Spring.Echo("cegFlare: " .. cegFlare)
					--if not table.contains(ud.sfxtypes.explosiongenerators, "custom:" .. cegFlare) then
						table.insert(ud.sfxtypes.explosiongenerators, weaponID + 1, "custom:" .. cegFlare)
					--end
				end
				--Spring.Echo(WeaponDefs, weapons[weaponID].name, WeaponDefs[string.lower(weapons[weaponID].name)])
				if (WeaponDefs[string.lower(weapons[weaponID].name)].range or 0) > maxrange then
					maxrange = WeaponDefs[string.lower(weapons[weaponID].name)].range
					cp.maxrangeid = weaponID
				end
			end
			cp.maxrange = maxrange
		end
		if cp.baseclass == "mech" or cp.baseclass == "vehicle" or cp.baseclass == "vtol" or cp.baseclass == "aero" then
			table.insert(ud.sfxtypes.explosiongenerators, "custom:HE_Large")
			table.insert(ud.sfxtypes.explosiongenerators, "custom:BlackSmoke")
			table.insert(ud.sfxtypes.explosiongenerators, "custom:Sparks")
			if ud.corpse and not FeatureDefs[ud.corpse] then -- don't override existing corpses e.g. Bishop
				--Spring.Echo("[WeaponDefs_post.lua]:" .. unitName .. " has a corpse (" .. ud.corpse .. ")")
				local modelPath = ud.objectname:sub(1, -(string.len(unitName .. ".s3o")+1))
				-- First level corpse
				local corpseModelBase = modelPath .. "corpse/" .. unitName:sub(4,-1) .. "_x"
				local corpseModels = {
					_x = corpseModelBase .. ".s3o",
				}
				if cp.baseclass == "mech" then
					corpseModels._x_both = corpseModelBase .. "_both.s3o"
					corpseModels._x_left = corpseModelBase .. "_left.s3o"
					corpseModels._x_right = corpseModelBase .. "_right.s3o"
				end
				-- check base corpse first
				local corpseModelBaseExists = VFS.FileExists("objects3d/" .. corpseModels._x, VFS.ZIP)
				if not corpseModelBaseExists then
					--Spring.Echo("[WeaponDefs_post.lua]:" .. unitName .. " has a corpse but the base model does not exist!")
				end
				for corpseType, path in pairs(corpseModels) do
					local corpseModelExists = VFS.FileExists("objects3d/" .. path, VFS.ZIP)
					corpseModel = (corpseModelExists and path) or (corpseModelBaseExists and corpseModels._x) or ud.objectname
					--Spring.Echo("corspeModel", corpseType, path, corpseModel, corpseModelExists)
					FeatureDefs[unitName .. corpseType] = Feature:New{
						damage = ud.maxdamage * 0.5,
						description = "Wrecked " .. ud.name,
						mass = ud.mass,
						metal = (cp.price or 200) * 0.5,
						featuredead = "wreck_x",
						footprintx = ud.footprintx,
						footprintz = ud.footprintz,
						object = corpseModel,
						customparams = {
							["was"] = ud.name,
							["normaltex"] = cp.normaltex,
						},
						reclaimable = true,
						upright = cp.baseclass == "mech",
					}
				end
			else
				--Spring.Echo("[WeaponDefs_post.lua]:" .. unitName .. " has no corpse!")
			end
			local weapString = "\t\t\255\255\255\255Weapons: "
			for weapName, count in pairs(table.unserialize(cp.weaponCounts)) do
				if weapName:lower() ~= "sight" then
					weapString = weapString .. WeaponColour(weapName) .. weapName .. " \255\255\255\255x" .. count .. ",\t"
				end
			end
			ud.description = (ud.description or "") .. weapString:sub(1, -3)
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
	if not ud.corpse then
		ud.customparams.wrecktex1 = "unittextures/wreck.dds"
		--Spring.Echo(unitName, "using defalt wreck.dds")
	end
end

local function isModelOK(fd)
 	local specifiesModel = fd.object and (fd.object ~= "")
 
 	-- explicitly modelless (geo etc)
 	if fd.drawtype == -1 and not specifiesModel then
 		return true
 	end
 
 	-- implicitly modelless
 	if not fd.drawtype and not specifiesModel then
 		return true
 	end
 
 	-- explicitly specified to use a model, but doesn't provide one (gigachad.jpg)
 	if fd.drawtype == 0
 	and not specifiesModel then
 		return false
 	end
 
 	-- old tree renderer removed from engine
 	if tonumber(fd.drawtype or 0) > 0 then
 		return false
 	end
 
 	local modelPath = "objects3d/" .. fd.object
 	return VFS.FileExists(modelPath          , VFS.ZIP)
 	    or VFS.FileExists(modelPath .. ".3do", VFS.ZIP)
 end
 
 
local trees = {
	"pine",
	"oak",
	"palm"
}
local notTrees = {
	"street"
}

for featureName, fd in pairs(FeatureDefs) do
	fd.customparams = fd.customparams or {}
	local cp = fd.customparams
	if not (cp and cp.was) then
		fd.reclaimable = false -- force all non corpses to be non salvageable
	end
	if not isModelOK(fd) then -- should be caught earlier (L142) but, bolts and braces
 		Spring.Log("weapondefs_post.lua", LOG.WARNING, "Removing feature def", featureName, "for having invalid model that would crash the engine", fd.object)
 		FeatureDefs[featureName] = nil
 	end
	for i, whiteList in pairs(trees) do
		if featureName:find(whiteList) or fd.description:lower():find(whiteList) then
			fd.customparams.uniformbin = "tree"
		end
	end
	for i, blackList in pairs(notTrees) do
		if (featureName:find(blackList) or fd.description:lower():find(blackList)) and fd.customparams.uniformbin == "tree" then
			fd.customparams.uniformbin = "feature"
		end
	end
end