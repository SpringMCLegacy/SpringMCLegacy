function gadget:GetInfo()
	return {
		name    = "Ammo Supplier",
		desc    = "Resupplies ammunition",
		author  = "FLOZi (C. Lawrence)",
		date    = "06/04/2013",
		license = "GNU GPL v2",
		layer   = 0,
		enabled = true -- loaded by default?
	}
end

-- function localisations
-- Synced Read
local GetUnitDefID       = Spring.GetUnitDefID
local GetUnitPosition    = Spring.GetUnitPosition
local GetUnitRulesParam  = Spring.GetUnitRulesParam
local GetUnitsInCylinder = Spring.GetUnitsInCylinder
-- Synced Ctrl
local SetUnitRulesParam  = Spring.SetUnitRulesParam

-- Variables
local ammoSuppliers = {} -- ammoSuppliers[supplierUnitID] = {team = teamID, range = cp.supplyradius}

if gadgetHandler:IsSyncedCode() then
--	SYNCED

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	-- Build table of suppliers
	if cp and cp.supplyradius then
		ammoSuppliers[unitID] = {team = teamID, range = tonumber(cp.supplyradius)}
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	ammoSuppliers[unitID] = nil
end

function gadget:UnitTaken(unitID, unitDefID, oldTeam, newTeam)
	gadget:UnitCreated(unitID, unitDefID, newTeam)
end


function gadget:GameFrame(n)
	if n % 32 == 0 then -- every 32 frames (once a second)
		for supplierID, supplyInfo in pairs(ammoSuppliers) do
			local x, _, z = GetUnitPosition(supplierID)
			local nearbyUnits = GetUnitsInCylinder(x, z, supplyInfo.range, supplyInfo.team)
			for _, unitID in pairs(nearbyUnits) do
				if unitID ~= supplierID then -- ignore yourself
					local unitDefID = GetUnitDefID(unitID)
					local info = GG.lusHelper[unitDefID]
					local ammoTypes = info.ammoTypes
					local env = Spring.UnitScript.GetScriptEnv(unitID)
					if env.Resupply then -- N.B. currently this runs for all mechs regardless of whether they have any ammo using weapons...
						for weaponNum, ammoType in pairs(ammoTypes) do --... but this loop will finish immediatly in that case
							local amount = info.burstLengths[weaponNum]
							local supplied = env.Resupply(ammoType, amount)
							if supplied then Spring.Echo("Deduct " .. amount .. " " .. ammoType) end
						end
					end
				end
			end
		end
	end
end

else
--	UNSYNCED
end
