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
      name		= "Income Modes",
      desc		= "How do you earn CBills?",
      type		= "list",
      def		= "default",
	  section	= '2gamemode',
      items = {
         {
		 key = "default",
		 name = "Dropship & Damage Income",
		 desc = "Income from your dropship and from damaging and killing enemy units" ,
		 },
		 {
		 key = "dropship",
		 name = "Dropship Income",
		 desc = "Income only from your dropship",
		 },
         {
		 key = "none",
		 name = "No Income",
		 desc = "Only a fixed starting sum to spend, no income, deathmatch style",
		 },
      },
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
