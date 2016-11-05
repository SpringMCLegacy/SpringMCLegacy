-- $Id$
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local SHADER_DIR = "ModelMaterials/Shaders/"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local frameLoc, frameLoc2

local trackWidths = {} -- unitID = proportionOfTexture

local function UnitCreated(unitID)
	local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
	if unitDef.leaveTracks then
		trackWidths[unitID] = unitDef.customParams.trackwidth
		Spring.Echo("MY WIDTH IS", trackWidths[unitID])
	end
end

local function DrawUnit(unitID, material)
  if frameLoc == nil then
    local curShader = (drawMode == 5) and material.deferredShader or material.standardShader
    frameLoc = gl.GetUniformLocation(curShader, "tankVel")
	frameLoc2 = gl.GetUniformLocation(curShader, "trackWidth")
  end

  gl.Uniform(frameLoc, 0.004 * select(4, Spring.GetUnitVelocity(unitID)))
  if trackWidths[unitID] then
	gl.Uniform(frameLoc2, trackWidths[unitID])
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
        ]],
        FRAGMENT_PRE_SHADING = [[
		// 0.005 scroll ~= 1.25 velocity -> scroll = velocity / 250 = 0.004 x velocity
		if (tex1c.x >= trackWidth) { // last 56 pixels
			tex1c.y += float(simFrame) * tankVel;  // scroll the right part of the texture
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

  if udef.leaveTracks then
    unitMaterials[udef.name] = {
	  "trackShader", 
	  NORMALTEX = udef.customParams.normaltex,
	}
  end
end
  
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return materials, unitMaterials

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
