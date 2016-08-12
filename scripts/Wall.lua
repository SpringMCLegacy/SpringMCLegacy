-- Common pieces
local base = piece ("base")

function ChangeType(upgrade)
	if upgrade then
		stage = -1
		Spring.SetUnitNoDraw(unitID, true)
	else
		Spring.SetUnitNoDraw(unitID, false)
		stage = 0
		--StartThread(fx)
	end
end

function script.Killed(recentDamage, maxHealth)
end
