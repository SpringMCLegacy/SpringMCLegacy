local armorDefs = {
	dropships = {
		"CL_Factory",
		"IS_Factory",	
	},
	beacons = {
		"beacon",
		"outpost_c3center",
		"outpost_vehicledepot",
		"outpost_listeningpost",
		"outpost_garrison",
		"outpost_controltower",
	},
	light = {
		"IS_Locust",
		"IS_Osiris",
		"IS_Wolfhound",
		"IS_Owens",
		"IS_Raven",
		"IS_Hollander",
		"CL_Firemoth",
		"CL_Kitfox",
		"CL_MistLynx",
		"CL_Cougar",
		"CL_Adder",
	},
	medium = {
		"IS_Chimera",
		"IS_Bushwacker",
		"CL_Iceferret",
		"CL_Nova",
		"CL_Stormcrow",
		"CL_Shadowcat",
	},
	heavy = {
		"IS_Orion",
		"IS_Warhammer",
		"IS_Catapult",
		"CL_Summoner",
		"CL_Timberwolf",
		"CL_Hellbringer",
		"CL_Maddog",
	},
	assault = {
		"IS_Awesome",
		"IS_Atlas",
		"IS_Devastator",
		"CL_Warhawk",
		"CL_Direwolf",
		"KH_Mauler",
	},
    vehicle = {
		"IS_Harasser",
		"IS_Scorpion_ac5",
		"IS_Scorpion_lgauss",
		"IS_Goblin",
		"IS_Schrek",
		"IS_Demolisher",
		"IS_Challenger",
		"IS_LRMCarrier",
		"IS_Sniper",
		"IS_Partisan",
		"CL_Hephaestus",
		"CL_Enyo",
		"CL_Oro_lbx",
		"CL_Ares",
		"CL_Oro_hag",
		"CL_Morrigu",
		"CL_Mars",
		"CL_Huit",
	},
	--[[aerospace = {
		"",
	},--]]
	vtol = {
		"IS_Hawkmoth",
		"CL_Donar",
	},
}
-- convert to named maps  (trepan is a noob)
for categoryName, categoryTable in pairs(armorDefs) do
  local t = {}
  for _, unitName in pairs(categoryTable) do
    t[unitName] = 1
  end
  armorDefs[categoryName] = t
end

local system = VFS.Include('gamedata/system.lua')  

return system.lowerkeys(armorDefs)
