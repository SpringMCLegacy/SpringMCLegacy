-- Author: Tobi Vollebregt


-- effects
local SMOKEPUFF = 258

-- localize
local random = math.random


function SmokeUnit(smokePieces)
	local n = #smokePieces
	while (GetUnitValue(COB.BUILD_PERCENT_LEFT) ~= 0) do
		Sleep(1000)
	end
	while true do
		local health = GetUnitValue(COB.HEALTH)
		if (health <= 66) then -- only smoke if less then 2/3rd health left
			EmitSfx(smokePieces[random(1,n)], SMOKEPUFF)
		end
		Sleep(9*health + random(100,200))
	end
end
