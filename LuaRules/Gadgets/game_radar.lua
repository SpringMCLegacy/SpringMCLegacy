function gadget:GetInfo()
	return {
		name = "Game - Radar",
		desc = "Units in radar range become visible",
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
local DelayCall = GG.Delay.DelayCall
local SetUnitRulesParam	= Spring.SetUnitRulesParam
-- Synced Read
local GetGameFrame 		= Spring.GetGameFrame
local GetTeamInfo		= Spring.GetTeamInfo
local GetUnitIsActive 	= Spring.GetUnitIsActive
local GetUnitIsDead 	= Spring.GetUnitIsDead
local GetUnitLosState	= Spring.GetUnitLosState
local GetUnitRulesParam	= Spring.GetUnitRulesParam
local GetUnitSeparation	= Spring.GetUnitSeparation
local GetUnitTeam		= Spring.GetUnitTeam
-- Synced Ctrl
local SetUnitLosMask 	= Spring.SetUnitLosMask
local SetUnitLosState 	= Spring.SetUnitLosState

-- Unsynced Ctrl
-- Constants

local FRAME_FUDGE = 16
local SECTOR_RADIUS = modOptions and modOptions.sectorrange or 1500
local BEACON_ID = UnitDefNames["beacon"].id
local NARC_ID = WeaponDefNames["narc"].id
local NARC_DURATION = 30 * 30 -- 30 seconds
Spring.SetGameRulesParam("NARC_DURATION", NARC_DURATION)

local TAG_ID = WeaponDefNames["tag"].id
local PPC_IDS = {}
for weaponDefID, weaponDef in pairs(WeaponDefs) do
	if weaponDef.name:find("ppc") then
		PPC_IDS[weaponDefID] = true
	end
end

local mobileUnitDefs = {}
local mobileUnits = {}
local visionCache = {} -- visionCache[unitDefID] = {x = sectorVectorX, z = sectorVectorZ, sight = lastWeaponNum}
for unitDefID, unitDef in pairs(UnitDefs) do
	local cp = unitDef.customParams
	if cp.sectorangle then
		local angle = tonumber(cp.sectorangle) -- defaults in unitdefs_post
		local s1x, s1z = GG.Vector.SectorVectorsFromAngle(math.rad(angle), unitDef.losRadius)
		visionCache[unitDefID] = {
			x = s1x,
			z = s1z,
			sight = #unitDef.weapons, -- always make the sight weapon the last one
		}
		mobileUnitDefs[unitDefID] = true
	elseif cp.baseclass == "vehicle" then
		mobileUnitDefs[unitDefID] = true
	end
end

-- Variables
local modOptions = Spring.GetModOptions()
local inRadarUnits = {}
local outRadarUnits = {}

local inAutoLos = {}
local unitSectorRadii = {} -- unitSectorRadii[unitID] = length
local allyJammers = {} -- allyJammers[allyTeam][unitID] = radius
GG.allyJammers = allyJammers
local allyBAPs = {} -- allyBAPs[allyTeam][unitID] = radius
GG.allyBAPs = allyBAPs

local allyTeams = Spring.GetAllyTeamList()
local numAllyTeams = #allyTeams
local teamsInAllyTeams = {}
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
	teamsInAllyTeams[allyTeam] = Spring.GetTeamList(allyTeam)
	sectorUnits[allyTeam] = {}
	prevSectorUnits[allyTeam] = {}
	allyTeamMechs[allyTeam] = {}
end

local narcUnits = {}

local PPC_DURATION = 5 * 30 -- 5 seconds
local sensorTypes = {"radarJammer"} -- "radar", "seismic", 
local unitSensorRadii = {} -- unitSensorRadii[unitID] = {radar = a, seismic = b ...}
local ppcUnits = {} -- ppcUnits[unitID] = gameframe
local bapUnits = {} -- bapUnits[unitID] = {gameframe, allyTeam}
local ecmUnits = {} -- ecmUnits[unitID] = {gameframe, allyTeam}

-- cache los tables (table creation is expensive!)
local prevLosTrue = {prevLos = true, contRadar=true}
local prevLosOnly = {los = false, prevLos = true, radar = false, contRadar = true}
local losTrue = {los = true}
local losFalseRestTrue = {los = false, prevLos = true, radar = true, contRadar = true}
local fullLOS = {los = true, prevLos = true, radar = true, contRadar = true}
local engineControl = {los = false, prevLos = true, radar = false, contRadar = true}


local function FinishPPC(unitID)
	if ppcUnits[unitID] and ppcUnits[unitID] <= Spring.GetGameFrame() then
		for _, sensorType in pairs(sensorTypes) do
			Spring.SetUnitSensorRadius(unitID, sensorType, unitSensorRadii[unitID][sensorType])
		end
		ppcUnits[unitID] = nil
		SetUnitRulesParam(unitID, "PPC_HIT", -1, {inlos = true})
	end
end

local function ApplyPPC(unitID)
	if not ppcUnits[unitID] then -- not yet under PPC effects
		unitSensorRadii[unitID] = {}
		for _, sensorType in pairs(sensorTypes) do
			-- perks change radii so can't rely on unitdef values
			unitSensorRadii[unitID][sensorType] = Spring.GetUnitSensorRadius(unitID, sensorType)
			Spring.SetUnitSensorRadius(unitID, sensorType, 0) -- ECM disabled altogether
		end
	end
	local delay = (GetUnitRulesParam(unitID, "insulation") or 1) * PPC_DURATION
	ppcUnits[unitID] = Spring.GetGameFrame() + delay
	SetUnitRulesParam(unitID, "PPC_HIT", ppcUnits[unitID], {inlos = true})
	GG.Delay.DelayCall(FinishPPC, {unitID}, delay)
end

local function GetUnitUnderJammer(unitID)
	return (GetUnitRulesParam(unitID, "FRIENDLY_ECM") or 0) + FRAME_FUDGE >= GetGameFrame() 
end
GG.GetUnitUnderJammer = GetUnitUnderJammer

-- helper functions for LUS
local function IsUnitNARCed(unitID)
	return (GetUnitRulesParam(unitID, "NARC") or 0) > 0
end
GG.IsUnitNARCed = IsUnitNARCed

local function IsUnitTAGed(unitID)
	return (GetUnitRulesParam(unitID, "TAG") or 0) + FRAME_FUDGE >= GetGameFrame()
end
GG.IsUnitTAGed = IsUnitTAGed

local function SetUnitSectorRadius(unitID, mult)
	unitSectorRadii[unitID] = (unitSectorRadii[unitID] or SECTOR_RADIUS) * mult
	SetUnitRulesParam(unitID, "sectorradius", unitSectorRadii[unitID])
end
GG.SetUnitSectorRadius = SetUnitSectorRadius

local function ResetLosStates(unitID, allyTeam) -- TODO:need to check los/radar status properly here rather than hard reset
	-- don't reset for turrets or outposts etc, they remain always visible once detected by whatever means
	if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) and mobileUnits[unitID] then
		--Spring.Echo("Reset los states for", unitID, UnitDefs[Spring.GetUnitDefID(unitID)].name)
		--SetUnitLosState(unitID, allyTeam, {los = Spring.IsUnitInLos(unitID, allyTeam), prevLos = true, radar = Spring.IsUnitInRadar(unitID, allyTeam), contRadar = true}) 
		--SetUnitLosMask(unitID, allyTeam, fullLOS) -- let engine handle los state for this unit	
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

