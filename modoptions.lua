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
	desc   = 'Sets options regarding income and winning conditions',
	type   = 'section',
  },
	
	
	{
      key		= "income",
      name		= "Income",
      desc		= "How many CBills per second?",
      type		= "number",
      def		= 100,
	  min		= 50,
	  max		= 1000,
	  step		= 50,
	  section	= '2gamemode',
	},
	{
		key		= "income_damage",
		name	= "Damage Income (Multiplier)",
		desc	= "How many CBills per HP of damage?",
		type	= "number",
		def		= 0.2,
		min		= 0.1,
		max		= 10.0,
		step	= 0.1,
		section	= '2gamemode',
	},
	{
		key = "start_tickets",
		name = "Tickets",
		desc = "Ticket Controls",
		type   = "number",
		def    = 200,
		min    = 100,
		max    = 1000,
		section = '2gamemode',
		step   = 10,
	},
	{
		key = "speed",
		name = "Test Speed Multipliers",
		desc = "Developer tool",
		type = "number",
		def = 1,
		min = 0.1,
		max = 100,
		section = "2gamemode",
	},
 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
}
return options
