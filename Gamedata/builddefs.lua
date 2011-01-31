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
}

return buildoptions
