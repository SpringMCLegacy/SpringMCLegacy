local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

buildoptions = 
{

        --------------------
        -- Clan Units --
        --------------------

  cl_factory = 
  {
    "cl_hephaestus",
	"cl_ares",
	"cl_enyo",
	"cl_oro",
	"cl_morrigu",
	"cl_mars",
	"cl_huit",
  },
  is_factory = 
  {
    "is_harasser",
	"is_scorpion",
	"is_goblin",
	"is_demolisher",
	"is_challenger",
	"is_schrek",
	"is_lrmcarrier",
	"is_sniper",
	"is_locust",
  },
}

return buildoptions
