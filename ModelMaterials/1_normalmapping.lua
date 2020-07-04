-- $Id$
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local materials = {
   normalMappedS3o = {
       shaderDefinitions = {
         "#define use_perspective_correct_shadows",
         "#define use_normalmapping",
         --"#define flip_normalmap",
       },
       shader    = include("ModelMaterials/Shaders/default.lua"),
       usecamera = false,
       culling   = GL.BACK,
       predl  = nil,
       postdl = nil,
       texunits  = {
         [0] = '%%UNITDEFID:0',
         [1] = '%%UNITDEFID:1',
         [2] = '$shadow',
         [3] = '$specular',
         [4] = '$reflection',
         [5] = '%NORMALTEX',
       },
   },
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Automated normalmap detection

local unitMaterials = {}

for i=1,#UnitDefs do
  local udef = UnitDefs[i]

  if (udef.customParams.baseclass and udef.customParams.normaltex and VFS.FileExists(udef.customParams.normaltex)) then
    unitMaterials[udef.name] = {"normalMappedS3o", NORMALTEX = udef.customParams.normaltex}
  end
end --for

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return materials, unitMaterials

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------