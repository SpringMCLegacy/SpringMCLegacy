local OPTION_SHADOWMAPPING    = 1
local OPTION_NORMALMAPPING    = 2
local OPTION_SHIFT_RGBHSV     = 4 -- userDefined[2].rgb (gl.SetUnitBufferUniforms(unitID, {math.random(),math.random()-0.5,math.random()-0.5}, 8) -- shift Hue, saturation, valence )
local OPTION_VERTEX_AO        = 8
local OPTION_FLASHLIGHTS      = 16
local OPTION_TREADS_ARM      = 32
local OPTION_TREADS_CORE     = 64
local OPTION_HEALTH_TEXTURING = 128
local OPTION_HEALTH_DISPLACE  = 256
local OPTION_HEALTH_TEXRAPTORS = 512
local OPTION_MODELSFOG        = 1024
local OPTION_TREEWIND         = 2048
local OPTION_PBROVERRIDE      = 4096
local OPTION_TREADS_LEG       = 8192

local defaultBitShaderOptions = OPTION_SHADOWMAPPING + OPTION_NORMALMAPPING  + OPTION_MODELSFOG

local uniformBins = {
	armunit = {
		bitOptions = defaultBitShaderOptions + OPTION_VERTEX_AO + OPTION_FLASHLIGHTS + OPTION_TREADS_ARM + OPTION_HEALTH_TEXTURING + OPTION_HEALTH_DISPLACE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.5,
	},
	corunit = {
		bitOptions = defaultBitShaderOptions + OPTION_VERTEX_AO + OPTION_FLASHLIGHTS + OPTION_TREADS_CORE + OPTION_HEALTH_TEXTURING + OPTION_HEALTH_DISPLACE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.5,
	},
	legunit = {
		bitOptions = defaultBitShaderOptions + OPTION_VERTEX_AO + OPTION_FLASHLIGHTS + OPTION_TREADS_LEG + OPTION_HEALTH_TEXTURING + OPTION_HEALTH_DISPLACE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.5,
	},
	armscavenger = {
		bitOptions = defaultBitShaderOptions + OPTION_VERTEX_AO + OPTION_FLASHLIGHTS + OPTION_TREADS_ARM + OPTION_HEALTH_TEXTURING + OPTION_HEALTH_DISPLACE,
		baseVertexDisplacement = 0.4,
		brightnessFactor = 1.5,
	},
	corscavenger = {
		bitOptions = defaultBitShaderOptions + OPTION_VERTEX_AO + OPTION_FLASHLIGHTS + OPTION_TREADS_CORE + OPTION_HEALTH_TEXTURING + OPTION_HEALTH_DISPLACE,
		baseVertexDisplacement = 0.4,
		brightnessFactor = 1.5,
	},
	legscavenger = {
		bitOptions = defaultBitShaderOptions + OPTION_VERTEX_AO + OPTION_FLASHLIGHTS + OPTION_TREADS_LEG + OPTION_HEALTH_TEXTURING + OPTION_HEALTH_DISPLACE,
		baseVertexDisplacement = 0.4,
		brightnessFactor = 1.5,
	},
	raptor = {
		bitOptions = defaultBitShaderOptions + OPTION_VERTEX_AO + OPTION_FLASHLIGHTS  + OPTION_HEALTH_DISPLACE + OPTION_HEALTH_TEXRAPTORS + OPTION_TREEWIND + OPTION_SHIFT_RGBHSV,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.5,
	},
	otherunit = {
		bitOptions = defaultBitShaderOptions,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.1,--1.5,
	},
	feature = {
		bitOptions = defaultBitShaderOptions + OPTION_PBROVERRIDE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
	featurepbr = {
		bitOptions = defaultBitShaderOptions,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
	treepbr = {
		bitOptions = defaultBitShaderOptions + OPTION_TREEWIND + OPTION_PBROVERRIDE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
	tree = {
		bitOptions = defaultBitShaderOptions + OPTION_TREEWIND + OPTION_PBROVERRIDE,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
	wreck = {
		bitOptions = defaultBitShaderOptions,
		baseVertexDisplacement = 0.0,
		brightnessFactor = 1.3,
	},
} -- maps uniformbins to a table of uniform names/values

return uniformBins