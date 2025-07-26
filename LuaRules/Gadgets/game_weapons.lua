function gadget:GetInfo()
	return {
		name 	= "Game - Weapons",
		desc 	= "Weapon and special ammo behaviours",
		author 	= "FLOZi (C. Lawrence)",
		date 	= "25/07/25", -- Though just a refactor of code from a span of many years
		license = "GNU GPL, v2 or later",
		layer 	= 4, -- after game_radar
		enabled = true,
	}
end

if (gadgetHandler:IsSyncedCode()) then
-- SYNCED
-- Localisations
-- SyncedRead
local GetGameFrame						= Spring.GetGameFrame
local GetProjectilePosition 			= Spring.GetProjectilePosition
local GetProjectileTarget				= Spring.GetProjectileTarget
local GetProjectileVelocity				= Spring.GetProjectileVelocity
local GetProjectilesInRectangle 		= Spring.GetProjectilesInRectangle
local GetUnitDefID						= Spring.GetUnitDefID
local GetUnitIsDead						= Spring.GetUnitIsDead
local GetUnitLastAttackedPiece			= Spring.GetUnitLastAttackedPiece
local GetUnitPosition					= Spring.GetUnitPosition
local GetUnitRulesParam					= Spring.GetUnitRulesParam
local GetUnitSensorRadius				= Spring.GetUnitSensorRadius
local GetUnitSeparation					= Spring.GetUnitSeparation
local GetUnitTeam						= Spring.GetUnitTeam
local GetUnitVelocity					= Spring.GetUnitVelocity
local GetUnitWeaponHaveFreeLineOfFire 	= Spring.GetUnitWeaponHaveFreeLineOfFire
local GetUnitWeaponState 				= Spring.GetUnitWeaponState
local GetTeamInfo						= Spring.GetTeamInfo
local ValidUnitID						= Spring.ValidUnitID
-- SyncedCtrl
local DeleteProjectile					= Spring.DeleteProjectile
local SetProjectileCollision 			= Spring.SetProjectileCollision
local SetProjectileIgnoreTrackingError 	= Spring.SetProjectileIgnoreTrackingError
local SetProjectileTarget				= Spring.SetProjectileTarget
local SetUnitRulesParam					= Spring.SetUnitRulesParam
local SetUnitSensorRadius				= Spring.SetUnitSensorRadius
local SetUnitWeaponState 				= Spring.SetUnitWeaponState
local SpawnProjectile					= Spring.SpawnProjectile
-- GG
local DelayCall							= GG.Delay.DelayCall

-- Constants
local ARROW_CLUSTER_ID = WeaponDefNames["arrowiv_cluster"].id
local AMS_DEF = WeaponDefNames["ams"] 
local AMS_ID = WeaponDefNames["ams"].id
local FRAME_FUDGE = 16
local GAUSS_ID = WeaponDefNames["gauss"].id
local NARC_ID = WeaponDefNames["narc"].id
local NARC_DURATION = 30 * 30 -- 30 seconds
Spring.SetGameRulesParam("NARC_DURATION", NARC_DURATION)
local PPC_DURATION = 5 * 30 -- 5 seconds
local PPC_ACCURACY = 1.75 -- 75% less accuracy, oof
local PPC_IDS = {}
for weaponDefID, weaponDef in pairs(WeaponDefs) do
	if weaponDef.name:find("ppc") then -- TODO: cp.weaponclass instead?
		PPC_IDS[weaponDefID] = true
	end
end
GG.PPC_IDS = PPC_IDS
local SILVERBULLET_DEF = WeaponDefNames["silverbullet"]
local TAG_ID = WeaponDefNames["tag"].id

-- Variables
local tracking = {}
local contTAG = {}
local amsPros = {}
local arrows = {}

