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
	"is_locust",
	"cl_firemoth",
	"cl_kitfox",
	"is_owens",
	"is_chimera",
	"cl_stormcrow",
	"cl_timberwolf",
	"cl_maddog",
	"is_mauler",
	"cl_warhawk",
	"is_atlas",
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
	"cl_firemoth",
	"cl_kitfox",
	"is_owens",
	"is_chimera",
	"cl_stormcrow",
	"cl_timberwolf",
	"cl_maddog",
	"is_mauler",
	"cl_warhawk",
	"is_atlas",
	"cl_direwolf",
  },
}

return buildoptions
