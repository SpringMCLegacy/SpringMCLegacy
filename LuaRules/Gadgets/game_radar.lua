function gadget:GetInfo()
	return {
		name = "Game - Radar",
		desc = "Controls unit sensors including LOS sectors, radar and jammers",
		author = "FLOZi (C. Lawrence)",
		date = "02/02/2011",
		license = "GNU GPL v2",
		layer = 3, -- must be after lus_helper
		enabled = true,
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations
local modOptions = Spring.GetModOptions()

local DelayCall = GG.Delay.DelayCall
local SetUnitRulesParam	= Spring.SetUnitRulesParam
-- Synced Read
local GetGameFrame 						= Spring.GetGameFrame
local GetTeamInfo						= Spring.GetTeamInfo
local GetTeamList						= Spring.GetTeamList
local GetUnitAllyTeam					= Spring.GetUnitAllyTeam
local GetUnitIsActive 					= Spring.GetUnitIsActive
local GetUnitIsDead 					= Spring.GetUnitIsDead
local GetUnitLosState					= Spring.GetUnitLosState
local GetUnitPiecePosDir 				= Spring.GetUnitPiecePosDir
local GetUnitPosition					= Spring.GetUnitPosition
local GetUnitRulesParam					= Spring.GetUnitRulesParam
local GetUnitTransporter				= Spring.GetUnitTransporter
local GetUnitsInCylinder				= Spring.GetUnitsInCylinder
local TraceRayGroundBetweenPositions	= Spring.TraceRayGroundBetweenPositions
local ValidUnitID						= Spring.ValidUnitID
-- Synced Ctrl
local EditUnitCmdDesc					= Spring.EditUnitCmdDesc
local FindUnitCmdDesc 					= Spring.FindUnitCmdDesc
local SetUnitLosMask 					= Spring.SetUnitLosMask
local SetUnitLosState 					= Spring.SetUnitLosState
local SetUnitRulesParam					= Spring.SetUnitRulesParam
local SetUnitSensorRadius				= Spring.SetUnitSensorRadius
local SetUnitStealth 					= Spring.SetUnitStealth
local SpawnCEG 							= Spring.SpawnCEG
-- Unsynced Ctrl
-- Constants

local FRAME_FUDGE = 16
local SECTOR_RADIUS = tonumber(modOptions and modOptions.sectorrange or 1000)

local mobileUnitDefs = {}
local mobileUnits = {}
local visionCache = {} -- visionCache[unitDefID] = {x = sectorVectorX, z = sectorVectorZ, sight = lastWeaponNum}
GG.visionCache = visionCache
for unitDefID, unitDef in pairs(UnitDefs) do
	local cp = unitDef.customParams
	if cp.sectorangle then
		local angle = tonumber(cp.sectorangle) -- defaults in unitdefs_post
		local s1x, s1z = GG.Vector.SectorVectorsFromAngle(math.rad(angle), unitDef.losRadius)
		visionCache[unitDefID] = {
			x = s1x,
			z = s1z,
			sight = #unitDef.weapons, -- always make the sight weapon the last one
			losHeight = unitDef.losHeight,
			radarHeight = unitDef.radarHeight,
		}
		mobileUnitDefs[unitDefID] = true
	elseif cp.baseclass == "vehicle" then
		mobileUnitDefs[unitDefID] = true
	elseif unitDef.name == "noise" then
		mobileUnitDefs[unitDefID] = true
	end
end

-- Variables
local inRadarUnits = {}
local outRadarUnits = {}
local inAutoLos = {}

local unitSectorRadii = {} -- unitSectorRadii[unitID] = length
GG.unitSectorRadii = unitSectorRadii
local allyJammers = {} -- allyJammers[allyTeam][unitID] = radius
GG.allyJammers = allyJammers
local allyBAPs = {} -- allyBAPs[allyTeam][unitID] = radius
GG.allyBAPs = allyBAPs
local jammerCache = {} -- unitID = true
GG.jammerCache = jammerCache
local angels = {} -- angels[unitID] = true
GG.angels = angels
local bloodHounds ={}
GG.bloodHounds = bloodHounds

local allyTeams = Spring.GetAllyTeamList()
local numAllyTeams = #allyTeams
local teamsInAllyTeams = {}
local livingTeams = GetTeamList()
local deadTeams = {}
local allyTeamMechs = {}

local sectorUnits = {}
local prevSectorUnits = {}
for i = 1, numAllyTeams do
	local allyTeam = allyTeams[i]
	inAutoLos[allyTeam] = {}
	inRadarUnits[allyTeam] = {}
	outRadarUnits[allyTeam] = {}
	allyJammers[allyTeam] = {}
	allyBAPs[allyTeam] = {}
	teamsInAllyTeams[allyTeam] = GetTeamList(allyTeam)
	sectorUnits[allyTeam] = {}
	prevSectorUnits[allyTeam] = {}
	allyTeamMechs[allyTeam] = {}
end

local narcUnits = {}
local bapUnits = {} -- bapUnits[unitID] = {gameframe, allyTeam}
local ecmUnits = {} -- ecmUnits[unitID] = {gameframe, allyTeam}
local eccmUnits = {} -- eccmUnits[unitID] = {gameframe, allyTeam}

-- cache los tables (table creation is expensive!)
local prevLosTrue = {prevLos = true, contRadar=true}
local prevLosOnly = {los = false, prevLos = true, radar = false, contRadar = true}
local losTrue = {los = true}
local losFalseRestTrue = {los = false, prevLos = true, radar = true, contRadar = true}
local fullLOS = {los = true, prevLos = true, radar = true, contRadar = true}
local engineControl = {los = false, prevLos = true, radar = false, contRadar = true}

local function GetUnitUnderJammer(unitID)
	return (GetUnitRulesParam(unitID, "FRIENDLY_ECM") or 0) + FRAME_FUDGE >= GetGameFrame() 
end
GG.GetUnitUnderJammer = GetUnitUnderJammer

local function GetUnitUnderECCM(unitID)
	return (GetUnitRulesParam(unitID, "ENEMY_ECM") or 0) + FRAME_FUDGE >= GetGameFrame() 
end
GG.GetUnitUnderECCM = GetUnitUnderECCM

-- helper functions for LUS
local function SetUnitSectorRadius(unitID, mult)
	unitSectorRadii[unitID] = unitSectorRadii[unitID] * mult
	SetUnitRulesParam(unitID, "sectorradius", unitSectorRadii[unitID])
end
GG.SetUnitSectorRadius = SetUnitSectorRadius

local function SetUnitECMRadius(unitID, mult, absolute, pieceNum)
	local allyTeam = GetUnitAllyTeam(unitID)
	local newValue = absolute or ((allyJammers[allyTeam][unitID] or 500) * (mult or 1))
	allyJammers[allyTeam][unitID] = newValue
	jammerCache[unitID] = true
	SetUnitSensorRadius(unitID, "radarJammer", newValue)
	--GG.ECMBubble(unitID, pieceNum or 1, newValue) -- TODO: disabled as luarules lups does not follow unit visibility
	SetUnitRulesParam(unitID, "FXOFF", 0, {public = true})
end
GG.SetUnitECMRadius = SetUnitECMRadius

local function ResetLosStates(unitID, allyTeam) -- TODO:need to check los/radar status properly here rather than hard reset
	-- don't reset for turrets or outposts etc, they remain always visible once detected by whatever means
	if ValidUnitID(unitID) and not GetUnitIsDead(unitID) and mobileUnits[unitID] then
		--Spring.Echo("Reset los states for", unitID, UnitDefs[Spring.GetUnitDefID(unitID)].name)
		SetUnitLosMask(unitID, allyTeam, engineControl)
		SetUnitLosState(unitID, allyTeam, prevLosTrue)
	end
end	

local function NARC(unitID, allyTeam, duration)
	local narcFrame = GetGameFrame() + duration
	narcUnits[unitID] = {frame = narcFrame, allyTeam = allyTeam}
	SetUnitLosState(unitID, allyTeam, {los=true, prevLos=true, radar=true, contRadar=true} ) 
	SetUnitLosMask(unitID, allyTeam, {los=true, prevLos=false, radar=false, contRadar=false} )	
	-- Set rules param here so that widgets know the unit is NARCed, value points to the frame NARC runs out
	SetUnitRulesParam(unitID, "NARC", narcFrame, {inlos = true})
end
GG.NARC = NARC

local function DeNARC(unitID, allyTeam, force)
	if not GetUnitIsDead(unitID) and narcUnits[unitID] and (narcUnits[unitID].frame <= GetGameFrame() + 1 or force) then
		narcUnits[unitID] = nil
		-- unset rules param
		SetUnitRulesParam(unitID, "NARC", -1, {inlos = true})
		ResetLosStates(unitID, allyTeam)
	end
end
GG.DeNARC = DeNARC

local hasStealthMod = {} -- unitID = true
GG.stealthActive = {} -- unitID = true

local function EnableStealth(unitID, tOrF)
	EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD.ONOFF), { params = tOrF and GG.stealthParams or GG.onOffCmdDesc.params})
	hasStealthMod[unitID] = tOrF
