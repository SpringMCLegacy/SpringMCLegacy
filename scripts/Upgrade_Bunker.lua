--pieces
local base = piece ("base")

local crate_base, crate_top, crate_right, crate_left, crate_front, crate_back = piece("crate_base", "crate_top", "crate_right", "crate_left", "crate_front", "crate_back")

-- includes

function script.Create()
end

function Unpack()
	-- TODO: Unpack anim goes here!
	-- TODO: Don't forget to Move(crate_base, y_axis, -SOME_NUMBER, SOME_SLOW_SPEED) :)
end

function script.Killed(recentDamage, maxHealth)
end
