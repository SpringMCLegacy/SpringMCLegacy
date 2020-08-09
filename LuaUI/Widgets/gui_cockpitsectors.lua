function widget:GetInfo()
	return {
		name = "MC:L - View Sectors",
		desc = "Indicates cockpit view sector",
		author = "Evil4Zerggin",
		date = "5 January 2009",
		license = "GNU LGPL, v2.1 or later",
		layer = 1,
		enabled = true
	}
end

------------------------------------------------
--config
------------------------------------------------
local alpha = 1
local color = {1, 0.5, 0, alpha} --if no color specified, picks a hashed color for each unit
local lineWidth = 1
local divsPerRadian = 16

------------------------------------------------
--vars
------------------------------------------------
--format: unitDefID = {list, range}
local unitDefInfos = {}

local stationaryLists = {}
local mobileLists = {}

------------------------------------------------
--speedups
------------------------------------------------
local FindUnitCmdDesc = Spring.FindUnitCmdDesc
local GetActiveCommand = Spring.GetActiveCommand
local GetInvertQueueKey = Spring.GetInvertQueueKey
local GetModKeyState = Spring.GetModKeyState
local GetMouseState = Spring.GetMouseState
local GetSelectedUnitsSorted = Spring.GetSelectedUnitsSorted
local GetUnitDefID = Spring.GetUnitDefID
local GetUnitHeading = Spring.GetUnitHeading
local GetUnitPosition = Spring.GetUnitPosition
local TraceScreenRay = Spring.TraceScreenRay

local glLineWidth = gl.LineWidth
local glColor = gl.Color

local glCreateList = gl.CreateList
local glCallList = gl.CallList
local glDeleteList = gl.DeleteList

local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix
local glTranslate = gl.Translate
local glRotate = gl.Rotate
local glScale = gl.Scale

local glShape = gl.Shape

local glDepthTest = gl.DepthTest

local vHeadingToDegrees
local GetUnitActiveCommandPosition
local GetUnitPositionAtEndOfQueue

local acos = math.acos
local sin, cos = math.sin, math.cos
local deg, rad = math.deg, math.rad
local ceil = math.ceil
local sqrt = math.sqrt

local strFind = string.find
local strSub = string.sub
local strLen = string.len

local GL_LINE_STRIP = GL.LINE_STRIP
local GL_LINE_LOOP = GL.LINE_LOOP

local PI = math.pi
local RAD1 = rad(1)

------------------------------------------------
--helper functions
------------------------------------------------

local maxAlpha = 0.45
local losAlpha = 0.15

local modOptions = Spring.GetModOptions()
local RADAR = (modOptions and modOptions.sectorrange or 1500)
local LOS = (modOptions and modOptions.mechsight or 400)


local function DrawStationary(maxAngleDif, sectorRange)
	sectorRange = (sectorRange or RADAR)
	local r, g, b = unpack({0.4, 0.9, 0})
	local THICC = 0.05
	local los = LOS/sectorRange
	local length = maxAngleDif
	local width = sqrt(1 - maxAngleDif * maxAngleDif)
	local vertices = {
		{v = {-width, 0, length}, 						c = {r, g, b, maxAlpha} },
		{v = {-width-THICC, 0, length+THICC},					c = {r, g, b, 0}},
		{v = {-width*los, 0, length*los}, 				c = {r, g, b, maxAlpha} },
		{v = {-width*los-THICC, 0, length*los}, 		c = {r, g, b, 0}},
	}
	local vertices2 = {
		{v = {width, 0, length}, 						c = {r, g, b, maxAlpha} },
		{v = {width+THICC, 0, length+THICC},					c = {r, g, b, 0}},
		{v = {width*los, 0, length*los}, 				c = {r, g, b, maxAlpha} },	
		{v = {width*los+THICC, 0, length*los}, 			c = {r, g, b, 0}},
	}
	local angle = math.acos(maxAngleDif)
	local vertices3 = {}
	for i = 0, 8 do
		local angle = i * angle / 8
		local ox = sin(angle)
		local oz = cos(angle)
		local ix = ox + THICC
		local iz = oz + THICC
		vertices3[2*i+1] = { v = {ix, 0, iz}, c = {r, g, b, 0} }
		vertices3[2*i+2] = { v = {ox, 0, oz}, c = {r, g, b, maxAlpha} }
	end
	vertices3[1] = { v = {0, 0, 1+THICC}, c = {r, g, b, 0} }
	vertices3[2] = { v = {0, 0, 1}, c = {r, g, b, maxAlpha} }
	local vertices4 = {}
	for i = 0, 8 do
		local angle = i * angle / 8
		local ox = -sin(angle)
		local oz = cos(angle)
		local ix = ox - THICC
		local iz = oz + THICC
		vertices4[2*i+1] = { v = {ix, 0, iz}, c = {r, g, b, 0} }
		vertices4[2*i+2] = { v = {ox, 0, oz}, c = {r, g, b, maxAlpha} }
	end
	vertices4[1] = { v = {0, 0, 1+THICC}, c = {r, g, b, 0} }
	vertices4[2] = { v = {0, 0, 1}, c = {r, g, b, maxAlpha} }
	
	angle = math.pi
	local vertices5 = {}
	for i = 1, 12 do
		local angle = (i+2) * angle / 8
		local ox = sin(angle)*los
		local oz = cos(angle)*los
		local ix = ox * 1.09
		local iz = oz * 1.09
		vertices5[2*i+1] = { v = {ix, 0, iz}, c = {r, g, b, 0} }
		vertices5[2*i+2] = { v = {ox, 0, oz}, c = {r, g, b, maxAlpha} }
	end
	vertices5[1] = {v = {width*los+THICC, 0, length*los}, 	c = {r, g, b, 0}}
	vertices5[2] = {v = {width*los, 0, length*los}, 		c = {r, g, b, maxAlpha} }	
	vertices5[27] = {v = {-width*los-THICC, 0, length*los}, 	c = {r, g, b, 0}}
	vertices5[28] = {v = {-width*los, 0, length*los}, 		c = {r, g, b, maxAlpha} }	
	
	glShape(GL.QUAD_STRIP, vertices)
	glShape(GL.QUAD_STRIP, vertices2)
	glShape(GL.QUAD_STRIP, vertices3)
	glShape(GL.QUAD_STRIP, vertices4)
	glShape(GL.QUAD_STRIP, vertices5)
