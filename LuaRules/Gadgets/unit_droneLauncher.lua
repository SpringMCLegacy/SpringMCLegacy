if (gadgetHandler:IsSyncedCode()) then

function gadget:GetInfo()
	return {
		name = "Drone Launcher",
		desc = "Handles Drone launching",
		author = "KDR_11k (David Becker)",
		date = "2008-04-09",
		license = "Public Domain",
		layer = 28,
		enabled = true
	}
end

local CMD_SUPPORT = GG.CustomCommands.GetCmdID("CMD_SUPPORT")
local CMD_WAITFORSQUAD = GG.CustomCommands.GetCmdID("CMD_WAITFORSQUAD")
local CMD_EMBARK = GG.CustomCommands.GetCmdID("CMD_EMBARK")

local apcGroups = {} -- apcID = group
local apcDefIDs = {} -- unitDefID = squad
local apcDeployed = {} -- apcID = number deployed
local apcTargets = {} -- targetID = apcID
local baAPCs = {} -- baID = apcID


local function GroupCentre(group)
	local x, z, n = 0, 0, 0
	for unitID in pairs(group) do
		n = n + 1
		if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
			local ux, _, uz = Spring.GetUnitPosition(unitID)
			x = x + ux
			z = z + uz
		end
	end
	x = x / n
	z = z / n
	return x, z
end



-- maybe in the following don't pass group as a table but rather have a table lookup apcGroup[apcID] = {groupMember1ID, ...}
-- function to periodically update APC to follow group and support at weapon range
-- this is probably called via CommandFallback?
local function SupportGroup(apcID, group)
	-- TODO: use APC primary weapon range
	local x, z = GroupCentre(group)
	Spring.SetUnitMoveGoal(apcID, x, 0, z, 800 * 0.7)
	--Spring.MarkerAddPoint(x, 0, z)
end

local function APCCountChange(apcID, change)
	apcDeployed[apcID] = apcDeployed[apcID] + change
	--Spring.Echo("APC", apcID, "has now got ", apcDeployed[apcID], "deployed")
	if apcDeployed[apcID] == 0 then
		-- everyone is home, be on your way
		GG.Delay.DelayCall(GG.Wander, {apcID}, 30)
	end
end

-- function for group to return to APC
-- TODO: APC behaviour here? Halt in current position, move to midpoint, close to loading range.
local function Embark(apcID, group)
	-- TODO: ...
	-- TODO: Call APC LUS function to handle the loading, though really this needs to be done on a 'as unit returns' basis...
	-- Spring.SetUnitLoadingTransport(passengerID, apcID)
	-- 
end

-- function for APC to halt and group to leave APC
local function DisEmbark(apcID, group, targetID, count)
	--Spring.Echo("CONFIRM Target ID is", targetID)
	-- TODO: ...
	Spring.GiveOrderToUnitMap(group, CMD.ATTACK, {targetID}, {})
	APCCountChange(apcID, count)
	--Spring.Echo("APC", apcID, "has now got ", apcDeployed[apcID], "deployed")
	apcGroups[apcID] = group
	apcTargets[targetID] = apcID
	Spring.GiveOrderToUnit(apcID, CMD_SUPPORT, {}, {})
	--SupportGroup(apcID, group)
end
GG.DisEmbark = DisEmbark

-- TODO: this would be a custom param of the apc
local basicSquad = {}
for i = 1, 5 do
	basicSquad[i] = "cl_elemental_prime"
end

function gadget:Initialize()
	for unitDefID, unitDef in pairs(UnitDefs) do
		if unitDef.transportCapacity > 0 and unitDef.trackWidth then -- TODO: replace this with cp.squad
			apcDefIDs[unitDefID] = basicSquad -- table.unserialize(unitDef.customparams.squad)
		end
	end
end

