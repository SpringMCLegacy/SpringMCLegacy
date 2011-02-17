function gadget:GetInfo()
	return {
		name		= "Armour Hit Volumes",
		desc		= "Limits armour to base and turret hit boxes",
		author		= "FLOZi (C. Lawrence)",
		date		= "03/11/10",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

local cache = {}
local accept = {pelvis = true, torso = true, rlowerarm = true, llowerarm = true, lupperleg = true, llowerleg = true, rupperleg = true, rlowerleg = true}

if gadgetHandler:IsSyncedCode() then
--	SYNCED

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if not cache[unitDefID] and not ud.name:find("factory") then
		cache[unitDefID] = true
		local pieces = Spring.GetUnitPieceList(unitID)
		for i, pieceName in pairs(pieces) do
			--Spring.Echo(i, pieceName)
			if not accept[pieceName] and i ~= "n" then
				--Spring.Echo("piece " .. i .. " called " .. pieceName .. " to be disabled")
				Spring.SetUnitPieceCollisionVolumeData(unitID, i - 1, true,true, false,false, 0,0,0, 0,0,0, -1, 0)
			end
		end
	end
end


else
--	UNSYNCED
end
