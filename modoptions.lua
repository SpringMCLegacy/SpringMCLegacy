--  Custom Options Definition Table format

--  NOTES:
--  - using an enumerated table lets you specify the options order

--
--  These keywords must be lowercase for LuaParser to read them.
--
--  key:      the string used in the script.txt
--  name:     the displayed name
--  desc:     the description (could be used as a tooltip)
--  type:     the option type
--  def:      the default value;
--  min:      minimum value for number options
--  max:      maximum value for number options
--  step:     quantization step, aligned to the def value
--  maxlen:   the maximum string length for string options
--  items:    array of item strings for list options
--  scope:    "all", "player", "team", "allyteam"      <<< not supported yet >>>


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local options = {
	{
		key    = '2gamemode',
		name   = 'Gameplay Settings',
		desc   = 'Sets options regarding winning conditions',
		type   = 'section',
	},
	{
		key 	= "start_tickets",
		name 	= "Tickets",
		desc 	= "Ticket Controls",
		type   = "number",
		def    = 200,
		min    = 100,
		max    = 1000,
		section = '2gamemode',
		step   = 10,
	},
	{
		key 	= "vehicle_delay",
		name 	= "Vehicle Delay",
		desc 	= "Minimum delay between vehicle spoawns",
		type   	= "number",
		def    	= 45,
		min    	= 5,
		max    	= 300,
		section = '2gamemode',
		step   	= 5,
	},
		{
		key    = 'devtools',
		name   = 'Developer Tools',
		desc   = 'Sets options for tweaking balance',
		type   = 'section',
	},
	{
		key = "speed",
		name = "Test Speed Multipliers",
		desc = "Developer tool",
		type = "number",
		def = 0.75,
		min = 0.1,
		max = 100,
		section = "devtools",
	},
	{
		key = "torso",
		name = "Test Torso Rotation Multipliers",
		desc = "Developer tool",
		type = "number",
		def = 0.4,
		min = 0.1,
		max = 5.0,
		step = 0.1,
		section = "devtools",
	},
	{
		key = "turn",
		name = "Test Turnrate Multipliers",
		desc = "Developer tool",
		type = "number",
		def = 0.6,
		min = 0.1,
		max = 5.0,
		step = 0.1,
		section = "devtools",
	},
	{
		key = "mechsight",
		name = "Test Mech LOS Radius",
		desc = "Developer tool",
		type = "number",
		def = 300, --250,
		min = 10,
		max = 500,
		step = 50,
		section = "devtools",
	},
	{
		key = "sectorangle",
		name = "Test Mech Sector Angle",
		desc = "Developer tool",
		type = "number",
		def = 45,
		min = 5,
		max = 270,
		step = 5,
		section = "devtools",
	},
	{
		key = "radar",
		name = "Test Radar Radius Multiplier",
		desc = "Developer tool",
		type = "number",
		def = 1, --0.75,
		min = 0.1,
		max = 1.5,
		step = 0.1,
		section = "devtools",
	},
	{
		key    = '2income',
		name   = 'Income Settings',
		desc   = 'Sets options regarding income',
		type   = 'section',
	},
	{
		key		= "income",
		name		= "Income",
		desc		= "How many CBills per second?",
		type		= "number",
		def		= 50,
		min		= 1,
		max		= 1000,
		step	= 1,
		section	= '2income',
	},
	{
		key		= "income_damage",
		name	= "Damage Income (Multiplier)",
		desc	= "How many CBills per HP of damage?",
		type	= "number",
		def		= 1.0,
		min		= 0.1,
		max		= 10.0,
		step	= 0.1,
		section	= '2income',
	},
	{
		key		= "insurance",
		name	= "Insurance (Multiplier)",
		desc	= "How many CBills returned to owner when a mech dies",
		type	= "number",
		def		= 0.2,
		min		= 0.01,
		max		= 1.0,
		step	= 0.01,
		section	= '2income',
	},
	{
		key		= "sell",
		name	= "Selling Price (Multiplier)",
		desc	= "What proportion of CBills returned to owner when a mech is sold",
		type	= "number",
		def		= 0.75,
		min		= 0.05,
		max		= 1.0,
		step	= 0.05,
		section	= '2income',
	},
	{
		key		= "pricemult",
		name	= "Price Multiplier",
		desc	= "Dev tool for balancing costs",
		type	= "number",
		def		= 1.5,
		min		= 0.1,
		max		= 10.0,
		step	= 0.1,
		section	= '2income',
	},
	------------------------------------
	{
		key    = '2AI',
		name   = 'AI Settings',
		desc   = 'Sets options regarding income and winning conditions',
		type   = 'section',
	},	
	{
		key    = "ai_difficulty",
		name   = "SpamBot AI difficulty level",
		desc   = "Sets the difficulty level of the SpamBot.",
		type   = "list",
		section = "2AI",
		def    = "1",
		items = {
			{
				key = "1",
				name = "Regular",
				desc = "Random unit selection. No resource cheating."
			},
			{
				key = "2",
				name = "Banker",
				desc = "Random unit selection. C-Bill cheating."
			},
			{
				key = "3",
				name = "Athlete",
				desc = "Only jump mechs. C-Bill & Tonnage cheating."
			},
			{
				key = "4",
				name = "Direbolical",
				desc = "Only assault mechs. C-Bill & Tonnage cheating."
			},
		}
	},
}
return options
