local moveDefs 	=	 {
	{
		name			=	"TANK",
		footprintX		=	3,
		maxWaterDepth	=	10,
		maxSlope		=	20,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"HOVER",
		footprintX		=	2,
		maxSlope		=	15,
		maxWaterSlope	= 	255,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"BA",
		footprintX		=	1,
		maxWaterDepth	=	2,
		maxSlope		=	45,
		crushStrength	=	0,
		heatmapping		=	false,
	},
	{
		name			=	"SMALLMECH",
		footprintX		=	2,
		maxWaterDepth	=	30,
		maxSlope		=	45,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"LARGEMECH",
		footprintX		=	3,
		maxWaterDepth	=	45,
		maxSlope		=	40,
		crushStrength	=	35,
		heatmapping		=	false,
	},
}

return moveDefs