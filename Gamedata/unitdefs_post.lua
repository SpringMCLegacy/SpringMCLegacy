-- USEFUL FUNCTIONS & INCLUDES
VFS.Include("LuaRules/Includes/utilities.lua", nil, VFS.ZIP)

local function GetWeight(mass)
	mass = tonumber(mass)
	local light = mass < 40
	local medium = not light and mass < 60
	local heavy = not light and not medium and mass < 80
	local assault = not light and not medium and not heavy
	local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
	return weight
end

local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
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

-- DROPZONES & Vpads
local DROPZONE_UDS = {} --DZ_IDS = {shortSideName = unitDef}
local DROPZONE_BUILDOPTIONS = {} -- D_B = {shortSideName = {unitname1, ...}}

local VPAD_UDS = {} --V_IDS = {shortSideName = unitDef}
local VPAD_SPAWNOPTIONS = {} -- V_S = {shortSideName = {unitname1, ...}}
local VPAD_REPLACES = {} -- V_R = {shortSideName = {oldUnitName = newUnitName}}

for i, sideName in pairs(SIDES) do
	DROPZONE_BUILDOPTIONS[sideName] = {}
	VPAD_REPLACES[sideName] = {}
	VPAD_SPAWNOPTIONS[sideName] = {
		light = {},
		medium = {},
		heavy = {},
		assault = {},
		apc = {},
		arty = {
			light = {},
			medium = {},
			heavy = {},
			assault = {},
		},
	}
end

local UPLINK_UD
local BEACON_UD
local UPLINK_BUILDOPTIONS = {}


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
	if cp and cp.baseclass then
		if not ud.objectname then
			ud.objectname = cp.baseclass .. "/" .. (cp.baseclass == "mech" and (ud.name:gsub(" ", "") .. "/") or "") .. name .. ".s3o"
		end
	end
	if cp and cp.baseclass then -- mech, vehicle, apc, vtol, infantry
		cp.normaltex = "unittextures/normals/" .. ud.name:gsub(" ", "") .. "_Normals.dds"
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
			cp.torsoturnspeed = cp.speed * 5
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
			ud.losemitheight = ud.mass / 10
			ud.radaremitheight = ud.mass / 10
			if cp.jumpjets then
				ud.description = ud.description .. " \255\001\179\214[JUMP]"
			end
			if cp.masc then
				ud.description = ud.description .. " \255\128\026\179[MASC]"
			end
		end
	end
	-- set maxvelocity by modoption
	ud.maxvelocity = (ud.maxvelocity or 0) * (modOptions.speed or 0.65)
	ud.turninplacespeedlimit = (tonumber(ud.maxvelocity) or 0) * 1 
	
	-- calculate reverse, acceleration, brake and turning speed based on maxvelocity
	ud.maxreversevelocity = ud.maxvelocity / 1.5
	ud.acceleration = ud.maxvelocity / 4
	ud.brakerate = ud.maxvelocity / 25
	ud.turnrate = ud.maxvelocity * 200
	if not name:find("decal") then
		ud.seismicdistance = 0
		ud.sightdistance = 1000
		ud.radardistance = 2000
		ud.airsightdistance = 2000
		ud.seismicsignature = 0
	end
	-- set sightrange/radardistance based on bap customparam
	if cp.ecm then
		ud.seismicsignature = 20
		ud.radardistancejam	= 500
		ud.description = ud.description .. " \255\128\128\128[ECM]"
	end
	if cp.bap then
		ud.seismicdistance = 3000
		ud.radaremitheight = 1000
		ud.radardistance = 3000
		ud.description = ud.description .. " \255\001\255\001[BAP]"
	end
	-- track strength should be 1/1000th of mass
	if ud.leavetracks then
		ud.trackstrength = ud.mass / 1000
	end
	local weapons = ud.weapons
	if weapons then
		for i, weapon in pairs(weapons) do
			if weapon.name:lower() == "ams" or weapon.name:lower() == "lams" then
				weapon.maxangledif = 360
				ud.description = ud.description .. " \255\230\160\016[AMS]"
			elseif weapon.name:lower() == "narc" then
				weapon.onlytargetcategory = "narctag"			
				ud.description = ud.description .. " \255\255\255\001[NARC]"
			elseif weapon.name:lower() == "tag" then
				weapon.onlytargetcategory = "narctag"			
				ud.description = ud.description .. " \255\255\051\051[TAG]"
			else
				if cp.baseclass == "mech" then
					--[[ Give all mechs 179d torso twist
					weapon.maxangledif = 179
					end]]
					if i ~= 1 then
						if not weapon.slaveto then -- don't overwrite unitdef [sniper slaves 3 to 2]
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
	end
	
	-- Automatically build dropship buildmenus
	local side = name:sub(1, 2)
	
	if (cp.baseclass == "mech" or cp.baseclass == "vehicle") and VALID_SIDES[side] then
		ud.category = ud.category .. " narctag"
		if not ud.canfly and not ud.movestate then
			ud.movestate = 0 -- Set default move state to Hold Position, unless already specified
		end
		if cp.baseclass == "mech" then -- add only mechs to Dropship buildoptions
			table.insert(DROPZONE_BUILDOPTIONS[side], name)
		else -- a vehicle
			if ud.transportcapacity then
				table.insert(VPAD_SPAWNOPTIONS[side]["apc"], name)
			elseif cp.artillery then
				table.insert(VPAD_SPAWNOPTIONS[side]["arty"][cp.weightclass], name)
			elseif cp.replaces then
				VPAD_REPLACES[side][cp.replaces] = name
			else
				table.insert(VPAD_SPAWNOPTIONS[side][cp.weightclass], name)
			end
			ud.maxdamage = ud.maxdamage * 0.5
		end
	elseif cp.baseclass == "tower" then
		table.insert(UPLINK_BUILDOPTIONS, name)
		ud.levelground = false
	end
	
	if name:find("dropzone") then
		DROPZONE_UDS[side] = ud
	end
		
	if name == "beacon" or cp.baseclass == "upgrade" or cp.dropship then 
		if name == "beacon" then
			BEACON_UD = ud 
			ud.canselfdestruct = false
		elseif name == "upgrade_uplink" then
			UPLINK_UD = ud
		elseif cp.dropship or name:find("dropzone") then
			ud.canselfdestruct = false
			ud.levelground = false
		elseif name:find("vehiclepad") then
			VPAD_UDS[side] = ud
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
	
	-- convert all customparams subtables back into strings for Spring
	if cp then
		for k, v in pairs (cp) do
			if type(v) == "table" or type(v) == "boolean" then
				cp[k] = table.serialize(v)
			end
		end
	end
end

for side, dropZoneOptions in pairs(DROPZONE_BUILDOPTIONS) do
	table.sort(dropZoneOptions)
	DROPZONE_UDS[side]["buildoptions"] = dropZoneOptions
end

for side, vPadSpawnOptions in pairs(VPAD_SPAWNOPTIONS) do
	VPAD_UDS[side].customparams.spawn = vPadSpawnOptions
	VPAD_UDS[side].customparams.house = VPAD_REPLACES[side]
	Spring.Echo("PRINT SPAWNTABLE FOR " .. side)
	table.echo(vPadSpawnOptions)
	Spring.Echo("PRINT REPLACE TABLE FOR " .. side)
	table.echo(VPAD_REPLACES[side])
end

table.sort(UPLINK_BUILDOPTIONS)
UPLINK_UD["buildoptions"] = UPLINK_BUILDOPTIONS