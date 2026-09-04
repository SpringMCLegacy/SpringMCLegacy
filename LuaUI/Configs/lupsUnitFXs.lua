effectUnitDefs = {

 }

ecm =  {
	{class='ShieldSphere', options={life=math.huge, pos={0,0,0}, size=500, onActive=true, colormap1 = {{0.9, 0.2, 0.2, 0.15}}, repeatEffect=true}},
	{class='ShieldJitter', options={delay=0,life=math.huge, pos={0,0,0}, size=512,onActive=true, precision=222, strength   = 0.002,  repeatEffect=true}},
	--{class='ShieldJitter', options={delay=0,life=math.huge, pos={0,0,0}, size=5, precision=22, strength   = 0.15,  repeatEffect=true}},
	--{class='ShieldJitter', options={delay=0,life=math.huge, pos={0,0,0}, size=100, precision=22, strength   = 0.005,  repeatEffect=true}},
}
local bigecm = {}
table.copy(ecm, bigecm)
bigecm[1].options.size = 1000
bigecm[2].options.size = 1012
local littleecm = {}
table.copy(ecm, littleecm)
littleecm[1].options.size = 150
littleecm[2].options.size = 162

for name, unitDef in pairs(UnitDefNames) do
	if unitDef.customParams.ecm then -- and unitDef.canMove then -- mobiles
		effectUnitDefs[name] = ecm
		if name == "outpost_ewar" then
			effectUnitDefs[name] = bigecm
		elseif name == "narc_ecm" then
			effectUnitDefs[name] = littleecm
		end
	end
end
 
leopard = {
	{class='Ribbon',	options={width=4, size=12, piece="fin1"}},
	{class='Ribbon',	options={width=4, size=12, piece="fin2"}},
	{class='Ribbon',	options={width=2, size=8, piece="fin3"}},
	{class='Ribbon',	options={width=2, size=8, piece="fin4"}},
	{class='Ribbon',	options={width=6, size=6, piece="nose1"}},
	{class='Ribbon',	options={width=6, size=6, piece="nose22"}},
}

avenger = {
	{class='Ribbon',	options={width=4, size=12, piece="fin1"}},
	{class='Ribbon',	options={width=4, size=12, piece="fin2"}},
	{class='Ribbon',	options={width=2, size=8, piece="fin3"}},
	{class='Ribbon',	options={width=2, size=8, piece="fin4"}},
	{class='Ribbon',	options={width=6, size=6, piece="root1"}},
	{class='Ribbon',	options={width=6, size=6, piece="root2"}},
}

local AERO = {
	exhausts = {
		small = {class='AirJet',	options={color={1,0.5,0.0,0.75},	width =  1, length=15, onActive=true}},
		big = {class='AirJet',	options={color={1,0.5,0.0,0.75},	width =  2, length=35, onActive=true}},
	},
	tip = {class='Ribbon',	options={width=1, size=8}},
}

local numExhausts = { -- TODO: can we access model data in this context?
	corsair = {
		big = 3,
		small = 2,
	},
	sparrowhawk = {
		big = 2,
		small = 2,
	},
	bashkir_p = {
		big = 2,
		small = 0,
	},
	sulla = {
		big = 2,
		small = 0,
	},
	lightning = {
		big = 1,
		small = 2,
	},
	stuka = {
		big = 1,
		small = 2,
	},
}

local tips = {
	"lwingtip",
	"rwingtip",
}

local function BuildTable(unitName)
	if not numExhausts[unitName] then return nil end
	local newTable = {}
	for exhaustSize, data in pairs(AERO.exhausts) do
		for i = 1, numExhausts[unitName][exhaustSize] do
			local exhaustTable = {}
			table.copy(data, exhaustTable)
			exhaustTable.options.piece = "exhaust" .. i + (exhaustSize == "small" and numExhausts[unitName]["big"] or 0) -- eww TODO: pass from script_helper in a rulesparam
			table.insert(newTable, exhaustTable)
		end
	end
	for _, tipPiece in pairs(tips) do
		local tipTable = {}
		table.copy(AERO.tip, tipTable)
		tipTable.options.piece = tipPiece
		table.insert(newTable, tipTable)
	end
	--Spring.Echo("lupsUnitFXs Table~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	--table.echo(newTable)
	return newTable
end
	
local sideData = VFS.Include("gamedata/sidedata.lua", {})
local Sides = {}
for sideNum, data in pairs(sideData) do
	Sides[data.shortName:lower()] = data.techBase
end

for sideName, techBase in pairs(Sides) do
	effectUnitDefs[sideName .. "_dropship_leopard"] = leopard
	if techBase == "IS" then
		effectUnitDefs[sideName .. "_avenger"] = avenger
		effectUnitDefs[sideName .. "_corsair"] = BuildTable("corsair")
		effectUnitDefs[sideName .. "_sparrowhawk"] = BuildTable("sparrowhawk")
		-- this duplicates variants for all IS sides and they won't exist but it shouldn't matter?
		effectUnitDefs[sideName .. "_lightning_ltng15"] = BuildTable("lightning")
		effectUnitDefs[sideName .. "_lightning_ltng16d"] = BuildTable("lightning")
		effectUnitDefs[sideName .. "_lightning_ltng16l"] = BuildTable("lightning")
		effectUnitDefs[sideName .. "_lightning_ltng16s"] = BuildTable("lightning")
		effectUnitDefs[sideName .. "_stuka_stud6"] = BuildTable("lightning")
	elseif techBase == "CL" then
		effectUnitDefs[sideName .. "_bashkir_p"] = BuildTable("bashkir_p")
		effectUnitDefs[sideName .. "_sulla"] = BuildTable("sulla")
	end
end
	
effectUnitDefsXmas = {
	-- armcom = {
		-- {class='SantaHat',	options={color={0,0.7,0,1.0}, pos={0,4,0.35}, emitVector={0.3,1.0,0.2},	width =  2.7, height=6, ballSize=0.7, piece="head"}},
	-- },
	-- corcom = {
		-- {class='SantaHat',	options={pos={0,6,2}, emitVector={0.4,1.0,0.2},	width =  2.7, height=6, ballSize=0.7, piece="head"}},
	-- },
}