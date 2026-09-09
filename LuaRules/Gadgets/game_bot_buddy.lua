--------------------------------------------------------------------------------
-- MCL Bot Buddy core - revision 4
--
-- Extends the placement prototype with desired-state reconstruction: each managed
-- Beacon wants three Wall units. Losses begin a quiet-period delay; after the
-- most recent loss has remained undisturbed for that delay, missing Walls are
-- rebuilt one at a time using fresh terrain-aware placement searches.
-- No economy, power, progression, salvage, production, or military behavior is
-- implemented yet.
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Game - Bot Buddy Core",
		desc      = "Tracks Bot Buddy Beacon Bases and tests delayed desired-state reconstruction",
		author    = "zvero + ChatGPT",
		date      = "August 2026",
		license   = "GNU GPL v2",
		layer     = 3,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then
	return
end

local defs = VFS.Include("LuaRules/Configs/BotBuddy/bot_buddy_defs.lua")
local placement = VFS.Include("LuaRules/Configs/BotBuddy/bot_buddy_placement.lua")

local CreateUnit          = Spring.CreateUnit
local DestroyUnit         = Spring.DestroyUnit
local Echo                = Spring.Echo
local GetAllUnits         = Spring.GetAllUnits
local GetGameFrame        = Spring.GetGameFrame
local GetGaiaTeamID       = Spring.GetGaiaTeamID
local GetModOptions       = Spring.GetModOptions
local GetPlayerInfo       = Spring.GetPlayerInfo
local GetPlayerList       = Spring.GetPlayerList
local GetTeamInfo         = Spring.GetTeamInfo
local GetTeamList         = Spring.GetTeamList
local GetTeamLuaAI        = Spring.GetTeamLuaAI
local GetUnitDefID        = Spring.GetUnitDefID
local GetUnitTeam         = Spring.GetUnitTeam
local SetUnitRulesParam   = Spring.SetUnitRulesParam
local TransferUnit        = Spring.TransferUnit
local ValidUnitID         = Spring.ValidUnitID

local GAIA_TEAM_ID = GetGaiaTeamID()
local BEACON_ID = UnitDefNames.beacon and UnitDefNames.beacon.id
local TEST_STRUCTURE_ID = UnitDefNames[defs.TEST_STRUCTURE_NAME] and UnitDefNames[defs.TEST_STRUCTURE_NAME].id

local modOptions = GetModOptions() or {}
local mode = tostring(modOptions[defs.MODOPTION_KEY] or defs.DEFAULT_MODE):lower()
if not defs.VALID_MODES[mode] then
	Echo("[MCL Bot Buddy r4] Unknown mode '" .. mode .. "'; falling back to '" .. defs.DEFAULT_MODE .. "'.")
	mode = defs.DEFAULT_MODE
end

local controllers = {}
local bases = {}
local structureToBase = {}

local function DebugEcho(...)
	if defs.DEBUG then
		Echo("[MCL Bot Buddy r4]", ...)
	end
end

local function FlagIsSet(value)
	return value == true or value == 1 or value == "1"
end

local function IsShadowBotBuddyTeam(teamID)
	if mode ~= "shadow" or teamID == GAIA_TEAM_ID then
		return false
	end

	local _, _, isDead, hasAI = GetTeamInfo(teamID, false)
	if isDead == nil or FlagIsSet(isDead) or FlagIsSet(hasAI) then
		return false
	end

	local luaAI = GetTeamLuaAI(teamID)
	if luaAI and luaAI ~= "" then
		return false
	end

	local players = GetPlayerList(teamID) or {}
	for i = 1, #players do
		local _, _, spectator = GetPlayerInfo(players[i], false)
		if spectator == false then
			return true
		end
	end

	return false
end

local function CreateController(teamID)
	local controller = controllers[teamID]
	if controller then
		return controller
	end
	if not IsShadowBotBuddyTeam(teamID) then
		return nil
	end

	controller = {
		teamID = teamID,
		mode = "shadow",
		playerEliminated = GG.deadDropshipTeams and GG.deadDropshipTeams[teamID] or false,
		bases = {},
	}
	controllers[teamID] = controller
	DebugEcho("Created shadow controller for team", teamID)
	return controller
