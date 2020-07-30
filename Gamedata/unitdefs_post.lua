-- USEFUL FUNCTIONS & INCLUDES
VFS.Include("LuaRules/Includes/utilities.lua", nil, VFS.ZIP)

local PROFILE_PATH 
local hoverMap
if Game then
	PROFILE_PATH = "maps/flagConfig/" .. Game.mapName .. "_profile.lua"
	if VFS.FileExists(PROFILE_PATH) then
		_, env = VFS.Include(PROFILE_PATH)
		hoverMap = env.hovers
	end
end

local function GetWeight(mass)
	mass = tonumber(mass)
	local light = mass < 40
	local medium = not light and mass < 60
	local heavy = not light and not medium and mass < 80
	local assault = not light and not medium and not heavy
	local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
	return weight
end


local roleSensors = {
	["scout"] 			= {radar = 1500,	sector = 80},
	["skirmisher"] 		= {radar = 1500,	sector = 65},
	["striker"] 		= {radar = 1500,	sector = 70},
	["juggernaut"] 		= {radar = 1500,	sector = 70},
	["brawler"] 		= {radar = 1500,	sector = 55},
	["multirole"] 		= {radar = 1500,	sector = 55},
	["sniper"]			= {radar = 1500,	sector = 45},
	["missile boat"]	= {radar = 1500,	sector = 45},
	["ranged"] 			= {radar = 1500,	sector = 55}, -- TODO: delete this
}

local menuRoleAlias = {
	["scout"]			= "fast",
	["skirmisher"]		= "fast",
	
	["striker"]			= "cqb",
	["juggernaut"]		= "cqb",
	
	["brawler"]			= "flexible",
	["multirole"] 		= "flexible",
	
	["sniper"]			= "ranged",
	["missile boat"]	= "ranged",
	["ranged"]			= "ranged", -- TODO: delete this
}

local function GetSpeedColoured(speed)
	local speedString = "\nSpeed: "
	if speed < 60 then -- red
		speedString = speedString .. "\255\255\001\001"
	elseif speed < 80 then -- orange
		speedString = speedString .. "\255\255\128\001"
	elseif speed < 110 then -- yellow
		speedString = speedString .. "\255\255\255\001"
	else -- green
		speedString = speedString .. "\255\001\255\001"
	end
	return speedString .. speed .. "\255\255\255\255 km/h"
end

local function GetRole(roleString)
	for role, info in pairs(roleSensors) do
		if roleString:lower():find(role) then
			return role
		end
	end
	return 
end

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


-- TODO: I still don't quite follow why the SIDES table from _pre (available to all defs) isn't available here
local sideData = VFS.Include("gamedata/sidedata.lua", VFS.ZIP)
local SIDES = {}
local VALID_SIDES = {}
for sideNum, data in pairs(sideData) do
	SIDES[sideNum] = data.shortName:lower()
	VALID_SIDES[data.shortName:lower()] = true
end

local function RecursiveReplaceStrings(t, name, side, replacedMap)
	if (replacedMap[t]) then
		return  -- avoid recursion / repetition
	end
	replacedMap[t] = true
	local changes = {}
	for k, v in pairs(t) do
		if (type(v) == 'string') then
			t[k] = v:gsub("<SIDE>", side):gsub("<NAME>", name)
		end
		if (type(v) == 'table') then
			RecursiveReplaceStrings(v, name, side, replacedMap)
		end
	end 
end

local function ReplaceStrings(t, name)
	local side = ""
	local replacedMap = {}
	for _, sideName in pairs(SIDES) do
		if name:find(sideName) == 1 then
			side = sideName
			break
		end
	end
	RecursiveReplaceStrings(t, name, side, replacedMap)
end

local ammoPerTon = lowerkeys(VFS.Include("gamedata/AmmoTypes.lua", nil, VFS.ZIP))
local armorTypes = lowerkeys(VFS.Include("gamedata/ArmorTypes.lua", nil, VFS.ZIP))

-- TODO: put this in a file and VFS.Include here and in the widget
local partsList	= {	mech	= {	"torso", "arm_left", "arm_right", "leg_left", "leg_right"},
					apc		= {	"turret", "base"},
					vehicle	= {	"turret", "base"},
					aero	= {	"body", "left_wing", "right_wing"},
					vtol	= {	"body", "rotor"},}

