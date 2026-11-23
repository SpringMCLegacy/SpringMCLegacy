local sidedata = {
	{
		name = "Federated Suns",
		shortName = "FS",
		techBase = "IS",
		texmods = {"DavionGuards"},
	},
	{
		name = "Lyran Alliance",
		shortName = "LA",
		techBase = "IS",
		texmods = {"LyranGuards"},
	},
	{
		name = "Draconis Combine",
		shortName = "DC",
		techBase = "IS",
		texmods = {"SwordofLight"},
	},
	{
		name = "Capellan Confederation",
		shortName = "CC",
		techBase = "IS",
		texmods = {"DeathCommandos"},
	},
	{
		name = "Free Worlds League",
		shortName = "FW",
		techBase = "IS",
		texmods = {"MarikMilitia"},
	},
	{
		name = "Clan Wolf",
		shortName = "WF",
		techBase = "CL",
		texmods = {"WFBeta", "WolfInExile"},
	},
--[[	{
		name = "Clan Jade Falcon",
		shortName = "JF",
		techBase = "CL",
	},--]]
	{
		name = "Clan Smoke Jaguar",
		shortName = "SJ",
		techBase = "CL",
		texmods = {"SJAlpha"},
	},
}

for i, data in pairs(sidedata) do
	data.startUnit = data.shortName .. "_dropzone"
end

return sidedata