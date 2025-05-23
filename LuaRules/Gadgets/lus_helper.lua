function gadget:GetInfo()
	return {
		name = "LUS - Helper",
		desc = "Parses UnitDef and Model data for LUS",
		author = "FLOZi (C. Lawrence)",
		date = "20/02/2011", -- 25 today ;_;
		license = "GNU GPL v2",
		layer = 2, -- must be after flagManager
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations
local modOptions = Spring.GetModOptions()
GG.modOptions = modOptions
GG.lusHelper = {}
GG.Sounds = VFS.Include("gamedata/sounds.lua")
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
local PAD_LENGTH = 12
local function PadString(input, length)
	while input:len() < (length or PAD_LENGTH) do
		input = " " .. input .. " "
	end
	return input
end
local function Pad(...)
	local arg = {...}
	local output = ""
	local length = (type (arg[1]) == type(1) and arg[1]) or nil
	for i, v in ipairs(arg) do
		if type (v) == "string" then
			output = output .. PadString(v, length) .. "\n"
		end
	end
	return output:sub(1,-2) -- remove trailing newline
end
GG.Pad = Pad

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
	local step = Game.squareSize * 4
	for z = 0, 2 * r, step do -- top to bottom diameter
		local lineLength = math.sqrt(r2 - (r - z) ^ 2)
		for x = -lineLength, lineLength, step do
			Spring.RemoveGrass((cx + x)/step, (cz + z - r)/step)
		end
	end
end
GG.RemoveGrassCircle = RemoveGrassCircle

function SpawnDecal(decalType, x, y, z, teamID, alwaysVisible, delay, duration)
	if delay then
		GG.Delay.DelayCall(SpawnDecal, {decalType, x, y, z, teamID, nil, duration}, delay)
	else
		local decalID = Spring.CreateUnit(decalType, x, y + 1, z, 0, teamID, false, false)
		if decalID then -- can fail if e.g. team just died
			Spring.SetUnitAlwaysVisible(decalID, alwaysVisible or false)
			Spring.SetUnitNoSelect(decalID, true)
			Spring.SetUnitBlocking(decalID, false, false, false, false, false, false, false)
			if duration then
				GG.Delay.DelayCall(Spring.DestroyUnit, {decalID, false, true}, duration)
			end
		end
	end
end
GG.SpawnDecal = SpawnDecal

function EmitSfxName(unitID, pieceName, effectName)
	local x,y,z,dx,dy,dz = GetUnitPiecePosDir(unitID, pieceName)
	SpawnCEG(effectName, x,y,z, dx, dy, dz)
end
GG.EmitSfxName = EmitSfxName

local function RecursiveHide(unitID, pieceNum, hide)
	if not pieceNum then return end
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
	local exists = GG.Sounds.SoundItems[sound]
	if exists then -- To check for missing sounds, remove this
		table.insert(unsyncedBuffer, {teamID, sound, volume})
	end
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

local function IsPieceAncestor(unitID, pieceName, ancestor, strict)
	local pieceMap = GetUnitPieceMap(unitID)
	local parent = GetUnitPieceInfo(unitID, pieceMap[pieceName]).parent
	if (strict and parent == ancestor) or (not strict and parent:find(ancestor)) then 
		return true, parent
	elseif parent == "[null]" then
		return false, parent
	else
		return IsPieceAncestor(unitID, parent, ancestor, strict)
	end
end

local function FindPieceProgenitor(unitID, pieceName, extra)
	-- order matters here, we want to return turret even if that turret is then attached to body
	local progenitors = {"lwing", "rwing", "rotory", "turret", "emitter", "trackr", "trackl", "body"}
	if extra then
		table.insert(progenitors, 1, extra) -- put any extra pieces at the start (highest priority)
	end
	for _, progenitor in ipairs(progenitors) do
		if pieceName:find(progenitor) then return pieceName end -- return the piece
		local found, parent = IsPieceAncestor(unitID, pieceName, progenitor, false)
		if found then return parent end 
	end
	return nil
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local info = GG.lusHelper[unitDefID]
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	info.builderID = builderID
	if info.firstTime == nil then
		info.firstTime = true -- only do this step once
		-- Parse Model Data
		local pieceMap = GetUnitPieceMap(unitID)
		local progenitorMap = {} -- pieceName => progenitor
		local weaponProgenitors = {} -- weaponProgenitors[weaponID] = pieceName
		
		-- mech, vehicle or dropship
		local launcherIDs = {}
		local barrelIDs = {}
		
		-- vehicle or dropship
		local turretIDs = {} -- weapon housed in turret_<weaponnum>
		local mantletIDs = {}
		
		-- vehicle only
		local mainTurretIDs = {} -- weapons housed in main turret
		local turretOnTurretIDs = {} -- turrets on top of main turret, FU Behemoth!
		local turretOnTurretSides = {}
		local numWheels = 0
		-- vtol vehicle only
		local numRotors = {x = 0, y = 0, z = 0}
		
		-- mech only
		local leftArmIDs = {}
		local rightArmIDs = {}
		local numJets = 0
		
		-- dropship only
		local numVExhausts = 0
		local numVExhaustLarges = 0
		local numHExhausts = 0
		local numHExhaustLarges = 0
		local numGears = 0
		local numDusts = 0
		local numBooms = 0
		local numCargoPieces = 0
		local trackEmitterIDs = {}
		
		for pieceName, pieceNum in pairs(pieceMap) do
			local parent = GetUnitPieceInfo(unitID, pieceNum)["parent"]
			local weapNumPos = pieceName:find("_") or 0
			local weapNumEndPos = pieceName:find("_", weapNumPos+1) or 0
			local weaponNum = tonumber(pieceName:sub(weapNumPos+1,weapNumEndPos-1))
			progenitorMap[pieceName] = FindPieceProgenitor(unitID, pieceName, cp.wheels and "wheel")
			if weaponNum and not weaponProgenitors[weaponNum] then
				weaponProgenitors[weaponNum] = progenitorMap[pieceName]
				--Spring.Echo(UnitDefs[unitDefID].name, "weapon num:", weaponNum, "progenitor:", weaponProgenitors[weaponNum])
			end
			-- Find launcher pieces
			if pieceName:find("launcher_") then
				launcherIDs[weaponNum] = true
			-- Find turret pieces
			elseif pieceName:find("turret_") then
				turretIDs[weaponNum] = true
				turretOnTurretIDs[weaponNum] = IsPieceAncestor(unitID, pieceName, "turret", true) -- strict check
				if turretOnTurretIDs[weaponNum] then
					turretOnTurretSides[weaponNum] = (Spring.GetUnitPieceInfo(unitID, pieceNum)["offset"][1] > 0) and -1 or 1
				end
			-- Find mantlet pieces
			elseif pieceName:find("mantlet_") then
				mantletIDs[weaponNum] = true
			-- Find track emitter pieces
			elseif pieceName:find("emitter_") then
				trackEmitterIDs[weaponNum] = true
			-- Find barrel pieces
			elseif pieceName:find("barrel_") then
				barrelIDs[weaponNum] = true
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "lupperarm")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "rupperarm")
			-- assign flare weaponIDs to left or right arms
			elseif pieceName:find("flare_") then
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "lupperarm")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "rupperarm")
				mainTurretIDs[weaponNum] = weaponProgenitors[weaponNum] == "turret"
			-- assign launchpoint weaponIDs to left or right arms
			elseif pieceName:find("launchpoint_") then
				leftArmIDs[weaponNum] = leftArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "lupperarm")
				rightArmIDs[weaponNum] = rightArmIDs[weaponNum] or IsPieceAncestor(unitID, pieceName, "rupperarm")
				mainTurretIDs[weaponNum] = weaponProgenitors[weaponNum] == "turret"
			-- Find the number of wheels
			elseif pieceName:find("wheel") then
				numWheels = numWheels + 1
			-- Find the number of rotors
			elseif pieceName:find("rotor") then
				if pieceName:find("x") then
					numRotors.x = numRotors.x + 1
				elseif pieceName:find("y") then
					numRotors.y = numRotors.y + 1
				elseif pieceName:find("z") then
					numRotors.z = numRotors.z + 1
				end
			-- Find the number of jumpjets
			elseif pieceName:find("jet") then
				numJets = numJets + 1
			-- Find the number of large vertical exhausts
			elseif pieceName:find("vexhaustlarge") then
				numVExhaustLarges = numVExhaustLarges + 1
			-- Find the number of vertical exhausts
			elseif pieceName:find("vexhaust") then
				numVExhausts = numVExhausts + 1
			-- Find the number of large horizontal exhausts
			elseif pieceName:find("hexhaustlarge") then
				numHExhaustLarges = numHExhaustLarges + 1
			-- Find the number of horizontal exhausts
			elseif pieceName:find("hexhaust") then
				numHExhausts = numHExhausts + 1
			-- Find the number of dust emitters
			elseif pieceName:find("dust") then
				numDusts = numDusts + 1
			-- Find the number of landing gears
			elseif pieceName:match("gear%d+.-") then
				numGears = math.max(numGears, pieceName:match("%d+")) -- just pick the highest number we find, because there's all manner of gear parts
			-- Find the number of booms
			elseif pieceName:find("boom") then
				numBooms = numBooms + 1
			-- Find the number of Cargo attachments
			elseif pieceName:find("cargopiece") then
				numCargoPieces = numCargoPieces + 1
			end
		end
		
		if cp.baseclass == "mech" then
			info.rightArmMasterID = GetArmMasterWeapon(rightArmIDs)
			info.leftArmMasterID = GetArmMasterWeapon(leftArmIDs)
			info.rightArmIDs = rightArmIDs
			info.leftArmIDs = leftArmIDs
		end
		info.cockpit = pieceMap["cockpit"]
		--elseif cp.baseclass == "dropship" then
			info.trackEmitterIDs = trackEmitterIDs
			info.numHExhausts = numHExhausts
			info.numHExhaustLarges = numHExhaustLarges
			info.numVExhausts = numVExhausts
			info.numVExhaustLarges = numVExhaustLarges
			info.numGears = numGears
			info.numDusts = numDusts
			info.numBooms = numBooms
			info.numCargoPieces = numCargoPieces
		--end

		info.progenitorMap = progenitorMap
		info.weaponProgenitors = weaponProgenitors
		info.launcherIDs = launcherIDs
		info.turretIDs = turretIDs
		info.mainTurretIDs = mainTurretIDs
		info.turretOnTurretIDs = turretOnTurretIDs
		info.turretOnTurretSides = turretOnTurretSides
		info.mantletIDs = mantletIDs
		info.barrelIDs = barrelIDs
		info.numWheels = numWheels
		for i = 1, numWheels do -- now that we know how many wheels there are we can setup limbHPs
			info.limbHPs["wheel" .. i] = ud.health * 0.01
		end
		info.numRotors = numRotors
		info.jumpjets = numJets
	end
	
	
	-- Remove aircraft land and repairlevel buttons
	if ud.canFly then
		Spring.GiveOrderToUnit(unitID, CMD.IDLEMODE, {0}, {})
		local toRemove = {CMD.IDLEMODE, CMD.AUTOREPAIRLEVEL}
		for _, cmdID in pairs(toRemove) do
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
			if cmdDescID then
				Spring.RemoveUnitCmdDesc(unitID, cmdDescID)
			end
		end
	-- Remove load/unload buttons from all transports
	elseif ud.transportCapacity and ud.name:find("mechbay") then
		local toRemove = {CMD.LOAD_UNITS, CMD.UNLOAD_UNITS}
		for _, cmdID in pairs(toRemove) do
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
			if cmdDescID then
				Spring.RemoveUnitCmdDesc(unitID, cmdDescID)
			end
		end
	end
	-- remove Wait / Firestate / Movestate / Repeat / Stop from everything other than mechs
	if cp.baseclass ~= "mech" then
		local toRemove = {CMD.MOVE_STATE, CMD.WAIT, CMD.REPEAT}
		if not ud.weapons[1] then 
			table.insert(toRemove, CMD.FIRE_STATE, CMD.STOP)
		end
		for _, cmdID in pairs(toRemove) do
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
			if cmdDescID then
				Spring.RemoveUnitCmdDesc(unitID, cmdDescID)
			end
		end				
	end