local spawnTable = {
	regular = {
		light = {},
		medium = {},
		heavy = {},
		assault = {},
	},
	apc = {
		light = {},
		medium = {},
		heavy = {},
		assault = {},
	},
	arty = {
		light = {},
		medium = {},
		heavy = {},
		assault = {},
	},
	vtol = {
		light = {},
		medium = {},
		heavy = {},
		assault = {},
	},
}
					
-- DROPZONES & spawn pads
local DROPZONE_UDS = {} --DZ_IDS = {shortSideName = unitDef}
local DROPZONE_BUILDOPTIONS = {} -- D_B = {shortSideName = {unitname1, ...}}

local VPAD_UD
local VPAD_SPAWNOPTIONS = {} -- V_S = {shortSideName = {unitname1, ...}}
local VPAD_HOUSE_REMOVE = {} -- V_R = {shortSideName = {oldUnitName = newUnitName}}

local HPAD_UD
local HPAD_SPAWNOPTIONS = {} -- H_S = {shortSideName = {unitname1, ...}}
local HPAD_HOUSE_REMOVE = {} -- H_R = {shortSideName = {oldUnitName = newUnitName}}

for i, sideName in pairs(SIDES) do
	DROPZONE_BUILDOPTIONS[sideName] = {}
	VPAD_HOUSE_REMOVE[sideName] = {}
	HPAD_HOUSE_REMOVE[sideName] = {}

	table.copy(spawnTable, VPAD_HOUSE_REMOVE[sideName])
	table.copy(spawnTable, HPAD_HOUSE_REMOVE[sideName])
	VPAD_SPAWNOPTIONS[sideName] = {
		{}, -- light & medium lvl 1
		{}, -- heavy outpost lvl 2
		{}, -- assault outpost lvl 3
	}
	HPAD_SPAWNOPTIONS[sideName] = {
		{}, -- light hover lvl 1
		{}, -- medium hover lvl 2
		{}, -- vtols lvl 3
	}
	for i = 1, 3 do 
		table.copy(spawnTable, VPAD_SPAWNOPTIONS[sideName][i])
		table.copy(spawnTable, HPAD_SPAWNOPTIONS[sideName][i])
	end
end

local TCONTROL_UD
local TCONTROL_BUILDOPTIONS = {}

