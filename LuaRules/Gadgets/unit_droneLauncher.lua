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
local apcTargets = {} -- apcID = targetID
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
	if group then
		local x, z = GroupCentre(group)
		Spring.SetUnitMoveGoal(apcID, x, 0, z, 400 * 0.7)
		--Spring.MarkerAddPoint(x, 0, z)
	end
end

local function APCCountChange(apcID, change)
	apcDeployed[apcID] = apcDeployed[apcID] + change
	--Spring.Echo(apcID, "APC has now got ", apcDeployed[apcID], "deployed")
	if apcDeployed[apcID] == 0 then
		-- everyone is home, be on your way
		--Spring.Echo(apcID, "Everyone is back, Wander")
		GG.Delay.DelayCall(GG.Wander, {apcID, CMD.FIGHT}, 30)
	end
end

function gadget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if apcDefIDs[Spring.GetUnitDefID(transportID)] then
		APCCountChange(transportID, -1)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if apcDefIDs[Spring.GetUnitDefID(transportID)] then
		APCCountChange(transportID, 1)
	end
end

-- function for group to return to APC
-- TODO: APC behaviour here? Halt in current position, move to midpoint, close to loading range.
local function Embark(apcID)
	-- TODO: ...
	-- TODO: Call APC LUS function to handle the loading, though really this needs to be done on a 'as unit returns' basis...
	-- Spring.SetUnitLoadingTransport(passengerID, apcID)
	-- 
	if (apcDeployed[apcID] or 0) > 0 and apcGroups[apcID] then -- troops left to embark
		Spring.GiveOrderToUnitMap(apcGroups[apcID], CMD_EMBARK, {}, {})
	else
		--Spring.Echo(apcID, "Asked to embark but already full, so Wander")
		GG.Delay.DelayCall(GG.Wander, {apcID, CMD.FIGHT}, 30)
	end
end
GG.Embark = Embark

--[[local function Embark2(apcID)
	-- TODO: ...
	-- TODO: Call APC LUS function to handle the loading, though really this needs to be done on a 'as unit returns' basis...
	-- Spring.SetUnitLoadingTransport(passengerID, apcID)
	-- 
	if apcDeployed[apcID] > 0 and apcGroups[apcID] then -- troops left to embark
		Spring.Echo(apcID, "embark", apcDeployed[apcID], "troops")
		Spring.GiveOrderToUnitMap(apcGroups[apcID], CMD_EMBARK, {}, {})
	else
		Spring.Echo(apcID, "Asked to embark but already full, so Wander")
		GG.Delay.DelayCall(GG.Wander, {apcID, CMD.FIGHT}, 30)
	end
end]]

-- function for APC to halt and group to leave APC
local function DisEmbark(apcID, group, targetID, count)
	--Spring.Echo(apcID, "CONFIRM Target ID is", targetID)
	-- TODO: ...
	Spring.GiveOrderToUnitMap(group, CMD.ATTACK, {targetID}, {})
	--APCCountChange(apcID, count)
	--Spring.Echo("APC", apcID, "has now got ", apcDeployed[apcID], "deployed")
	apcGroups[apcID] = group
	apcTargets[apcID] = targetID
	Spring.GiveOrderToUnit(apcID, CMD_SUPPORT, {}, {})
	Spring.SetUnitRulesParam(apcID, "deployed", count)
	--SupportGroup(apcID, group)
end
GG.DisEmbark = DisEmbark

-- TODO: this would be a custom param of the apc
local basicSquad = {}
for i = 1, 5 do
	basicSquad[i] = "cl_elemental_prime"
end

function gadget:Initialize()
	Spring.AssignMouseCursor("support", "cursordefend", true, false)
	Spring.SetCustomCommandDrawData(CMD_SUPPORT, "support", {1,0.5,0,.8}, false)
	for unitDefID, unitDef in pairs(UnitDefs) do
		if unitDef.transportCapacity > 0 and unitDef.customParams.baseclass == "vehicle" then -- TODO: replace this with cp.squad
			--Spring.Echo("APC found:", unitDef.name)
			apcDefIDs[unitDefID] = basicSquad -- table.unserialize(unitDef.customparams.squad)
		end
	end
end

