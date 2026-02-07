-- Common pieces
local base = piece ("base")

function ChangeType(outpost)
	if outpost then
		stage = -1
		Spring.SetUnitNoDraw(unitID, true)
		--Spring.SetUnitBlocking(unitID, false, false, false, false, false, false, false)
		Spring.SetUnitNoSelect(unitID, true)
	else
		Spring.SetUnitNoDraw(unitID, false)
		--Spring.SetUnitBlocking(unitID, false, false, false, true, false, false, false)
		Spring.SetUnitNoSelect(unitID, false)
		stage = 0
	end
end

function script.Create()
	if unitDef.name == "mine" then
		local TIME_TO_LIVE = 300
		local VARIATION = math.floor(TIME_TO_LIVE/30)
		TIME_TO_LIVE = TIME_TO_LIVE + math.random(-VARIATION, VARIATION)
		GG.Delay.DelayCall(Spring.DestroyUnit, {unitID, false, true}, TIME_TO_LIVE * 30)
	elseif unitDef.name == "beacon_point" then
		Spring.SetUnitBlocking(unitID, false, false, false, false, false, false, false)
	end
end

function script.Killed(recentDamage, maxHealth)
end
