function gadget:GetInfo()
	return {
		name		= "Game - Outposts",
		desc		= "Controls construction of beacon point outposts",
		author		= "FLOZi (C. Lawrence)",
		date		= "10/08/13",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
local modOptions = Spring.GetModOptions()
local SetUnitRulesParam		= Spring.SetUnitRulesParam
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetTeamResources		= Spring.GetTeamResources
--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local TransferUnit			= Spring.TransferUnit

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local BEACON_ID = UnitDefNames["beacon"].id
GG.Beacons = {}
local BEACON_POINT_ID = UnitDefNames["beacon_point"].id

local COLOURS = GG.GameConstants.colours
-- Variables
local outpostDefs = {} -- outpostDefs[unitDefID] = {cmdDesc = {cmdDescTable}, cost = cost}
GG.outpostDefs = outpostDefs -- make available to game_dropships for running AssociateOutpost
local dropZoneDefs = {}

local outpostCMDs = {} -- outpostCMDs[cmdID] = unitDefID
local outpostPointIDs = {} -- outpostPointIDs[outpostID] = outpostPointID
local outpostIDs = {} -- outpostIDs[outpostPointID] = outpostID
GG.outpostIDs = outpostIDs -- for AI

local outpostPointBeaconIDs = {} -- outpostPointBeaconIDs[outpostPointID] = beaconID
local beaconOutpostPointIDs = {} -- beaconOutpostPointIDs[beaconID] = {outpostPointID1, outpostPointID2, outpostPointID3}
GG.beaconOutpostPointIDs = beaconOutpostPointIDs -- for AI

local function BeaconPoints(beaconID, teamID, x, y, z, radius, numPoints, spotNum)
	beaconOutpostPointIDs[beaconID] = {}
	radius = radius - 60
	local spot = GG.beaconSpots[spotNum]
	local unitsToSpawn = spot and spot.gaiaoutposts or {}
	for i = 0, numPoints - 1 do
		local angle = i * 2 * math.pi / numPoints
		local dx, dz = math.sin(angle) * radius, math.cos(angle) * radius
		local outpostPointID = CreateUnit(BEACON_POINT_ID, x + dx, y, z + dz, "s", teamID)
		Spring.SetUnitAlwaysVisible(outpostPointID, true)
		Spring.SetUnitBlocking(outpostPointID, false, false, false) -- blocking, solid objects, projectiles
		outpostPointBeaconIDs[outpostPointID] = beaconID
		beaconOutpostPointIDs[beaconID][i+1] = outpostPointID
		if unitsToSpawn[i+1] then
			local outpostID = Spring.CreateUnit(unitsToSpawn[i+1], x + dx, y, z + dz, "s", teamID)
			outpostIDs[outpostPointID] = outpostID
		end
	end
end
GG.BeaconPoints = BeaconPoints

local function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

local outpostDefsSorteds = {}
local function AlphaNameSort(a, b)
	return UnitDefs[a].humanName < UnitDefs[b].humanName
end

local menuOrder = {
	"outpost_c3array", "outpost_mechbay", "outpost_salvageyard", 	-- Mechs
	"outpost_turretcontrol", "outpost_vehiclepad", "outpost_aircon",-- Additional units
	"outpost_garrison", "outpost_sensor", "outpost_ewar",			-- Beacon Defense
	"outpost_artillery", "outpost_launcher", "outpost_uplink",		-- Artillery Support
}

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		if cp.baseclass == "outpost" then -- automatically build beacon outpost cmdDescs
			local cBillCost = unitDef.metalCost
			local outpostCmdDesc = {
				id     = GG.CustomCommands.GetCmdID("CMD_" .. name:upper(), cBillCost),
				type   = CMDTYPE.ICON,
				--name   = GG.Pad(10,unpack(mysplit(unitDef.humanName))),
				action = 'outpost',
				tooltip = 'Build: ' .. unitDef.humanName .. "\n" .. unitDef.tooltip .. "\n(" .. COLOURS.cbills .. "C-Bills cost: " .. cBillCost .. COLOURS.white .. ")",
				texture = 'unitpics/' .. name .. '.png',
			}
			outpostDefs[unitDefID] = {cmdDesc = outpostCmdDesc, cost = cBillCost}
			outpostCMDs[outpostCmdDesc.id] = unitDefID
			--table.insert(outpostDefsSorteds, unitDefID)
		end
	end
	-- sort the defs for a static order
	--table.sort(outpostDefsSorteds, AlphaNameSort)
	for position, name in ipairs(menuOrder) do
		outpostDefsSorteds[position] = UnitDefNames[name].id
	end
end

-- REGULAR OUTPOSTS

local function AddOutpostOptions(unitID)
	if not Spring.ValidUnitID(unitID) then return end
	for i, outpostDefID in ipairs(outpostDefsSorteds) do
		local outpostInfo = outpostDefs[outpostDefID]
		InsertUnitCmdDesc(unitID, outpostInfo.cmdDesc)
	end
end

local function ToggleOutpostOptions(unitID, on)
	if not Spring.ValidUnitID(unitID) then return end
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, outpostInfo.cmdDesc.id), {disabled = not on})
	end
end
GG.ToggleOutpostOptions = ToggleOutpostOptions

