function widget:GetInfo()
  return {
    name      = "MC:L - Minimum Ranges",
    desc      = "Draws minimum range rings",
    author    = "FLOZi (C. Lawrence)",
    date      = "28/07/2013",
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

local AttackRed = {1.0, 0.2, 0.2, 0.7}
local BuildGreen = {0.3, 1.0, 0.3, 0.5} -- doesn't match engine for some reason so make less opaque

local minRanges = {} -- minRange[unitDefID] = {weapName = range, ...}
local maxRanges = {}
local buildRanges = {} -- buildRange[unitDefID] = minRange

local maxRangesToDraw = {} -- maxRangesToDraw[unitDefID] = {range = string}
local minRangesToDraw = {} -- minRangesToDraw[unitDefID] = {range = string}

function widget:Initialize()
	-- Change default command menu font
	local currentFont = Spring.GetConfigString("FontFile")
	local currentFontSmall = Spring.GetConfigString("SmallFontFile")
	Spring.SendCommands("font Handel Gothic.ttf")
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
		local buildRange = unitDef.customParams.minbuildrange or nil
		if buildRange then
			buildRanges[unitDefID] = buildRange
		end
		-- now loop over min and max and build the strings
		maxRangesToDraw[unitDefID] = {}
		minRangesToDraw[unitDefID] = {}
		for name, range in pairs(maxRanges[unitDefID]) do
			if not maxRangesToDraw[unitDefID][range] then
				maxRangesToDraw[unitDefID][range] = "Max Range: " .. WeaponDefNames[name].customParams.textcolour .. name
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

function widget:DrawWorldPreUnit()
	for _,unitID in ipairs(GetSelectedUnits()) do
		local unitDefID = GetUnitDefID(unitID)
		if select(4, GetActiveCommand()) == "Attack" then
			glColor(AttackRed)
			local minRangesU = minRangesToDraw[unitDefID]
			local maxRangesU = maxRangesToDraw[unitDefID]
			local x, y, z = GetUnitPosition(unitID)
			if maxRangesU then
				for radius, info in pairs(maxRangesU) do
					gl.PushMatrix()
						glDrawGroundCircle(x,y,z, radius,24)
						glTranslate(x, y + 40, z + radius + 40)
						glBillboard()
						btFont:Print(info, 0, 0, 24, "oc")
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
						btFont:Print(info, 0, 0, 24, "oc")
						gl.LineStipple(false)
					gl.PopMatrix()
				end
			end
		--[[elseif UnitDefNames[select(4, GetActiveCommand())] then -- command is a valid unitname i.e. build command
			rangesToDraw = buildRanges[unitDefID]
			if rangesToDraw then
				local x, y, z = GetUnitPosition(unitID)
				glColor(BuildGreen)
				gl.PushMatrix()
					glDrawGroundCircle(x,y,z, rangesToDraw,24)
				gl.PopMatrix()
			end--]]
		end
		glColor(1,1,1,1)
	end
end