local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

buildoptions = 
{

        --------------------
        -- Clan Units --
        --------------------

  CL_Factory = 
  {
    "CL_Hephaestus",
	"CL_Ares",
	"CL_Enyo",
	"CL_Oro",
	"CL_Morrigu",
	"CL_Mars",
	"CL_Huit",
  },
}

return buildoptions
