function gadget:GetInfo()
	return {
		name = "LUS Helper",
		desc = "Parses UnitDef and Model data for LUS",
		author = "FLOZi (C. Lawrence)",
		date = "20/02/2011", -- 25 today ;_;
		license = "GNU GPL v2",
		layer = -1,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations
GG.lusHelper = {}
sqrt = math.sqrt
-- Synced Read
local GetUnitPieceInfo 		= Spring.GetUnitPieceInfo
local GetUnitPieceMap		= Spring.GetUnitPieceMap
local GetUnitPosition		= Spring.GetUnitPosition
-- Synced Ctrl
local PlaySoundFile			= Spring.PlaySoundFile
-- Unsynced Ctrl
-- Constants
-- Variables

-- Useful functions for GG

local function PlaySoundAtUnit(unitID, sound, volume, channel)
	local x,y,z = GetUnitPosition(unitID)
	volume = volume or 5
	channel = channel or "sfx"
	PlaySoundFile(sound, volume, x, y, z, channel)
 end
 GG.PlaySoundAtUnit = PlaySoundAtUnit

local function GetUnitDistanceToPoint(unitID, tx, ty, tz, bool3D)
	local x,y,z = GetUnitPosition(unitID)
	local dy = (bool3D and ty and (ty - y)^2) or 0
	local distanceSquared = (tx - x)^2 + (tz - z)^2 + dy
	return sqrt(distanceSquared)
end
GG.GetUnitDistanceToPoint = GetUnitDistanceToPoint

local function StringToTable(input)
	return loadstring("return " .. (input or "{}"))()
end
GG.StringToTable = StringToTable

local function IsParentAnArm(parent, side)
	if side == "left" then
		if (parent == "lupperarm" or parent == "llowerarm") then
			return true
		end
	elseif side == "right" then
		if (parent == "rupperarm" or parent == "rlowerarm") then
			return true
		end
	end
	return nil
end
local function GetArmMasterWeapon(input)
	local lowestID = 32
	for weaponID, _ in pairs(input) do
		if weaponID < lowestID then lowestID = weaponID end
	end
	return lowestID
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local info = GG.lusHelper[unitDefID]
	info.builderID = builderID
	if info.arms == nil then --and not UnitDefs[unitDefID].name:find("dropship") then
		-- Parse Model Data
		local pieceMap = GetUnitPieceMap(unitID)
		info.arms = pieceMap["rupperarm"] ~= nil
		local leftArmIDs = {}
		local rightArmIDs = {}
		
		local launcherIDs = {}
		local turretIDs = {}
		local mantletIDs = {}
		local barrelIDs = {}
		local numWheels = 0
		for pieceName, pieceNum in pairs(pieceMap) do
			local parent = GetUnitPieceInfo(unitID, pieceNum)["parent"]
			local weapNumPos = pieceName:find("_") or 0
			local weaponNum = tonumber(pieceName:sub(weapNumPos+1,weapNumPos+1))
			-- Find launcher pieces
			if pieceName:find("launcher_") then
				launcherIDs[weaponNum] = true
			-- Find mantlet pieces
			elseif pieceName:find("mantlet_") then
				mantletIDs[weaponNum] = true
			-- Find barrel pieces
			elseif pieceName:find("barrel_") then
				barrelIDs[weaponNum] = true
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsParentAnArm(parent, "left")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsParentAnArm(parent, "right")
			-- Find the number of wheels
			elseif pieceName:find("wheel") then
				numWheels = numWheels + 1
			-- assign flare weaponIDs to left or right arms
			elseif pieceName:find("flare_") then
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsParentAnArm(parent, "left")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsParentAnArm(parent, "right")
			-- assign launchpoint weaponIDs to left or right arms
			elseif pieceName:find("launchpoint_") then
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsParentAnArm(parent, "left")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsParentAnArm(parent, "right")
			end
		end

		info.rightArmMasterID = GetArmMasterWeapon(rightArmIDs)
		info.leftArmMasterID = GetArmMasterWeapon(leftArmIDs)
		info.rightArmIDs = rightArmIDs
		info.leftArmIDs = leftArmIDs
		--Spring.Echo("Right: ", info.rightArmMasterID, "Left:", info.leftArmMasterID)
		
		info.launcherIDs = launcherIDs
		info.turretIDs = turretIDs
		info.mantletIDs = mantletIDs
		info.barrelIDs = barrelIDs
		info.numWheels = numWheels
	end
end

function gadget:GamePreload()
	-- Parse UnitDef Data
	for unitDefID, unitDef in pairs(UnitDefs) do
		local info = {}
		local cp = unitDef.customParams
		local weapons = unitDef.weapons
		
		-- Parse UnitDef Weapon Data
		local missileWeaponIDs = {}
		local jammableIDs = {}
		local burstLengths = {}
		local firingHeats = {}		
		local reloadTimes = {}
		local ammoTypes = {}
		local minRanges = {}
		local spinSpeeds = {}
		for i = 1, #weapons do
			local weaponInfo = weapons[i]
			local weaponDef = WeaponDefs[weaponInfo.weaponDef]
			reloadTimes[i] = weaponDef.reload
			burstLengths[i] = weaponDef.salvoSize
			firingHeats[i] = (weaponDef.customParams.heatgenerated or 0) * 0.5
			ammoTypes[i] = weaponDef.customParams.ammotype -- intentionally nil otherwise
			minRanges[i] = tonumber(weaponDef.customParams.minrange) -- intentionally nil otherwise
			spinSpeeds[i] = weaponDef.customParams.spinspeed and math.rad(weaponDef.customParams.spinspeed)
			if weaponDef.type == "MissileLauncher" and weaponDef.name ~= "narc" then --burstLengths[i] > 1 then
				missileWeaponIDs[i] = true
			end
			if weaponDef.interceptor == 1 then
				info.amsID = i
			end
			jammableIDs[i] = (tonumber(weaponDef.customParams.jammable) == 1)
		end
		-- WeaponDef Level Info
		info.missileWeaponIDs = missileWeaponIDs
		info.reloadTimes = reloadTimes
		info.burstLengths = burstLengths
		info.firingHeats = firingHeats
		info.ammoTypes = ammoTypes
		info.minRanges = minRanges
		info.spinSpeeds = spinSpeeds
		info.jammableIDs = jammableIDs
		
		-- UnitDef Level Info
		-- Mechs
		info.jumpjets = GG.jumpDefs[unitDefID] ~= nil
		info.torsoTurnSpeed = math.rad(tonumber(cp.torsoturnspeed) or 100)
		-- Limb HPs
		info.limbHPs = {}
		if cp.unittype == "mech" then
			info.limbHPs["left_leg"] = unitDef.health * 0.1
			info.limbHPs["right_leg"] = unitDef.health * 0.1
			info.limbHPs["left_arm"] = unitDef.health * 0.15
			info.limbHPs["right_arm"] = unitDef.health * 0.15
		elseif cp.unittype == "vehicle" then
			info.limbHPs["turret"] = unitDef.health * 0.25
		end
		-- Vehicles
		info.hover = unitDef.moveData.family == "hover"
		info.vtol = unitDef.hoverAttack
		info.aero = unitDef.myGravity
		info.turrets = StringToTable(cp.turrets)
		info.turretTurnSpeed = math.rad(tonumber(cp.turretturnspeed) or 75)
		info.turret2TurnSpeed = math.rad(tonumber(cp.turret2turnspeed) or 75)
		info.barrelRecoilSpeed = (tonumber(cp.barrelrecoilspeed) or 100)
		info.barrelRecoilDist = StringToTable(cp.barrelrecoildist)
		info.wheelSpeed = math.rad(tonumber(cp.wheelspeed) or 100)
		info.wheelAccel = math.rad(tonumber(cp.wheelaccel) or info.wheelSpeed * 2)
		-- General
		info.heatLimit = (tonumber(cp.heatlimit) or 50) * 10
		info.coolRate = info.heatLimit / 50 -- or a constant rate of 10?
		info.numWeapons = #weapons
		info.elevationSpeed = math.rad(tonumber(cp.elevationspeed) or math.deg(info.torsoTurnSpeed))
		info.maxAmmo = StringToTable(cp.maxammo)
		-- And finally, stick it in GG for the script to access
		GG.lusHelper[unitDefID] = info
	end
	
end

function gadget:Initialize()
	gadget:GamePreload()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else

-- UNSYNCED

end
