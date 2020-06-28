--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Projectile Lups",
		desc = "Attaches Lups FX to projectiles",
		author = "KingRaptor (L.J. Lim)",
		date = "2013-06-28",
		license = "GNU GPL, v2 or later",
		layer = 1,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local fxs = include("LuaRules/Configs/lups_projectile_fxs.lua")
local weapons = {}

for id, wd in pairs(WeaponDefs) do
	if wd.customParams and wd.customParams.projectilelups then
		local data
		local func, err = loadstring("return " .. (wd.customParams.projectilelups or ""))
		if func then
			effects = func()
		elseif err then
			Spring.Log(gadget:GetInfo().name, LOG.WARNING, "malformed projectile Lups definition for weapon " .. wd.name .. "\n" .. err  )
		end
		if effects then
			local fxList = {}
			for i, effect in pairs(effects) do
				fxList[i] = fxs[effect]
			end
			weapons[id] = fxList
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (gadgetHandler:IsSyncedCode()) then

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local projectiles = {}
local tracking = {}
local lbx = {}

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	--Spring.Echo("PC", proID, proOwnerID, weaponID)
	if WeaponDefs[weaponID] and WeaponDefs[weaponID].name == "arrowiv" then
		for i = 1, 5 do
			--Spring.Echo("Arrow IV launched!")
		end
		--tracking[proID] = true
	elseif lbx[weaponID] then
		--Spring.Echo("LBX Fired!")
		local targetType, info, more = Spring.GetProjectileTarget(proID)
		local tx,ty,tz
		if targetType == string.byte('u') then -- unit target, info is ID
			tx,ty,tz = Spring.GetUnitPosition(info)
		else -- TODO: assuming ground, but engine gives all 0s for the pos table :(
			--Spring.Echo(targetType, string.byte("g"), info, more)
			tx,ty,tz = unpack(info)
			--for k,v in pairs(info) do Spring.Echo(k,v) end
		end
		if GG.GetUnitDistanceToPoint(proOwnerID, tx, ty, tz) < 500 then
			--Spring.Echo("Close range, switch to cluster!")
			-- delete old projectile and fire cluster instead
			local clusterWD = WeaponDefNames[lbx[weaponID]]
			local x,y,z = Spring.GetProjectilePosition(proID)
			local vx, vy, vz = Spring.GetProjectileVelocity(proID)
			local spray = math.asin(clusterWD.sprayAngle) * 140 -- a rough reproduction of engine spray TODO: cache this or find a nicer calculation
			for i = 1, clusterWD.projectiles do
				Spring.SpawnProjectile(clusterWD.id, {
						pos = {x,y,z},
						speed = {(vx+math.random(-spray,spray))/2, (vy-math.random(spray))/2, (vz+math.random(-spray,spray))/2}, -- TODO: remove halving?
					})
			end
			Spring.DeleteProjectile(proID)
		end
	end
	if weapons[weaponID] then
		projectiles[proID] = true
		SendToUnsynced("lupsProjectiles_AddProjectile", proID, proOwnerID, weaponID)
	end
end	

function gadget:ProjectileDestroyed(proID)
	tracking[proID] = nil
	if projectiles[proID] then
		SendToUnsynced("lupsProjectiles_RemoveProjectile", proID)
		projectiles[proID] = nil
	end
end

function gadget:Initialize()
	for weaponID in pairs(weapons) do -- all cached defs with projectilelups
		Script.SetWatchWeapon(weaponID, true)
	end
	for id, wd in pairs(WeaponDefs) do
		if wd.customParams and (wd.customParams.projectilelups or wd.customParams.weaponclass == "lbx") then
			Script.SetWatchWeapon(id, true) -- we can't call SWW outside of synced so do it here
			if wd.customParams.weaponclass == "lbx" then -- don't include the cluster munuitions themselves or we end up with circular bs
				lbx[id] = wd.name .. "_cluster"
			end
		end
	end
end
--[[function gadget:GameFrame()
	for id in pairs(tracking) do
		local ydir = select(2,Spring.GetProjectileDirection(id))
		Spring.Echo(id, "TTL:", Spring.GetProjectileTimeToLive(id), "DIR Y:",ydir)
		if ydir < 0 then
			local x,y,z = Spring.GetProjectilePosition(id)
			local vx, vy, vz = Spring.GetProjectileVelocity(id)
			Spring.DeleteProjectile(id)
			for i = 1, 5 do
				Spring.SpawnProjectile(WeaponDefNames["nac10"].id, {
					pos = {x, y,z},
					spread = {math.random(500), math.random(500), math.random(500)},
					speed = {vx + math.random(50), 0, vz + math.random(50)},
					gravity = -1,
				})
			end
		end
	end
end]]

function gadget:Shutdown()
	for weaponID in pairs(weapons) do
		Script.SetWatchWeapon(weaponID, false)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- unsynced
--------------------------------------------------------------------------------

local Lups
local LupsAddParticles 
local SYNCED = SYNCED

local projectiles = {}

local function AddProjectile(_, proID, proOwnerID, weaponID)
  if (not Lups) then Lups = GG['Lups']; LupsAddParticles = Lups.AddParticles end
  projectiles[proID] = {}
  local def = weapons[weaponID]
  for i=1,#def do
    local fxTable = projectiles[proID]
    local fx = def[i]
    local options = {}
	table.copy(fx.options, options)
    --options.unit = proOwnerID
    options.projectile = proID
    options.weapon = weaponID
    --options.worldspace = true
    local fxID = LupsAddParticles(fx.class, options)
    if fxID ~= -1 then
      fxTable[#fxTable+1] = fxID
    end
  end
end

local function RemoveProjectile(_, proID)
  if projectiles[proID] then
    for i=1,#projectiles[proID] do
      local fxID = projectiles[proID][i]
      local fx = Lups.GetParticles(fxID)
      if fx and fx.persistAfterDeath then
        fx.isvalid = nil
      else
        Lups.RemoveParticles(fxID)
      end
    end
    projectiles[proID] = nil
  end
end



function gadget:Initialize()
  gadgetHandler:AddSyncAction("lupsProjectiles_AddProjectile", AddProjectile)
  gadgetHandler:AddSyncAction("lupsProjectiles_RemoveProjectile", RemoveProjectile)
end


function gadget:Shutdown()
  gadgetHandler:RemoveSyncAction("lupsProjectiles_AddProjectile")
  gadgetHandler:RemoveSyncAction("lupsProjectiles_RemoveProjectile")
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------