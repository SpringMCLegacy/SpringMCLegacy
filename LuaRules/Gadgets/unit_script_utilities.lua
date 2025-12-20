function gadget:GetInfo()
	return {
		name = "LUS - Utilities",
		desc = "Handy functions for LUS scripts",
		author = "FLOZi (C. Lawrence)",
		date = "13/10/2025", -- split from lus_helper
		license = "GNU GPL v2",
		layer = 2,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations
local modOptions = Spring.GetModOptions()
GG.modOptions = modOptions -- used for speed mods in mechs

sqrt = math.sqrt

-- Synced Read
local GetUnitPieceInfo 		= Spring.GetUnitPieceInfo
local GetUnitPieceMap		= Spring.GetUnitPieceMap
local GetUnitPiecePosDir	= Spring.GetUnitPiecePosDir
local GetUnitPosition		= Spring.GetUnitPosition
-- Synced Ctrl
local SpawnCEG				= Spring.SpawnCEG
-- LUS
local CallAsUnit 			= Spring.UnitScript.CallAsUnit	

-- Unsynced Ctrl
-- Constants
-- Variables

-- Useful functions for GG

function RemoveGrassSquare(x, z, r)
	local startX = math.floor(x - r/2)
	local startZ = math.floor(z - r/2)
	for i = 0, r, Game.squareSize * 4 do
		for j = 0, r, Game.squareSize * 4 do
			--Spring.Echo(startX + i, startZ + j)
			Spring.RemoveGrass((startX + i)/Game.squareSize, (startZ + j)/Game.squareSize)
		end
	end
end
GG.RemoveGrassSquare = RemoveGrassSquare

function RemoveGrassCircle(cx, cz, r)
	local r2 = r * r
	local step = Game.squareSize * 4
	for z = 0, 2 * r, step do -- top to bottom diameter
		local lineLength = sqrt(r2 - (r - z) ^ 2)
		for x = -lineLength, lineLength, step do
			Spring.RemoveGrass((cx + x)/step, (cz + z - r)/step)
		end
	end
end
GG.RemoveGrassCircle = RemoveGrassCircle

function EmitSfxName(unitID, pieceName, effectName)
	if not pieceName then Spring.Echo("Bug report unit_script_utilities L63", UnitDefs[Spring.GetUnitDefID(unitID)].name) return end
	local x,y,z,dx,dy,dz = GetUnitPiecePosDir(unitID, pieceName)
	SpawnCEG(effectName, x,y,z, dx, dy, dz)
end
GG.EmitSfxName = EmitSfxName

local function RecursiveHide(unitID, pieceNum, hide)
	if not pieceNum then return end
	-- Hide this piece
	local func = (hide and Spring.UnitScript.Hide) or Spring.UnitScript.Show
	CallAsUnit(unitID, func, pieceNum)
	-- Recursively hide children
	local pieceMap = GetUnitPieceMap(unitID)
	local children = GetUnitPieceInfo(unitID, pieceNum).children
	if children then
		for _, pieceName in pairs(children) do
			--Spring.Echo("pieceName:", pieceName, pieceMap[pieceName])
			RecursiveHide(unitID, pieceMap[pieceName], hide)
		end
	end
end
GG.RecursiveHide = RecursiveHide

local function GetUnitDistanceToPoint(unitID, tx, ty, tz, bool3D)
	if not (tx and tz) then return 0 end
	local x,y,z = GetUnitPosition(unitID)
	local dy = (bool3D and ty and (ty - y)^2) or 0
	local distanceSquared = (tx - x)^2 + (tz - z)^2 + dy
	return sqrt(distanceSquared)
end
GG.GetUnitDistanceToPoint = GetUnitDistanceToPoint


function SpawnDecal(decalName, x, z, size, angle, delay, duration)
	if delay then
		GG.Delay.DelayCall(SpawnDecal, {decalName, x, z, size, angle, duration}, delay)
	else
		SendToUnsynced("SPAWNDECAL", decalName, x, z, size, angle, duration)
	end
end
GG.SpawnDecal = SpawnDecal

function KillDecals(killCode)
	SendToUnsynced("KILLDECAL", killCode)
end
GG.KillDecals = KillDecals

else
-- UNSYNCED

local decalDefs = {
	decal_beacon = {
		alias 	= 1,
		size 	= 64, 
		vary 	= {
			tintMax		= 85,
			tintMin		= 15,
			sizeMax		= 115,
			sizeMin		= 85,
			angleMax	= 360,
		},
	},
	-- decal_beacon_normal
	decal_drop = {
		alias	= 3,
		size 	= 256,
		vary 	= {
			tintMax		= 65,
			tintMin		= 45,
			sizeMax		= 120,
			sizeMin		= 95,
			angleMax	= 360,
		},
		duration	= {
			fadeIn		= 1.5,
			stable		= 3,
			fadeOut		= 120,
		},
	},
	decal_beacon_zone = {
		alias	= 4,
		alpha	= 0.2,
	},
	decal_foot = {
		alias 	= 5,
		size 	= 85, 
		vary 	= {
			tintMax		= 80,
			tintMin		= 20,
		},
		duration	= {
			fadeIn		= 0.5,
			stable		= 30,
			fadeOut		= 240,
		},
	},
	-- decal_foot_normal
	decal_outpost = {
		alias 	= 7,
		size 	= 80, 
		alpha 	= 0.2,
		vary 	= {
			tintMax		= 55,
			tintMin		= 45,
			sizeMax		= 110,
			sizeMin		= 90,
		},
		duration	= {
			fadeIn		= 0.8,
			stable		= 10,
			fadeOut		= 60,
		},
	},
	-- decal_outpost_normal
	decal_start = {
		alias = 11,
		size = 200,
	}
}

local killCodes = {} -- killCode = {decalID1, ...}

local function SpawnDecal(eventID, decalName, x, z, decalSize, angle, killCode)
	--Spring.Echo("UNSYNCED SpawnDecal", eventID, decalName, x, z, decalSize)
	local decalID = Spring.CreateGroundDecal()
	killCode = killCode or decalName
	killCodes[killCode] = killCodes[killCode] or {} 
	table.insert(killCodes[killCode], decalID)
	
	if decalID then
		local decalInfo = decalDefs[decalName]
		decalSize = decalSize or decalInfo.size
		-- Initialize textures
		Spring.SetGroundDecalTexture(decalID, "maindecal_" .. decalInfo.alias, true)
		Spring.SetGroundDecalTexture(decalID, "normdecal_" .. decalInfo.alias, false)
		Spring.SetGroundDecalPosAndDims(decalID, x, z, decalSize, decalSize)
		if decalInfo.alpha then
			Spring.SetGroundDecalAlpha(decalID, decalInfo.alpha, 0.0)
		end
		if angle then
			Spring.SetGroundDecalRotation(decalID, angle)
		end
		local variation = decalInfo.vary
		if variation then
			-- Variation
			local varySize = (variation.sizeMin or variation.sizeMax) and math.floor(decalSize * math.random(variation.sizeMin or 0, variation.sizeMax or 100)/100)
			if varySize then
				Spring.SetGroundDecalPosAndDims(decalID, x, z, varySize, varySize)
			end
			local varyAngle = (variation.angleMin or variation.angleMax) and math.rad(math.random(variation.angleMin or 0, variation.angleMax or 360))
			if varyAngle then
				Spring.SetGroundDecalRotation(decalID, varyAngle)
			end
			local varyTint = (variation.tintMin or variation.tintMax) and math.random(variation.tintMin or 0, variation.tintMax or 100)/100
			if varyTint then
				Spring.SetGroundDecalTint(decalID, varyTint, varyTint, varyTint, varyTint)
			end
		end
		local duration = decalInfo.duration
		if duration then
			-- fade in
			if duration.fadeIn then
				Spring.SetGroundDecalAlpha(decalID, 0, -1/duration.fadeIn)
				GG.Delay.DelayCall(Spring.SetGroundDecalAlpha, {decalID, 1, 0}, math.floor(duration.fadeIn*30))
			else
				Spring.SetGroundDecalAlpha(decalID, 1, 0)
			end
			-- schedule a fade out
			GG.Delay.DelayCall(Spring.SetGroundDecalAlpha, {decalID, 1, 1/duration.fadeOut}, ((duration.fadeIn or 0) + duration.stable)*30)
			--GG.Delay.DelayCall(Spring.Echo, {"SetGroundDecalAlpha"}, ((duration.fadeIn or 0) + duration.stable)*30)
			GG.Delay.DelayCall(Spring.DestroyGroundDecal, {decalID}, ((duration.fadeIn or 0) + duration.stable + duration.fadeOut)*30)
			--GG.Delay.DelayCall(Spring.Echo,  {"DestroyGroundDecal"}, ((duration.fadeIn or 0) + duration.stable + duration.fadeOut)*30)
		end
	end
end

local function KillDecals(eventID, killCode)
	local toKill = killCode and killCodes[killCode]
	if toKill then
		for i, decalID in pairs(toKill) do
			Spring.DestroyGroundDecal(decalID)
		end
		killCodes[killCode] = nil
	else
		Spring.Echo("[unit_script_utilities] L244 invalid killCode")
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("SPAWNDECAL", SpawnDecal)
	gadgetHandler:AddSyncAction("KILLDECAL", KillDecals)
end

end