local function CreateSquad(apcID, squad, teamID)
	apcDeployed[apcID] = 0
	env = Spring.UnitScript.GetScriptEnv(apcID)
	if env.Load then
		-- spawn and load the squad
		for i, unitName in ipairs(squad) do
			--Spring.Echo("SPAWN ME A ", unitName)
			local squaddieID = Spring.CreateUnit(unitName, 0,0,0, 0, teamID)
			baAPCs[squaddieID] = apcID
			Spring.UnitScript.CallAsUnit(apcID, env.Load, squaddieID)
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local squad = apcDefIDs[unitDefID]
	if squad then
		GG.Delay.DelayCall(CreateSquad, {unitID, squad, teamID}, 1) -- avoid recursion BS
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	local apcID = apcTargets[unitID]
	if apcID and not Spring.GetUnitIsDead(apcID) then -- a APC target died, RTB if idle
		--Spring.Echo("TANGO DOWN!", apcID)
		-- check if APC is now idle
		local hasTarget = false
		for i = 1, 2 do -- TODO: check all APC weapons?
			local targetType, _, targetID = Spring.GetUnitWeaponTarget(apcID, i)
			hasTarget = hasTarget or (targetType == 1 and targetID ~= unitID and targetID)
		end
		if hasTarget then
			--Spring.Echo("APC ", apcID, "has target", hasTarget)
			Spring.GiveOrderToUnitMap(apcGroups[apcID], CMD.ATTACK, {hasTarget}, {})
			apcTargets[hasTarget] = apcID	
		else -- idle, rtb
			Spring.GiveOrderToUnitMap(apcGroups[apcID], CMD_EMBARK, {}, {})
			--Spring.Echo("No more targets, RTB!")
		end
		apcTargets[unitID] = nil
	end
	if baAPCs[unitID] then
		local apcID = baAPCs[unitID]
		if apcID and not Spring.GetUnitIsDead(apcID) then
			APCCountChange(apcID, -1)
			apcGroups[apcID][unitID] = nil
		end
		baAPCs[unitID] = nil
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag)
	if apcDefIDs[unitDefID] then
		if (apcDeployed[unitID] or 0) > 0 then
			return cmdID == CMD_SUPPORT
		end
	end
	return true
end

local LOAD_RADIUS = 45
function gadget:CommandFallback(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag)
	if apcDefIDs[unitDefID] then
		if cmdID == CMD_SUPPORT then
			--Spring.Echo("GET YO ASS OVER HERE AN HELP ME!")
			SupportGroup(unitID, apcGroups[unitID])
			return true, false
			-- TODO: handle the command ending on embark
		end
	elseif unitDefID == UnitDefNames["cl_elemental_prime"].id then -- TODO: dehack this, cache BA defs
		if cmdID == CMD_EMBARK then
			local apcID = baAPCs[unitID]
			if apcID and not Spring.GetUnitIsDead(apcID) then
				local x,y,z = Spring.GetUnitPosition(apcID)
				-- UnitSeparation is no good for getting in at the back... 
				--local dist = Spring.GetUnitSeparation(unitID, apcID)
				local dx, dy, dz = Spring.GetUnitDirection(apcID)
				if not dx then
					Spring.Echo("WTF mate", apcID, UnitDefs[Spring.GetUnitDefID(apcID)].name)
				end
				local tx, tz = x - LOAD_RADIUS * dx, z - LOAD_RADIUS * dz -- crash here due to dx being nil... wtf?
				local dist = GG.GetUnitDistanceToPoint(unitID, tx, y, tz)
				if dist > LOAD_RADIUS then
					Spring.SetUnitMoveGoal(unitID, tx, y, tz, LOAD_RADIUS * 0.5)
					--Spring.Echo("RTB mate!")
					return true, false
				else
					env = Spring.UnitScript.GetScriptEnv(apcID)
					if env.Load then
						--Spring.SetUnitLoadingTransport(unitID, apcID)
						Spring.UnitScript.CallAsUnit(apcID, env.Load, unitID)
						APCCountChange(apcID, -1)
						return true, true
					end
				end
			else -- APC is dead
				return true, true
			end
		end
	end
	return false, false
end

end