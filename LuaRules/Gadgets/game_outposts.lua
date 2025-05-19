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

-- Variables
local outpostDefs = {} -- outpostDefs[unitDefID] = {cmdDesc = {cmdDescTable}, cost = cost}
GG.outpostDefs = outpostDefs -- TODO: check why this is in GG
local dropZoneDefs = {}

local outpostCMDs = {} -- outpostCMDs[cmdID] = unitDefID
local outpostPointIDs = {} -- outpostPointIDs[outpostID] = outpostPointID
local outpostIDs = {} -- outpostIDs[outpostPointID] = outpostID
GG.outpostIDs = outpostIDs -- for AI

local outpostPointBeaconIDs = {} -- outpostPointBeaconIDs[outpostPointID] = beaconID
local beaconOutpostPointIDs = {} -- beaconOutpostPointIDs[beaconID] = {outpostPointID1, outpostPointID2, outpostPointID3}
GG.beaconOutpostPointIDs = beaconOutpostPointIDs -- for AI

local BEACON_POINT_DIST = 400
local function BeaconPoints(beaconID, teamID, x, y, z)
	beaconOutpostPointIDs[beaconID] = {}
	for i = 0, 2 do
		local angle = i * 2 * math.pi / 3
		local dx, dz = math.sin(angle) * BEACON_POINT_DIST, math.cos(angle) * BEACON_POINT_DIST
		local outpostPointID = CreateUnit(BEACON_POINT_ID, x + dx, y, z + dz, "s", teamID)
		Spring.SetUnitAlwaysVisible(outpostPointID, true)
		Spring.SetUnitBlocking(outpostPointID, false, false, false) -- blocking, solid objects, projectiles
		outpostPointBeaconIDs[outpostPointID] = beaconID
		beaconOutpostPointIDs[beaconID][i+1] = outpostPointID
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

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		if cp.baseclass == "outpost" then -- automatically build beacon outpost cmdDescs
			local cBillCost = unitDef.metalCost
			local outpostCmdDesc = {
				id     = GG.CustomCommands.GetCmdID("CMD_" .. name:upper(), cBillCost),
				type   = CMDTYPE.ICON,
				name   = GG.Pad(10,unpack(mysplit(unitDef.humanName))),
				action = 'outpost',
				tooltip = unitDef.tooltip .. " (C-Bills cost: " .. cBillCost .. ")",
			}
			outpostDefs[unitDefID] = {cmdDesc = outpostCmdDesc, cost = cBillCost}
			outpostCMDs[outpostCmdDesc.id] = unitDefID
		end
	end
end

-- REGULAR OUTPOSTS

local function AddOutpostOptions(unitID)
	if not Spring.ValidUnitID(unitID) then return end
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
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


function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == BEACON_ID then
		GG.Beacons[unitID] = true
	elseif unitDefID == BEACON_POINT_ID then
		AddOutpostOptions(unitID)
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
	local cp = UnitDefs[unitDefID].customParams
	if cp.baseclass == "outpost" then -- unit is an outpost 
		local lastDamagedFrame = lastDamaged[unitID] or 0
		local currFrame = GetGameFrame()
		local name = UnitDefs[unitDefID].name
		if lastDamagedFrame < currFrame - MIN_LAST_DAMAGED then
			lastDamaged[unitID] = currFrame
			GG.PlaySoundForTeam(teamID, "BB_" .. name .. "_UnderAttack", 1)
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
			if Spring.GetUnitRulesParam(unitID, "secure") == 0 then 
				Spring.SendMessageToTeam(teamID, "Cannot place outpost at beacon - Under attack!")
				return false 
			end
			local outpostDefID = outpostCMDs[cmdID]
			local cost = (Spring.IsNoCostEnabled() and 0) or (outpostDefs[outpostDefID] and outpostDefs[outpostDefID].cost or 1000)
			if cost <= GetTeamResources(teamID, "metal") and GG.teamSide[teamID] then
				--Spring.Echo("I'm totally gonna outpost your beacon bro!")
				ToggleOutpostOptions(unitID, false)
				outpostIDs[unitID] = true -- overwritten with unitID on spawn
				GG.DropshipDelivery(outpostPointBeaconIDs[unitID], unitID, teamID, GG.teamSide[teamID] .. "_drost", outpostDefID, cost, "BB_Dropship_Inbound", DROPSHIP_DELAY)
			else
				GG.PlaySoundForTeam(teamID, "BB_Insufficient_Funds", 1)
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

end
