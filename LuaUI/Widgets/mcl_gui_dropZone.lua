function widget:GetInfo()
	return {
		name = "MC: L Unit Platters",
		desc = "Dropzone indicator & unit selection platters",
		author = "FLOZi (C. Lawrence)",
		date = "25/10/2016",
		license = "GPL v2",
		layer = -2,
		enabled = true
		}
end

local MechDefs = {}
local TowerDefs = {}
local MECH_TEX_SELECT = ":a:luaui/images/mech_select.png"
local MECH_TEX = ":a:luaui/images/mech.png"


local BEACON_POINT_DEFID = UnitDefNames["beacon_point"].id
local BEACON_POINT_TEX = ":a:luaui/images/outpostpoint.png"


local OUTPOST_TEX = ":a:icons/beaconpoint.png"

local SALVAGE_DEFID = FeatureDefNames["salvage"].id
local SALVAGE_TEX = ":a:luaui/images/salvage.png"

local DZDefs = {}
local DZ_LIST
local Y_OFFSET = 1.0

local rotate = 0

--local DZ_TEX = "icons/beacon.png"

local DZ_TEX_PATH = ":a:luaui/images/dz/frame"--attack_"
local DZ_TEX_FRAMES = 8--5
local DZ_ANIM_WAIT = 40
local DZ_TEXS = {}

for i = 1, DZ_TEX_FRAMES do
	DZ_TEXS[i] = DZ_TEX_PATH .. i .. ".png"
end

local glCreateList = gl.CreateList
local glBeginEnd = gl.BeginEnd
local glTexCoord = gl.TexCoord
local glVertex = gl.Vertex
local glDepthTest = gl.DepthTest
local glDepthMask = gl.DepthMask
local glBlending = gl.Blending
local GL_SRC_ALPHA = GL.SRC_ALPHA
local GL_ONE = GL.ONE
local glResetState = gl.ResetState
local glTexture = gl.Texture
local glDrawListAtUnit = gl.DrawListAtUnit
local glPolygonOffset = gl.PolygonOffset
local glColor = gl.Color

local GetVisibleUnits = Spring.GetVisibleUnits
local GetUnitDefID = Spring.GetUnitDefID

local GetTeamColor = Spring.GetTeamColor


local function SetupCommandColors(state)
  local alpha = state and 1 or 0
  local f = io.open('cmdcolors.tmp', 'w+')
  if (f) then
    f:write('unitBox  0 1 0 ' .. alpha)
    f:close()
    Spring.SendCommands({'cmdcolors cmdcolors.tmp'})
  end
  os.remove('cmdcolors.tmp')
end

function widget:Initialize()
	SetupCommandColors(false)
	for unitDefID, unitDef in pairs(UnitDefs) do
		if unitDef.name:find("dropzone") then
			DZDefs[unitDefID] = true
		elseif unitDef.customParams.baseclass == "mech" then
			MechDefs[unitDefID] = true
		elseif unitDef.customParams.baseclass == "tower" then
			TowerDefs[unitDefID] = true
		end
	end	

	DZ_LIST = glCreateList(function()
	    glBeginEnd(GL.QUADS, function()
			glTexCoord(0.0, 0.0)
			glVertex(-1, Y_OFFSET, -1)
			glTexCoord(1.0, 0.0)
			glVertex(1, Y_OFFSET, -1)
			glTexCoord(1.0, 1.0)
			glVertex(1, Y_OFFSET, 1)
			glTexCoord(0.0, 1.0)
			glVertex(-1, Y_OFFSET, 1)
	    end)
	end)
end

function widget:GameFrame(n)
	if n > 0 then
		rotate = rotate + 0.5
		if rotate > 360 then 
			rotate = 0 
		end
	end
end

function widget:Shutdown()
	gl.DeleteList(DZ_LIST)
end


function widget:DrawWorldPreUnit()
	-- TODO: Use local myDZ = Spring.GetTeamUnitsByDefs(Spring.GetMyUnitDefID instead, need to know 'my' side
	local visibleUnits = GetVisibleUnits(Spring.GetMyTeamID())
	local visibleFeatures = Spring.GetVisibleFeatures()

	if (#visibleUnits + #visibleFeatures) > 0 then
		glBlending(GL_SRC_ALPHA, GL_ONE)
		glDepthTest(true)
		glDepthMask(false)
		gl.PolygonOffset(-50, -50)
		local r,g,b = Spring.GetTeamColor(Spring.GetMyTeamID())
		for _,unitID in pairs(visibleUnits) do
			local unitDefID = GetUnitDefID(unitID)
			local selected = Spring.IsUnitSelected(unitID)
			if DZDefs[unitDefID] then
				local radius = 4.75 * UnitDefs[unitDefID].xsize
				glColor(1.0, 1.0, 1.0, 0.5)
				glTexture(DZ_TEXS[math.floor(Spring.GetGameFrame() % DZ_ANIM_WAIT / (DZ_ANIM_WAIT / #DZ_TEXS))+1])
				glDrawListAtUnit(unitID, DZ_LIST, false, radius, 1.0, radius, rotate, 0, 1.0, 0)
			elseif unitDefID == BEACON_POINT_DEFID then
				local radius = 20 * UnitDefs[unitDefID].xsize
				glColor(r, g, b, selected and 0.9 or 0.4)
				glTexture(BEACON_POINT_TEX)
				glDrawListAtUnit(unitID, DZ_LIST, false, radius, 1.0, radius, 0, 0, 1.0, 0)				
			elseif UnitDefs[unitDefID].customParams.baseclass == "outpost" then -- TODO: cache
				local radius = 15 * UnitDefs[unitDefID].xsize
				glTexture(OUTPOST_TEX)
				glColor(r, g, b, selected and 0.9 or 0.65)
				glDrawListAtUnit(unitID, DZ_LIST, false, radius, 1.0, radius, 0, 0, 1.0, 0)								
			elseif TowerDefs[unitDefID] and not Spring.GetUnitNeutral(unitID) then -- ewww
				local radius = 5 * UnitDefs[unitDefID].xsize
				glTexture(OUTPOST_TEX)
				glColor(r, g, b, selected and 0.9 or 0.65)
				glDrawListAtUnit(unitID, DZ_LIST, false, radius, 1.0, radius, 0, 0, 1.0, 0)								
			elseif MechDefs[unitDefID] then
				local radius = Spring.GetUnitRadius(unitID) * 2.25
				local rx, ry, rz = Spring.GetUnitRotation(unitID)
				local x, y, z = Spring.GetUnitBasePosition(unitID)
				local gx, gy, gz = Spring.GetGroundNormal(x, z)
				glTexture(selected and MECH_TEX_SELECT or MECH_TEX)
				glColor(r, g, b, selected and 0.9 or 0.65)
				glDrawListAtUnit(unitID, DZ_LIST, false, radius, 1.0, radius, math.deg(-ry), 0, 1, 0)
			end
		end
		for _, featureID in pairs(visibleFeatures) do
			local featureDefID = Spring.GetFeatureDefID(featureID)
			if featureDefID == SALVAGE_DEFID then
				local x,y,z = Spring.GetFeaturePosition(featureID)
				gl.PushMatrix()
					gl.Translate(x, y, z)
					glTexture(SALVAGE_TEX)
					--glColor(0.8, 0.8, 0.8, 0.45) -- colors.slategray = "\255\198\226\255"
					glColor(198/255, 226/255, 1, 0.65)
					gl.Scale(10, 1, 10) 
					gl.CallList(DZ_LIST)
				gl.PopMatrix()
			end
		end
		glTexture(false)
		glBlending(false)
	end	
end
