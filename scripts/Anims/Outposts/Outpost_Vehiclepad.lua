-- Vehicle Pad pieces
local ramps = {}
local blinks = {}
for i = 1, 6 do
	ramps[i] = piece("ramp" .. i)
	blinks[i] = piece("blink" .. i)
end

local rad = math.rad

function Setup()
	for i = 1, 6 do
		Turn(ramps[i], y_axis, rad((i-1) * -60))
	end
end

function Deploy()
	for i = 1, 6 do
		Turn(ramps[i], x_axis, rad(-115), CRATE_SPEED)
	end
	WaitForTurn(ramps[6], x_axis)
	StartThread(Blinks)
	GG.LCLeft(nil, unitID, teamID) -- fake call, no dropship really left
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end

function Blinks()
	local i = 1
	while true do
		EmitSfx(blinks[i], SFX.CEG)
		Sleep(500)
		i = i + 1
		if i == 7 then i = 1 end
	end
end

local function CloseAnim(delay)
	for i = 1, 6 do
		Turn(ramps[i], x_axis, 0, CRATE_SPEED)
	end
	WaitForTurn(ramps[6], x_axis)
	Sleep(delay * 1000 / 30) -- convert frame-seconds to milliseconds
	for i = 1, 6 do
		Turn(ramps[i], x_axis, rad(-115), CRATE_SPEED)
	end
	WaitForTurn(ramps[6], x_axis)
end

function Close(delay)
	StartThread(CloseAnim, delay)
end