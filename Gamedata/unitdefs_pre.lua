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
---------------------------------------------------------------------------------------------
-- Base Classes
---------------------------------------------------------------------------------------------
local Mech = Unit:New{
	upright				= true,
	canMove				= true,
	script				= "Mech.lua",	
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	activateWhenBuilt   = true,
	onoffable           = true,
	
	customparams = {
		hasturnbutton	= "1",
		unittype		= "mech",
    },
}

local Light = Mech:New{
	iconType			= "lightmech",
	footprintX			= 3,
	footprintZ 			= 3,
	movementClass		= "LARGEMECH",
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

---------------------------------------------------------------------------------------------
-- This is where the magic happens
local sharedEnv = {
	Unit = Unit,
	Mech = Mech,
	Light = Light,
	Medium = Medium,
	Heavy = Heavy,
	Assault = Assault,
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