end
GG.EnableStealth = EnableStealth

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if GG.mechCache[unitDefID] and cmdID == CMD.ONOFF then
		if GetUnitRulesParam(unitID, "shutdown") == 1 then return false end
		if cmdParams[1] == 2 then
			--Spring.Echo("Engage stealth armour!")
			SetUnitSensorRadius(unitID, "radarJammer", 10)
			SetUnitRulesParam(unitID, "FXOFF", 1)
			SetUnitStealth(unitID, true)
			GG.stealthActive[unitID] = true
		else
			SetUnitSensorRadius(unitID, "radarJammer", UnitDefs[unitDefID].jammerRadius) -- TODO: respect mods
			SetUnitStealth(unitID, false)
			GG.stealthActive[unitID] = false
			SetUnitRulesParam(unitID, "FXOFF", 0)
		end
		GG.onOffCmdDesc.params[1] = cmdParams[1]
		GG.stealthParams[1] = cmdParams[1]
		local newParams = hasStealthMod[unitID] and GG.stealthParams or GG.onOffCmdDesc.params
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD.ONOFF), { params = newParams})
	end
	-- everything else
	return true
end

local warnings = {
	[UnitDefNames["outpost_launcher"].id] = "bb_enemy_launcher_detected",
	[UnitDefNames["outpost_artillery"].id] = "bb_enemy_artillery_detected",
	[UnitDefNames["outpost_uplink"].id] = "bb_enemy_uplink_detected",
}