local function DeNARC(unitID, allyTeam, force)
	if not GetUnitIsDead(unitID) and narcUnits[unitID] and (narcUnits[unitID].frame <= GetGameFrame() + 1 or force) then
		narcUnits[unitID] = nil
		-- unset rules param
		SetUnitRulesParam(unitID, "NARC", -1, {inlos = true})
		ResetLosStates(unitID, allyTeam)
	end
end


local unitArmours = {} -- unitID = true
local function EnableArmour(unitID, apply, armourType)
	unitArmours[unitID] = apply and armourType or nil
end
GG.EnableArmour = EnableArmour

local unitSpecialAmmos = {} -- [unitID][weaponType] = ammoName
GG.unitSpecialAmmos = unitSpecialAmmos -- for Thunder spawning
local function EnableAmmo(unitID, apply, weaponType, ammoName, weapNum)
	unitSpecialAmmos[unitID] = unitSpecialAmmos[unitID] or {}
	unitSpecialAmmos[unitID][weaponType] = unitSpecialAmmos[unitID][weaponType] or {}
	unitSpecialAmmos[unitID][weaponType] = apply and ammoName or nil
end
GG.EnableAmmo = EnableAmmo

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
	-- Don't allow any damage to beacons or dropzones
	if unitDefID == BEACON_ID or UnitDefs[unitDefID].name:find("dropzone") or UnitDefs[unitDefID].customParams.decal then return 0 end
	-- ignore none weapons
	if not attackerID then return damage end
	
	-- Armour & Ammo Mods
	local weaponDef = weaponID and WeaponDefs[weaponID]
	local heatDamage = weaponDef and weaponDef.customParams.heatdamage
	local speedChange
	-- Ammos
	local specialAmmos = unitSpecialAmmos[attackerID]
	if specialAmmos then
		local weaponType = weaponDef.customParams.weaponclass
		local specialAmmo = specialAmmos[weaponType]
		if specialAmmo == "inferno" then
			damage = 0
			heatDamage = 2
		elseif specialAmmo == "armourpiercing" and not unitArmours[unitID] == "hard" then
			damage = damage * 1.25
		elseif specialAmmo == "magpulse" then
			damage = 0
			heatDamage = 2.5
			ApplyPPC(unitID)
		elseif specialAmmo == "thunder" then
			damage = damage * 0.75
		elseif specialAmmo == "bola" then
			speedChange = 0.01
		elseif specialAmmo == "explosivepod" then
			damage = 400
		elseif specialAmmo == "tandem" and not unitArmours[unitID] == "hard" then
			damage = damage * 2
		end
	end
	-- Armours
	if heatDamage and not (unitArmours[unitID] == "heat") then
		env = Spring.UnitScript.GetScriptEnv(unitID)
		Spring.UnitScript.CallAsUnit(unitID, env.ChangeHeat, heatDamage)
	end
	if unitArmours[unitID] == "reactive" and weaponDef.weaponType == "MissileLauncher" then
		damage = damage * 0.75
	elseif unitArmours[unitID] == "ferro" then
		damage = damage * 0.88
	elseif unitArmours[unitID] == "hard" then
		damage = damage * 0.75
	elseif unitArmours[unitID] == "reflec" then
		local energy = weaponDef.customParams.weaponclass == "ppc" or weaponDef.customParams.weaponclass == "energy"
		if energy then
			damage = damage * 0.75
		end
	end
	
	-- NARCs
	if weaponID == NARC_ID then
		-- Don't allow dropships to be NARCed
		if UnitDefs[unitDefID].customParams.dropship then return 0 end
		if speedChange then -- Bola Pod
			Spring.Echo("speed change now", Spring.GetGameFrame())
			GG.SpeedChange(unitID, unitDefID, 0.1)
			DelayCall(GG.SpeedChange, {unitID, unitDefID, 1}, 5*30)
			--Spring.MoveCtrl.Enable(unitID)
			--DelayCall(Spring.MoveCtrl.Disable, {unitID}, 5 * 30)
			return 0
		elseif damage == 400 then -- Explosive Pod
			return damage
		else -- regular NARC
			--if GetUnitUnderJammer(unitID, unitTeam) then return 0 end
			local allyTeam = select(6, GetTeamInfo(attackerTeam))
			-- do the NARC, delay the deNARC
			local duration = GetUnitRulesParam(attackerID, "NARC_DURATION") or NARC_DURATION
			NARC(unitID, allyTeam, duration)
			DelayCall(DeNARC, {unitID, allyTeam}, duration)
			-- NARC does 0 damage
			return 0
		end
	elseif weaponID == TAG_ID then
		-- Don't allow dropships to be TAGed
		if not UnitDefs[unitDefID].customParams.dropship then
			SetUnitRulesParam(unitID, "TAG", GetGameFrame(), {inlos = true})
			--Spring.Echo("I AM BEING TAGGED!")
		end
		return 0
	elseif PPC_IDS[weaponID] then
		ApplyPPC(unitID)
	end

	return damage, 1
