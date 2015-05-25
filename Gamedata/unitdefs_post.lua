VFS.Include("LuaRules/Includes/utilities.lua", nil, VFS.ZIP)

local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

-- TODO: I still don't quite follow why the Sides table from _pre (available to all defs) isn't available here
local sideData = VFS.Include("gamedata/sidedata.lua", VFS.ZIP)
local Sides = {}
for sideNum, data in pairs(sideData) do
	Sides[sideNum] = data.shortName:lower()
end

local DROPZONE_UDS = {} --DZ_IDS = {shortSideName = unitDef}
local DROPZONE_BUILDOPTIONS = {} -- D_B = {shortSideName = {unitname1, ...}}
for i, sideName in pairs(Sides) do
	DROPZONE_BUILDOPTIONS[sideName] = {}
end

local UPLINK_UD
local BEACON_UD
local UPLINK_BUILDOPTIONS = {}


for name, ud in pairs(UnitDefs) do
	-- convert all customparams subtables back into strings for Spring
	if ud.customparams then
		for k, v in pairs (ud.customparams) do
			if type(v) == "table" or type(v) == "boolean" then
				ud.customparams[k] = table.serialize(v)
			end
		end
	end
	-- no OTA nanoframes please
	ud.shownanoframe = false
	ud.idleautoheal = 0
	-- override nochasecategories so units don't do anything.
	--ud.category = (ud.category or "") .. " all"
	--ud.nochasecategory = (ud.nochasecategory or "") .. " all"
	-- add buildpics to unitdefs even though engine loads them automatically, so the filenames are available to lua (Chili)
	ud.buildpic = name .. ".png"
	local speed = (ud.maxvelocity or 0) * 30
	if speed > 0 or ud.canfly then
		ud.cantbetransported = false
		if ud.customparams.unittype == "mech" then
			ud.losemitheight = ud.mass / 100
			ud.radaremitheight = ud.mass / 100
			if ud.customparams.canjump then
				ud.description = ud.description .. " \255\001\179\214[JUMP]"
			end
			if ud.customparams.canmasc then
				ud.description = ud.description .. " \255\128\026\179[MASC]"
			end
		end
	end
	-- set maxvelocity by modoption
	ud.maxvelocity = (ud.maxvelocity or 0) * (modOptions.speed or 0.65)
	ud.turninplacespeedlimit = (tonumber(ud.maxvelocity) or 0) * 1 
	ud.turninplace = false
	-- calculate reverse, acceleration, brake and turning speed based on maxvelocity
	ud.maxreversevelocity = ud.maxvelocity / 1.5
	ud.acceleration = ud.maxvelocity / 4
	ud.brakerate = ud.maxvelocity / 25
	ud.turnrate = ud.maxvelocity * 200
	-- set sightrange/radardistance based on hasbap customparam
	if ud.customparams.hasbap == "true" or ud.customparams.hasecm == "true" then
		ud.sightdistance = 1500
		ud.radardistance = 3000
		ud.airsightdistance = 3000
		if ud.customparams.hasecm == "true" then
			ud.seismicsignature = 20
			ud.radardistancejam	= 500
			ud.description = ud.description .. " \255\128\128\128[ECM]"
		else
			seismicsignature = 0
		end
		if ud.customparams.hasbap == "true" then
			ud.seismicdistance = 3000
			ud.radaremitheight = 1000
			ud.description = ud.description .. " \255\001\255\001[BAP]"
		end
	elseif not name:find("decal") then
		ud.seismicdistance = 0
		ud.sightdistance = 1000
		ud.radardistance = 2000
		ud.airsightdistance = 2000
		ud.seismicsignature = 0
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
				if ud.customparams.unittype then
					-- Give all mechs 179d torso twist
					--[[if ud.customparams.unittype == "mech" then
						weapon.maxangledif = 179
					end]]
					if i ~= 1 then
						if not weapon.slaveto then -- don't overwrite unitdef [sniper slaves 3 to 2]
							weapon.slaveto = 1
						end
					end
					if ud.customparams.unittype == vehicle then
						if not weapon.onlytargetcategory then
							weapon.onlytargetcategory = "ground"
						end
						ud.customparams.wheelspeed = ud.maxvelocity * 166
					end
				end
				weapon.onlytargetcategory = (weapon.onlytargetcategory or "") .. " notbeacon"
				weapon.badtargetcategory = (weapon.badtargetcategory or "") .. " dropship structure"
			end
		end
	end
	
	-- Automatically build dropship buildmenus
	local unitType = ud.customparams.unittype
	local side = name:sub(1, 2)
	
	if unitType == "mech" or unitType == "vehicle" then
		ud.category = ud.category .. " narctag"
		if not ud.canfly and not ud.movestate then
			ud.movestate = 0 -- Set default move state to Hold Position, unless already specified
		end
		if unitType == "mech" then -- add only mechs to Dropship buildoptions
			table.insert(DROPZONE_BUILDOPTIONS[side], name)
		else -- a vehicle
			ud.maxdamage = ud.maxdamage * 0.5
		end
	elseif ud.customparams.towertype then
		table.insert(UPLINK_BUILDOPTIONS, name)
		ud.levelground = false
	end
	
	if name:find("dropzone") then
		DROPZONE_UDS[side] = ud
	end
		
	if name == "beacon" or name:find("upgrade") or name:find("dropzone") or ud.customparams.dropship then 
		if name == "beacon" then
			BEACON_UD = ud 
			ud.canselfdestruct = false
		elseif name == "upgrade_uplink" then
			UPLINK_UD = ud
		elseif ud.customparams.dropship or name:find("dropzone") then
			ud.canselfdestruct = false
			ud.levelground = false
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

for side, dropZoneOptions in pairs(DROPZONE_BUILDOPTIONS) do
	table.sort(dropZoneOptions)
	DROPZONE_UDS[side]["buildoptions"] = dropZoneOptions
end

table.sort(UPLINK_BUILDOPTIONS)
UPLINK_UD["buildoptions"] = UPLINK_BUILDOPTIONS

