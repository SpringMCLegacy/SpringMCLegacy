function gadget:GetInfo()
  return {
    name      = "Lups Projectile Ribbons",
    desc      = "",
    author    = "FLOZi (C. Lawrence)",
    date      = "Feb. 2014",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true
  }
end


if (gadgetHandler:IsSyncedCode()) then

local unsyncedBuffer = {}
local bufferSize = 0

-- SYNCED

function gadget:Initialize()
	for weapDefID, weapDef in pairs(WeaponDefs) do
		if weapDef.customParams and weapDef.customParams.lupsribbon then
			Script.SetWatchWeapon(weapDefID, true)
		end
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	bufferSize = bufferSize + 1
	unsyncedBuffer[bufferSize] = {proID, proOwnerID, weaponDefID}
end

function gadget:GameFrame(n)
	_G.unsyncedBuffer2 = unsyncedBuffer
	SendToUnsynced("lups_projectiles")
	_G.unsyncedBuffer2 = nil
	bufferSize = 0
	unsyncedBuffer = {}
end

else

-- UNSYNCED

local weapCache = {}
	
local function UpdateProjectiles()
	local Lups = GG.Lups
	for i, callInfo in spairs(SYNCED.unsyncedBuffer2) do
		--for k,v in spairs(callInfo) do Spring.Echo(k,v) end
		local proID, proOwnerID, weaponDefID = GG.sunpack(callInfo)
		--Spring.Echo(proID, proOwnerID, weaponDefID)
		if weaponDefID > 0 then
			local cache = weapCache[weaponDefID]
			if cache then
				--[[local options = {}
				for k,v in pairs(cache) do options[k] = v end]]
				cache.projectile = proID
				Lups.AddParticles("Ribbon", cache) -- TODO: Kinda unsafe!
			end
		end
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("lups_projectiles", UpdateProjectiles)
	
	for weapDefID, weapDef in pairs(WeaponDefs) do
		if weapDef.customParams and weapDef.customParams.lupsribbon then
			weapCache[weapDefID] = GG.StringToTable(weapDef.customParams.lupsribbon)
		end
	end
end

function gadget:Shutdown()
	gadgetHandler.RemoveSyncAction("lups_projectiles")
end

end