local ppcEmits = {}
local ppcSensorTypes = {"radarJammer"} -- "radar", "seismic", 
local unitSensorRadii = {} -- unitSensorRadii[unitID] = {radar = a, seismic = b ...}
local unitWeaponAccuracies = {} -- unitWeaponAccuracys[unitID] = {[1] = a, [2] = b, ...}
local ppcUnits = {} -- ppcUnits[unitID] = gameframe
GG.ppcUnits = ppcUnits -- for game_radar
local artemisUnits = {} -- [unitID][weaponType] = true
GG.artemisUnits = artemisUnits

local lbx = {}
local silverBulletUnits = {}
local airTargets = {}
GG.airTargets = airTargets

local unitSpecialAmmos = {} -- [unitID][weaponType] = ammoName
GG.unitSpecialAmmos = unitSpecialAmmos -- for Thunder spawning
local unitArmours = {} -- unitID = true

-- helper functions for LUS
local function IsUnitNARCed(unitID)
	return (GetUnitRulesParam(unitID, "NARC") or 0) > 0
end
GG.IsUnitNARCed = IsUnitNARCed

local function IsUnitTAGed(unitID)
	return (GetUnitRulesParam(unitID, "TAG") or 0) + FRAME_FUDGE >= GetGameFrame()
end
GG.IsUnitTAGed = IsUnitTAGed

local function EnableArmour(unitID, apply, armourType)
	unitArmours[unitID] = apply and armourType or nil
end
GG.EnableArmour = EnableArmour

local function EnableAmmo(unitID, apply, weaponType, ammoName, weapNum)
	unitSpecialAmmos[unitID] = unitSpecialAmmos[unitID] or {}
	unitSpecialAmmos[unitID][weaponType] = apply and ammoName or nil
end
GG.EnableAmmo = EnableAmmo

local function IsTargetArtemised(unitID, targetID, weaponType)
	local info = GG.visionCache[GetUnitDefID(unitID)]-- TODO: might be better ways to do this now, only needs #ud.weapons
	if not info then return false end
	local dist = GetUnitSeparation(unitID, targetID)
	local rayTrace = GetUnitWeaponHaveFreeLineOfFire(unitID, info.sight, targetID)
	--Spring.Echo("Is target artemised?", artemisUnits[unitID], dist,GG.unitSectorRadii[unitID], rayTrace)
	return artemisUnits[unitID] and artemisUnits[unitID][weaponType] and (dist and dist <= GG.unitSectorRadii[unitID]) and rayTrace -- compare num with nil
end
GG.IsTargetArtemised = IsTargetArtemised

local function EnableArtemis(unitID, weaponType, tOrF)
	artemisUnits[unitID] = artemisUnits[unitID] or {}
	artemisUnits[unitID][weaponType] = tOrF
end
GG.EnableArtemis = EnableArtemis

local function EnableSilverBullet(unitID, tOrF)
	silverBulletUnits[unitID] = tOrF
end
GG.EnableSilverBullet = EnableSilverBullet
-----------------------------------------
-- PPC
-----------------------------------------
local function FinishPPC(unitID)
	if ppcUnits[unitID] and ppcUnits[unitID] <= GetGameFrame() then
		for _, sensorType in pairs(ppcSensorTypes) do
			SetUnitSensorRadius(unitID, sensorType, unitSensorRadii[unitID][sensorType])
		end
		for weapNum, accuracy in pairs(unitWeaponAccuracies[unitID]) do
			SetUnitWeaponState(unitID, weapNum, "accuracy", accuracy)
		end
		ppcUnits[unitID] = nil
		SetUnitRulesParam(unitID, "PPC_HIT", -1, {inlos = true})
		SetUnitRulesParam(unitID, "FXOFF", GG.stealthActive[unitID] and 1 or 0, {public = true})
		unitSensorRadii[unitID] = nil
		unitWeaponAccuracies[unitID] = nil
	end
end

