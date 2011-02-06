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
	"cl_oro_lbx",
	"cl_oro_hag",
	"cl_morrigu",
	"cl_mars",
	"cl_huit",
	"cl_firemoth",
	"cl_kitfox",
	"cl_stormcrow",
	"cl_timberwolf",
	"cl_maddog",
	"cl_warhawk",
	"cl_direwolf",
  },
  is_factory = 
  {
    "is_harasser",
	"is_scorpion_ac5",
	"is_scorpion_lgauss",
	"is_goblin",
	"is_demolisher",
	"is_challenger",
	"is_schrek",
	"is_lrmcarrier",
	"is_sniper",
	"is_locust",
	"is_owens",
	"is_chimera",
	"is_bushwacker",
	"is_catapult",
	"is_mauler",
	"is_atlas",
  },
}

return buildoptions
