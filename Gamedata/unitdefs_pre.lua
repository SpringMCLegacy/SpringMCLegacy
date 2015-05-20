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
	for k,v in pairs(p) do 
		if type(k) == "string" then
			k:lower() -- really we need to run lowerkeys() on both c and p
		end
		if type(v) == "table" then
			if c[k] == nil then c[k] = {} end
			inherit(c[k], v)
		else
			if concatNames and k == "name" then 
				c[k] = v .. " " .. (c[k] or "")
			else
				if c[k] == nil then c[k] = v end
			end
		end
	end
end

local Unit = {}
function Unit:New(newAttribs, concatName)
	local newClass = {}
	inherit(newClass, newAttribs)
	inherit(newClass, self, concatName)
	return newClass
end

local Weapon = {
	avoidFeature	= false,
	collideFeature	= true,
}
function Weapon:New(newAttribs, concatName)
	local newClass = {}
	inherit(newClass, newAttribs)
	inherit(newClass, self, concatName)
	return newClass
end
---------------------------------------------------------------------------------------------
-- Base Classes
---------------------------------------------------------------------------------------------

-- Mechs ----
local Mech = Unit:New{
	upright				= true,
	canMove				= true,
	script				= "Mech.lua",	
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	activateWhenBuilt   = true,
	onoffable           = true,
	usepiececollisionvolumes = true,
	
	customparams = {
		hasturnbutton	= "1",
		unittype		= "mech",
    },
}

local Light = Mech:New{
	iconType			= "lightmech",
	footprintX			= 1,
	footprintZ 			= 1,
	movementClass		= "SMALLMECH",
}

local Medium = Mech:New{
	iconType			= "mediummech",
	footprintX			= 2,
	footprintZ 			= 2,
	movementClass		= "SMALLMECH",
}

local Heavy = Mech:New{
	iconType			= "heavymech",
	footprintX			= 3,
	footprintZ 			= 3,
	movementClass		= "LARGEMECH",
}

local Assault = Mech:New{
	iconType			= "assaultmech",
	footprintX			= 3,
	footprintZ 			= 3,
	movementClass		= "LARGEMECH",
}

-- Vehicles ----
local Vehicle = Unit:New{
	iconType			= "vehicle",
	script				= "Vehicle.lua",
	activateWhenBuilt   = true,
	onoffable           = true,
	canMove 			= true,
	footprintX			= 3,-- current both TANK and HOVER movedefs are 2x2 even if unitdefs are not
	footprintZ 			= 3,
	moveState			= 0, -- Hold Position
	usepiececollisionvolumes = true,
	
	customparams = {
		unittype		= "vehicle",
    },
}

local Tank = Vehicle:New{
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	noChaseCategory		= "beacon air",
	movementClass   	= "TANK",
	leaveTracks			= true,
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
	
	customparams = {
		flagcaprate		= "0",
		flagdefendrate	= "0",
	}
}
	
local Aero = Aircraft:New{
	category 			= "aero air notbeacon",
	noChaseCategory		= "beacon ground",
	cruiseAlt			= 300,
	canLoopbackAttack 	= true,
}

local VTOL = Aircraft:New{
	category 			= "vtol air notbeacon",
	noChaseCategory		= "beacon air vtol",
	cruiseAlt			= 250,
	hoverAttack			= true,
	airHoverFactor		= -0.0001,
	
	customparams = {
		hasturnbutton	= "1",
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
		ignoreatbeacon	= true,
	},
}

---------------------------------------------------------------------------------------------
-- This is where the magic happens
local sharedEnv = {
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
	Tower = Tower,
	Upgrade = Upgrade,
	printTable = printTable,
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