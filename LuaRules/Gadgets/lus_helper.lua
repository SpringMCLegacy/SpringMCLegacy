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
local GetUnitPiecePosDir	= Spring.GetUnitPiecePosDir
local GetUnitPosition		= Spring.GetUnitPosition
-- Synced Ctrl
local PlaySoundFile			= Spring.PlaySoundFile
local SpawnCEG				= Spring.SpawnCEG
-- LUS
local CallAsUnit 			= Spring.UnitScript.CallAsUnit	

-- Unsynced Ctrl
-- Constants
-- Variables

-- Useful functions for GG

function RemoveGrassSquare(x, z, r)
	local startX = math.floor(x - r/2)
	local startZ = math.floor(z - r/2)
	for i = 0, r, Game.squareSize * 4 do
		for j = 0, r, Game.squareSize * 4 do
			--Spring.Echo(startX + i, startZ + j)
			Spring.RemoveGrass((startX + i)/Game.squareSize, (startZ + j)/Game.squareSize)
		end
	end
end
GG.RemoveGrassSquare = RemoveGrassSquare

function RemoveGrassCircle(cx, cz, r)
	local r2 = r * r
	for z = 0, 2 * r, Game.squareSize * 4 do -- top to bottom diameter
		local lineLength = math.sqrt(r2 - (r - z) ^ 2)
		for x = -lineLength, lineLength, Game.squareSize * 4 do
			Spring.RemoveGrass((cx + x)/Game.squareSize, (cz + z - r)/Game.squareSize)
		end
	end
end
GG.RemoveGrassCircle = RemoveGrassCircle

function SpawnDecal(decalType, x, y, z, teamID, delay, duration)
	if delay then
		GG.Delay.DelayCall(SpawnDecal, {decalType, x, y, z, teamID, nil, duration}, delay)
	else
		local decalID = Spring.CreateUnit(decalType, x, y + 1, z, 0, Spring.GetGaiaTeamID(), false, false)
		Spring.SetUnitAlwaysVisible(decalID, teamID == nil and true)
		Spring.SetUnitNoSelect(decalID, true)
		Spring.SetUnitBlocking(decalID, false, false, false, false, false, false, false)
		if duration then
			GG.Delay.DelayCall(Spring.DestroyUnit, {decalID, false, true}, duration)
		end
	end
end
GG.SpawnDecal = SpawnDecal

function EmitSfxName(unitID, pieceName, effectName) -- currently unused
	local x,y,z,dx,dy,dz = GetUnitPiecePosDir(unitID, pieceName)
	SpawnCEG(effectName, x,y,z, dx, dy, dz)
end

local function RecursiveHide(unitID, pieceNum, hide)
	-- Hide this piece
	local func = (hide and Spring.UnitScript.Hide) or Spring.UnitScript.Show
	CallAsUnit(unitID, func, pieceNum)
	-- Recursively hide children
	local pieceMap = GetUnitPieceMap(unitID)
	local children = GetUnitPieceInfo(unitID, pieceNum).children
	if children then
		for _, pieceName in pairs(children) do
			--Spring.Echo("pieceName:", pieceName, pieceMap[pieceName])
			RecursiveHide(unitID, pieceMap[pieceName], hide)
		end
	end
end
GG.RecursiveHide = RecursiveHide

local function PlaySoundAtUnit(unitID, sound, volume, sx, sy, sz, channel)
	local x,y,z = GetUnitPosition(unitID)
	volume = volume or 5
	channel = channel or "sfx"
	PlaySoundFile(sound, volume, x, y, z, sx, sy, sz, channel)
end
GG.PlaySoundAtUnit = PlaySoundAtUnit

local unsyncedBuffer = {}
local function PlaySoundForTeam(teamID, sound, volume)
	table.insert(unsyncedBuffer, {teamID, sound, volume})
end
GG.PlaySoundForTeam = PlaySoundForTeam

function gadget:GameFrame(n)
	for _, callInfo in pairs(unsyncedBuffer) do
		SendToUnsynced("SOUND", callInfo[1], callInfo[2], callInfo[3])
	end
	unsyncedBuffer = {}
end

