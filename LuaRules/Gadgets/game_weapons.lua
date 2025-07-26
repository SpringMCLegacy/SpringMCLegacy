--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (gadgetHandler:IsSyncedCode()) then
-- SYNCED
-- Localisations
-- SyncedRead
local GetProjectilePosition 			= Spring.GetProjectilePosition
local GetProjectileTarget				= Spring.GetProjectileTarget
local GetProjectileVelocity				= Spring.GetProjectileVelocity
local GetProjectilesInRectangle 		= Spring.GetProjectilesInRectangle
local GetUnitDefID						= Spring.GetUnitDefID
local GetUnitIsDead						= Spring.GetUnitIsDead
local GetUnitPosition					= Spring.GetUnitPosition
local GetUnitTeam						= Spring.GetUnitTeam
local GetUnitVelocity					= Spring.GetUnitVelocity
local ValidUnitID						= Spring.ValidUnitID
-- SyncedCtrl
local DeleteProjectile					= Spring.DeleteProjectile
local SetProjectileCollision 			= Spring.SetProjectileCollision
local SetProjectileIgnoreTrackingError 	= Spring.SetProjectileIgnoreTrackingError
local SetProjectileTarget				= Spring.SetProjectileTarget
local SpawnProjectile					= Spring.SpawnProjectile
-- GG
local DelayCall							= GG.Delay.DelayCall

-- Constants
local ARROW_CLUSTER_ID = WeaponDefNames["arrowiv_cluster"].id
local AMS_DEF = WeaponDefNames["ams"] 
local AMS_ID = WeaponDefNames["ams"].id
local GAUSS_ID = WeaponDefNames["gauss"].id
local SILVERBULLET_DEF = WeaponDefNames["silverbullet"]

-- Variables
local tracking = {}
local contTAG = {}
local arrows = {}

local amsPros = {}
local ppcEmits = {}
GG.ppcEmits = ppcEmits -- TODO: remove this once brought over from game_radar

local lbx = {}
local silverBulletUnits = {}

local function EnableSilverBullet(unitID, tOrF)
	silverBulletUnits[unitID] = tOrF
end
GG.EnableSilverBullet = EnableSilverBullet


local function SetMissileTarget(proID, info)
--	Spring.Echo("SetMissileTarget", proID, info.targetID, info.ownerID, info.weaponclass, info.artemisOnly)
	if info.targetID and ValidUnitID(info.targetID) and not GetUnitIsDead(info.targetID) -- target is alive
    and info.ownerID and ValidUnitID(info.ownerID) and not GetUnitIsDead(info.ownerID) then -- owner is alive
		--Spring.Echo("SetMissileTarget", proID, UnitDefs(GetUnitDefID(info.targetID)].name, UnitDefs[GetUnitDefID(info.ownerID)].name, info.weaponclass, info.artemisOnly)
		if ((GG.IsUnitNARCed(info.targetID) or GG.IsUnitTAGed(info.targetID)) and not info.artemisOnly)
		or (info.artemisOnly and GG.IsTargetArtemised(info.ownerID, info.targetID, info.weaponclass)) 
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
		local arad = GG.jammerCache[targetID] and GG.unitSpecialAmmos[proOwnerID][weaponClass] == "arad"
		local ad = GG.unitSpecialAmmos[proOwnerID][weaponClass] == "ad" and GG.airTargets[targetID]
		if ((GG.IsUnitNARCed(targetID) or GG.IsUnitTAGed(targetID)) and not artemisOnly) 
		or (artemisOnly and GG.IsTargetArtemised(proOwnerID, targetID, weaponClass)) 
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
	if weaponID == MELTDOWN_WDID then
		Spring.SetProjectileAlwaysVisible(proID, true)
	end
	-- Mech only Special Ammos
	if proOwnerID and GG.mechCache[GetUnitDefID(proOwnerID)] then
		if wd and wd.name == "arrowiv" then
			local ammoType = GG.unitSpecialAmmos[proOwnerID]["arrowiv"]
			if ammoType == "homing" 
			or ammoType == "arad" then
				ChangeMissile(proID, proOwnerID, WeaponDefNames["arrowiv_guided"])
			elseif	ammoType == "ad" then
				local targetType, info = GetProjectileTarget(proID)
				if GG.airTargets[info] then
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
			if GG.unitSpecialAmmos[proOwnerID]["lrm"] == "homing" 
			or GG.unitSpecialAmmos[proOwnerID]["lrm"] == "arad"
			or (GG.artemisUnits[proOwnerID] and GG.artemisUnits[proOwnerID]["lrm"]) then
				ChangeMissile(proID, proOwnerID, WeaponDefNames["lrm_guided"], GG.artemisUnits[proOwnerID] and GG.artemisUnits[proOwnerID]["lrm"])
			end
		elseif wd and wd.customParams.weaponclass == "srm" then
			if GG.artemisUnits[proOwnerID] and GG.artemisUnits[proOwnerID]["srm"] then
				ChangeMissile(proID, proOwnerID, WeaponDefNames["srm_guided"], GG.artemisUnits[proOwnerID] and GG.artemisUnits[proOwnerID]["srm"])
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
			--for k,v in pairs(info) do Spring.Echo(k,v) end
		end
		if GG.GetUnitDistanceToPoint(proOwnerID, tx, ty, tz) < lbxInfo[3] then
			--Spring.Echo("Close range, switch to cluster!")
			-- delete old projectile and fire cluster instead
			SpawnCluster(proID, proOwnerID, lbxInfo[1], lbxInfo[2])
		end
	-- PPC emit points for lightning
	elseif GG.PPC_IDS[weaponID] then
		local x,y,z = GetProjectilePosition(proID)
		ppcEmits[proID] = {x, y , z}
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
