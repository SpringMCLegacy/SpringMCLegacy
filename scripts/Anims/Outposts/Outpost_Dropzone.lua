-- Dropzone pieces
local blinks = {}
for i = 1, 12 do
	blinks[i] = piece("blink_" .. i)
end

function Setup()
	local i = 1
	Spring.SetUnitBlocking(unitID, false, false, false, --[[true]]false, false, false, true)
	Spring.SetFactoryBuggerOff(unitID, true, 0, 200)
	while true do
		EmitSfx(blinks[i], SFX.CEG)
		Sleep(500)
		i = i + 1
		if i == 13 then i = 1 end
	end
end

function ClearTheDeck(yes)
	Spring.UnitScript.SetUnitValue(COB.BUGGER_OFF, yes)
end