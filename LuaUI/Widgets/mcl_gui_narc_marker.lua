--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    gui_narc_marker.lua
--  brief:   draws a visible indicator around NARCed units
--  author:  yuritch (but this is just a modified gui_team_platter.lua by Dave Rodgers)
--
--  Copyright (C) 2011.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
 
function widget:GetInfo()
  return {
    name  = "MC:L - NARC indicator",
    desc  = "NARC circles",
    author  = "trepan, zwzsg, smoth, yuritch, FLOZi",
    date  = "Feb 6, 2011",
    license = "GNU GPL, v2 or later",
    layer  = 5,
    enabled  = true --  loaded by default?
  }
end
 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
 
-- Automatically generated local definitions
 
local GL_LINE_LOOP				= GL.LINE_LOOP
local GL_TRIANGLE_FAN			= GL.TRIANGLE_FAN
local glBeginEnd				= gl.BeginEnd
local glBillboard				= gl.Billboard
local glColor					= gl.Color
local glCreateList				= gl.CreateList
local glDeleteList				= gl.DeleteList
local glDepthTest				= gl.DepthTest
local glDrawFuncAtUnit			= gl.DrawFuncAtUnit
local glDrawListAtUnit			= gl.DrawListAtUnit
local glLineWidth				= gl.LineWidth
local glPolygonOffset			= gl.PolygonOffset
local glPopMatrix				= gl.PopMatrix
local glPushMatrix				= gl.PushMatrix
local glVertex					= gl.Vertex
local spDiffTimers				= Spring.DiffTimers
local spGetAllUnits				= Spring.GetAllUnits
local spGetGroundNormal			= Spring.GetGroundNormal
local spGetSelectedUnits		= Spring.GetSelectedUnits
local spGetTimer				= Spring.GetTimer
local spGetUnitBasePosition		= Spring.GetUnitBasePosition
local spGetUnitDefDimensions	= Spring.GetUnitDefDimensions
local spGetUnitDefID			= Spring.GetUnitDefID
local spGetUnitHeight			= Spring.GetUnitHeight
local spGetUnitRadius			= Spring.GetUnitRadius
local spGetUnitTeam				= Spring.GetUnitTeam
local spGetUnitViewPosition		= Spring.GetUnitViewPosition
local spIsUnitSelected			= Spring.IsUnitSelected
local spIsUnitVisible			= Spring.IsUnitVisible
local spSendCommands			= Spring.SendCommands
local GetUnitRulesParam			= Spring.GetUnitRulesParam
local GetGameFrame				= Spring.GetGameFrame
local trackSlope  = true
 
local circleLines  = 0
local circleDivs  = 32
local circleOffset  = 0
 
local MY_TEAM_ID = Spring.GetMyTeamID()
local NARC_DURATION = Spring.GetGameRulesParam("NARC_DURATION")
local FONT_SIZE = 18

local startTimer  = spGetTimer()
 
local realRadii    = {}
local heights = {}
local colors = {}
colors.narc = "\255\255\255\001"
colors.tag = "\255\255\051\051"
colors.linkLost = "\255\255\255\255"
colors.ppc = "\255\140\166\255"
 
function widget:Initialize()
  circleLines = glCreateList(function()
    glBeginEnd(GL_LINE_LOOP, function()
      local radstep = (2.0 * math.pi) / circleDivs
      for i = 1, circleDivs do
        local a = (i * radstep)
        glVertex(math.sin(a), circleOffset, math.cos(a))
      end
    end)
  end)
  btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", FONT_SIZE, 2, 30)
end
 
function widget:PlayerChanged()
	MY_TEAM_ID = Spring.GetMyTeamID()
end
 
function widget:Shutdown()
  glDeleteList(circleLines)
end
 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
 
local function GetUnitDefRealRadius(udid)
  local radius = realRadii[udid]
  if (radius) then
    return radius
  end
 
  local ud = UnitDefs[udid]
  if (ud == nil) then return nil end
 
  local dims = UnitDefs[udid].zsize/3
  
  if (dims == nil) then dims = 2 end
        
  radius = dims*15
  realRadii[udid] = radius
  return radius
end
 
 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
 
local function CountDown(frame, height)
	local timeLeft = string.format('%.1f', (frame - Spring.GetGameFrame()) / 32.0)
	glPushMatrix()
	glBillboard()
	btFont:Print(colors.narc .. "NARC: " .. timeLeft, 0, height + 8, FONT_SIZE, "oc")
	glPopMatrix()
end
 
local function TagText(height)
	glPushMatrix()
	glBillboard()
	btFont:Print(colors.tag .. "TAG", 0, height + 24, FONT_SIZE, "oc")
	glPopMatrix()