local function AssociateOutpost(beaconID, targetID, cargoID)
	if cargoID and targetID then -- can fail at game end
		if Spring.GetUnitTeam(beaconID) ~= Spring.GetUnitTeam(cargoID) then return end -- in case beaocn was capped before dropship spawned
		-- extra behaviour to link outposts with beacons
		outpostPointIDs[cargoID] = targetID 
		outpostIDs[targetID] = cargoID
		-- Let unsynced know about this pairing
		Spring.SetUnitRulesParam(cargoID, "beaconID", beaconID)
		Spring.SetUnitRulesParam(targetID, "outpostID", cargoID)
	end
end
GG.AssociateOutpost = AssociateOutpost

local C = "\n\n\n" .. COLOURS.cbills .. "C          "

local function CheckOutpostOptions(unitID, teamID)
	if not Spring.ValidUnitID(unitID) then return end
	if outpostIDs[unitID] then return end -- don't override ToggleOutpostOptions
	local money = GetTeamResources(teamID, "metal")
	local noCost = Spring.IsNoCostEnabled()
	
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
		if not noCost and outpostInfo.cost > money then
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, outpostInfo.cmdDesc.id), {disabled = true, name = C})
		else
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, outpostInfo.cmdDesc.id), {disabled = false, name = ""})
		end
	end
end

function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		-- check if orders are still too expensive
		for unitID in pairs(outpostPointBeaconIDs) do
			CheckOutpostOptions(unitID, Spring.GetUnitTeam(unitID))
		end
	end
end

local function RemoveCmdDescs(unitID, unitDefID)
	local ud = UnitDefs[unitDefID]
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

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == BEACON_ID then
		GG.Beacons[unitID] = true
		RemoveCmdDescs(unitID, unitDefID)
	elseif unitDefID == BEACON_POINT_ID then
		AddOutpostOptions(unitID)
		RemoveCmdDescs(unitID, unitDefID)
	elseif outpostDefs[unitDefID] then
		RemoveCmdDescs(unitID, unitDefID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if outpostDefs[unitDefID] then
		local outpostPointID = outpostPointIDs[unitID]
		if outpostPointID then -- beaconID can be nil if /give testing
			GG.Delay.DelayCall(SetUnitRulesParam, {unitID, "beaconID", ""}, 5) -- delay for safety
			env = Spring.UnitScript.GetScriptEnv(outpostPointID)
			if env and env.ChangeType then
				Spring.UnitScript.CallAsUnit(outpostPointID, env.ChangeType, false)
			end
			outpostIDs[outpostPointID] = nil
			-- Re-add outpost options to beacon
			ToggleOutpostOptions(outpostPointID, true)
		end
		outpostPointIDs[unitID] = nil
	end
end


local lastDamaged = {} -- lastDamaged[unitID] = lastDamagedFrame
local MIN_LAST_DAMAGED = 20 * 30 -- 20s
function gadget:UnitDamaged(unitID, unitDefID, teamID, damage)
	if outpostDefs[unitDefID] or GG.dropShipCache[unitDefID] == "mech" then -- unit is an outpost or dropship
		local lastDamagedFrame = lastDamaged[unitID] or 0
		local currFrame = GetGameFrame()
		local name = GG.dropShipCache[unitDefID] and "dropship" or UnitDefs[unitDefID].name
		if lastDamagedFrame < currFrame - MIN_LAST_DAMAGED then
			lastDamaged[unitID] = currFrame
			GG.PlaySoundForTeam(teamID, "bb_" .. name .. "_underattack", 1)
			local x,y,z = Spring.GetUnitPosition(unitID)
			SendToUnsynced("MESSAGE", teamID, x,y,z)
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if unitDefID == BEACON_ID then
		for i, outpostPointID in pairs(beaconOutpostPointIDs[unitID]) do			
			DelayCall(TransferUnit, {outpostPointID, newTeam}, 1) -- also transfer all the beacon outpost points
		end
	elseif unitDefID == BEACON_POINT_ID then
		-- in case point was captured between order being sent and dropship arriving
		outpostIDs[unitID] = nil -- was set to true on order, unitID only once spawned
		ToggleOutpostOptions(unitID, true) -- Re-add outpost options to beacon point
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == BEACON_POINT_ID then
		if outpostCMDs[cmdID] and not outpostIDs[unitID] then
			if GG.deadDropshipTeams[teamID] then 
				Spring.SendMessageToTeam(teamID, "Cannot place outpost at beacon - You have no dropship!")
				--GG.PlaySoundForTeam(teamID, "bb_outpost_blocked_noship", 1)
				return false 
			elseif Spring.GetUnitRulesParam(unitID, "secure") == 0 then 
				Spring.SendMessageToTeam(teamID, "Cannot place outpost at beacon - Under attack!")
				return false 
			end
			local outpostDefID = outpostCMDs[cmdID]
			local cost = (Spring.IsNoCostEnabled() and 0) or (outpostDefs[outpostDefID] and outpostDefs[outpostDefID].cost or 1000)
			if cost <= GetTeamResources(teamID, "metal") and GG.teamSide[teamID] then
				--Spring.Echo("I'm totally gonna outpost your beacon bro!")
				ToggleOutpostOptions(unitID, false)
				outpostIDs[unitID] = true -- overwritten with unitID on spawn
				GG.DropshipDelivery(outpostPointBeaconIDs[unitID], unitID, teamID, GG.teamSide[teamID] .. "_bishop", outpostDefID, cost, "bb_outpost_deploying", DROPSHIP_DELAY)
			else
				GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
			end
		else -- any other command or the beaconPoint is already outposted
			return false
		end	
	elseif UnitDefs[unitDefID].customParams.decal then
		return false -- disallow all commands to decals
	end
	return true
end

function gadget:Initialize()
	gadget:GamePreload()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED
return false end