local function ApplyPPC(unitID, unitDefID)
	if not ppcUnits[unitID] then -- not yet under PPC effects
		unitSensorRadii[unitID] = {}
		for _, sensorType in pairs(ppcSensorTypes) do
			-- perks change radii so can't rely on unitdef values
			unitSensorRadii[unitID][sensorType] = GetUnitSensorRadius(unitID, sensorType)
			SetUnitSensorRadius(unitID, sensorType, 0) -- ECM disabled altogether
		end
		unitWeaponAccuracies[unitID] = {}
		local unitWeapons = UnitDefs[unitDefID].weapons
		for weapNum, info in pairs(unitWeapons) do
			local currAccuracy = GetUnitWeaponState(unitID, weapNum, "accuracy")
			unitWeaponAccuracies[unitID][weapNum] = currAccuracy
			SetUnitWeaponState(unitID, weapNum, "accuracy", currAccuracy * PPC_ACCURACY)
		end
	end
	local delay = (GetUnitRulesParam(unitID, "insulation") or 1) * PPC_DURATION
	ppcUnits[unitID] = GetGameFrame() + delay
	SetUnitRulesParam(unitID, "PPC_HIT", ppcUnits[unitID], {inlos = true})
	SetUnitRulesParam(unitID, "FXOFF", 1, {public = true})
	DelayCall(FinishPPC, {unitID}, delay)
end
GG.ApplyPPC = ApplyPPC -- for inhbitor removal self own

-----------------------------------------
-- Homing missiles (Smart LRM, Homing Arrow, ARAD LRM, AD Arrow)
-----------------------------------------
local function SetMissileTarget(proID, info)
--	Spring.Echo("SetMissileTarget", proID, info.targetID, info.ownerID, info.weaponclass, info.artemisOnly)
	if info.targetID and ValidUnitID(info.targetID) and not GetUnitIsDead(info.targetID) -- target is alive
    and info.ownerID and ValidUnitID(info.ownerID) and not GetUnitIsDead(info.ownerID) then -- owner is alive
		--Spring.Echo("SetMissileTarget", proID, UnitDefs(GetUnitDefID(info.targetID)].name, UnitDefs[GetUnitDefID(info.ownerID)].name, info.weaponclass, info.artemisOnly)
		if ((IsUnitNARCed(info.targetID) or IsUnitTAGed(info.targetID)) and not info.artemisOnly)
		or (info.artemisOnly and IsTargetArtemised(info.ownerID, info.targetID, info.weaponclass)) 
		or (info.arad or info.ad) then
			--Spring.Echo("Target is tagged", info.weaponclass, contTAG[proID] and "continuous lock" or "lock reaquired!")
			contTAG[proID] = true -- re-establish TAG if lost
			--SetProjectileTarget(proID, targetID)
			local _,_,_,_,_,_,x,y,z = GetUnitPosition(info.targetID, true, true)
			--Spring.Echo(x,y,z)
			local vx, vy, vz = GetUnitVelocity(info.targetID)
			SetProjectileTarget(proID, x+vx,y+vy+1.5,z+vz)
		elseif contTAG[proID] then -- continuous TAG up to here
			--Spring.Echo("Target TAG lost")
			contTAG[proID] = false
			local x,y,z = GetUnitPosition(info.targetID)
			SetProjectileTarget(proID, x,y,z)
		end
	else -- target is dead, stop tracking altogether
		arrows[proID] = nil
	end
end