end

local function LinkText(height)
	glPushMatrix()
	glBillboard()
	local num = Spring.GetGameSeconds() % 4
	local dots = ""
	for i = 1, num do dots = dots .. "." end
	btFont:Print(colors.linkLost .. "Link lost" .. dots, -40, height - 8, FONT_SIZE, "oc")
	glPopMatrix()
end

local function PPCText(frame, gameFrame, height) -- hodor, frame calc is reverse of NARC
	local timeLeft = string.format('%.1f', (frame - gameFrame) / 30.0)
	glPushMatrix()
	glBillboard()
	btFont:Print(colors.ppc .. "PPC: " .. timeLeft, 0, height + 40, FONT_SIZE, "oc")
	glPopMatrix()
end

--[[function widget:GameFrame(n)
	for _,unitID in ipairs(spGetAllUnits()) do
		--if (spIsUnitVisible(unitID)) then
			-- check if it's NARCed
			local NARCFrame = GetUnitRulesParam(unitID, "NARC") or 0
			if NARCFrame - n + 1 == NARC_DURATION then
				if Spring.GetUnitTeam(unitID) == MY_TEAM_ID then
					Spring.PlaySoundFile("sounds/warn.wav", 5, "ui")
				else
					Spring.PlaySoundFile("sounds/narc.wav", 5, "ui")
				end
			end
		--end
	end
 end]]
 
function widget:DrawWorldPreUnit()
	glLineWidth(2.0)
	glDepthTest(false)
	glPolygonOffset(-50, -2)
 
	local gameFrame = GetGameFrame()
	for _,unitID in ipairs(spGetAllUnits()) do
		if (spIsUnitVisible(unitID)) then
			-- check if it's NARCed
			local NARCFrame = GetUnitRulesParam(unitID, "NARC") or 0
			if NARCFrame > 0 then
				local teamID = spGetUnitTeam(unitID)
				if (teamID and teamID ~= Spring.GetGaiaTeamID()) then
					local udid = spGetUnitDefID(unitID)
					local radius = GetUnitDefRealRadius(udid)
					local height = heights[udid]
					if not height then
						height = spGetUnitHeight(unitID)
						heights[udid] = height
					end
					if (radius) then
						local diffTime = spDiffTimers(spGetTimer(), startTimer)
						local alpha = 1 * math.abs(0.5 - (diffTime * 3.0 % 1.0))
						local x, y, z = spGetUnitBasePosition(unitID)
						local gx, gy, gz = spGetGroundNormal(x, z)
						local degrot = math.acos(gy) * 180 / math.pi
						-- draw concentric yellow blinky circles
						glColor(1, 1, 0, 1)
						glDrawFuncAtUnit(unitID, true, CountDown, NARCFrame, height) -- should really cache heights
						glColor(1, 1, 0, alpha)
						glDrawListAtUnit(unitID, circleLines, false, radius, 1.0, radius, degrot, gz, 0, -gx)
						glDrawListAtUnit(unitID, circleLines, false, radius * 1.5, 1.0, radius * 1.5, degrot, gz, 0, -gx)
						glDrawListAtUnit(unitID, circleLines, false, radius * 2.5, 1.0, radius * 2.5, degrot, gz, 0, -gx)
					end
				end
			end
			-- check for TAG
			local TAGFrame = GetUnitRulesParam(unitID, "TAG") or 0
			if TAGFrame >= gameFrame - 5 then -- unit is TAGed
				local udid = spGetUnitDefID(unitID)
				local height = heights[udid]
				if not height then
					height = spGetUnitHeight(unitID)
					heights[udid] = height
				end
				glDrawFuncAtUnit(unitID, true, TagText, height)
			end
			-- check Link
			local linkLost = (GetUnitRulesParam(unitID, "LOST_LINK") or 0) == 1
			if linkLost then
				local udid = spGetUnitDefID(unitID)
				local height = heights[udid]
				if not height then
					height = spGetUnitHeight(unitID)
					heights[udid] = height
				end
				glDrawFuncAtUnit(unitID, true, LinkText, height)
			end
			-- check PPC
			local PPCFrame = GetUnitRulesParam(unitID, "PPC_HIT") or 0
			if PPCFrame > gameFrame then
				local udid = spGetUnitDefID(unitID)
				local height = heights[udid]
				if not height then
					height = spGetUnitHeight(unitID)
					heights[udid] = height
				end
				glDrawFuncAtUnit(unitID, true, PPCText, PPCFrame, gameFrame, height)
            end
		end
	end
 
	glPolygonOffset(false)
	glDepthTest(false)
	glLineWidth(1.0)
end