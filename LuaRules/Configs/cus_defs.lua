local OPTION_SHADOWMAPPING		= 1		
local OPTION_NORMALMAPPING		= 2		-- Applies normalmapping
local OPTION_SHIFT_RGBHSV		= 4 	-- userDefined[2].rgb (gl.SetUnitBufferUniforms(unitID, {math.random(),math.random()-0.5,math.random()-0.5}, 8) -- shift Hue, saturation, valence )
local OPTION_VERTEX_AO			= 8		-- Per vertex Ambient Occlusion
local OPTION_FLASHLIGHTS		= 16	-- All emissive (tex2.red) will strobe in brightness
local OPTION_TREADS     	 	= 32	-- FLOZiTODO: deal with the treads
--local OPTION_TREADS_CORE		= 64	-- Unused, kept for easier updates from BAR in future
local OPTION_HEALTH_TEXTURING	= 128	-- Gradually overlays wreck texture as unit gets damaged (units only)
local OPTION_HEALTH_DISPLACE	= 256	-- Gradually bends vertices out of shape as unit gets damaged
local OPTION_HEALTH_TEXRAPTORS	= 512	-- Health texturing for skinned units?
local OPTION_MODELSFOG			= 1024
local OPTION_TREEWIND			= 2048	-- Makes trees sway gently in the breeze
local OPTION_PBROVERRIDE		= 4096	-- Forces Recoil default tex2 (non PBR) beavhiour
--local OPTION_TREADS_LEG		= 8192	-- Unused, kept for easier updates from BAR in future

local defaultBitShaderOptions = OPTION_SHADOWMAPPING + OPTION_NORMALMAPPING + OPTION_MODELSFOG
local defaultUnitBitShaderOptions = defaultBitShaderOptions + OPTION_VERTEX_AO + OPTION_HEALTH_TEXTURING + OPTION_HEALTH_DISPLACE

local uniformBins = {
	-- Special overriding uniformBins go here, i.e. so that you can set different bitOptions, baseVertexDisplacement & brightnessFactor
	-- To force a unit or feature into any uniformBin, assign customParams.uniformbin = binName,
	-- this method is preferred to the mix of BAR customparams which are kept for backwards compat
	
	-- myunitswithflashinglights = {
	--		bitOptions = defaultUnitBitShaderOptions + OPTION_FLASHLIGHTS,
	--		baseVertexDisplacement = 0.0,
	--		brightnessFactor = 1.5,
	-- },
	
	defaultunit = {
		-- by default gadget will assign these options to every unit texture set bin
		bitOptions = defaultUnitBitShaderOptions,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.1,
	},
	-- These are the default featureDef uniformBins, you probably don't want to mess with them unless you really know what you're doing
	feature = {
		-- by default gadget will assign these options to every (non-wreck, non-tree) feature texture set bin
		bitOptions = defaultBitShaderOptions + OPTION_PBROVERRIDE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
	featurepbr = {
		-- any feature with featureDef.customParams.cuspbr or with 'pilha_crystal' in the name
		bitOptions = defaultBitShaderOptions,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
	treepbr = {
		-- Currently unused?
		bitOptions = defaultBitShaderOptions + OPTION_TREEWIND + OPTION_PBROVERRIDE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
	tree = {
		-- any whitelisted tree in ModelMaterials_GL4/known_feature_trees.lua or with featureDef.customParams.treeshader = 'yes'
		bitOptions = defaultBitShaderOptions + OPTION_TREEWIND + OPTION_PBROVERRIDE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
	wreck = {
		-- any feature referenced in a unitDef.corpse, or featureDef.featureDead or with '_x', '_dead' or '_heap' in the name
		bitOptions = defaultBitShaderOptions + OPTION_VERTEX_AO,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
} -- maps uniformbins to a table of uniform names/values

return uniformBins