end

local function EnsureController(teamID)
	return controllers[teamID] or CreateController(teamID)
end

local function DetachBase(base)
	local oldControllerTeamID = base.controllerTeamID
	if oldControllerTeamID then
		local controller = controllers[oldControllerTeamID]
		if controller then
			controller.bases[base.beaconID] = nil
		end
	end
	base.controllerTeamID = nil
end

local function AttachBase(base, teamID)
	DetachBase(base)
	base.ownerTeamID = teamID

	local controller = EnsureController(teamID)
	if controller then
		base.controllerTeamID = teamID
		controller.bases[base.beaconID] = base
	end

	return controller
end

local function NewBaseState(beaconID, ownerTeamID, frame)
	local base = {
		beaconID = beaconID,
		ownerTeamID = ownerTeamID,
		controllerTeamID = nil,

		level = 0,
		developmentStartFrame = frame,
		neutralizedFrame = nil,
		previousOwnerTeamID = nil,

		structures = {},
		utilityUnits = {},
		activeConstruction = nil,

		-- r4 desired-state prototype placement/reconstruction state.
		testStructureIDs = {},
		nextPrototypeSerial = 1,
		nextPlacementFrame = frame,
		reconstructionReadyFrame = nil,
	}
	bases[beaconID] = base
	AttachBase(base, ownerTeamID)
	return base
end

local function ForgetStructure(base, unitID)
	if not base or not unitID then
		return
	end
	base.structures[unitID] = nil
	structureToBase[unitID] = nil
	if base.testStructureIDs then
		base.testStructureIDs[unitID] = nil
	end
end