local function CreateSquad(apcID, squad, teamID)
	apcDeployed[apcID] = #squad
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
	for apcID, targetID in pairs(apcTargets) do
		if unitID == targetID then
			if not Spring.GetUnitIsDead(apcID) then -- a APC target died, RTB if idle
				--Spring.Echo(apcID, "TANGO DOWN!", unitID)
				-- check if APC is now idle
				local hasTarget = false
				for i = 1, 2 do -- TODO: check all APC weapons?
					local targetType, _, targetID = Spring.GetUnitWeaponTarget(apcID, i)
					hasTarget = hasTarget or (targetType == 1 and targetID ~= unitID and targetID)
				end
				if hasTarget then
					--Spring.Echo("APC ", apcID, "has target", hasTarget)
					Spring.GiveOrderToUnitMap(apcGroups[apcID], CMD.ATTACK, {hasTarget}, {})
					apcTargets[apcID] = hasTarget
				else -- idle, rtb
					Embark(apcID)
					--Spring.Echo("No more targets, RTB!")
					apcTargets[apcID] = nil
				end
			end
		end
	end
	if baAPCs[unitID] then -- A BA died
		local apcID = baAPCs[unitID]
		if apcID and apcGroups[apcID] then
			--APCCountChange(apcID, -1)
			apcGroups[apcID][unitID] = nil
		end
		baAPCs[unitID] = nil
	elseif apcGroups[unitID] then -- An APC died
		for baID in pairs(apcGroups[unitID]) do
			baAPCs[baID] = nil
		end
		apcGroups[unitID] = nil
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag)
	if apcDefIDs[unitDefID] then
		if (apcDeployed[unitID] or 0) > 0 then
			--Spring.Echo(unitID, "Only Allow APC Support Command", cmdID, CMD[cmdID], GG.CustomCommands.names[cmdID])
			if cmdID ~= CMD_SUPPORT then
				--Spring.Echo(unitID, "Only Allow APC Support Command", cmdID, CMD[cmdID], GG.CustomCommands.names[cmdID], apcDeployed[unitID])
				local x,y,z = Spring.GetUnitPosition(unitID)
				if x and y and z then
					--Spring.MarkerAddPoint(x,y,z, "Issued non-support order " .. unitID)
				end
			end
			return cmdID == CMD_SUPPORT
		end
		--Spring.Echo(unitID, "Allow APC Command", cmdID, CMD[cmdID], GG.CustomCommands.names[cmdID], apcDeployed[unitID])
	end
	return true
end

local function UnitIdleCheck(unitID, unitDefID, teamID)
	if (not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID) then return false end -- unit died
	if select(3, Spring.GetTeamInfo(teamID)) then return false end -- team died
	if teamID == GAIA_TEAM_ID then return false end -- team died and unit transferred to gaia
	local cmdQueueSize = (Spring.GetUnitCommandCount and Spring.GetUnitCommandCount(unitID)) or Spring.GetCommandQueue(unitID, 0) or 0
	--Spring.Echo(unitID, "cmdQueueSize:", cmdQueueSize)
	if cmdQueueSize > 0 then 
		--Spring.Echo(unitID, "UnitIdleCheck: I'm so not idle!") 
	elseif not apcTargets[unitID] then
		--Spring.Echo(unitID, "UnitIdleCheck: I'm so fucking idle!", apcDeployed[unitID]) 
		local x,y,z = Spring.GetUnitPosition(unitID)
		--Spring.MarkerAddPoint(x,y,z, "Idle APC: " .. unitID)
		Embark2(unitID)
	end
end

--[[function gadget:UnitIdle(unitID, unitDefID, teamID)
	if baAPCs[unitID] then -- Idle BA
		--Spring.GiveOrderToUnit(unitID, CMD_EMBARK, {}, {})
		--Spring.Echo(baAPCs[unitID], "Embark damnit", unitID)
		--GG.Delay.DelayCall(Embark, {baAPCs[unitID]},30)
	elseif apcDefIDs[unitDefID] then -- Idle APC
		--Spring.Echo(unitID, "APC is idle, ask to embark")
		local x,y,z = Spring.GetUnitPosition(unitID)
		--Spring.MarkerAddPoint(x,y,z, "Idle APC: " .. unitID)
		--GG.Delay.DelayCall(Embark, {unitID},16)
		--GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, 128)
	end
end]]

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
						--APCCountChange(apcID, -1)
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