for name, ud in pairs(UnitDefs) do
	-- Replace all occurences of <SIDE> and <NAME> with the respective values
	ReplaceStrings(ud, ud.unitname or name)
	if not ud.customparams then
		ud.customparams = {}
	end
	local cp = ud.customparams
	-- override nochasecategories so units don't do anything.
	--ud.category = (ud.category or "") .. " all"
	--ud.nochasecategory = (ud.nochasecategory or "") .. " all"
	local speed = (ud.maxvelocity or 0) * 30
	if speed > 0 or ud.canfly then
		ud.cantbetransported = false
	end
	if cp then
		if not ud.objectname then
			if cp.baseclass then
				ud.objectname = cp.baseclass .. "/" .. (cp.baseclass == "mech" and (ud.name:gsub(" ", "") .. "/") or "") .. name .. ".s3o"
			else -- dropship, for now
				ud.objectname = "dropship/" .. name .. ".s3o"
				cp.normaltex = "unittextures/normals/" .. ud.name .. "_Normals.dds"
			end
		end
	end
	if cp and cp.baseclass then -- mech, vehicle, apc, vtol, infantry
		local normalname = (cp.baseclass == "outpost" and name) or ud.name:gsub(" ", "")
		cp.normaltex = "unittextures/normals/" .. normalname .. "_Normals.dds"
		if not VFS.FileExists(cp.normaltex) then cp.normaltex = nil end
		ud.name = ud.name .. " " .. (cp.variant or "") -- concatenate variant code to name
		cp.infocard = {}
		if partsList[cp.baseclass] then -- infantry don't exist but won't show up on unitcard anwyay
			for _, partName in pairs(partsList[cp.baseclass]) do
				cp.infocard[partName] = "bitmaps/ui/infocard/" .. cp.baseclass .. "/" .. ud.name .. "/" .. partName .. ".png"
				if not VFS.FileExists(cp.infocard[partName]) then
					--Spring.Echo("WARNING: unitdefs_post.lua; No custom infocard piece (" .. partName .. ") for unit " .. ud.name)
					cp.infocard[partName] = "bitmaps/ui/infocard/" .. cp.baseclass .. "/dummy_" .. partName .. ".png"
				else
					--Spring.Echo("SUCCESS: unitdefs_post.lua; Found custom infocard piece (" .. partName .. ") for unit " .. ud.name)
				end
			end
		end
		if cp.tonnage then
			ud.mass = (cp.tonnage or 0) * 100
			if cp.armor then
				ud.maxdamage = cp.tonnage / 10 + cp.armor.tons * 1000
				ud.maxdamage = ud.maxdamage * (armorTypes[cp.armor.type] or 1)
			end
			cp.weightclass = GetWeight(cp.tonnage)
		end
		if cp.speed then
			ud.maxvelocity = tonumber(cp.speed or 0) / (cp.baseclass == "mech" and 20 or 30) -- convert kph to game speed
			--cp.torsoturnspeed = cp.speed * 5
		end
		if cp.maxammo then
			for ammoType, tons in pairs(cp.maxammo) do
				if ammoPerTon[ammoType] then
					cp.maxammo[ammoType] = tons * ammoPerTon[ammoType]
				else
					Spring.Echo("ERROR: unitdefs_post.lua; unknown ammoType (" .. ammoType .. ") for " .. ud.name)
				end
			end
		end
		if cp.baseclass == "mech" then
			ud.buildCostEnergy = (cp.tonnage or 0)
			-- scale prices by a multiplier from an origin of 4000
			local priceMult = modOptions and modOptions.pricemult or 1
			ud.buildCostMetal = ((cp.price or 0) * priceMult - (4000 * (priceMult - 1)))
			ud.power = ud.buildCostMetal * ud.buildCostEnergy
			if cp.jumpjets then
				ud.description = ud.description .. " \255\001\179\214[JUMP]"
			end
			if cp.masc then
				ud.description = ud.description .. " \255\128\026\179[MASC]"
			end
		elseif cp.baseclass == "infantry" then
			ud.radardistance = 1000 -- no sensors
			cp.sectorangle = 180
		elseif cp.baseclass == "outpost" then
			ud.buildcostmetal = ud.buildcostmetal * (modOptions.outpostmult or 1)
		end
	end
	-- set maxvelocity by modoption
	ud.maxvelocity = (ud.maxvelocity or 0) * (modOptions.speed or 0.65)
	ud.turninplace = not cp.wheels
	ud.turninplacespeedlimit = (tonumber(ud.maxvelocity) or 0) * (cp.wheels and 0.5 or 1 )
	
	-- calculate reverse, acceleration, brake and turning speed based on maxvelocity
	ud.maxreversevelocity = ud.maxvelocity / (cp.wheels and 1.5 or 1.5)
	ud.acceleration = ud.maxvelocity / (cp.wheels and 8 or 4)
	ud.brakerate = ud.maxvelocity / (cp.wheels and 50 or 25)
	ud.turnrate = ud.maxvelocity * (cp.wheels and 100 or 200) * (modOptions.turn or 1)
	cp.torsoturnspeed = cp.torsoturnspeed or (ud.maxvelocity * 50 * (modOptions.torso or 1)) -- for now keep this independent of turnrate so we can tweak them separately

	-- Deal with sensors
	if not name:find("decal") then -- everything
		if cp.dropship then
			ud.radardistance = 1500
			ud.sightdistance = 0
			ud.airsightdistance = modOptions.mechSight or 400
		end
		ud.sightdistance = ud.sightdistance or modOptions.mechsight
		if cp.baseclass == "mech" then -- mechs only
			table.insert(ud.weapons, {name = "sight"})
			
			cp.role = GetRole(ud.description)
			if cp.role then
				cp.menu = menuRoleAlias[cp.role]
			else
				Spring.Echo("Warning [unitdefs_post.lua]: Unit (" .. name .. ") has no known role (" .. ud.description .. ")")
			end
			cp.sectorangle = (cp.sectorangle or (cp.role and roleSensors[cp.role].sector)) * modOptions.sectorangle
			ud.radardistance = roleSensors[cp.role].radar * modOptions.radar
			ud.losemitheight = cp.cockpitheight or (ud.mass / 10)
			ud.radaremitheight = 100
			ud.seismicsignature = cp.tonnage / 10
			ud.airsightdistance = ud.sightdistance * 1.05
		else -- everything but mechs
			ud.seismicsignature = 0
			ud.radardistance = ud.radardistance or 0
			ud.airsightdistance = ud.radardistance
		end
		if cp.ecm then
			ud.radardistancejam	= 500
			ud.description = ud.description .. " \255\128\128\128[ECM]"
		end
		if cp.bap then
			ud.radaremitheight = 1000
			ud.airsightdistance = ud.radardistance
			ud.description = ud.description .. " \255\001\255\001[BAP]"
		end
	end
	-- track strength should be 1/1000th of mass
	if ud.leavetracks then
		ud.trackstrength = ud.mass / 1000
		cp.trackwidth = 1 - ((cp.trackwidth or 46)/512)
	end
	local weapons = ud.weapons
	local weaponCounts = {}
	if weapons then
		for i, weapon in pairs(weapons) do
			local weapName = weapon.name
			local weapNameL = weapName:lower()
			weaponCounts[weapName] = (weaponCounts[weapName] or 0) + 1
			if weapNameL == "ams" or weapNameL == "lams" then
				weapon.maxangledif = 360
				ud.description = ud.description .. " \255\230\160\016[AMS]"
			elseif weapNameL == "narc" then
				weapon.onlytargetcategory = "narctag"			
				ud.description = ud.description .. " \255\255\255\001[NARC]"
			elseif weapNameL == "tag" then
				weapon.onlytargetcategory = "narctag"			
				ud.description = ud.description .. " \255\255\051\051[TAG]"
			elseif cp.sectorangle and i == #weapons then -- sight
				weapon.onlytargetcategory = "nevertargetanythingever"
			else
				if cp.baseclass == "mech" then
					--[[ Give all mechs 179d torso twist
					weapon.maxangledif = 179
					end]]
					if i ~= 1 and i ~= #weapons then -- don't slave primary or sight weapon
						if not weapon.slaveto then -- don't overwrite unitdef
							weapon.slaveto = 1
						end
					end
				elseif cp.baseclass == vehicle then
					if not weapon.onlytargetcategory then
						weapon.onlytargetcategory = "ground"
					end
					cpwheelspeed = ud.maxvelocity * 166
				end
				weapon.onlytargetcategory = (weapon.onlytargetcategory or "") .. " notbeacon"
				weapon.badtargetcategory = (weapon.badtargetcategory or "") .. " dropship structure"
			end
		end
		cp.weaponCounts = weaponCounts -- stick this in here for weapondefs_post
		if cp.speed then
			ud.description = (ud.description or "") .. GetSpeedColoured(cp.speed)
		end
	end
	
	-- Automatically build dropship buildmenus
	local side = name:sub(1, 2)
	
	if (cp.baseclass == "mech" or cp.baseclass == "vehicle" or cp.baseclass == "vtol") and VALID_SIDES[side] then
		ud.category = ud.category .. " narctag"
		if not ud.canfly and not ud.movestate then
			ud.movestate = 0 -- Set default move state to Hold Position, unless already specified
		end
		if cp.baseclass == "mech" then -- add only mechs to Dropship buildoptions
			table.insert(DROPZONE_BUILDOPTIONS[side], name)
		else -- a vehicle
			ud.icontype = "vehicle" .. cp.weightclass
			local startTier = ((cp.weightclass == "light" or cp.weightclass == "medium") and 1) or (cp.weightclass == "heavy" and 2) or 3
			local hover = ud.movementclass == "HOVER" -- TODO: make hover a baseclass? (used in armordefs.lua, unitcard widget, game_radar, lus_helper, unitPieceHitVols, unit_vehiclePad, ...)
			local vtol = cp.baseclass == "vtol"
			local class = (ud.transportcapacity and "apc") or (cp.artillery and "arty") or (vtol and "vtol") or "regular"
			if cp.replaces then
				if hover or vtol then
					HPAD_HOUSE_REMOVE[side][class][cp.weightclass][cp.replaces] = true
				else
					VPAD_HOUSE_REMOVE[side][class][cp.weightclass][cp.replaces] = true
				end
			end
			for i = startTier, 3 do
				if hover or vtol then
					table.insert(HPAD_SPAWNOPTIONS[side][i][class][cp.weightclass], name)
				else
					table.insert(VPAD_SPAWNOPTIONS[side][i][class][cp.weightclass], name)
				end
			end
			ud.maxdamage = ud.maxdamage * 0.5
		end
	elseif cp.baseclass == "tower" and not name:find("garrison") then
		table.insert(TCONTROL_BUILDOPTIONS, name)
		ud.levelground = false
	end
	
	if name:find("dropzone") then
		DROPZONE_UDS[side] = ud
	end
		
	if name == "beacon" or cp.baseclass == "outpost" or cp.dropship then 
		if name == "beacon" then
			BEACON_UD = ud 
			ud.canselfdestruct = false
		elseif name == "outpost_turretcontrol" then
			TCONTROL_UD = ud
		elseif cp.dropship or name:find("dropzone") then
			ud.canselfdestruct = false
			ud.levelground = false
		elseif name:find("vehiclepad") then
			VPAD_UD = ud
		elseif name:find("hoverpad") then
			HPAD_UD = ud
		end
		ud.canmove = false
		ud.canrepair = false
		ud.canrestore = false
		ud.canpatrol = false
		ud.canguard = false
		ud.canreclaim = false
		ud.canfight = false
		ud.canassist = false
		ud.canrepeat = false
	end