function gadget:UnitEnteredRadar(unitID, unitTeam, allyTeam, unitDefID)
	--Spring.Echo("UERadar:", unitID, unitTeam, UnitDefs[unitDefID].name)
	if not mobileUnitDefs[unitDefID] then
		-- statics are perma-visible
		if GG.outpostDefs[unitDefID] then
			Script.LuaRules.OutpostVisible(unitID, unitDefID, unitTeam, allyTeam)
		end
		DelayCall(SetUnitLosState, {unitID, allyTeam, fullLOS}, 1)
		DelayCall(SetUnitLosMask, {unitID, allyTeam, fullLOS}, 1) -- don't let engine update any los status
		local warning = warnings[unitDefID]
		if warning then
			local x,y,z = GetUnitPosition(unitID)
			for i, teamID in pairs(GetTeamList(allyTeam)) do
				GG.PlaySoundForTeam(teamID, warning, 1)
				SendToUnsynced("MESSAGE", teamID, x,y,z)
			end
		end
	end
end


function gadget:UnitEnteredLos(unitID, unitTeam, allyTeam, unitDefID)
	--Spring.Echo("UELOS:", unitID, unitTeam, UnitDefs[unitDefID].name)
	if mobileUnitDefs[unitDefID] and not sectorUnits[allyTeam][unitID] then
		inAutoLos[allyTeam][unitID] = true
	end