end

function gadget:UnitEnteredRadar(unitID, unitTeam, allyTeam, unitDefID)
	--Spring.Echo("UERadar:", unitID, unitTeam, UnitDefs[unitDefID].name)
	if mobileUnitDefs[unitDefID] then -- force spring to recognise units spawned inside radar
		--[[for i = 1, numAllyTeams do
			local aTeam = allyTeams[i]
			ResetLosStates(unitID, aTeam)
			SetUnitLosState(unitID, aTeam, {los = Spring.IsUnitInLos(unitID, aTeam), prevLos = true, radar = Spring.IsUnitInRadar(unitID, aTeam), contRadar = true}) 
		end]]
	else
		-- statics are perma-visible
		GG.Delay.DelayCall(SetUnitLosState, {unitID, allyTeam, fullLOS}, 1)
		GG.Delay.DelayCall(SetUnitLosMask, {unitID, allyTeam, fullLOS}, 1) -- don't let engine update any los status
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
		allyJammers[allyTeam][unitID] = jamRadius
	end
	if ud.customParams.bap then
		local allyTeam = select(6, GetTeamInfo(teamID))
		allyBAPs[allyTeam][unitID] = Spring.GetUnitSensorRadius(unitID, "radar") -- can be perked! TODO: update this via perk side too
	end
	if mobileUnitDefs[unitDefID] then
		mobileUnits[unitID] = true
	end
	if visionCache[unitDefID] then -- a mech!
		unitSpecialAmmos[unitID] = {}
		visionCache[unitDefID].cockpit = GG.lusHelper[unitDefID].cockpit
		allyTeamMechs[Spring.GetUnitAllyTeam(unitID)][unitID] = visionCache[unitDefID]
		-- force Spring to recognise units spawned within sectors should be full LOS
		for i = 1, numAllyTeams do
			local allyTeam = allyTeams[i]
			--SetUnitLosMask(unitID, allyTeam, losTrue)
		end
	end
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		SetUnitLosMask(unitID, allyTeam, prevLosTrue)
		SetUnitLosState(unitID, allyTeam, prevLosTrue)
		--ResetLosStates(unitID, allyTeam)
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
	ppcUnits[unitID] = nil
	bapUnits[unitID] = nil
	ecmUnits[unitID] = nil
	allyTeamMechs[Spring.GetUnitAllyTeam(unitID)][unitID] = nil
	SetUnitRulesParam(unitID, "FRIENDLY_ECM", 0)
	-- armour
	unitArmours[unitID] = nil
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	gadget:UnitDestroyed(unitID, unitDefID, oldTeam)
	gadget:UnitCreated(unitID, unitDefID, newTeam)