local function ChangeMissile(proID, proOwnerID, wd, artemisOnly)
	local targetType, targetID = GetProjectileTarget(proID)
	if targetType == string.byte('u') then -- unit target, info is ID
		local weaponClass = wd.customParams.weaponclass
		local arad = GG.jammerCache[targetID] and unitSpecialAmmos[proOwnerID][weaponClass] == "arad"
		local ad = unitSpecialAmmos[proOwnerID][weaponClass] == "ad" and airTargets[targetID]
		if ((IsUnitNARCed(targetID) or IsUnitTAGed(targetID)) and not artemisOnly) 
		or (artemisOnly and IsTargetArtemised(proOwnerID, targetID, weaponClass)) 
		or (arad or ad) then
			local x,y,z = GetProjectilePosition(proID)
			local vx, vy, vz = GetProjectileVelocity(proID)
			local _,_,_, _,_,_,tx, ty, tz = GetUnitPosition(targetID, true, true)
			--Spring.Echo("Arrow detected a TAG!", vx,vy,vz)
			local newProID = SpawnProjectile(wd.id, {
				pos = {x,y,z},
				speed = {vx, vy, vz},
				["error"] = {0, 0, 0},
				spread = {0, 0, 0},
				owner = proOwnerID,
				team = GetUnitTeam(proOwnerID),
				tracking = 8000, --?
				ttl = 100,
				["end"] = {tx, ty, tz},
			})
			local info = {
				["targetID"] = targetID,
				["ownerID"] = proOwnerID,
				["weaponclass"] = wd.customParams.weaponclass,
				["artemisOnly"] = artemisOnly,
				["arad"] = arad,
				["ad"] = ad,
			}
			arrows[newProID] = info
			SetMissileTarget(newProID, info)
			SetProjectileIgnoreTrackingError(newProID, true)
			DeleteProjectile(proID)
		end
	end
end

-----------------------------------------
-- Cluster weapons (LBX, SilverBullet, Cluster & Thunder Arrow)
-----------------------------------------
local function SpawnCluster(proID, proOwnerID, clusterWD, spray, sprayMult, vMult, down)
	local x,y,z = GetProjectilePosition(proID)
	local vx, vy, vz = GetProjectileVelocity(proID)
	local teamID = GetUnitTeam(proOwnerID)
	if down then
		vx = vx * 0.5
		vy = vy * 0.5
		vz = vz * 0.5
		local newProID = SpawnProjectile(ARROW_CLUSTER_ID, { -- TODO: unhardcode the name
			pos = {x,y,z},
			speed = {vx, vy * 0.1, vz},
			owner = proOwnerID,
			team = teamID,
		})
	end
	DeleteProjectile(proID)
	spray = math.ceil((spray or math.asin(clusterWD.sprayAngle) * 140) * (sprayMult or 1))
	vMult = vMult or 0.5
	-- spawn the cluster munuitions
	for i = 1, clusterWD.projectiles do
		SpawnProjectile(clusterWD.id, {
			pos = {x,y,z},
			speed = {(vx+math.random(-spray,spray))*vMult, (vy-math.random(spray))*vMult, (vz+math.random(-spray,spray))*vMult},
			owner = proOwnerID,
			team = teamID,
		})
	end	
end


function RangeToTarget(proID, proOwnerID, clusterWD, tx, tz, range2)
	if tracking[proID] then
		local x, _, z = GetProjectilePosition(proID)
		local dist2 = (x-tx)^2 + (z-tz)^2
		--Spring.Echo("RangeToTarget", dist2, range2)
		if dist2 < range2 then
			SpawnCluster(proID, proOwnerID, clusterWD, nil, 2.5, 0.25, true)
		else
			DelayCall(RangeToTarget, {proID, proOwnerID, clusterWD, tx, tz, range2}, 15)
		end
	end
end


