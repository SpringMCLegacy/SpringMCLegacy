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
-- Synced Read
local GetUnitPieceInfo 		= Spring.GetUnitPieceInfo
local GetUnitPieceMap		= Spring.GetUnitPieceMap
-- Synced Ctrl

-- Unsynced Ctrl
-- Constants

-- Variables

local function StringToTable(input)
	return loadstring("return " .. (input or "{}"))()
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local info = GG.lusHelper[unitDefID]
	if info.arms == nil then --and not UnitDefs[unitDefID].name:find("dropship") then
		-- Parse Model Data
		local pieceMap = GetUnitPieceMap(unitID)
		info.arms = pieceMap["rlowerarm"] ~= nil
		local launcherIDs = {}
		local turretIDs = {}
		local mantletIDs = {}
		local barrelIDs = {}
		local numWheels = 0
		for pieceName, pieceNum in pairs(pieceMap) do
			-- Find launcher pieces
			if pieceName:find("launcher_") and #pieceName <= 10 then -- better to use a regex here really
				local weaponNum = tonumber(pieceName:sub(10, -1))
				launcherIDs[weaponNum] = true
			-- Find mantlet pieces
			elseif pieceName:find("mantlet_") then
				local weaponNum = tonumber(pieceName:sub(9, -1))
				mantletIDs[weaponNum] = true
			-- Find barrel pieces
			elseif pieceName:find("barrel_") then
				local weaponNum = tonumber(pieceName:sub(8, -1))
				barrelIDs[weaponNum] = true
			-- Find the number of wheels
			elseif pieceName:find("wheel") then
				numWheels = numWheels + 1
			end
		end
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
		local burstLengths = {}
		local firingHeats = {}		
		local reloadTimes = {}
		for i = 1, #weapons do
			local weaponInfo = weapons[i]
			local weaponDef = WeaponDefs[weaponInfo.weaponDef]
			reloadTimes[i] = weaponDef.reload
			burstLengths[i] = weaponDef.salvoSize
			firingHeats[i] = (weaponDef.customParams.heatgenerated or 0) * 0.5
			if weaponDef.type == "MissileLauncher" and weaponDef.name ~= "narc" then --burstLengths[i] > 1 then
				missileWeaponIDs[i] = true
			end
			if weaponDef.isShield then
				info.amsID = i
			end
		end
		-- UnitDef Level Info
		-- Mechs
		info.jumpjets = GG.jumpDefs[unitDefID] ~= nil
		info.torsoTurnSpeed = math.rad(tonumber(cp.torsoturnspeed) or 100)
		info.leftArmID = tonumber(cp.leftarmid) or 1
		info.rightArmID = tonumber(cp.rightarmid) or 2
		-- Vehicles
		info.hover = unitDef.canHover
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
		info.heatLimit = (cp.heatlimit or 50) * 10
		info.coolRate = info.heatLimit / 50 -- or a constant rate of 10?
		info.numWeapons = #weapons
		info.elevationSpeed = math.rad(tonumber(cp.elevationspeed) or math.deg(info.torsoTurnSpeed))
		
		-- WeaponDef Level Info
		info.missileWeaponIDs = missileWeaponIDs
		info.reloadTimes = reloadTimes
		info.burstLengths = burstLengths
		info.firingHeats = firingHeats
		GG.lusHelper[unitDefID] = info
	end
	
end

else

-- UNSYNCED

end
