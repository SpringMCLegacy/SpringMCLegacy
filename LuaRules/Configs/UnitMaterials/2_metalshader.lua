-- $Id$
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local GADGET_DIR = "LuaRules/Configs/"

local materials = {
   metalS3o = {
       shaderDefinitions = {
	--"#define use_perspective_correct_shadows",
        --"#define use_normalmapping",
        --"#define flip_normalmap",
       },
       shader    = include(GADGET_DIR .. "UnitMaterials/Shaders/metal.lua"),
       usecamera = false,
       culling   = GL.BACK,
       texunits  = {
         [0] = '%%UNITDEFID:0',
         [1] = '%%UNITDEFID:1',
         [2] = '$shadow',
         [3] = '$specular',
         [4] = '$reflection',
         [6] = 'bitmaps/decal.png',
       },
   },
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Automated normalmap detection

local unitMaterials = {}

for i=1,#UnitDefs do
  local udef = UnitDefs[i]
  unitMaterials[udef.name] = {"metalS3o"}
end --for

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return materials, unitMaterials

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