function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	--Spring.Echo("PC", proID, proOwnerID, weaponID)
	local wd = WeaponDefs[weaponID]
	-- Mech only Special Ammos
	if proOwnerID and GG.mechCache[GetUnitDefID(proOwnerID)] then
		if wd and wd.name == "arrowiv" then
			local ammoType = unitSpecialAmmos[proOwnerID]["arrowiv"]
			if ammoType == "homing" 
			or ammoType == "arad" then
				ChangeMissile(proID, proOwnerID, WeaponDefNames["arrowiv_guided"])
			elseif	ammoType == "ad" then
				local targetType, info = GetProjectileTarget(proID)
				if airTargets[info] then
					ChangeMissile(proID, proOwnerID, WeaponDefNames["adarrow"])
				end
			elseif ammoType == "cluster" 
			or ammoType == "thunder" then
				local vx, vy, vz = GetProjectileVelocity(proID)
				local targetType, info = GetProjectileTarget(proID)
				local tx,ty,tz
				if targetType == string.byte('u') then -- unit target, info is ID
					tx,ty,tz = GetUnitPosition(info)
				else -- TODO: assuming ground, but engine gives all 0s for the pos table :(
					--Spring.Echo(targetType, string.byte("g"), info, more)
					tx,ty,tz = unpack(info)
				end
				tracking[proID] = true
				RangeToTarget(proID, proOwnerID, WeaponDefNames[ammoType], tx, tz, 650^2)
			end
		elseif wd and wd.customParams.weaponclass == "lrm" then
			if unitSpecialAmmos[proOwnerID]["lrm"] == "homing" 
			or unitSpecialAmmos[proOwnerID]["lrm"] == "arad"
			or (artemisUnits[proOwnerID] and artemisUnits[proOwnerID]["lrm"]) then
				ChangeMissile(proID, proOwnerID, WeaponDefNames["lrm_guided"], artemisUnits[proOwnerID] and artemisUnits[proOwnerID]["lrm"])
			end
		elseif wd and wd.customParams.weaponclass == "srm" then
			if artemisUnits[proOwnerID] and artemisUnits[proOwnerID]["srm"] then
				ChangeMissile(proID, proOwnerID, WeaponDefNames["srm_guided"], artemisUnits[proOwnerID] and artemisUnits[proOwnerID]["srm"])
			end
		elseif weaponID == GAUSS_ID and proOwnerID and silverBulletUnits[proOwnerID] then
			SpawnCluster(proID, proOwnerID, SILVERBULLET_DEF)
		end
	end
	-- LBX cluster shot
	local lbxInfo = lbx[weaponID]
	if lbxInfo then -- vehicles might have LBX
		--Spring.Echo("LBX Fired!")
		local targetType, info = GetProjectileTarget(proID)
		local tx,ty,tz
		if targetType == string.byte('u') then -- unit target, info is ID
			tx,ty,tz = GetUnitPosition(info)
		else -- TODO: assuming ground, but engine gives all 0s for the pos table :(
			--Spring.Echo(targetType, string.byte("g"), info, more)
			tx,ty,tz = unpack(info)
		end
		if GG.GetUnitDistanceToPoint(proOwnerID, tx, ty, tz) < lbxInfo[3] then
			--Spring.Echo("Close range, switch to cluster!")
			-- delete old projectile and fire cluster instead
			SpawnCluster(proID, proOwnerID, lbxInfo[1], lbxInfo[2])
		end
	-- PPC emit points for lightning
	elseif PPC_IDS[weaponID] then
		local x,y,z = GetProjectilePosition(proID)
		ppcEmits[proID] = {x, y, z}
	-- AMS tracking for lua'd burnBlow & AoE
	elseif weaponID == AMS_ID then
		amsPros[proID] = true
	end
end	


function gadget:ProjectileDestroyed(proID)
	tracking[proID] = nil
	arrows[proID] = nil
	contTAG[proID] = nil
	ppcEmits[proID] = nil -- layer must be set to after game_radar
	
	if amsPros[proID] then
		-- implement a rough approximation of burnBlow tag vs projectiles
		local x,y,z = GetProjectilePosition(proID)
		local radius = AMS_DEF.damageAreaOfEffect
		local nearPros = GetProjectilesInRectangle(x - radius, z-radius, x+radius, z+ radius, false, true)
		for i, pro in pairs(nearPros) do
			SetProjectileCollision(pro, true)
		end
	end
end



local MINE_ID = WeaponDefNames["mine"].id
local MINE_DEF_ID = UnitDefNames["mine"].id
function gadget:UnitCreated(unitID, unitDefID, teamID)
	local ud = UnitDefs[unitDefID]
	airTargets[unitID] = ud.springCategories.air
	if GG.mechCache[unitDefID] then
		unitSpecialAmmos[unitID] = {}
	end
end

local function InvincibleUnit(unitDefID) -- TODO: cache this better, single customparam?
	if unitDefID == BEACON_ID or unitDefID == BEACON_POINT_ID or UnitDefs[unitDefID].name:find("dropzone") or UnitDefs[unitDefID].customParams.decal then return true end
	return false
end
GG.InvincibleUnit = InvincibleUnit

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
	-- Don't allow any damage to beacons or dropzones
	if InvincibleUnit(unitDefID) then return 0 end
	 -- disallow mines blowing up mines
	if weaponID == MINE_ID then	return unitDefID == MINE_DEF_ID and 0 or damage end
	-- ignore none weapons
	if not attackerID then return damage end
	
	-- Armour & Ammo Mods
	local weaponDef = weaponID and WeaponDefs[weaponID]
	local heatDamage = weaponDef and weaponDef.customParams.heatdamage
	local speedChange
	-- Ammos
	local specialAmmos = unitSpecialAmmos[attackerID]
	local specialAmmo = nil
	if specialAmmos then
		local weaponType = weaponDef.customParams.weaponclass
		specialAmmo = specialAmmos[weaponType]
		if specialAmmo == "inferno" then
			damage = 0
			heatDamage = 2
		elseif specialAmmo == "armourpiercing" and not unitArmours[unitID] == "hard" then
			damage = damage * 1.25
		elseif specialAmmo == "magpulse" then
			damage = 0
			heatDamage = 1
			ApplyPPC(unitID, unitDefID)
		elseif specialAmmo == "thunder" then
			damage = damage * 0.75
		elseif specialAmmo == "bola" then
			speedChange = 0.01
		elseif specialAmmo == "explosivepod" then
			damage = 400
		elseif specialAmmo == "ecm" then
			damage = 0
		elseif specialAmmo == "tandem" and not unitArmours[unitID] == "hard" then
			damage = damage * 2
		end
	end
	-- Armours
	if heatDamage and not (unitArmours[unitID] == "heat") then
		env = Spring.UnitScript.GetScriptEnv(unitID)
		if env and env.ChangeHeat then -- dropships don't track heat
			Spring.UnitScript.CallAsUnit(unitID, env.ChangeHeat, heatDamage)
		end
	end
	if unitArmours[unitID] == "reactive" and weaponDef.weaponType == "MissileLauncher" then
		damage = damage * 0.75
	elseif unitArmours[unitID] == "ferro" then
		damage = damage * 0.88
	elseif unitArmours[unitID] == "hard" then
		damage = damage * 0.75
	elseif unitArmours[unitID] == "reflec" then
		local energy = weaponDef.customParams.weaponclass == "energy"
		if energy then
			damage = damage * 0.75
		end
	end
	
	-- NARCs
	if weaponID == NARC_ID then
		-- Don't allow dropships to be NARCed
		if GG.dropShipCache[unitDefID] then return 0 end
		if specialAmmo == "bola" then
			--Spring.Echo("speed change now", Spring.GetGameFrame())
			GG.SpeedChange(unitID, unitDefID, 0.1)
			DelayCall(GG.SpeedChange, {unitID, unitDefID, 1}, 5*30)
		elseif specialAmmo == "explosivepod" then
			return damage
		elseif specialAmmo == "thermite" then
			if unitArmours[unitID] == "heat" then return 0 end 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			if env and env.ChangeHeat then -- dropships don't track heat
				local info = {unitID, env.ChangeHeat, 0.5} -- only build the table once
				local pieceNum = env.piece(GetUnitLastAttackedPiece(unitID) or "torso")
				local fxInfo = {unitID, pieceNum, "sparks"}
				-- lol this is silly
				for i = 1, NARC_DURATION, 30 do
					DelayCall(Spring.UnitScript.CallAsUnit, info, i)
					DelayCall(GG.EmitSfxName, fxInfo, i)
				end
			end
		elseif specialAmmo == "haywire" then
			GG.setWeaponClassAttribute(unitID, "all", "accuracy", 2)
			DelayCall(GG.setWeaponClassAttribute, {unitID, "all", "accuracy", 0.5}, NARC_DURATION)
		elseif specialAmmo == "ecm" then
			local x,y,z = GetUnitPosition(unitID)
			if x then
				local ecmBeacon = Spring.CreateUnit("narc_ecm", x, y, z, 0, attackerTeam)
				Spring.UnitAttach(unitID, ecmBeacon, 0)
				SetUnitRulesParam(unitID, "ENEMY_ECM", GetGameFrame() + FRAME_FUDGE + NARC_DURATION)
				DelayCall(Spring.DestroyUnit, {ecmBeacon}, NARC_DURATION)
			end
		else -- regular NARC
			--if GG.GetUnitUnderJammer(unitID, unitTeam) then return 0 end
			local allyTeam = select(6, GetTeamInfo(attackerTeam))
			-- do the NARC, delay the deNARC
			local duration = GetUnitRulesParam(attackerID, "NARC_DURATION") or NARC_DURATION
			GG.NARC(unitID, allyTeam, duration)
			DelayCall(GG.DeNARC, {unitID, allyTeam}, duration)
		end
		-- NARC does 0 damage
		return 0
	elseif weaponID == TAG_ID then
		-- Don't allow dropships to be TAGed
		if not GG.dropShipCache[unitDefID] then
			SetUnitRulesParam(unitID, "TAG", GetGameFrame(), {inlos = true})
			--Spring.Echo("I AM BEING TAGGED!")
		end
		return 0
	elseif PPC_IDS[weaponID] then
		ApplyPPC(unitID, unitDefID)
		if attackerID and projectileID then 
			--Spring.Echo("Let there be light")
			local x,y,z = GetProjectilePosition(projectileID)
			if x then -- can be nil sometimes?
				local ox, oy, oz = unpack(ppcEmits[projectileID])
				local params = {
					["pos"]={ox,oy+5,oz}, 
					["end"] = {x,y,z}, 
					["owner"] = attackerID,
					["ttl"] = 1,
				}
				for i = 1, 6 do
					DelayCall(SpawnProjectile, {WeaponDefNames["ppc_fx"].id, params}, (i-1) * 2)
				end
				GG.PlaySoundAtUnit(unitID, "sounds/ppc_connect.wav", 5, x - ox, y - oy, z - oz, "sfx")
			end
		end
	end
	return damage, 1
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	ppcUnits[unitID] = nil
	airTargets[unitID] = nil
	-- armour
	unitArmours[unitID] = nil
	unitSpecialAmmos[unitID] = nil
end

function gadget:Initialize()
	for id, wd in pairs(WeaponDefs) do
		if wd.name ~= "sight" then Script.SetWatchAllowTarget(id, true) end -- TODO:move to set_target, can it be filtered down?
		
		local cp = wd.customParams
		local weaponClass = cp and cp.weaponclass
		if weaponClass == "lrm" or weaponClass == "arrowiv" or weaponClass == "srm" -- potential homing or cluster missiles
		or weaponClass == "lbx" -- LBX shotgun
		or wd.name == "gauss" then -- 'Silver Bullet' shotgun
			Script.SetWatchProjectile(id, true)
			if weaponClass == "lbx" then
				local clusterName = wd.name .. "_cluster"
				local clusterDef = WeaponDefNames[clusterName]
				lbx[id] = {
					clusterDef,
					math.asin(clusterDef.sprayAngle) * 140, -- a rough reproduction of engine spray 
					clusterDef.range,
				}
			end
		end
	end
end

function gadget:GameFrame()
	for proID, info in pairs(arrows) do
		SetMissileTarget(proID, info)
	end
end

else
-- Unsynced
end
