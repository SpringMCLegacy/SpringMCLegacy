function widget:GetInfo()
  return {
    name      = "BTL - Minimum Ranges",
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
local glDrawGroundCircle 	= gl.DrawGroundCircle
local glDepthTest 			= gl.DepthTest
local glColor 				= gl.Color
-- SyncedRead
local GetUnitPosition 		= Spring.GetUnitPosition
local GetUnitDefID			= Spring.GetUnitDefID
-- UnsyncedRead
local GetActiveCommand		= Spring.GetActiveCommand
local GetSelectedUnits		= Spring.GetSelectedUnits

local AttackRed = {1.0, 0.2, 0.2, 0.7}

function widget:Initialize()
	btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", 24, 2, 30)
	btFont:SetTextColor(AttackRed)
end

function widget:DrawWorldPreUnit()
	if select(4, GetActiveCommand()) == "Attack" then
		glDepthTest(true)
		glColor(AttackRed)
		for _,unitID in ipairs(GetSelectedUnits()) do
			local unitDef = UnitDefs[GetUnitDefID(unitID)]
			local weapons = unitDef.weapons
			local minRanges = {}
			for i = 1, #weapons do
				local weaponInfo = weapons[i]
				local weaponDef = WeaponDefs[weaponInfo.weaponDef]
				local minRange = tonumber(weaponDef.customParams.minrange) or nil
				if minRange then
					minRanges[weaponDef.name] = minRange
				end
			end
			local x, y, z = GetUnitPosition(unitID)
			for weapName, radius in pairs(minRanges) do
				glDrawGroundCircle(x,y,z, radius,24)
				gl.DrawFuncAtUnit(unitID, false, function()
					gl.Translate(0, 40, radius - 40)
					gl.Billboard()	
					btFont:Print("Min Range: " .. weapName, 0, 0, 24, "c")
				end)
			end
		end
		glDepthTest(false)
		glColor(1,1,1,1)
	end
end