end

local function sorter(a, b)
	local tonnageA = tonumber(UnitDefs[a].customparams.tonnage)
	local tonnageB = tonumber(UnitDefs[b].customparams.tonnage)
	if tonnageA == tonnageB then-- if they are the same, alphabetize
		return a < b
	else -- order by tonnage
		return  tonnageA < tonnageB
	end		
end

for side, dropZoneOptions in pairs(DROPZONE_BUILDOPTIONS) do
	table.sort(dropZoneOptions, sorter)
	DROPZONE_UDS[side]["buildoptions"] = dropZoneOptions
end

-- remove replaced versions in all tiers
-- VPAD_HOUSE_REMOVE[side][cp.weightclass][cp.replaces] = true
-- VPAD_HOUSE_REMOVE sideName = {light = {unitName = true, unitName2 = true , ... }, medium = {...}, ...}

-- TODO: function?
for side, sideTable in pairs(VPAD_HOUSE_REMOVE) do
	for tier = 1, 3 do
		for class, weightTable in pairs(sideTable) do
			for weightClass, weightTable in pairs(weightTable) do
				for removed in pairs(weightTable) do
					table.removeElement(VPAD_SPAWNOPTIONS[side][tier][class][weightClass], removed)
				end			
			end
		end
	end
end
for side, sideTable in pairs(HPAD_HOUSE_REMOVE) do
	for tier = 1, 3 do
		for class, weightTable in pairs(sideTable) do
			for weightClass, weightTable in pairs(weightTable) do
				for removed in pairs(weightTable) do
					table.removeElement(HPAD_SPAWNOPTIONS[side][tier][class][weightClass], removed)
				end			
			end
		end
	end
end

table.sort(TCONTROL_BUILDOPTIONS)
TCONTROL_UD["buildoptions"] = TCONTROL_BUILDOPTIONS
VPAD_UD.customparams.spawn = hoverMap and HPAD_SPAWNOPTIONS or VPAD_SPAWNOPTIONS
--HPAD_UD.customparams.spawn = HPAD_SPAWNOPTIONS
--table.echo(VPAD_UD.customparams.spawn)
--table.echo(HPAD_UD.customparams.spawn)

for name, ud in pairs(UnitDefs) do
	local cp = ud.customparams
	-- convert all customparams subtables back into strings for Spring
	if cp then
		for k, v in pairs (cp) do
			if type(v) == "table" or type(v) == "boolean" then
				cp[k] = table.serialize(v)
			end
		end
	end
end