end

function gadget:GamePreload()
	-- Parse UnitDef Data
	for unitDefID, unitDef in pairs(UnitDefs) do
		local preload = unitDef.model.midx -- access model to force preloading
		local info = {}
		local cp = unitDef.customParams
		local weapons = unitDef.weapons
		
		-- Parse UnitDef Weapon Data
		local missileWeaponIDs = {}
		local jammableIDs = {}
		local amsIDs = {}
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
				amsIDs[i] = true
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
		info.amsIDs = amsIDs
		
		-- UnitDef Level Info
		-- General
		info.hasEcm = string.tobool(cp.hasecm)
		info.numWeapons = #weapons
		info.maxAmmo = table.unserialize(cp.maxammo)
		-- Temperatures
		local MapTemps = GG.MapTemperatures
		if MapTemps then -- purely for dumb loading bug
			local mapAmbientTempMult = 0.9 ^ (MapTemps.ambient / 20)
			local waterSign = MapTemps.ambient - MapTemps.water < 0 and -1 or 1
			local mapWaterTempMult = waterSign * 0.9 ^ (waterSign * MapTemps.water / 10)
			info.heatLimit = (tonumber(cp.heatlimit) or 50)
			info.coolRate = info.heatLimit / 25 * mapAmbientTempMult
			info.waterCoolRate = mapWaterTempMult
		end
		-- Mechs
		--info.jumpjets = GG.jumpDefs[unitDefID] ~= nil
		info.torsoTurnSpeed = math.rad(tonumber(cp.torsoturnspeed) or 100) --* (modOptions and tonumber(modOptions.torso) or 1)
		info.elevationSpeed = math.rad(tonumber(cp.elevationspeed) or math.deg(info.torsoTurnSpeed))
		-- Limb HPs
		info.limbHPs = {}
		if cp.baseclass == "mech" then
			info.limbHPs["left_leg"] = unitDef.health * 0.25
			info.limbHPs["right_leg"] = unitDef.health * 0.25
			info.limbHPs["left_arm"] = unitDef.health * 0.15
			info.limbHPs["right_arm"] = unitDef.health * 0.15
			-- coolant
			info.maxAmmo["coolant"] = 100
			info.ammoTypes[-1] = "coolant"
			info.burstLengths[-1] = 20	
		elseif cp.baseclass == "vehicle" then
			info.limbHPs["turret"] = unitDef.health * 1.0
			info.limbHPs["trackl"] = unitDef.health * 0.1
			info.limbHPs["trackr"] = unitDef.health * 0.1
		elseif cp.baseclass == "vtol" then
			info.limbHPs["rotory1"] = unitDef.health * 0.1 -- 0.01
			info.limbHPs["rotory2"] = unitDef.health * 0.1 -- 0.01
		elseif cp.baseclass == "aero" then
			info.limbHPs["lwing"] =	 unitDef.health * 0.5
			info.limbHPs["rwing"] = unitDef.health * 0.5
		end
		-- Vehicles
		info.hover = unitDef.moveDef.family == "hover"
		info.vtol = cp.baseclass == "vtol"
		info.aero = unitDef.canFly and not info.vtol
		--info.turrets = table.unserialize(cp.turrets)
		info.turretTurnSpeed = math.rad(tonumber(cp.turretturnspeed) or 75)
		info.turret2TurnSpeed = math.rad(tonumber(cp.turret2turnspeed) or 75)
		info.barrelRecoilSpeed = (tonumber(cp.barrelrecoilspeed) or 100)
		info.barrelRecoilDist = table.unserialize(cp.barrelrecoildist)
		info.chainFireDelays = table.unserialize(cp.chainfiredelays)
		info.wheelSpeed = math.rad(tonumber(cp.wheelspeed) or 100)
		info.wheelAccel = math.rad(tonumber(cp.wheelaccel) or info.wheelSpeed * 2)
		-- And finally, stick it in GG for the script to access
		GG.lusHelper[unitDefID] = info
	end
	GG.lusHelper.MINE_WDID = WeaponDefNames["mine"].id
end

local MELTDOWN_WDID = WeaponDefNames["meltdown"].id
function gadget:Initialize()
	gadget:GamePreload()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	Script.SetWatchWeapon(MELTDOWN_WDID, true)
end

function gadget:MoveCtrlNotify(unitID, unitDefID, unitTeam, data)
	-- check for tower drops too
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	env = Spring.UnitScript.GetScriptEnv(unitID)
	if env.TouchDown then
		Spring.UnitScript.CallAsUnit(unitID, env.TouchDown)
		Spring.MoveCtrl.Disable(unitID)
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if weaponDefID == MELTDOWN_WDID then
		Spring.SetProjectileAlwaysVisible(proID, true)
	end
end

else

-- UNSYNCED

local PlaySoundFile	= Spring.PlaySoundFile

function PlayTeamSound(eventID, teamID, sound, volume)
	if teamID == Spring.GetMyTeamID() then
		PlaySoundFile(sound, volume, "ui")
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("SOUND", PlayTeamSound)
end

end
