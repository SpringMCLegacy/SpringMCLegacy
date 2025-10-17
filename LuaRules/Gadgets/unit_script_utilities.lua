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

function SpawnDecal(decalType, x, y, z, teamID, alwaysVisible, delay, duration)
	if delay then
		GG.Delay.DelayCall(SpawnDecal, {decalType, x, y, z, teamID, nil, duration}, delay)
	else
		local decalID = Spring.CreateUnit(decalType, x, y + 1, z, 0, teamID, false, false)
		if decalID then -- can fail if e.g. team just died
			Spring.SetUnitAlwaysVisible(decalID, alwaysVisible or false)
			Spring.SetUnitNoSelect(decalID, true)
			Spring.SetUnitBlocking(decalID, false, false, false, false, false, false, false)
			if duration then
				GG.Delay.DelayCall(Spring.DestroyUnit, {decalID, false, true}, duration)
			end
		end
	end
end
GG.SpawnDecal = SpawnDecal

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

else
-- UNSYNCED
return false end