end

function gadget:GameFrame(n)
	-- reset any BAP'd units before re-checking los & radar states
	for bapped, data in pairs(bapUnits) do
		if data[1] < n - FRAME_FUDGE then
			if Spring.ValidUnitID(bapped) and not Spring.GetUnitIsDead(bapped) then
				ResetLosStates(bapped, data[2]) -- unit is no longer under BAP, need to reset to use rest of checks
			end
			bapUnits[bapped] = nil
		end
	end
	-- TODO: needed?
	for ecmed, data in pairs(ecmUnits) do
		if data[1] < n - FRAME_FUDGE then
			ecmUnits[ecmed] = nil
		end
	end
	
	local GetUnitPosition 	= Spring.GetUnitPosition
	for i = 1, numAllyTeams do
		local allyTeam = allyTeams[i]
		-- Firstly all sector mechs
		for unitID, info in pairs(allyTeamMechs[allyTeam]) do
			if not inAutoLos[allyTeam][unitID] and Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) and not Spring.GetUnitTransporter(unitID) then
				local x, _, z = GetUnitPosition(unitID)
				local inRadius = Spring.GetUnitsInCylinder(x, z, unitSectorRadii[unitID] or SECTOR_RADIUS) -- use current sensor radius here as perks can change it
				if not info.cockpit then Spring.Echo("Oh shit, ", UnitDefs[Spring.GetUnitDefID(unitID)].name, "seems to have no cockpit") else
					local v1x, v1z, v2x, v2z = GG.Vector.SectorVectorsFromUnitPiece(unitID, info.cockpit, info.x, info.z)
					--Spring.MarkerAddPoint(x + v1x, 0, z + v1z, "V1")
					--Spring.MarkerAddPoint(x + v2x, 0, z + v2z, "V2")
					for _, enemyID in pairs(inRadius) do -- may not actually be enemy? should check allyteam prior to this?
						local unitAllyTeam = Spring.GetUnitAllyTeam(enemyID)
						if enemyID ~= unitID and unitAllyTeam ~= allyTeam -- not an allied unit
						and mobileUnits[enemyID] -- is mobile
						and not Spring.GetUnitTransporter(enemyID) -- Not current in a dropship
						then
							local ex, _, ez = GetUnitPosition(enemyID)
							local inSector = GG.Vector.IsInsideSectorVector(ex, ez, x, z, v1x, v1z, v2x, v2z)
							if inSector then
								--Spring.Echo("inSector yes", enemyID, UnitDefs[Spring.GetUnitDefID(enemyID)].name)
								-- check it is really this unit sector giving them los
								local rayTrace = Spring.GetUnitWeaponHaveFreeLineOfFire(unitID, info.sight, enemyID)
								if rayTrace then
									SetUnitLosState(enemyID, allyTeam, fullLOS)
									SetUnitLosMask(enemyID, allyTeam, fullLOS)
									sectorUnits[allyTeam][enemyID] = true
									--Spring.Echo("rayTrace yes", enemyID, UnitDefs[Spring.GetUnitDefID(enemyID)].name)
								else
									--Spring.Echo("rayTrace no", enemyID, UnitDefs[Spring.GetUnitDefID(enemyID)].name)
								end
							elseif not sectorUnits[allyTeam][enemyID] then -- not in another sector FOUND SO FAR?
								--ResetLosStates(enemyID, allyTeam) -- TODO: see if we can't avoid calling this. Probably requires a second loop though.
							else
								-- Not in any sector
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
			if not ppcUnits[unitID] and GetUnitIsActive(unitID) and not Spring.GetUnitTransporter(unitID) then
				for _, teamID in pairs(teamsInAllyTeams[allyTeam]) do
					if not deadTeams[teamID] then
						local x, _, z = GetUnitPosition(unitID)
						local nearbyUnits = Spring.GetUnitsInCylinder(x, z, ecmRadius, teamID)
						--Spring.Echo("Jammer", jammerID, "(", UnitDefs[Spring.GetUnitDefID(jammerID)].name, ")")
						for _, allyID in pairs(nearbyUnits) do
							local unitAllyTeam = Spring.GetUnitAllyTeam(allyID)
							if unitAllyTeam == allyTeam then -- is an allied unit, including the ECM source itself
								--Spring.Echo("nearby", UnitDefs[Spring.GetUnitDefID(nearbyUnits[i])].name)
								SetUnitRulesParam(allyID, "FRIENDLY_ECM", n, {inlos = true})
								ecmUnits[allyID] = {n, allyTeam}
							end
						end
					end
				end
			end
		end
		-- Then BAP units
		for unitID, bapRadius in pairs(allyBAPs[allyTeam]) do
			-- only active units can utilise BAP
			if GetUnitIsActive(unitID) and not Spring.GetUnitTransporter(unitID) then
				local x, _, z = GetUnitPosition(unitID)
				local nearbyUnits = Spring.GetUnitsInCylinder(x, z, bapRadius)
				for _, enemyID in pairs(nearbyUnits) do
					local unitAllyTeam = Spring.GetUnitAllyTeam(enemyID)
					if enemyID ~= unitID and unitAllyTeam ~= allyTeam then-- not an allied unit
					--and not sectorUnits[allyTeam][enemyID] then -- not already visible in sector
						if allyJammers[unitAllyTeam][enemyID] then -- it is an enemy ECM emitter
							if n % 30 == 0 then -- every second emit a ping
								local ex, ey, ez = Spring.GetUnitPosition(enemyID)
								Spring.SpawnCEG("ecm_ping", ex,ey,ez)
							end
						elseif ecmUnits[enemyID] then -- under enemy ECM (we already checked it is not allied unit)
							-- nothing, should still be invisible to bap
						elseif not sectorUnits[allyTeam][enemyID] and mobileUnits[enemyID] and not GetUnitIsActive(enemyID) then 
							-- not in a sector, but under BAP radar, only consider radar-off mobile units (Engine handles radar-on)
							bapUnits[enemyID] = {n, allyTeam}
							SetUnitLosState(enemyID, allyTeam, losFalseRestTrue) 
							SetUnitLosMask(enemyID, allyTeam, losFalseRestTrue)	-- let lua handle radar state for this unit
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
		if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
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
end

else

-- UNSYNCED

end
