-- $Id$
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local GADGET_DIR = "ModelMaterials"

local materials = {
   metalS3o = {
       shaderDefinitions = {
	      "#define use_perspective_correct_shadows",
          "#define use_normalmapping",
        --"#define flip_normalmap",
       },
       shader    = include(GADGET_DIR .. "/Shaders/metal.lua"),
       usecamera = false,
       culling   = GL.BACK,
       texunits  = {
         [0] = '%%UNITDEFID:0',
         [1] = '%%UNITDEFID:1',
         [2] = '$shadow',
         [3] = '$specular',
         [4] = '$reflection',
		 [5] = '%NORMALTEX',
         [6] = ':g:bitmaps/hull.jpg',
       },
   },
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Automated normalmap detection

local unitMaterials = {}

for i=1,#UnitDefs do
  local udef = UnitDefs[i]
  if (not udef.customParams.baseclass and udef.customParams.normaltex and VFS.FileExists(udef.customParams.normaltex)) then
    -- dropships only for now
    unitMaterials[udef.name] = {"metalS3o", NORMALTEX = udef.customParams.normaltex}
  else
    unitMaterials[udef.name] = {"metalS3o"}
  end
end --for

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return materials, unitMaterials

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
