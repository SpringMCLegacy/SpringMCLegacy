--pieces
local base = piece ("base")
local gate = piece ("gate")

local GATE_SPEED = 20
local GATE_HEIGHT = 45

function GateOpen(open)
	local dist = open and -GATE_HEIGHT or 0
	Move(gate, y_axis, dist, GATE_SPEED)
	WaitForMove(gate, y_axis)
	Spring.SetUnitBlocking(unitID, not open, not open, false)
end

function script.Activate()
	StartThread(GateOpen, false)
end

function script.Deactivate()
	StartThread(GateOpen, true)
end

function script.Killed(recentDamage, maxHealth)
end
