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


local function DrawStationary(maxAngleDif)
	local length = maxAngleDif
	local width = sqrt(1 - maxAngleDif * maxAngleDif)
	local vertices = {
		{v = {-width, 0, length}},
		{v = {0, 0, 0}},
		{v = {width, 0, length}},
	}

	glShape(GL_LINE_STRIP, vertices)
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
					DrawFieldOfFire(unitID, info[1], Spring.GetUnitSensorRadius(unitID, "radar"))
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
