local armorDefs = {
   dropships = {
		"CL_Factory",
		"IS_Factory",	
   },
   beacons = {
		"beacon",
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
