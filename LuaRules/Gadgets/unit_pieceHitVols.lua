function gadget:GetInfo()
	return {
		name		= "Armour Hit Volumes",
		desc		= "Limits armour to base and turret hit boxes",
		author		= "FLOZi (C. Lawrence)",
		date		= "03/11/10",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true,	--	loaded by default?
	}
end

local accept = { 
		mech = {pelvis = true, torso = true, rupperarm = true, rlowerarm = true, lupperarm = true, llowerarm = true, lupperleg = true, llowerleg = true, rupperleg = true, rlowerleg = true},
		vehicle = {body = true, turret = true, launcher_1 = true, turret_2 = true, trackr = true, trackl = true},
		aero = {lwing = true, rwing = true},
		vtol = {body = true, rotory1 = true, rotory2 = true},
	}

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
--SyncedRead
local GetPieceColVol = Spring.GetUnitPieceCollisionVolumeData
--SyncedCtrl
local SetPieceColVol = Spring.SetUnitPieceCollisionVolumeData

-- Constants
local TORSO_SCALE = 0.85
local LIMB_SCALE = 1.1
local BODY_SCALE = 1.0
local HULL_SCALE = 0.8
local TURRET_SCALE = 1.1
local TRACK_SCALE = 1.0
local WHEEL_SCALE = 1.1

local adjust = 0
if not Script.IsEngineMinVersion(101, 0) then
	adjust = 1
end

local function SetUnitPieceColVol(unitID, i, sx, sy, sz, volType, axis)
	scaleMult = scaleMult or 1
	sy = sy or sx
	sz = sz or sx
	local scaleX, scaleY, scaleZ, offsetX, offsetY, offsetZ, volumeType, _, primaryAxis = GetPieceColVol (unitID, i - adjust)
	SetPieceColVol(unitID, i - adjust, true, 
					sx*scaleX, sy*scaleY, sz*scaleZ, 
					offsetX, offsetY, offsetZ, volType or volumeType, axis or primaryAxis)
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if (ud.speed > 0 or ud.canFly) and not cp.dropship then 
		local pieces = Spring.GetUnitPieceList(unitID)
		local unitType = cp.baseclass
		if accept[unitType] then
		local scaleMult
			for i, pieceName in pairs(pieces) do
				--Spring.Echo(i, pieceName)
				if cp.wheels and pieceName:find("wheel") then
					scaleMult = (cp.wheelscale or WHEEL_SCALE)
					SetUnitPieceColVol(unitID, i, scaleMult, scaleMult, scaleMult, 1, 0)
				elseif not accept[unitType][pieceName] and i ~= "n" then
					--Spring.Echo("piece " .. i .. " called " .. pieceName .. " to be disabled")
					SetPieceColVol (unitID, i - adjust, false, 0,0,0, 0,0,0, -1, 0)
				else 
					scaleMult = (cp.limbscale or LIMB_SCALE)
					if pieceName == "torso" or pieceName == "pelvis" then 
						scaleMult = (cp.torsoscale or TORSO_SCALE) 
					elseif pieceName == "body" then
						scaleMult = (cp.bodyscale or (unitType == "mech" and BODY_SCALE) or HULL_SCALE)
					elseif pieceName == "turret" or pieceName == "launcher_1" or pieceName == "turret_2" then
						scaleMult = (cp.turretscale or TURRET_SCALE)
					end
					SetUnitPieceColVol(unitID, i, scaleMult)
					-- special cases
					if pieceName == "trackr" or pieceName == "trackl" then
						scaleMult = (cp.trackscale or TRACK_SCALE)
						SetUnitPieceColVol(unitID, i, scaleMult * 1.2, scaleMult, scaleMult) -- extra width
					elseif pieceName:find("rotory") then -- replace with y-cylinder
						SetPieceColVol(unitID, i - adjust, true, 
										scaleMult*70, scaleMult*1, scaleMult*70,  -- use a constant radius
										0, 0, 0, 1, 1)				
					end
				end
			end
		end
	end
end


else
--	UNSYNCED
end
