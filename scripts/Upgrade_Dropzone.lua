--pieces
local base = piece ("base")
local blinks = {}
for i = 1, 12 do
	blinks[i] = piece("blink_" .. i)
end

function script.Create()
	local i = 1
	Spring.SetUnitBlocking(unitID, false, false, false, --[[true]]false, false, false, true)
	while true do
		EmitSfx(blinks[i], SFX.CEG)
		Sleep(500)
		i = i + 1
		if i == 13 then i = 1 end
	end
end

function script.Killed(recentDamage, maxHealth)
	Spring.Echo("I wanna die, die in the summertime")
	return 1
end
