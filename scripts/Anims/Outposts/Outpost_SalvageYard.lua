-- Salvage Yard pieces
mount = piece ("mount")
local foundation, recoveryrail, armature1, armature2 = piece ("foundation", "recoveryrail", "armature1", "armature2")
local supporttorchattach, supporttorchupper, supporttorchmid, supporttorchlower = piece ("supporttorchattach", "supporttorchupper", "supporttorchmid", "supporttorchlower")
local supporthandattach, supporthandupper, supporthandmid, supporthandlower, supporthandjoint, supporthandfingers1, supporthandfingers2 = piece ("supporthandattach", "supporthandupper", "supporthandmid", "supporthandlower", "supporthandjoint", "supporthandfingers1", "supporthandfingers2")
local doora1, doora2, doorb1, doorb2, doorc1, doorc2 = piece ("doora1", "doora2", "doorb1", "doorb2", "doorc1", "doorc2")
local doors = {}
for i = 1, 6 do
	doors[i] = piece("door" .. i)
end
local armPieces = {"armattach", "armjointa", "armextender", "armjointb", "saw"}
local arms = {}
for i, pieceType in ipairs(armPieces) do
	arms[pieceType] = {}
end
for i = 1, 6 do
	for j, pieceType in ipairs(armPieces) do
		arms[pieceType][i] = piece(pieceType .. i)
	end
end

local rad = math.rad

function Setup()
	Hide(foundation)
	--RecursiveHide(recoveryrail, true)
	Move(armature1, z_axis, 10)
	Move(armature2, z_axis, -10)
end

local function RecoverAnim(tons)
	--Spring.Echo("yoooooo, turn that shit upside down brah!")
	Turn(mount, x_axis, -math.rad(90), math.rad(10))
	WaitForTurn(mount, x_axis)
	for n = 0, 100 do
		Spring.SetUnitRulesParam(unitID, "recover", n)
		Sleep(tons * 10) -- 1% x tons x 1000ms
		--Spring.Echo("Recovery:", n, "%")
	end
	--Spring.Echo("Shazam I am done")
	GG.YardNotifyDone(unitID, teamID, mount)
	Spring.SetUnitRulesParam(unitID, "recover", nil)
end

function Recover(tons)
	--Spring.Echo("yoooooo, recover me brah!")
	StartThread(RecoverAnim, tons)
end

function Deploy()
	--GG.SpawnSalvager(unitID, teamID)
	Show(foundation)
	Move(armature1, z_axis, 0, CRATE_SPEED * 2)
	Move(armature2, z_axis, 0, CRATE_SPEED * 2)
	WaitForMove(armature2, z_axis)
	--GG.PopulateQueue(unitID) -- initialise the queue with any existing corpses
	Spring.SetUnitBlocking(unitID, false, false) -- make it easy to get out
	for i = 1, 6 do
		local sign = i % 2 == 0 and -1 or 1
		Move(doors[i], z_axis, sign, CRATE_SPEED * 2)
	end
	WaitForMove(doors[6], z_axis)
	for i = 1, 6 do
		local sign = i % 2 == 1 and -1 or 1
		Turn(arms["armjointa"][i], z_axis, sign * rad(-45), CRATE_SPEED * 2)
		Turn(arms["armjointb"][i], z_axis, sign * rad(220), CRATE_SPEED * 2)
	end
	Turn(supporthandupper, z_axis, rad(45), CRATE_SPEED * 2)
	Turn(supporthandlower, z_axis, rad(-45), CRATE_SPEED * 2)
	Turn(supporttorchupper, z_axis, rad(-45), CRATE_SPEED * 2)
	Turn(supporttorchlower, z_axis, rad(45), CRATE_SPEED * 2)
	WaitForTurn(arms["armjointb"][6], z_axis)
	Turn(arms["armattach"][1], x_axis, rad(-30), CRATE_SPEED * 2)
	Turn(arms["armattach"][3], x_axis, rad(10), CRATE_SPEED * 2)
	Move(arms["armextender"][3], y_axis, 2, CRATE_SPEED * 2)
	Turn(arms["armattach"][2], x_axis, rad(10), CRATE_SPEED * 2)
	Move(arms["armextender"][2], y_axis, 2, CRATE_SPEED * 2)
	Turn(arms["armattach"][5], x_axis, rad(-20), CRATE_SPEED * 2)
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end

function Upgrade2()
	Show(foundation)
	RecursiveHide(recoveryrail, false)
end