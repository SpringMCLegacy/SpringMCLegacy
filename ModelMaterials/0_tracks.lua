-- $Id$
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local SHADER_DIR = "ModelMaterials/Shaders/"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local frameLoc, frameLoc2, frameLoc3

local trackWidths = {} -- unitID = proportionOfTexture
local trackCache = {}

local function UnitCreated(unitID)
	local unitDefID = Spring.GetUnitDefID(unitID)
	local width = trackCache[unitDefID]
	if width then
		trackWidths[unitID] = width
		--Spring.Echo("MY WIDTH IS", trackWidths[unitID], width)
	end
end

local function DrawUnit(unitID, material)
  if frameLoc == nil then
    local curShader = (drawMode == 5) and material.deferredShader or material.standardShader
    frameLoc = gl.GetUniformLocation(curShader, "tankVel")
	frameLoc2 = gl.GetUniformLocation(curShader, "trackWidth")
	frameLoc3 = gl.GetUniformLocation(curShader, "turnRate")
  end

  gl.Uniform(frameLoc, 0.004 * select(4, Spring.GetUnitVelocity(unitID)))
  if trackWidths[unitID] then
	gl.Uniform(frameLoc2, trackWidths[unitID])
	gl.Uniform(frameLoc3, 0.00002 * (Spring.GetUnitRulesParam(unitID, "turning") or 0))
  end
  -- engine should still draw it (we just set the uniforms for the shader)
  return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local materials = {
   trackShader = {
      shaderDefinitions = {
		"#define use_perspective_correct_shadows",
        "#define use_normalmapping",
      },
      shaderPlugins = {
        FRAGMENT_GLOBAL_NAMESPACE = [[
          uniform int simFrame;
		  uniform float tankVel;
		  uniform float trackWidth;
		  uniform float turnRate;
        ]],
        FRAGMENT_PRE_SHADING = [[
		// 0.005 scroll ~= 1.25 velocity -> scroll = velocity / 250 = 0.004 x velocity
		if (tex1c.x >= trackWidth) { // last 56 pixels
			tex1c.y += float(simFrame) * (tankVel+turnRate);  // scroll the right part of the texture
		}
        ]],
      },
      shader    = include(SHADER_DIR .. "default.lua"),
      force     = true,
      usecamera = false,
      culling   = GL.BACK,

      texunits  = {
        [0] = '%%UNITDEFID:0',
        [1] = '%%UNITDEFID:1',
        [2] = '$shadow',
        [3] = '$specular',
        [4] = '$reflection',
		[5] = '%NORMALTEX',
      },
      DrawUnit = DrawUnit,
	  UnitCreated = UnitCreated,
   },
}



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- affected unitdefs

local unitMaterials = {}

for i=1,#UnitDefs do
  local udef = UnitDefs[i]

  if udef.leaveTracks and udef.customParams.baseclass == "vehicle" and not udef.customParams.wheels and udef.customParams.normaltex then
	--Spring.Echo("found a unit with tracks", udef.name)
    unitMaterials[udef.name] = {
	  "trackShader", 
	  NORMALTEX = udef.customParams.normaltex,
	}
	trackCache[i] = udef.customParams.trackwidth
  end
end
  
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return materials, unitMaterials

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