local function DestroyPrototypeStructures(base)
	if not base or not base.testStructureIDs then
		return
	end

	local toDestroy = {}
	for unitID in pairs(base.testStructureIDs) do
		toDestroy[#toDestroy + 1] = unitID
	end
	for i = 1, #toDestroy do
		local unitID = toDestroy[i]
		ForgetStructure(base, unitID)
		if ValidUnitID(unitID) then
			DestroyUnit(unitID, false, true)
		end
	end
end

local function TransferBaseStructures(base, newTeam)
	for unitID in pairs(base.structures) do
		if ValidUnitID(unitID) then
			TransferUnit(unitID, newTeam, false)
		else
			ForgetStructure(base, unitID)
		end
	end
end

local function RemoveBase(beaconID, reason)
	local base = bases[beaconID]
	if not base then
		return
	end
	DetachBase(base)
	for unitID in pairs(base.structures) do
		structureToBase[unitID] = nil
	end
	bases[beaconID] = nil
	DebugEcho("Removed BaseState for Beacon", beaconID, reason or "")
end

local function RegisterOwnedBeacon(beaconID, teamID, reason)
	local controller = EnsureController(teamID)
	if not controller then
		return nil
	end

	local base = bases[beaconID]
	if not base then
		base = NewBaseState(beaconID, teamID, GetGameFrame())
		DebugEcho("Created BaseState for Beacon", beaconID, "team", teamID, reason or "")
	elseif base.ownerTeamID ~= teamID or base.controllerTeamID ~= teamID then
		AttachBase(base, teamID)
		DebugEcho("Attached existing BaseState for Beacon", beaconID, "to team", teamID, reason or "")
	end
	return base
end

local function HandleBeaconNeutralized(beaconID, oldTeam)
	local base = bases[beaconID]
	if not base then
		return
	end

	-- r3's Walls are only placement probes. Do not attempt the future neutral
	-- infrastructure-adoption mechanic yet; Gaia-owned structures inside a
	-- Beacon's capture radius would themselves contest capture under the current
	-- flag manager. The real neutral-transfer policy will be implemented later.
	DestroyPrototypeStructures(base)

	DetachBase(base)
	base.previousOwnerTeamID = oldTeam
	base.ownerTeamID = GAIA_TEAM_ID
	base.level = 0
	base.developmentStartFrame = nil
	base.neutralizedFrame = GetGameFrame()
	base.activeConstruction = nil
	base.testStructureIDs = {}
	base.nextPrototypeSerial = 1
	base.nextPlacementFrame = nil
	base.reconstructionReadyFrame = nil

	DebugEcho("Beacon", beaconID, "neutralized from team", oldTeam, "- prototype structures cleared")
end

local function HandleBeaconCaptured(beaconID, newTeam)
	local frame = GetGameFrame()
	local base = bases[beaconID]
	local controller = EnsureController(newTeam)

	if not base then
		if not controller then
			return
		end
		base = NewBaseState(beaconID, newTeam, frame)
	else
		DetachBase(base)
		base.ownerTeamID = newTeam
		base.level = 0
		base.developmentStartFrame = frame
		base.neutralizedFrame = nil
		base.previousOwnerTeamID = nil
		base.activeConstruction = nil
		base.testStructureIDs = {}
		base.nextPrototypeSerial = 1
		base.nextPlacementFrame = frame
		base.reconstructionReadyFrame = nil
		if controller then
			base.controllerTeamID = newTeam
			controller.bases[beaconID] = base
		end
	end

	if controller then
		DebugEcho("Beacon", beaconID, "captured by team", newTeam, "- placement prototype armed")
	else
		DebugEcho("Beacon", beaconID, "captured by unmanaged team", newTeam, "- retained BaseState is not controlled")
	end
end

local function HandleBeaconTransferred(beaconID, oldTeam, newTeam)
	local base = bases[beaconID]
	local controller = EnsureController(newTeam)

	if not base then
		if not controller then
			return
		end
		base = NewBaseState(beaconID, newTeam, GetGameFrame())
		DebugEcho("Beacon", beaconID, "transferred to team", newTeam, "without prior BaseState - created at level 0")
		return
	end

	local preservedLevel = base.level
	local preservedStartFrame = base.developmentStartFrame
	DetachBase(base)
	base.previousOwnerTeamID = oldTeam
	base.ownerTeamID = newTeam
	base.neutralizedFrame = nil
	base.level = preservedLevel
	base.developmentStartFrame = preservedStartFrame

	if controller then
		base.controllerTeamID = newTeam
		controller.bases[beaconID] = base
		TransferBaseStructures(base, newTeam)
		DebugEcho("Beacon", beaconID, "allied transfer", oldTeam, "->", newTeam, "- progression and prototype structure preserved")
	else
		DebugEcho("Beacon", beaconID, "transferred", oldTeam, "-> unmanaged team", newTeam, "- BaseState retained")
	end
end

local function HandleBeaconOwnershipChange(beaconID, newTeam, oldTeam)
	if newTeam == oldTeam then
		return
	end

	if newTeam == GAIA_TEAM_ID then
		HandleBeaconNeutralized(beaconID, oldTeam)
	elseif oldTeam == GAIA_TEAM_ID then
		HandleBeaconCaptured(beaconID, newTeam)
	else
		HandleBeaconTransferred(beaconID, oldTeam, newTeam)
	end
end

local function DiscoverControllers()
	if mode ~= "shadow" then
		return
	end
	local teams = GetTeamList() or {}
	for i = 1, #teams do
		EnsureController(teams[i])
	end
end

local function ScanExistingBeacons()
	if not BEACON_ID then
		return
	end
	local units = GetAllUnits() or {}
	for i = 1, #units do
		local unitID = units[i]
		if GetUnitDefID(unitID) == BEACON_ID then
			local teamID = GetUnitTeam(unitID)
			if teamID and teamID ~= GAIA_TEAM_ID then
				RegisterOwnedBeacon(unitID, teamID, "(existing Beacon scan)")
			end
		end
	end
end

local function CheckPlayerEliminations()
	local deadDropshipTeams = GG.deadDropshipTeams
	if not deadDropshipTeams then
		return
	end

	for teamID, controller in pairs(controllers) do
		if not controller.playerEliminated and deadDropshipTeams[teamID] then
			controller.playerEliminated = true
			DebugEcho("Team", teamID, "Dropship elimination detected; no Bot Buddy ownership action is taken yet")
		end
	end
end

local function FormatPlacementStats(stats)
	if not stats then
		return "no stats"
	end
	local parts = {
		"tested=" .. tostring(stats.tested or 0),
		"valid=" .. tostring(stats.valid or 0),
	}
	if stats.rejected then
		for reason, count in pairs(stats.rejected) do
			parts[#parts + 1] = reason .. "=" .. count
		end
	end
	return table.concat(parts, ", ")
end

local function CountPrototypeStructures(base)
	local count = 0
	local stale = {}
	for unitID in pairs(base.testStructureIDs or {}) do
		if ValidUnitID(unitID) then
			count = count + 1
		else
			stale[#stale + 1] = unitID
		end
	end
	for i = 1, #stale do
		ForgetStructure(base, stale[i])
	end
	return count
end

local function AttemptPrototypePlacement(base, frame)
	if not TEST_STRUCTURE_ID
		or not base.controllerTeamID
		or base.ownerTeamID == GAIA_TEAM_ID
		or (base.nextPlacementFrame and frame < base.nextPlacementFrame)
		or (base.reconstructionReadyFrame and frame < base.reconstructionReadyFrame)
	then
		return
	end

	local existingCount = CountPrototypeStructures(base)
	if existingCount >= defs.TEST_STRUCTURE_COUNT then
		base.nextPlacementFrame = nil
		base.reconstructionReadyFrame = nil
		return
	end

	-- Once the quiet-period delay has expired, reconstruction proceeds normally.
	if base.reconstructionReadyFrame and frame >= base.reconstructionReadyFrame then
		DebugEcho(
			"Beacon", base.beaconID,
			"reconstruction delay expired; restoring prototype desired state",
			existingCount .. "/" .. defs.TEST_STRUCTURE_COUNT
		)
		base.reconstructionReadyFrame = nil
	end

	local placementSerial = base.nextPrototypeSerial or 1
	local site, stats = placement.FindBuildPosition(
		base.beaconID,
		TEST_STRUCTURE_ID,
		defs.PLACEMENT,
		placementSerial
	)
	if not site then
		base.nextPlacementFrame = frame + defs.PLACEMENT.RETRY_FRAMES
		DebugEcho(
			"Beacon", base.beaconID,
			"found no valid", defs.TEST_STRUCTURE_NAME,
			"site while at", existingCount .. "/" .. defs.TEST_STRUCTURE_COUNT .. "; retry scheduled;",
			FormatPlacementStats(stats)
		)
		return
	end

	local unitID = CreateUnit(defs.TEST_STRUCTURE_NAME, site.x, site.y, site.z, site.facing, base.ownerTeamID)
	if not unitID then
		base.nextPlacementFrame = frame + defs.PLACEMENT.RETRY_FRAMES
		DebugEcho("Beacon", base.beaconID, "selected a site but failed to create", defs.TEST_STRUCTURE_NAME)
		return
	end

	base.testStructureIDs[unitID] = true
	base.nextPrototypeSerial = placementSerial + 1
	base.nextPlacementFrame = frame + defs.PLACEMENT.PLACEMENT_UPDATE_FRAMES
	base.structures[unitID] = {
		role = "TEST_STRUCTURE",
		unitDefID = TEST_STRUCTURE_ID,
		prototypeSerial = placementSerial,
	}
	structureToBase[unitID] = base.beaconID

	SetUnitRulesParam(unitID, "bot_buddy", 1, {public = true})
	SetUnitRulesParam(unitID, "bot_buddy_beacon", base.beaconID, {public = true})
	SetUnitRulesParam(unitID, "bot_buddy_test_structure", 1, {public = true})
	SetUnitRulesParam(unitID, "bot_buddy_test_index", placementSerial, {public = true})

	local newCount = existingCount + 1
	DebugEcho(
		"Beacon", base.beaconID,
		"placed", defs.TEST_STRUCTURE_NAME,
		newCount .. "/" .. defs.TEST_STRUCTURE_COUNT,
		"unit", unitID,
		string.format("at %.0f, %.0f (distance %.0f, terrain delta %.1f);", site.x, site.z, site.distance, site.terrainDelta),
		FormatPlacementStats(stats)
	)
end

local function UpdatePrototypePlacements(frame)
	for _, base in pairs(bases) do
		AttemptPrototypePlacement(base, frame)
	end
end

function gadget:Initialize()
	GG.BotBuddy = {
		revision = defs.REVISION,
		mode = mode,
		controllers = controllers,
		bases = bases,
		structureToBase = structureToBase,
		GetController = function(teamID)
			return controllers[teamID]
		end,
		GetBase = function(beaconID)
			return bases[beaconID]
		end,
	}

	if not BEACON_ID then
		Echo("[MCL Bot Buddy r4] ERROR: UnitDefNames.beacon was not found; Bot Buddy core cannot track bases.")
		return
	end
	if not TEST_STRUCTURE_ID then
		Echo("[MCL Bot Buddy r4] ERROR: UnitDefNames." .. tostring(defs.TEST_STRUCTURE_NAME) .. " was not found; placement prototype disabled.")
	end

	DebugEcho("Initialized in mode", mode, "using delayed three-structure desired-state prototype", defs.TEST_STRUCTURE_NAME)

	if GetGameFrame() > 0 and mode ~= "off" then
		DiscoverControllers()
		ScanExistingBeacons()
		CheckPlayerEliminations()
	end
end

function gadget:GameStart()
	if mode == "off" or not BEACON_ID then
		if mode == "off" then
			DebugEcho("Bot Buddies disabled by modoption")
		end
		return
	end

	DiscoverControllers()
	ScanExistingBeacons()
end

function gadget:GameFrame(frame)
	if mode == "off" then
		return
	end
	if frame % defs.ELIMINATION_CHECK_FRAMES == 0 then
		CheckPlayerEliminations()
	end
	if TEST_STRUCTURE_ID and frame % defs.PLACEMENT.PLACEMENT_UPDATE_FRAMES == 0 then
		UpdatePrototypePlacements(frame)
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if mode == "off" or unitDefID ~= BEACON_ID or unitTeam == GAIA_TEAM_ID then
		return
	end
	RegisterOwnedBeacon(unitID, unitTeam, "(UnitCreated)")
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if mode == "off" or unitDefID ~= BEACON_ID then
		return
	end
	HandleBeaconOwnershipChange(unitID, newTeam, oldTeam)
end

function gadget:UnitDestroyed(unitID, unitDefID)
	if unitDefID == BEACON_ID then
		RemoveBase(unitID, "(Beacon destroyed)")
		return
	end

	local beaconID = structureToBase[unitID]
	if beaconID then
		local base = bases[beaconID]
		ForgetStructure(base, unitID)
		if base and base.controllerTeamID and base.ownerTeamID ~= GAIA_TEAM_ID then
			local frame = GetGameFrame()
			base.reconstructionReadyFrame = frame + defs.RECONSTRUCTION.DELAY_FRAMES
			base.nextPlacementFrame = base.reconstructionReadyFrame
			local remaining = CountPrototypeStructures(base)
			DebugEcho(
				"Prototype structure", unitID, "destroyed for Beacon", beaconID .. ";",
				remaining .. "/" .. defs.TEST_STRUCTURE_COUNT, "remain; reconstruction quiet-period reset to",
				string.format("%.1f seconds", defs.RECONSTRUCTION.DELAY_FRAMES / 30)
			)
		end
	end
end

function gadget:Shutdown()
	if GG.BotBuddy and GG.BotBuddy.revision == defs.REVISION then
		GG.BotBuddy = nil
	end
end
