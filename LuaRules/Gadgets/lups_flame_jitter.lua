-- $Id: lups_flame_jitter.lua 3643 2009-01-03 03:00:52Z jk $
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Lups Flamethrower Jitter",
    desc      = "Flamethrower jitter FX with LUPS",
    author    = "jK",
    date      = "Apr, 2008",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true,  --  loaded by default?
  }
end

local MIN_EFFECT_INTERVAL = 20

if (gadgetHandler:IsSyncedCode()) then
-------------------------------------------------------------------------------------
-- -> SYNCED
-------------------------------------------------------------------------------------

  --// Speed-ups
  local SendToUnsynced = SendToUnsynced

  -------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------

  local thisGameFrame = 0
  local lastLupsSpawn = {}

  function FlameShot(unitID,unitDefID,_, weapon)
    lastLupsSpawn[unitID] = lastLupsSpawn[unitID] or {}
    if ( ((lastLupsSpawn[unitID][weapon] or lastLupsSpawn[unitID]["engine"] or 0) - thisGameFrame) <= -MIN_EFFECT_INTERVAL ) then
      if weapon then
	    lastLupsSpawn[unitID][weapon] = thisGameFrame
	  else
	    lastLupsSpawn[unitID]["engine"] = thisGameFrame
	  end
      SendToUnsynced("flame_FlameShot", unitID, unitDefID, weapon)
    end
  end
  
  GG.LUPS = GG.LUPS or {}
  GG.LUPS.FlameShot = FlameShot

  function gadget:GameFrame(n)
    thisGameFrame = n
    SendToUnsynced("flame_GameFrame")
  end

  -------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------

  function gadget:Initialize()
    gadgetHandler:RegisterGlobal("FlameShot",FlameShot)
    gadgetHandler:RegisterGlobal("FlameSetDir",FlameSetDir)
    gadgetHandler:RegisterGlobal("FlameSetFirePoint",FlameSetFirePoint)
  end

  function gadget:Shutdown()
    gadgetHandler:DeregisterGlobal("FlameShot")
    gadgetHandler:DeregisterGlobal("FlameSetDir")
    gadgetHandler:DeregisterGlobal("FlameSetFirePoint")
  end

else
-------------------------------------------------------------------------------------
-- -> UNSYNCED
-------------------------------------------------------------------------------------

  local particleCnt  = 1
  local particleList = {}

  local lastShoot = {}

  function FlameShot(_,unitID, unitDefID, weapon)

    local posx,posy,posz, dirx,diry,dirz 
	local range
	
	if weapon then
	  posx,posy,posz,dirx,diry,dirz = Spring.GetUnitWeaponVectors(unitID,weapon)
      local wd  = WeaponDefs[UnitDefs[unitDefID].weapons[weapon].weaponDef]
      range = wd.range*wd.duration
	  --local weaponVelocity = wd.projectilespeed
	else -- engine
	  posx,posy,posz = Spring.GetUnitPosition(unitID)
	  dirx,diry,dirz = 0, -1, 0
	  range = 1000
	end

    local speedx,speedy,speedz = Spring.GetUnitVelocity(unitID)
    local partpos = "x*delay,y*delay,z*delay|x="..speedx..",y="..speedy..",z="..speedz
	
    particleList[particleCnt] = {
      class        = 'JitterParticles2',
      colormap     = { {1,1,1,1},{1,1,1,1} },
      count        = 6,
      life         = range / 6,
      delaySpread  = 25,
      force        = {0,1.5,0},
      --forceExp     = 0.2,

      partpos      = partpos,
      pos          = {posx,posy,posz},

      emitVector   = {dirx,diry,dirz},
      emitRotSpread= 10,

      speed        = 7,
      speedSpread  = 0,
      speedExp     = 1.5,

      size         = 15,
      sizeGrowth   = 5.0,

      scale        = 1.5,
      strength     = 1.0,
      heat         = 2,
    }
    particleCnt = particleCnt + 1

  end

  function GameFrame()
    if (particleCnt>1) then
      particleList.n = particleCnt
      GG.Lups.AddParticlesArray(particleList)
      particleList = {}
      particleCnt  = 1
    end
  end

  -------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------

  function gadget:Initialize()
    gl.DeleteTexture("bitmaps/GPL/flame.png")
    gadgetHandler:AddSyncAction("flame_GameFrame", GameFrame)
    gadgetHandler:AddSyncAction("flame_FlameShot", FlameShot)
  end

  function gadget:Shutdown()
    gadgetHandler:RemoveSyncAction("flame_FlameShot")
  end

end