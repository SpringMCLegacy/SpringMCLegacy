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
	name   = 'Income Settings',
	desc   = 'Sets options regarding Income modes',
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
		 name = "Dropship & Beacon & Damage Income",
		 desc = "Income from your dropship, damaging enemy units and capturing beacons",
		 },
         {
		 key = "damageonly",
		 name = "Dropship & Damage Income Only",
		 desc = "Income from your dropship and from damaging and killing enemy units" ,
		 },
         {
		 key = "none",
		 name = "No Income",
		 desc = "Only a fixed starting sum to spend, no income, deathmatch style",
		 },
      },
   },
 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
}
return options
