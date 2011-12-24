local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

local RAMP_DISTANCE = 156 -- 206
local HANGAR_DISTANCE = 256

for name, ud in pairs(UnitDefs) do
	ud.shownanoframe = false
	local speed = (ud.maxvelocity or 0) * 30
	if speed > 0 then
		if ud.customparams.unittype == "mech" then
			ud.buildtime = RAMP_DISTANCE / speed
		elseif ud.canfly then
			ud.buildtime = HANGAR_DISTANCE / (speed * 0.5)
		end
	end
	ud.maxvelocity = (ud.maxvelocity or 0) * (modOptions.speed or 1)
	ud.maxreversevelocity = (ud.maxreversevelocity or 0) * (modOptions.speed or 1)
end