end

local function DrawFieldOfFire2(x, y, z, list, range, rotation)
	glPushMatrix()
		glTranslate(x, y, z)
		glRotate(rotation, 0, 1, 0)
		glScale(range, range, range)
		glCallList(list)
	glPopMatrix()
end

local function DrawFieldOfFire(unitID, list, range)
	local map = Spring.GetUnitPieceMap(unitID)
	local x, y, z, dx, dy, dz = Spring.GetUnitPiecePosDir(unitID, map["cockpit"])
	_,y,_ = Spring.GetUnitPosition(unitID)
	local rotation = math.deg(math.atan2(dx, dz))

	return DrawFieldOfFire2(x, y, z, list, range, rotation)
end

local function GetUnitDefMaxAngleDif(unitDef)
	if unitDef.customParams.sectorangle then
		return math.cos(math.rad(unitDef.customParams.sectorangle)/2)
	else
		return 0
	end
end

local function GetBasename(name)
	local underscoreIndex = strFind(name, "_")
	if underscoreIndex then
		return strSub(name, 1, underscoreIndex - 1)
	else
		return name
	end
end

------------------------------------------------
--callins
------------------------------------------------
function widget:Initialize()
	-- 							always 		/ 		LOS 	/ 	radar 		/ 	jam 	/ 	radar2
	Spring.SetLosViewColors({0.25,0.25,0.25}, {0.3,0.3,0.3}, {0.1,0.9,0.1}, {0.2,0.01,0.01}, {0.07,0.07,0.07})
	vHeadingToDegrees = WG.Vector.HeadingToDegrees
	GetUnitActiveCommandPosition = WG.CmdQueue.GetUnitActiveCommandPosition
	GetUnitPositionAtEndOfQueue = WG.CmdQueue.GetUnitPositionAtEndOfQueue
	
	local inUse = false
	--outer loop: stationaries
	for stationaryUnitDefID, stationaryUnitDef in ipairs(UnitDefs) do
		local maxAngleDif = GetUnitDefMaxAngleDif(stationaryUnitDef)
		if maxAngleDif > 0 then -- and stationaryUnitDef.speed == 0 then
			--create stationary list
			local list = stationaryLists[maxAngleDif]
			local range = stationaryUnitDef.losRadius
			if not list then
				list = glCreateList(DrawStationary, maxAngleDif)
				stationaryLists[maxAngleDif] = list
			end
			unitDefInfos[stationaryUnitDefID] = {list, range}

			inUse = true
		end
	end

	--remove self if unused
	if (not inUse) then
		WG.RemoveWidget(self)
	end
end

function widget:Shutdown()
	for _, list in pairs(stationaryLists) do
		glDeleteList(list)
	end

	for _, list in pairs(mobileLists) do
		glDeleteList(list)
	end
end

function widget:DrawWorld()
	glColor(color)
	glLineWidth(lineWidth)
	glDepthTest(false)

	local selectedUnitsSorted = GetSelectedUnitsSorted()

	local tx, tz
	local cmdID, cmdDescID, cmdDescType, cmdDescName = GetActiveCommand()

	for unitDefID, info in pairs(unitDefInfos) do
		local units = selectedUnitsSorted[unitDefID]
		if units then
			for i=1,#units do
				local unitID = units[i]
				if GetUnitDefID(unitID) then
					DrawFieldOfFire(unitID, info[1], (Spring.GetUnitRulesParam(unitID, "sectorradius") or RADAR) - 50)
				end
			end
		end
	end

	glLineWidth(1)
	glColor(1, 1, 1, 1)
end

--[[function widget:GameFrame(n)
	local units = Spring.GetSelectedUnits()
	for i, unitID in pairs(units) do
		Spring.Echo("HEP HEP", i, unitID)
		local path, stuff = Spring.GetUnitEstimatedPath(unitID)
		for j = 1, #path do
			local point = path[j]
			Spring.MarkerAddPoint(point[1], point[2], point[3])
		end
	end
end]]
