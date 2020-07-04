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

local function FindNormalmap(tex1, tex2)
  local normaltex

  --// check if there is a corresponding _normals.dds file
  if (VFS.FileExists(tex1)) then
    local basefilename = tex1:gsub("%....","")
    if (tonumber(basefilename:sub(-1,-1))) then
      basefilename = basefilename:sub(1,-2)
    end
    if (basefilename:sub(-1,-1) == "_") then
       basefilename = basefilename:sub(1,-2)
    end
    normaltex = basefilename .. "_normals.dds"
    if (not VFS.FileExists(normaltex)) then
      normaltex = nil
    end
  end --if FileExists

  if (not normaltex) and tex2 and (VFS.FileExists(tex2)) then
    local basefilename = tex2:gsub("%....","")
    if (tonumber(basefilename:sub(-1,-1))) then
      basefilename = basefilename:sub(1,-2)
    end
    if (basefilename:sub(-1,-1) == "_") then
      basefilename = basefilename:sub(1,-2)
    end
    normaltex = basefilename .. "_normals.dds"
    if (not VFS.FileExists(normaltex)) then
      normaltex = nil
    end
  end

  return normaltex
end



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