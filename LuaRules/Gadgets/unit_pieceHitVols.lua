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

local accept = {pelvis = true, torso = true, rlowerarm = true, llowerarm = true, lupperleg = true, llowerleg = true, rupperleg = true, rlowerleg = true}

if gadgetHandler:IsSyncedCode() then
--	SYNCED

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if not ud.name:find("dropship") then
		local pieces = Spring.GetUnitPieceList(unitID)
		for i, pieceName in pairs(pieces) do
			--Spring.Echo(i, pieceName)
			if not accept[pieceName] and i ~= "n" then
				--Spring.Echo("piece " .. i .. " called " .. pieceName .. " to be disabled")
				Spring.SetUnitPieceCollisionVolumeData(unitID, i - 1, false, 0,0,0, 0,0,0, -1, 0)
			elseif pieceName == "torso" then
				local scaleX, scaleY, scaleZ, offsetX, offsetY, offsetZ, volumeType, testType, primaryAxis = Spring.GetUnitPieceCollisionVolumeData (unitID, i-1 )
				Spring.SetUnitPieceCollisionVolumeData(unitID, i - 1, true, 0.5*scaleX,0.5*scaleY,0.5*scaleZ, offsetX,offsetY,offsetZ, volumeType, primaryAxis)
			else
				local scaleX, scaleY, scaleZ, offsetX, offsetY, offsetZ, volumeType, testType, primaryAxis = Spring.GetUnitPieceCollisionVolumeData (unitID, i-1 )
				Spring.SetUnitPieceCollisionVolumeData(unitID, i - 1, true, 1.5*scaleX,1.5*scaleY,1.5*scaleZ, offsetX,offsetY,offsetZ, volumeType, primaryAxis)
			end
		end
	end
end


else
--	UNSYNCED
end
