-- Direct-control integration revision 2
function widget:GetInfo()
  return {
    name      = "MC:L - Minimum Ranges",
    desc      = "Draws weapon range rings with zoom-scaled labels for attack targeting and direct control",
    author    = "FLOZi (C. Lawrence)",
    date      = "28/07/2013; direct-control/zoom integration 2026",
    license   = "GNU GPL v2",
    layer     = 10000,
    enabled   = true,
  }
end

-- localisations

-- OGL
local glBillboard	 		= gl.Billboard
local glColor 				= gl.Color
local glDrawGroundCircle 	= gl.DrawGroundCircle
local glTranslate			= gl.Translate
-- SyncedRead
local GetUnitPosition 		= Spring.GetUnitPosition
local GetUnitDefID			= Spring.GetUnitDefID
-- UnsyncedRead
local GetActiveCommand		= Spring.GetActiveCommand
local GetSelectedUnits		= Spring.GetSelectedUnits
local GetCameraPosition		= Spring.GetCameraPosition

local sqrt = math.sqrt
local min = math.min
local max = math.max

-- Range labels are world-space billboard text. A fixed world size grows huge on
-- screen as the camera zooms in, so scale the world size with camera distance.
-- This is camera-agnostic: stock cameras and Shooter Control use the same rule.
local RANGE_LABEL_BASE_SIZE = 20
local RANGE_LABEL_REFERENCE_DISTANCE = 1600
local RANGE_LABEL_MIN_SIZE = 3
local RANGE_LABEL_MAX_SIZE = 22

local AttackRed = {1.0, 0.2, 0.2, 0.7}
--local BuildGreen = {0.3, 1.0, 0.3, 0.5} -- doesn't match engine for some reason so make less opaque
local SalvageBlue = {0.77647, 0.88627, 1, 0.5}

local minRanges = {} -- minRange[unitDefID] = {weapName = range, ...}
local maxRanges = {}
local salvageRanges = {} -- salvageRange[unitDefID] = minRange

local maxRangesToDraw = {} -- maxRangesToDraw[unitDefID] = {range = string}
local minRangesToDraw = {} -- minRangesToDraw[unitDefID] = {range = string}

function widget:Initialize()
	-- Change default command menu font
	local currentFont = Spring.GetConfigString("FontFile")
	local currentFontSmall = Spring.GetConfigString("SmallFontFile")
	Spring.SendCommands("font HandelGothic.ttf")
	Spring.SetConfigString("FontFile", currentFont)
	Spring.SetConfigString("SmallFontFile", currentFontSmall)
	-- Cache ranges
	for unitDefID, unitDef in pairs(UnitDefs) do
		local weapons = unitDef.weapons
		local weaponTypes = {}
		local mech = unitDef.customParams.baseclass == "mech"
		for i = 1, #weapons - (mech and 1 or 0) do -- cut off sight weapon for mechs
			local weaponDef = WeaponDefs[weapons[i].weaponDef]
			weaponTypes[weaponDef.name] = weaponDef.range
			local minRange = tonumber(weaponDef.customParams.minrange) or nil
			if minRange then
				if not minRanges[unitDefID] then
					minRanges[unitDefID] = {}
				end
				minRanges[unitDefID][weaponDef.name] = minRange
			end
		end
		maxRanges[unitDefID] = weaponTypes
		local salvageRange = unitDef.customParams.salvagerange or nil
		if salvageRange then
			salvageRanges[unitDefID] = salvageRange
		end
		-- now loop over min and max and build the strings
		maxRangesToDraw[unitDefID] = {}
		minRangesToDraw[unitDefID] = {}
		for name, range in pairs(maxRanges[unitDefID]) do
			if not maxRangesToDraw[unitDefID][range] then
				maxRangesToDraw[unitDefID][range] = "Max Range: " .. (WeaponDefNames[name].customParams.textcolour or "") .. name
			else
				maxRangesToDraw[unitDefID][range] = maxRangesToDraw[unitDefID][range] .. ", " .. WeaponDefNames[name].customParams.textcolour.. name
			end
			local minRangeDef = minRanges[unitDefID]
			local minRange = minRangeDef and minRangeDef[name] or nil
				
			if minRange then
				if not minRangesToDraw[unitDefID][minRange] then
					minRangesToDraw[unitDefID][minRange] = "Min Range: " .. WeaponDefNames[name].customParams.textcolour .. name
				else
					minRangesToDraw[unitDefID][minRange] = minRangesToDraw[unitDefID][minRange] .. ", " .. WeaponDefNames[name].customParams.textcolour .. name
				end				
			end
		end
	end
	-- Setup fonts for drawing
	btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", 24, 2, 30)
end

local function IsDirectControlledUnit(unitID)
	local shooter =
		WG
		and WG.MCLShooterControl

	if
		not shooter
		or not shooter.IsControlledUnit
	then
		return false
	end

	local ok, result =
		pcall(
			shooter.IsControlledUnit,
			unitID
		)

	return
		ok
		and result == true
end

local function ShouldDrawWeaponRanges(unitID)
	if
		select(
			2,
			GetActiveCommand()
		) == CMD.ATTACK
	then
		return true
	end

	return
		IsDirectControlledUnit(
			unitID
		)
end

local function GetRangeLabelSize(x, y, z)
	if not GetCameraPosition then
		return RANGE_LABEL_BASE_SIZE
	end

	local cx, cy, cz =
		GetCameraPosition()

	if not cx then
		return RANGE_LABEL_BASE_SIZE
	end

	local dx = x - cx
	local dy = y - cy
	local dz = z - cz

	local distance =
		sqrt(
			dx * dx +
			dy * dy +
			dz * dz
		)

	local size =
		RANGE_LABEL_BASE_SIZE *
		(distance / RANGE_LABEL_REFERENCE_DISTANCE)

	return
		max(
			RANGE_LABEL_MIN_SIZE,
			min(
				RANGE_LABEL_MAX_SIZE,
				size
			)
		)
end

function widget:DrawWorldPreUnit()
	for _,unitID in ipairs(GetSelectedUnits()) do
		local unitDefID = GetUnitDefID(unitID)
		if ShouldDrawWeaponRanges(unitID) then
			glColor(AttackRed)
			local minRangesU = minRangesToDraw[unitDefID]
			local maxRangesU = maxRangesToDraw[unitDefID]
			local x, y, z = GetUnitPosition(unitID)
			local labelSize = GetRangeLabelSize(x, y + 40, z)
			if maxRangesU then
				for radius, info in pairs(maxRangesU) do
					gl.PushMatrix()
						glDrawGroundCircle(x,y,z, radius,24)
						glTranslate(x, y + 40, z + radius + 40)
						glBillboard()
						btFont:Print(info, 0, 0, labelSize, "oc")
					gl.PopMatrix()
				end
			end
			if minRangesU then
				for radius, info in pairs(minRangesU) do
					gl.PushMatrix()
						gl.LineStipple(4, 15)
						glDrawGroundCircle(x,y,z, radius,24)
						glTranslate(x, y + 40, z + radius - 40)
						glBillboard()
						btFont:Print(info, 0, 0, labelSize, "oc")
						gl.LineStipple(false)
					gl.PopMatrix()
				end
			end
		else
			rangesToDraw = salvageRanges[unitDefID]
			if rangesToDraw then
				local x, y, z = GetUnitPosition(unitID)
				glColor(SalvageBlue)
				gl.PushMatrix()
					glDrawGroundCircle(x,y,z, rangesToDraw,24)
				gl.PopMatrix()
			end
		end
		glColor(1,1,1,1)
	end
end