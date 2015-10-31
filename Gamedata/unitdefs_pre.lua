VFS.Include('gamedata/VFSUtils.lua') -- for RecursiveFileSearch()
lowerkeys = VFS.Include('gamedata/system.lua').lowerkeys -- for lowerkeys()
modOptions = Spring.GetModOptions()

-- Our shared funcs
local function printTable (input)
	for k,v in pairs(input) do
		Spring.Echo(k, v)
		if type(v) == "table" then
			printTable(v)
		end
	end
end

local function inherit (c, p, concatNames)
	lowerkeys(c)
	for k,v in pairs(p) do 
		if type(k) == "string" and type(v) ~= "function" then
			k = k:lower() -- can't use lowerkeys() on parent, as breaks e.g. New() -> new
		end
		if type(v) == "table" then
			if c[k] == nil then c[k] = {} end
			inherit(c[k], v)
		else
			if concatNames and k == "name" then 
				c[k] = v .. " " .. (c[k] or "")
			else
				if c[k] == nil then c[k] = v end
				--Spring.Echo(c.name, k, v, c[k])
			end
		end
	end
end

local function append (c, p)
	lowerkeys(c)
	for k,v in pairs(p) do
		if type(v) == "string" then
			c[k] = v .. " " .. (c[k] or "")
		else
			Spring.Log("ERROR: Attempt to concatenate non-string value")
		end
	end
end

-- Make sides available to all def files
local sideData = VFS.Include("gamedata/sidedata.lua", VFS.ZIP)
local Sides = {}
for sideNum, data in pairs(sideData) do
	Sides[sideNum] = data.shortName:lower()
end

-- Root Classes
Def = {
}

function Def:New(newAttribs, concatName)
	local newClass = {}
	if type(newAttribs) == "table" then
		inherit(newClass, newAttribs)
	end
	inherit(newClass, self, concatName)
	return newClass
end

function Def:Clone(name) -- name is passed to <NAME> in _post, it is the unitname of the unit to copy from
	local newClass = {}
	inherit(newClass, self)
	newClass.unitname = name:lower()
	return newClass
end

Unit = Def:New{
	shownanoframe 		= false,
	idleautoheal 		= 0,
	turninplace 		= false,
}

Feature = Def:New{
	object				= "<NAME>.s3o",
	usepiececollisionvolumes = true,
}

Weapon = Def:New{
	avoidFeature	= false,
	collideFeature	= true,
}

---------------------------------------------------------------------------------------------
-- Base Classes
---------------------------------------------------------------------------------------------

-- Mechs ----
local Mech = Unit:New{
	activateWhenBuilt   = true,
	canMove				= true,
	corpse				= "<NAME>_x",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	onoffable           = true,
	script				= "Mech.lua",
	upright				= true,
	usepiececollisionvolumes = true,
	
	customparams = {
		hasturnbutton	= true,
		unittype		= "mech",
		baseclass		= "Mech",
    },
}

local Light = Mech:New{
	iconType			= "light",
	footprintX			= 1,
	footprintZ 			= 1,
	movementClass		= "SMALLMECH",
}

local Medium = Mech:New{
	iconType			= "medium",
	footprintX			= 2,
	footprintZ 			= 2,
	movementClass		= "SMALLMECH",
}

local Heavy = Mech:New{
	iconType			= "heavy",
	footprintX			= 3,
	footprintZ 			= 3,
	movementClass		= "LARGEMECH",
}

local Assault = Mech:New{
	iconType			= "assault",
	footprintX			= 3,
	footprintZ 			= 3,
	movementClass		= "LARGEMECH",
}

-- Vehicles ----
local Vehicle = Unit:New{
	activateWhenBuilt   = true,
	canMove 			= true,
	footprintX			= 3,-- current both TANK and HOVER movedefs are 2x2 even if unitdefs are not
	footprintZ 			= 3,
	iconType			= "vehicle",
	moveState			= 0, -- Hold Position
	onoffable           = true,
	script				= "Vehicle.lua",
	usepiececollisionvolumes = true,
	
	customparams = {
		unittype		= "vehicle",
		ignoreatbeacon  = true,
		baseclass		= "Vehicle",
    },
}

local Tank = Vehicle:New{
	category 			= "tank ground notbeacon",
	corpse				= "<NAME>_x",
	explodeAs          	= "mechexplode",
	leaveTracks			= true,	
	movementClass   	= "TANK",
	noChaseCategory		= "beacon air",
	trackType			= "Thick",
	trackOffset			= 10,
	customparams = {
		hasturnbutton	= "1",
    },
}

local LightTank = Tank:New{
	footprintX			= 2, 
	footprintZ 			= 2,
	trackType			= "Thin",
}

