function widget:GetInfo()
  return {
    name      = "coordinates helper v1",
    desc      = "(for mapmarkers) helps with finding the correct coordinates when placing rocks by logging marker coordinates in infolog.txt",
    author    = "knorke",
    date      = "9 Nov 2010",
    license   = "GNU GPL, v2 or later or horse",
    layer     = 0,
    enabled   = false,  --  loaded by default?
  }
end


local coordfile = nil


local function log_coord (px, pz, label)
local coordfile_fn = Game.mapName .. "_coordinates.txt"
if (coordfile==nil) then
        coordfile = io.open (coordfile_fn, "w") 
        if (coordfile) then Spring.Echo ("tp_coordinate:  coordinate logfile opened: " .. coordfile_fn) else Spring.Echo ("tp_coordinate:  failed to open " .. coordfile_fn) end
end


if (label==nil) then label = "" end
local coordtext = "SpawnResource (" .. px .." , " .. pz .. ")" .. "   -- " .. label
coordfile:write (coordtext .. "\n")
Spring.Echo ("tp_coordinate:" ..coordtext)
coordfile:flush()
end


function widget:Initialize()
Spring.Echo ("tp_coordinate: place markers on the map to log their coordinates")
end


function widget:MapDrawCmd(playerID, cmdType, px, py, pz, label)
--Spring.Echo ("playerID: " .. playerID .. "cmdType:" .. cmdType .. "px:" .. px .. "py:" .. py .. "pz:" .. pz .."label:" .. label)      
--if (string.find (label, "boom") ~= nil) then make_a_bet (playerID, px, py, pz, label) end
log_coord (px, pz, label)
end