end

function gadget:UnitLeftLos(unitID, unitTeam, allyTeam, unitDefID)
	--Spring.Echo("ULLOS:", unitID, unitTeam, UnitDefs[unitDefID].name)
	if mobileUnitDefs[unitDefID] then
		inAutoLos[allyTeam][unitID] = nil
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local ud = UnitDefs[unitDefID]
	local jamRadius = ud.jammerRadius
	if jamRadius > 0 then
		local allyTeam = select(6, GetTeamInfo(teamID))
		SetUnitECMRadius(unitID, nil, jamRadius)
	end
	if ud.customParams.bap then
		local allyTeam = select(6, GetTeamInfo(teamID))
		allyBAPs[allyTeam][unitID] = Spring.GetUnitSensorRadius(unitID, "radar") -- can be perked! TODO: update this via perk side too
	end
	if mobileUnitDefs[unitDefID] then
		mobileUnits[unitID] = true
	end
	if visionCache[unitDefID] then -- a mech or hturret... something with a sector!
		if not visionCache[unitDefID].cockpit then 
			visionCache[unitDefID].cockpit = GG.lusHelper[unitDefID].cockpit
			local losHeight = visionCache[unitDefID].losHeight
			local pieceMap = Spring.GetUnitPieceMap(unitID)
			local px, py, pz = Spring.GetUnitPiecePosition(unitID, pieceMap.cockpit)
			local mx, my, mz = Spring.GetUnitPiecePosition(unitID, pieceMap.torso)
			local pCent = (py-my-losHeight)/losHeight * 100
			if pCent > 5 then
				Spring.Echo("[game_radar.lua]", ud.name, "Unit losHeight is", losHeight, "but cockpit is at", py-my, "% error is ", pCent)
			end
		end
		unitSectorRadii[unitID] = SECTOR_RADIUS
		allyTeamMechs[GetUnitAllyTeam(unitID)][unitID] = visionCache[unitDefID]
	end
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		SetUnitLosMask(unitID, allyTeam, prevLosTrue)
		SetUnitLosState(unitID, allyTeam, prevLosTrue)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		ResetLosStates(unitID, allyTeam) -- as called via UnitGiven too
		allyJammers[allyTeam][unitID] = nil
	end
	mobileUnits[unitID] = nil
	narcUnits[unitID] = nil
	bapUnits[unitID] = nil
	ecmUnits[unitID] = nil
	jammerCache[unitID] = nil
	angels[unitID] = nil
	bloodHounds[unitID] = nil
	allyTeamMechs[GetUnitAllyTeam(unitID)][unitID] = nil
	SetUnitRulesParam(unitID, "FRIENDLY_ECM", 0)
	SetUnitRulesParam(unitID, "ENEMY_ECM", 0)
	-- armour
	GG.stealthActive[unitID] = nil
	unitSectorRadii[unitID] = nil
	hasStealthMod[unitID] = nil
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	gadget:UnitDestroyed(unitID, unitDefID, oldTeam)
	gadget:UnitCreated(unitID, unitDefID, newTeam)
end