local function GetUnitDistanceToPoint(unitID, tx, ty, tz, bool3D)
	local x,y,z = GetUnitPosition(unitID)
	local dy = (bool3D and ty and (ty - y)^2) or 0
	local distanceSquared = (tx - x)^2 + (tz - z)^2 + dy
	return sqrt(distanceSquared)
end
GG.GetUnitDistanceToPoint = GetUnitDistanceToPoint


-- functions for determining weapon placement
local function GetArmMasterWeapon(input)
	local lowestID = 32
	for weaponID, valid in pairs(input) do
		if valid then
			if weaponID < lowestID then lowestID = weaponID end
		end
	end
	return lowestID
end

local function IsPieceAncestor(unitID, pieceName, ancestor)
	local pieceMap = GetUnitPieceMap(unitID)
	local parent = GetUnitPieceInfo(unitID, pieceMap[pieceName]).parent
	if parent:find(ancestor) then 
		return true
	elseif parent == "" or parent == nil then
		return false
	else
		return IsPieceAncestor(unitID, parent, ancestor)
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local info = GG.lusHelper[unitDefID]
	local cp = UnitDefs[unitDefID].customParams
	info.builderID = builderID
	if info.arms == nil then
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
		local numJets = 0
		for pieceName, pieceNum in pairs(pieceMap) do
			local parent = GetUnitPieceInfo(unitID, pieceNum)["parent"]
			local weapNumPos = pieceName:find("_") or 0
			local weapNumEndPos = pieceName:find("_", weapNumPos+1) or 0
			local weaponNum = tonumber(pieceName:sub(weapNumPos+1,weapNumEndPos-1))
			-- Find launcher pieces
			if pieceName:find("launcher_") then
				launcherIDs[weaponNum] = true
			-- Find mantlet pieces
			elseif pieceName:find("mantlet_") then
				mantletIDs[weaponNum] = true
			-- Find barrel pieces
			elseif pieceName:find("barrel_") then
				barrelIDs[weaponNum] = true
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "lupperarm")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "rupperarm")
			-- Find the number of wheels
			elseif pieceName:find("wheel") then
				numWheels = numWheels + 1
			-- Find the number of jumpjets
			elseif pieceName:find("jet") then
				numJets = numJets + 1
			-- assign flare weaponIDs to left or right arms
			elseif pieceName:find("flare_") then
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "lupperarm")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "rupperarm")
				turretIDs[weaponNum] = turretIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "turret")
			-- assign launchpoint weaponIDs to left or right arms
			elseif pieceName:find("launchpoint_") then
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "lupperarm")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "rupperarm")
				turretIDs[weaponNum] = turretIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "turret")
			end
		end
		
		if cp.unittype == "mech" then
			info.rightArmMasterID = GetArmMasterWeapon(rightArmIDs)
			info.leftArmMasterID = GetArmMasterWeapon(leftArmIDs)
			info.rightArmIDs = rightArmIDs
			info.leftArmIDs = leftArmIDs
		elseif cp.unittype == "vehicle" then
			info.turretIDs = turretIDs
		end
		
		info.launcherIDs = launcherIDs
		info.turretIDs = turretIDs
		info.mantletIDs = mantletIDs
		info.barrelIDs = barrelIDs
		info.numWheels = numWheels
		info.jumpjets = numJets
	end
	
	-- Remove aircraft land and repairlevel buttons
	if UnitDefs[unitDefID].canFly then
		Spring.GiveOrderToUnit(unitID, CMD.IDLEMODE, {0}, {})
		local toRemove = {CMD.IDLEMODE, CMD.AUTOREPAIRLEVEL}
		for _, cmdID in pairs(toRemove) do
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
			Spring.RemoveUnitCmdDesc(unitID, cmdDescID)
		end
	-- Remove load/unload buttons from all transports
	elseif UnitDefs[unitDefID].transportCapacity and UnitDefs[unitDefID].name:find("mechbay") then
		local toRemove = {CMD.LOAD_UNITS, CMD.UNLOAD_UNITS, CMD.STOP, CMD.WAIT, CMD.MOVE_STATE}
		for _, cmdID in pairs(toRemove) do
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
			Spring.RemoveUnitCmdDesc(unitID, cmdDescID)
		end
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
		local flareOnShots = {}
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
			jammableIDs[i] = string.tobool(weaponDef.customParams.jammable)
			flareOnShots[i] = string.tobool(weaponDef.customParams.flareonshot)
		end
		-- WeaponDef Level Info
		info.missileWeaponIDs = missileWeaponIDs
		info.flareOnShots = flareOnShots
		info.reloadTimes = reloadTimes
		info.burstLengths = burstLengths
		info.firingHeats = firingHeats
		info.ammoTypes = ammoTypes
		info.minRanges = minRanges
		info.spinSpeeds = spinSpeeds
		info.jammableIDs = jammableIDs
		
		-- UnitDef Level Info
		-- Mechs
		--info.jumpjets = GG.jumpDefs[unitDefID] ~= nil
		info.torsoTurnSpeed = math.rad(tonumber(cp.torsoturnspeed) or 100)
		-- Limb HPs
		info.limbHPs = {}
		if cp.unittype == "mech" then
			info.limbHPs["left_leg"] = unitDef.health * 0.1
			info.limbHPs["right_leg"] = unitDef.health * 0.1
			info.limbHPs["left_arm"] = unitDef.health * 0.15
			info.limbHPs["right_arm"] = unitDef.health * 0.15
		elseif cp.unittype == "vehicle" then
			info.limbHPs["turret"] = unitDef.health * 0.3
			if unitDef.canFly then
				info.limbHPs["lwing"] =	 unitDef.health * 0.5
				info.limbHPs["rwing"] = unitDef.health * 0.5
				info.limbHPs["rotor"] = unitDef.health * 0.1 -- 0.01
			end
		end
		-- Vehicles
		info.hover = unitDef.moveDef.family == "hover"
		info.vtol = unitDef.hoverAttack
		info.aero = unitDef.canFly and not info.vtol
		info.turrets = table.unserialize(cp.turrets)
		info.turretTurnSpeed = math.rad(tonumber(cp.turretturnspeed) or 75)
		info.turret2TurnSpeed = math.rad(tonumber(cp.turret2turnspeed) or 75)
		info.barrelRecoilSpeed = (tonumber(cp.barrelrecoilspeed) or 100)
		info.barrelRecoilDist = table.unserialize(cp.barrelrecoildist)
		info.wheelSpeed = math.rad(tonumber(cp.wheelspeed) or 100)
		info.wheelAccel = math.rad(tonumber(cp.wheelaccel) or info.wheelSpeed * 2)
		-- Temperatures
		local MapTemps = GG.MapTemperatures
		if MapTemps then -- purely for dumb loading bug
			local mapAmbientTempMult = 0.9 ^ (MapTemps.ambient / 20)
			local waterSign = MapTemps.ambient - MapTemps.water < 0 and -1 or 1
			local mapWaterTempMult = waterSign * 0.9 ^ (waterSign * MapTemps.water / 10)
			info.heatLimit = (tonumber(cp.heatlimit) or 50) * 10
			info.coolRate = info.heatLimit / 25 * mapAmbientTempMult
			info.waterCoolRate = mapWaterTempMult
		end
		-- General
		info.hasEcm = string.tobool(cp.hasecm)
		info.numWeapons = #weapons
		info.elevationSpeed = math.rad(tonumber(cp.elevationspeed) or math.deg(info.torsoTurnSpeed))
		info.maxAmmo = table.unserialize(cp.maxammo)
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

function gadget:MoveCtrlNotify(unitID, unitDefID, unitTeam, data)
	local BEACON_ID = UnitDefNames["beacon"].id
	local IS_DROPSHIP_ID = UnitDefNames["is_dropship"].id
	local CL_DROPSHIP_ID = UnitDefNames["cl_dropship"].id
	-- check for tower drops too
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams

	env = Spring.UnitScript.GetScriptEnv(unitID)
	if env.TouchDown then
		Spring.UnitScript.CallAsUnit(unitID, env.TouchDown)
		Spring.MoveCtrl.Disable(unitID)
	end
end

else

-- UNSYNCED

local PlaySoundFile	= Spring.PlaySoundFile
local MY_TEAM_ID = Spring.GetMyTeamID()

function PlayTeamSound(eventID, teamID, sound, volume)
	if teamID == MY_TEAM_ID then
		PlaySoundFile(sound, volume, "ui")
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("SOUND", PlayTeamSound)
end

end
