local moveDefs 	=	 {
	{
		name			=	"TANK",
		footprintX		=	4,
		maxWaterDepth	=	10,
		maxSlope		=	35,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"HOVER",
		footprintX		=	3,
		maxSlope		=	35,
		maxWaterSlope	= 	255,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"SMALLMECH",
		footprintX		=	3,
		maxWaterDepth	=	30,
		maxSlope		=	45,
		crushStrength	=	25,
		heatmapping		=	false,
	},
	{
		name			=	"LARGEMECH",
		footprintX		=	4,
		maxWaterDepth	=	45,
		maxSlope		=	40,
		crushStrength	=	35,
		heatmapping		=	false,
	},
}

return moveDefs