effectUnitDefs = {
	-- Aero
	is_sparrowhawk = {
		{class='AirJet',	options={color={1,0.5,0.0,0.75},	width =  2, length=35, piece="exhaust1", onActive=true}},
		{class='AirJet',	options={color={1,0.5,0.0,0.75},	width =  2, length=35, piece="exhaust2", onActive=true}},
		{class='AirJet',	options={color={1,0.5,0.0,0.75},	width =  1, length=15, piece="exhaust3", onActive=true}},
		{class='AirJet',	options={color={1,0.5,0.0,0.75},	width =  1, length=15, piece="exhaust4", onActive=true}},
		{class='Ribbon',	options={width=1, size=8, piece="lwingtip"}},
		{class='Ribbon',	options={width=1, size=8, piece="rwingtip"}},
	},
	cl_bashkir = {
		{class='AirJet',	options={color={1,0.5,0.0,0.75},	width =  2, length=35, piece="exhaust1", onActive=true}},
		{class='AirJet',	options={color={1,0.5,0.0,0.75},	width =  2, length=35, piece="exhaust2", onActive=true}},
		--{class='Ribbon',	options={width=1, size=8, piece="lwingtip"}},
		--{class='Ribbon',	options={width=1, size=8, piece="rwingtip"}},
	},	
	is_avenger = {
		{class='Ribbon',	options={width=4, size=12, piece="fin1"}},
		{class='Ribbon',	options={width=4, size=12, piece="fin2"}},
		{class='Ribbon',	options={width=2, size=8, piece="fin3"}},
		{class='Ribbon',	options={width=2, size=8, piece="fin4"}},
		{class='Ribbon',	options={width=6, size=6, piece="root1"}},
		{class='Ribbon',	options={width=6, size=6, piece="root2"}},
	},
 }

ecm =  {
	{class='ShieldSphere', options={life=math.huge, pos={0,0,0}, size=500, onActive=true, colormap1 = {{0.9, 0.2, 0.2, 0.25}}, repeatEffect=true}},
	{class='ShieldJitter', options={delay=0,life=math.huge, pos={0,0,0}, size=512,onActive=true, precision=222, strength   = 0.002,  repeatEffect=true}},
	--{class='ShieldJitter', options={delay=0,life=math.huge, pos={0,0,0}, size=5, precision=22, strength   = 0.15,  repeatEffect=true}},
	--{class='ShieldJitter', options={delay=0,life=math.huge, pos={0,0,0}, size=100, precision=22, strength   = 0.005,  repeatEffect=true}},
}
for name, unitDef in pairs(UnitDefNames) do
	if unitDef.customParams.ecm then
		effectUnitDefs[name] = ecm
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

local sideData = VFS.Include("gamedata/sidedata.lua", {})
local Sides = {}
for sideNum, data in pairs(sideData) do
	Sides[sideNum] = data.shortName:lower()
end

for i, sideName in pairs(Sides) do
	effectUnitDefs[sideName .. "_dropship_leopard"] = leopard
end
	
effectUnitDefsXmas = {
	-- armcom = {
		-- {class='SantaHat',	options={color={0,0.7,0,1.0}, pos={0,4,0.35}, emitVector={0.3,1.0,0.2},	width =  2.7, height=6, ballSize=0.7, piece="head"}},
	-- },
	-- corcom = {
		-- {class='SantaHat',	options={pos={0,6,2}, emitVector={0.4,1.0,0.2},	width =  2.7, height=6, ballSize=0.7, piece="head"}},
	-- },
}