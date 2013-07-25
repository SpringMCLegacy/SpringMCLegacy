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

-- localisations
--SyncedRead
local GetPieceColVol = Spring.GetUnitPieceCollisionVolumeData
--SyncedCtrl
local SetPieceColVol = Spring.SetUnitPieceCollisionVolumeData

-- Constants
local TORSO_SCALE = 0.5
local LIMB_SCALE = 1.5

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if not ud.name:find("dropship") then
		local pieces = Spring.GetUnitPieceList(unitID)
		for i, pieceName in pairs(pieces) do
			--Spring.Echo(i, pieceName)
			if not accept[pieceName] and i ~= "n" then
				--Spring.Echo("piece " .. i .. " called " .. pieceName .. " to be disabled")
				SetPieceColVol (unitID, i - 1, false, 0,0,0, 0,0,0, -1, 0)
			else 
				local scaleX, scaleY, scaleZ, offsetX, offsetY, offsetZ, volumeType, _, primaryAxis = GetPieceColVol (unitID, i-1)
				local scaleMult = LIMB_SCALE
				if pieceName == "torso" or pieceName == "pelvis" then scaleMult = TORSO_SCALE end
				SetPieceColVol(unitID, i - 1, true, 
								scaleMult*scaleX, scaleMult*scaleY, scaleMult*scaleZ, 
								offsetX, offsetY, offsetZ, volumeType, primaryAxis)
			end
		end
	end
end


else
--	UNSYNCED
end
