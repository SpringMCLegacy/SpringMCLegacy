local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

buildoptions = 
{

        --------------------
        -- Clan Units --
        --------------------

  cl_dropship = 
	{
    --"cl_hephaestus",
	--"cl_enyo",
	--"cl_oro_lbx",
	--"cl_ares",
	--"cl_oro_hag",
	--"cl_morrigu",
	--"cl_mars",
	--"cl_huit",
	"cl_firemoth",
	"cl_kitfox",
	"cl_cougar",
	"cl_mistlynx",
	"cl_iceferret",
	"cl_nova",
	"cl_stormcrow",
	"cl_summoner",
	"cl_timberwolf",
	"cl_hellbringer",
	"cl_maddog",
	"cl_warhawk",
	"cl_direwolf",
  },
  is_dropship = 
  {
    --"is_harasser",
	--"is_scorpion_ac5",
	--"is_scorpion_lgauss",
	--"is_goblin",
	--"is_schrek",
	--"is_demolisher",
	--"is_challenger",
	--"is_lrmcarrier",
	--"is_sniper",
	"is_locust",
	"is_osiris",
	"is_wolfhound",
	"is_owens",
	"is_raven",
	"is_chimera",
	"is_bushwacker",
	"is_hollander",
	"is_orion",
	"is_warhammer",
	"is_catapult",
	"is_awesome",
	"is_devastator",
	"is_atlas",
  },
  outpost_vehicledepot = 
  {
	"is_harasser",
	"is_scorpion_ac5",
	--"is_scorpion_lgauss",
	"is_goblin",
	"is_schrek",
	"is_demolisher",
	"is_challenger",
	"is_lrmcarrier",
	"is_sniper",
	"cl_hephaestus",
	"cl_enyo",
	"cl_oro_lbx",
	"cl_ares",
	"cl_oro_hag",
	"cl_morrigu",
	"cl_mars",
	"cl_huit",
  },
}

return buildoptions
