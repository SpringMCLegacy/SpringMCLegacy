local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

local RAMP_DISTANCE = 206

for name, ud in pairs(UnitDefs) do
	ud.shownanoframe = false
	if ud.customparams.unittype == "mech" then
		local speed = (ud.maxvelocity or 0) * 30
		if speed > 0 then
			ud.buildtime = RAMP_DISTANCE / speed
		end
	end
	ud.maxvelocity = (ud.maxvelocity or 0) * (modOptions.speed or 1)
	ud.maxreversevelocity = (ud.maxreversevelocity or 0) * (modOptions.speed or 1)
end
