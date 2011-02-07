local moveDefs 	=	 {
	{
		name			=	"TANK",
		footprintX		=	2,
		maxWaterDepth	=	10,
		maxSlope		=	25,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"HOVER",
		footprintX		=	2,
		maxSlope		=	25,
		maxWaterSlope	= 	255,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"SMALLMECH",
		footprintX		=	2,
		maxWaterDepth	=	15,
		maxSlope		=	35,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"LARGEMECH",
		footprintX		=	3,
		maxWaterDepth	=	25,
		maxSlope		=	30,
		crushStrength	=	35,
		heatmapping		=	false,
	},
}

return moveDefs