local Hover = LightTank:New{
	movementClass   = "HOVER",
	leaveTracks		= false,
}

-- Aircraft ----
local Aircraft = Vehicle:New{
	footprintX			= 2,
	footprintZ 			= 2,
	iconType			= "aero",
	explodeAs          	= "mechexplode",
	canFly				= true,
	factoryHeadingTakeoff = false,
}
	
local Aero = Aircraft:New{
	category 			= "aero air notbeacon",
	noChaseCategory		= "beacon ground",
	cruiseAlt			= 300,
	canLoopbackAttack 	= true,
	
	customparams = {
		baseclass			= "Aero",
	},
}

local VTOL = Aircraft:New{
	category 			= "vtol air notbeacon",
	noChaseCategory		= "beacon air vtol",
	cruiseAlt			= 250,
	hoverAttack			= true,
	airHoverFactor		= -0.0001,
	
	customparams = {
		hasturnbutton		= "1",
		baseclass			= "VTOL",
    },
}

-- DropShips ----
local DropShip = Unit:New{
	description         = "BattleMech Dropship",
	iconType			= "dropship",
	script				= "Dropship_union.lua", -- TODO: make dropship script generic for all spheroids
	category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 180000, -- TODO: Do we want to make lower tier dropships vulnerable?
	mass                = 36000,
	footprintX			= 20, -- TODO: Probably safe to leave this as standard?
	footprintZ 			= 20,
	idleAutoHeal		= 0,
	transportSize		= 8,
	transportCapacity	= 96, -- 12x transportSize
	transportMass		= 120000,
	holdSteady 			= true,
	power				= 1, -- don't target me!
	
	customparams = {
		bap					= true,
		dropship			= "mech",
		--baseclass			= "dropship",
    },
}

-- Towers ----
local Tower = Unit:New{
	name              	= "Weapon Emplacement", -- overwritten by ecm & bap
	script				= "Turret.lua",
	category 			= "structure notbeacon ground",
	activateWhenBuilt   = true, -- false? activate when deployed?
	buildCostMetal      = 3000,
	maxDamage           = 4000,
	mass                = 5000,
	footprintX			= 3,
	footprintZ 			= 3,
	maxSlope			= 100,
	collisionVolumeType = "box",
	collisionVolumeScales = "25 25 25",
	canMove				= false,
	maxVelocity			= 0,
	idleAutoHeal		= 0,

	customparams = {
		towertype = "turret", -- overwritten by ecm & bap
		ignoreatbeacon = true,
		baseclass		= "Turret",
	}
}

-- Upgrades ----
local Upgrade = Unit:New{
	script				= "Upgrade.lua",
	iconType			= "beacon",
	category 			= "structure ground notbeacon",
	activateWhenBuilt   = true,
	footprintX			= 4,
	footprintZ 			= 4,
	collisionVolumeType = "box",
	collisionVolumeScales = [[75 75 75]],
	buildCostEnergy     = 0,
	buildCostMetal      = 15000, -- overridden by C3 & Garrison
	canMove				= true,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	cantbetransported	= false,
	
	customparams = {
		upgrade = true,
		baseclass		= "Upgrade",
	},
}

---------------------------------------------------------------------------------------------
-- This is where the magic happens
local sharedEnv = {
	Sides = Sides,
	printTable = printTable,
	lowerkeys = lowerkeys,
	modOptions = modOptions,
	Def = Def,
	Feature = Feature,
	Weapon = Weapon,
	Unit = Unit,
	Mech = Mech,
	Light = Light,
	Medium = Medium,
	Heavy = Heavy,
	Assault = Assault,
	Tank = Tank,
	LightTank = LightTank,
	Hover = Hover,
	VTOL = VTOL,
	Aero = Aero,
	DropShip = DropShip,
	Tower = Tower,
	Upgrade = Upgrade,
}
local sharedEnvMT = nil


-- override setmetatable to expose our shared functions to all def files
local setmetatable_orig = setmetatable
function setmetatable(t, mt)
	if type(mt.__index) == "table" then
		if (mt.__index.lowerkeys) then
			if (not sharedEnvMT) then
				sharedEnvMT = setmetatable_orig(sharedEnv, {
					__index     = mt.__index,
					__newindex  = function() error('Attempt to write to system') end,
					__metatable = function() error('Attempt to access system metatable') end
				})
				--Spring.Echo("foo", type(sharedEnv), type(sharedEnvMT))
			end
			local x = setmetatable_orig(t, { __index = sharedEnvMT })
			--Spring.Echo("bar", x.SharedDefFunc)
			return x
		end
	end
	return setmetatable_orig(t, mt)
end