function gadget:GameFrame(n)
	-- reset any BAP'd units before re-checking los & radar states
	for bapped, data in pairs(bapUnits) do
		if data[1] < n - FRAME_FUDGE then
			if ValidUnitID(bapped) and not GetUnitIsDead(bapped) then
				ResetLosStates(bapped, data[2]) -- unit is no longer under BAP, need to reset to use rest of checks
			end
			bapUnits[bapped] = nil
		end
	end
	-- reset friendly ECM lists
	for ecmed, data in pairs(ecmUnits) do
		if data[1] < n - FRAME_FUDGE then
			ecmUnits[ecmed] = nil
		end
	end
	-- reset enemy ECCM lists
	for eccmed, data in pairs(eccmUnits) do
		if data[1] < n - FRAME_FUDGE then
			eccmUnits[eccmed] = nil
		end
	end	
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		-- Firstly all sector mechs
		for unitID, info in pairs(allyTeamMechs[allyTeam]) do
			if not inAutoLos[allyTeam][unitID] and ValidUnitID(unitID) and not GetUnitIsDead(unitID) and not GetUnitTransporter(unitID) then
				local x, _, z = GetUnitPosition(unitID)
				local inRadius = GetUnitsInCylinder(x, z, unitSectorRadii[unitID]) -- use current sensor radius here as perks can change it
				if not info.cockpit then Spring.Echo("Oh shit, ", UnitDefs[Spring.GetUnitDefID(unitID)].name, "seems to have no cockpit") else
					local v1x, v1z, v2x, v2z = GG.Vector.SectorVectorsFromUnitPiece(unitID, info.cockpit, info.x, info.z)
					for _, enemyID in pairs(inRadius) do -- may not actually be enemy? should check allyteam prior to this?
						local unitAllyTeam = GetUnitAllyTeam(enemyID)
						if enemyID ~= unitID and unitAllyTeam ~= allyTeam -- not an allied unit
						and mobileUnits[enemyID] -- is mobile
						and not GetUnitTransporter(enemyID) -- Not current in a dropship
						then
							local _, _, _, ex, ey, ez = GetUnitPosition(enemyID, true) -- midpos
							local inSector = GG.Vector.IsInsideSectorVector(ex, ez, x, z, v1x, v1z, v2x, v2z)
							if inSector then
								--Spring.Echo("inSector yes", enemyID, UnitDefs[Spring.GetUnitDefID(enemyID)].name)
								-- check it is really this unit sector giving them los
								--local rayTrace = GetUnitWeaponHaveFreeLineOfFire(unitID, info.sight, enemyID)
								local sx, sy, sz = GetUnitPiecePosDir(unitID, info.cockpit)
								local rayTraceHitGround = TraceRayGroundBetweenPositions(sx, sy, sz, ex, ey, ez)
								if not rayTraceHitGround then
									SetUnitLosState(enemyID, allyTeam, fullLOS)
									SetUnitLosMask(enemyID, allyTeam, fullLOS)
									sectorUnits[allyTeam][enemyID] = true
									--Spring.Echo("rayTrace yes", enemyID, UnitDefs[Spring.GetUnitDefID(enemyID)].name)
								else
									--Spring.Echo("rayTrace no", enemyID, UnitDefs[Spring.GetUnitDefID(enemyID)].name)
								end
							end
						end
					end
				end
			end
		end
		for enemyID in pairs(prevSectorUnits[allyTeam]) do
			if not sectorUnits[allyTeam][enemyID] then
				-- unit was previously in a sector but is now not inside a sector, reset
				ResetLosStates(enemyID, allyTeam)
			end
		end
		-- Now deal with ECM units
		for unitID, ecmRadius in pairs(allyJammers[allyTeam]) do
			-- only active non-PPC'd units can utilise ECM
			if not GG.ppcUnits[unitID] and GetUnitIsActive(unitID) and not GetUnitTransporter(unitID) then
				for _, teamID in pairs(livingTeams) do 
					if not deadTeams[teamID] then
						local x, _, z = GetUnitPosition(unitID)
						local nearbyUnits = GetUnitsInCylinder(x, z, ecmRadius, teamID)
						--Spring.Echo("Jammer", unitID, "(", UnitDefs[Spring.GetUnitDefID(unitID)].name, ")")
						for _, nearbyID in pairs(nearbyUnits) do
							local unitAllyTeam = GetUnitAllyTeam(nearbyID)
							--Spring.Echo("nearby to", unitID, "(", UnitDefs[Spring.GetUnitDefID(unitID)].name, ")", nearbyID, UnitDefs[Spring.GetUnitDefID(nearbyID)].name)
							if unitAllyTeam == allyTeam then -- is an allied unit, including the ECM source itself
								--Spring.Echo("nearby", UnitDefs[Spring.GetUnitDefID(nearbyID)].name)
								SetUnitRulesParam(nearbyID, "FRIENDLY_ECM", n, {inlos = true})
								ecmUnits[nearbyID] = {n, allyTeam, angels[unitID]}
							else -- under enemy ECCM
								--Spring.Echo("Duncan 'am BLIND!", UnitDefs[Spring.GetUnitDefID(nearbyID)].name)
								SetUnitRulesParam(nearbyID, "ENEMY_ECM", n, {inlos = true})
								eccmUnits[nearbyID] = {n, allyTeam}--, angels[unitID]}
							end
						end
					end
				end
			end
		end
		-- Then BAP units
		for unitID, bapRadius in pairs(allyBAPs[allyTeam]) do
			-- only active units can utilise BAP
			if GetUnitIsActive(unitID) and not GetUnitTransporter(unitID) then
				local x, _, z = GetUnitPosition(unitID)
				local nearbyUnits = GetUnitsInCylinder(x, z, bapRadius)
				for _, enemyID in pairs(nearbyUnits) do
					local unitAllyTeam = GetUnitAllyTeam(enemyID)
					if enemyID ~= unitID and unitAllyTeam ~= allyTeam -- not an allied unit
					and not sectorUnits[allyTeam][enemyID] then -- not already visible in sector
						local ecmInfo = ecmUnits[enemyID]
					
						if allyJammers[unitAllyTeam][enemyID] and not GG.stealthActive[enemyID] and not angels[enemyID] and not bloodHounds[unitID] then -- it is an enemy ECM emitter
							if n % 30 == 0 then -- every second emit a ping
								local ex, ey, ez = GetUnitPosition(enemyID)
								SpawnCEG("ecm_ping", ex,ey,ez)
							end
						elseif ecmInfo and (not bloodHounds[unitID] or ecmInfo[3]) then -- under enemy ECM (we already checked it is not allied unit)
							-- nothing, should still be invisible to bap
						elseif mobileUnits[enemyID] then
							if not sectorUnits[allyTeam][enemyID] and not GetUnitIsActive(enemyID)
							-- not in a sector, but under BAP radar, only consider radar-off mobile units (Engine handles radar-on)
							or (ecmInfo and not ecmInfo[3] or GG.stealthActive[enemyID]) and bloodHounds[unitID] then
							-- or is visible to bloodhound
								bapUnits[enemyID] = {n, allyTeam}
								SetUnitLosState(enemyID, allyTeam, losFalseRestTrue) 
								SetUnitLosMask(enemyID, allyTeam, losFalseRestTrue)	-- let lua handle radar state for this unit
							end
						end
					end
				end
			end
		end
		-- cleanup for next frame
		table.copy(sectorUnits[allyTeam], prevSectorUnits[allyTeam])
		sectorUnits[allyTeam] = {}
	end
	-- really finally, check NARC as it should override anything else
	for unitID, info in pairs(narcUnits) do
		if ValidUnitID(unitID) and not GetUnitIsDead(unitID) then
			SetUnitLosState(unitID, info.allyTeam, fullLOS) 
			SetUnitLosMask(unitID, info.allyTeam, fullLOS)
		end
	end
	if Spring.IsGameOver() then
		gadgetHandler:RemoveGadget()
	end
end

function gadget:TeamDied(teamID)
	deadTeams[teamID] = true
	livingTeams[teamID] = false
end

else
-- UNSYNCED
return false end