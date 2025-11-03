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
	if not pieceName then Spring.Echo("Bug report unit_script_utilities L79", UnitDefs[Spring.GetUnitDefID(unitID)].name) return end
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


function SpawnDecal(decalName, x, z, delay, duration, size)
	if delay then
		GG.Delay.DelayCall(SpawnDecal, {decalName, x, z, nil, duration, size}, delay)
	else
		SendToUnsynced("SPAWNDECAL", decalName, x, z, size, duration)
	end
end
GG.SpawnDecal = SpawnDecal

else
-- UNSYNCED

local decalDefs = {
	decal_beacon = {
		alias 	= 1,
		size 	= 64, 
		vary	= true,
	},
	decal_drop = {
		alias	= 3,
		size 	= 256,
		vary 	= true,
	},
	decal_beacon_zone = {
		alias	= 4,
		vary	= false,
		alpha	= 0.2,
	},
}

local function SpawnDecal(eventID, decalName, x, z, decalSize, duration)
	--Spring.Echo("UNSYNCED SpawnDecal", eventID, decalName, x, z, decalSize, duration)
	local decalID = Spring.CreateGroundDecal()
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
		if decalInfo.vary then
			-- Variation
			decalSize = math.floor(decalSize * math.random(85, 115)/100)
			Spring.SetGroundDecalPosAndDims(decalID, x, z, decalSize, decalSize)
			local angle = math.random() * 2 * math.pi
			Spring.SetGroundDecalRotation(decalID, angle)
			local tintFactor = math.random(15,85)/100
			Spring.SetGroundDecalTint(decalID, tintFactor, tintFactor, tintFactor, tintFactor)
		end
		
		if duration then
			-- fade in
			Spring.SetGroundDecalAlpha(decalID, 0, -1/1.5)
			-- schedule a fade out
			GG.Delay.DelayCall(Spring.SetGroundDecalAlpha, {decalID, 1, 30/duration}, 75 + 90)
			GG.Delay.DelayCall(Spring.DestroyGroundDecal, {decalID}, 75 + 90 + duration)
		end
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("SPAWNDECAL", SpawnDecal)
end

end