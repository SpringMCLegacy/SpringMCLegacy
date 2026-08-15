-- Mechbay pieces
local rampr, rampl, ramprfoldrear, ramprfoldfront, ramplfoldrear, ramplfoldfront = piece ("rampr", "rampl", "ramprfoldrear", "ramprfoldfront", "ramplfoldrear", "ramplfoldfront")
local supportrlower, supportllower, supportrupper, supportlupper = piece ("supportrlower", "supportllower", "supportrupper", "supportlupper")
local ramprtoolupper, ramprtoolmid, ramprtoollower, ramprtoolfinger1, ramprtoolfinger2 = piece ("ramprtoolupper", "ramprtoolmid", "ramprtoollower", "ramprtoolfinger1", "ramprtoolfinger2")
local rampltoolupper, rampltoolmid, rampltoollower, rampltoolfinger1, rampltoolfinger2 = piece ("rampltoolupper", "rampltoolmid", "rampltoollower", "rampltoolfinger1", "rampltoolfinger2")
local supportrtorchattach, supportrtorchupper, supportrtorchmid, supportrtorchlower = piece ("supportrtorchattach", "supportrtorchupper", "supportrtorchmid", "supportrtorchlower")
local supportrhandattach, supportrhandupper, supportrhandmid, supportrhandlower, supportrhandjoint, supportrhandfingers1, supportrhandfingers2 = piece ("supportrhandattach", "supportrhandupper", "supportrhandmid", "supportrhandlower", "supportrhandjoint", "supportrhandfingers1", "supportrhandfingers2")
local supportltorchattach, supportltorchupper, supportltorchmid, supportltorchlower = piece ("supportltorchattach", "supportltorchupper", "supportltorchmid", "supportltorchlower")
local supportlhandattach, supportlhandupper, supportlhandmid, supportlhandlower, supportlhandjoint, supportlhandfingers1, supportlhandfingers2 = piece ("supportlhandattach", "supportlhandupper", "supportlhandmid", "supportlhandlower", "supportlhandjoint", "supportlhandfingers1", "supportlhandfingers2")
local supportltorchspark, supportrtorchspark = piece ("supportltorchspark", "supportrtorchspark")
local ramprtoolspark, rampltoolspark = piece ("ramprtoolspark", "rampltoolspark")

-- Constants
local BAY_RESTORE = 5000 -- 5 seconds
local UNLOAD_X, UNLOAD_Z

-- Variables
local bayReady = false
local rad = math.rad

function Deploy()
	Spring.SetUnitBlocking(unitID, false, false) -- make it easy to get out
	MechBayOpen()
	local x, _ ,z = Spring.GetUnitPosition(unitID)
	local heading = Spring.GetUnitHeading(unitID)
	local dx, dz = Spring.GetVectorFromHeading(heading)
	UNLOAD_X = (x + 150 * dx) or 0
	UNLOAD_Z = (z + 150 * dz) or 0
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end


function MechBayOpen()
	Move(rampr, x_axis, 10, CRATE_SPEED * 10)
	Move(ramprtoolupper, x_axis, 5, CRATE_SPEED * 5)
	Move(rampl, x_axis, -10, CRATE_SPEED * 10)
	Move(rampltoolupper, x_axis, -5, CRATE_SPEED * 5)
	Sleep(100)
	Turn(ramprtoolupper, x_axis, rad(90), CRATE_SPEED)
	Turn(rampltoolupper, x_axis, rad(-90), CRATE_SPEED)
	Turn(ramprtoolmid, z_axis, rad(-70), CRATE_SPEED)
	Turn(rampltoolmid, z_axis, rad(70), CRATE_SPEED)
	Turn(ramprtoollower, x_axis, rad(-90), CRATE_SPEED)
	Turn(rampltoollower, x_axis, rad(90), CRATE_SPEED)
	Turn(ramprtoolfinger1, y_axis, rad(-45), CRATE_SPEED)
	Turn(ramprtoolfinger2, y_axis, rad(45), CRATE_SPEED)
	Turn(rampltoolfinger1, y_axis, rad(-30), CRATE_SPEED)
	Turn(rampltoolfinger2, y_axis, rad(30), CRATE_SPEED)
	Move(supportrupper, y_axis, 22, CRATE_SPEED * 10)
	Move(supportlupper, y_axis, 22, CRATE_SPEED * 10)
	Sleep(100)
	Turn(ramplfoldfront, x_axis, rad(179), CRATE_SPEED)
	Turn(ramprfoldfront, x_axis, rad(179), CRATE_SPEED)
	Turn(ramplfoldrear, x_axis, rad(-179), CRATE_SPEED)
	Turn(ramprfoldrear, x_axis, rad(-179), CRATE_SPEED)
	WaitForTurn(ramprfoldrear, x_axis)
	bayReady = true
end

function MechBayRepair()
	SetSignalMask(1)
	while true do
		PlaySound("MechbayWorking")
		--ramptools
		Turn(ramprtoolmid, z_axis, rad(-70), CRATE_SPEED * 5)
		Turn(rampltoolmid, z_axis, rad(70), CRATE_SPEED * 5)
		--r torch
		Move(supportrtorchattach, z_axis, 5, CRATE_SPEED * 5)
		Move(supportrtorchupper, z_axis, 0, CRATE_SPEED* 5)
		Move(supportrtorchmid, y_axis, 0, CRATE_SPEED* 5)
		Turn(supportrtorchattach, z_axis, rad(45), CRATE_SPEED * 5)
		Turn(supportrtorchupper, y_axis, rad(-10), CRATE_SPEED * 5)
		Turn(supportrtorchlower, z_axis, rad(-90), CRATE_SPEED * 5)
		--l torch
		Move(supportltorchattach, z_axis, 5, CRATE_SPEED * 5)
		Move(supportltorchupper, z_axis, 0, CRATE_SPEED* 5)
		Move(supportltorchmid, y_axis, 0, CRATE_SPEED* 5)
		Turn(supportltorchattach, z_axis, rad(-45), CRATE_SPEED * 5)
		Turn(supportltorchupper, y_axis, rad(10), CRATE_SPEED * 5)
		Turn(supportltorchlower, z_axis, rad(90), CRATE_SPEED * 5)
		--r hand
		Move(supportrhandattach, z_axis, -3, CRATE_SPEED * 5)
		Turn(supportrhandupper, z_axis, rad(35), CRATE_SPEED * 5)
		Turn(supportrhandlower, z_axis, rad(-90), CRATE_SPEED * 5)
		Move(supportrhandfingers1, z_axis, -1, CRATE_SPEED * 5)
		Move(supportrhandfingers2, z_axis, 1, CRATE_SPEED * 5)
		--l hand
		Move(supportlhandattach, z_axis, -3, CRATE_SPEED * 5)
		Turn(supportlhandupper, z_axis, rad(-35), CRATE_SPEED * 5)
		Turn(supportlhandlower, z_axis, rad(90), CRATE_SPEED * 5)
		Move(supportlhandfingers1, z_axis, -1, CRATE_SPEED * 5)
		Move(supportlhandfingers2, z_axis, 1, CRATE_SPEED * 5)
		WaitForMove(supportlhandattach, z_axis)
		PlaySound("MechbayWelding")
		for i = 1, 10 do
			GG.EmitSfxName(unitID, supportltorchspark, "sparks")
			GG.EmitSfxName(unitID, supportrtorchspark, "sparks")
			GG.EmitSfxName(unitID, ramprtoolspark, "sparks")
			GG.EmitSfxName(unitID, rampltoolspark, "sparks")
			Sleep(100)
		end
		PlaySound("MechbayWorking")
		Turn(ramprtoolmid, z_axis, rad(-50), CRATE_SPEED * 5)
		Turn(rampltoolmid, z_axis, rad(30), CRATE_SPEED * 5)
		--r torch
		Move(supportrtorchattach, z_axis, 0, CRATE_SPEED* 5)
		Move(supportrtorchupper, z_axis, 3, CRATE_SPEED* 5)
		Turn(supportrtorchupper, y_axis, rad(20), CRATE_SPEED * 5)
		Turn(supportrtorchlower, z_axis, rad(-120), CRATE_SPEED * 5)
		--l torch
		Move(supportltorchattach, z_axis, 0, CRATE_SPEED* 5)
		Move(supportltorchupper, z_axis, 3, CRATE_SPEED* 5)
		Turn(supportltorchupper, y_axis, rad(20), CRATE_SPEED * 5)
		Turn(supportltorchlower, z_axis, rad(120), CRATE_SPEED * 5)
		--r hand
		Move(supportrhandattach, z_axis, 7, CRATE_SPEED * 5)
		Turn(supportrhandupper, z_axis, rad(50), CRATE_SPEED * 5)
		Turn(supportrhandlower, z_axis, rad(-120), CRATE_SPEED * 5)
		Turn(supportrhandjoint, y_axis, rad(0), CRATE_SPEED * 5)
		Move(supportrhandfingers1, z_axis, 0, CRATE_SPEED * 5)
		Move(supportrhandfingers2, z_axis, 0, CRATE_SPEED * 5)
		-- l hand
		Move(supportlhandattach, z_axis, 7, CRATE_SPEED * 5)
		Turn(supportlhandupper, z_axis, rad(-50), CRATE_SPEED * 5)
		Turn(supportlhandlower, z_axis, rad(120), CRATE_SPEED * 5)
		Turn(supportlhandjoint, y_axis, rad(0), CRATE_SPEED * 5)
		Move(supportlhandfingers1, z_axis, 0, CRATE_SPEED * 5)
		Move(supportlhandfingers2, z_axis, 0, CRATE_SPEED * 5)
		WaitForMove(supportlhandattach, z_axis)
		PlaySound("MechbayWelding")
		for i = 1, 10 do
			GG.EmitSfxName(unitID, supportltorchspark, "sparks")
			GG.EmitSfxName(unitID, supportrtorchspark, "sparks")
			GG.EmitSfxName(unitID, ramprtoolspark, "sparks")
			GG.EmitSfxName(unitID, rampltoolspark, "sparks")
			Sleep(100)
		end
		PlaySound("MechbayWorking")
		Turn(ramprtoolmid, z_axis, rad(-90), CRATE_SPEED * 5)
		Turn(rampltoolmid, z_axis, rad(10), CRATE_SPEED * 5)
		--r torch
		Move(supportrtorchattach, z_axis, -4, CRATE_SPEED * 5)
		Move(supportrtorchupper, z_axis, 2, CRATE_SPEED* 5)
		Move(supportrtorchmid, y_axis, -5, CRATE_SPEED* 5)
		Turn(supportrtorchattach, z_axis, rad(30), CRATE_SPEED * 5)
		Turn(supportrtorchupper, y_axis, rad(20), CRATE_SPEED * 5)
		Turn(supportrtorchlower, z_axis, rad(-110), CRATE_SPEED * 5)
		WaitForMove(supportrtorchattach, z_axis)
		--l torch
		Move(supportltorchattach, z_axis, -4, CRATE_SPEED * 5)
		Move(supportltorchupper, z_axis, 2, CRATE_SPEED* 5)
		Move(supportltorchmid, y_axis, -5, CRATE_SPEED* 5)
		Turn(supportltorchattach, z_axis, rad(-30), CRATE_SPEED * 5)
		Turn(supportltorchupper, y_axis, rad(10), CRATE_SPEED * 5)
		Turn(supportltorchlower, z_axis, rad(110), CRATE_SPEED * 5)
		--r hand
		Move(supportrhandattach, z_axis, 0, CRATE_SPEED * 5)
		Turn(supportrhandupper, z_axis, rad(50), CRATE_SPEED * 5)
		Turn(supportrhandlower, z_axis, rad(-40), CRATE_SPEED * 5)
		Turn(supportrhandjoint, y_axis, rad(90), CRATE_SPEED * 5)
		Move(supportrhandfingers1, z_axis, 1, CRATE_SPEED * 5)
		Move(supportrhandfingers2, z_axis, -1, CRATE_SPEED * 5)
		--l hand
		Move(supportlhandattach, z_axis, 0, CRATE_SPEED * 5)
		Turn(supportlhandupper, z_axis, rad(-50), CRATE_SPEED * 5)
		Turn(supportlhandlower, z_axis, rad(40), CRATE_SPEED * 5)
		Turn(supportlhandjoint, y_axis, rad(-90), CRATE_SPEED * 5)
		Move(supportlhandfingers1, z_axis, 1, CRATE_SPEED * 5)
		Move(supportlhandfingers2, z_axis, -1, CRATE_SPEED * 5)
		WaitForMove(supportlhandattach, z_axis)
		PlaySound("MechbayWelding")
		for i = 1, 10 do
			GG.EmitSfxName(unitID, supportltorchspark, "sparks")
			GG.EmitSfxName(unitID, supportrtorchspark, "sparks")
			GG.EmitSfxName(unitID, ramprtoolspark, "sparks")
			GG.EmitSfxName(unitID, rampltoolspark, "sparks")
			Sleep(100)
		end
	end
end

function MechBayClose()
	bayReady = false
	script.TransportDrop()
	Signal(BAY_RESTORE)
	SetSignalMask(BAY_RESTORE)
	Turn(ramplfoldfront, x_axis, 0, CRATE_SPEED)
	Turn(ramprfoldfront, x_axis, 0, CRATE_SPEED)
	Turn(ramplfoldrear, x_axis, 0, CRATE_SPEED)
	Turn(ramprfoldrear, x_axis, 0, CRATE_SPEED)
	Sleep(100)
	Turn(ramprtoolupper, x_axis, 0, CRATE_SPEED)
	Turn(rampltoolupper, x_axis, 0, CRATE_SPEED)
	Turn(ramprtoolmid, z_axis, 0, CRATE_SPEED)
	Turn(rampltoolmid, z_axis, 0, CRATE_SPEED)
	Turn(ramprtoollower, x_axis, 0, CRATE_SPEED)
	Turn(rampltoollower, x_axis, 0, CRATE_SPEED)
	Turn(ramprtoolfinger1, y_axis, 0, CRATE_SPEED)
	Turn(ramprtoolfinger2, y_axis, 0, CRATE_SPEED)
	Turn(rampltoolfinger1, y_axis, 0, CRATE_SPEED)
	Turn(rampltoolfinger2, y_axis, 0, CRATE_SPEED)
	Move(supportrupper, y_axis, 0, CRATE_SPEED * 10)
	Move(supportlupper, y_axis, 0, CRATE_SPEED * 10)
	Sleep(100)	
	Move(rampr, x_axis, 0, CRATE_SPEED * 10)
	Move(ramprtoolupper, x_axis, 0, CRATE_SPEED * 5)
	Move(rampl, x_axis, 0, CRATE_SPEED * 10)
	Move(rampltoolupper, x_axis, 0, CRATE_SPEED * 5)	
	WaitForMove(rampr, x_axis)
	Sleep(BAY_RESTORE)
	MechBayOpen()
end

function script.HitByWeapon()
	StartThread(MechBayClose)
end

-- Localisations
local GetUnitDefID	= Spring.GetUnitDefID
local GetUnitHealth	= Spring.GetUnitHealth
local SetUnitHealth	= Spring.SetUnitHealth
-- Constants
local REPAIR_RATE = 0.05
local LIMB_REPAIR_RATE = REPAIR_RATE
-- Variables
local passengerDefID
local passengerInfo
local passengerEnv

local repaired = false
local resupplied = false
local restored = false

local restoredLimbs = {}
local suppliedAmmos = {}

autoGetOut = true

local SIG_EXIT = 1

function Repair(passengerID)
	SetSignalMask(SIG_EXIT)
	StartThread(MechBayRepair)
	local curHP, maxHP = GetUnitHealth(passengerID)
	while curHP ~= maxHP do
		local newHP = math.min(curHP + maxHP * REPAIR_RATE, maxHP)
		SetUnitHealth(passengerID, newHP)
		--curHP, maxHP = GetUnitHealth(passengerID)
		curHP, maxHP = GetUnitHealth(passengerID)
		Sleep(1000)
	end
	repaired = true
	if autoGetOut and resupplied and restored then -- I'm the last task to finish, move out!
		Sleep(5000) -- always wait 5 seconds before shoving the mech out
		if autoGetOut then script.TransportDrop(passengerID) end -- check again
	end
end


function RestoreLimb(passengerID, limb, maxHP)
	restoredLimbs[limb] = false -- so the loop has something to go over
	local curHP = passengerEnv.limbHPControl(limb, 0)
	while curHP ~= maxHP do
		curHP = passengerEnv.limbHPControl(limb, -maxHP * LIMB_REPAIR_RATE)
		Sleep(1000)
	end
	restoredLimbs[limb] = true
end

function Restore(passengerID)
	SetSignalMask(SIG_EXIT)
	local limbHPs = passengerInfo.limbHPs
	if passengerEnv.limbHPControl then -- N.B. currently this runs for all mechs
		for limb, maxHP in pairs(limbHPs) do
			restoredLimbs[limb] = false
			StartThread(RestoreLimb, passengerID, limb, maxHP)
		end
	end
	while not restored do
		local allDone = true
		for limb, done in pairs(restoredLimbs) do
			allDone = allDone and done
		end
		restored = allDone
		Sleep(1000)
	end
	if autoGetOut and repaired and resupplied then -- I'm the last task to finish, move out!
		Sleep(5000) -- always wait 5 seconds before shoving the mech out
		if autoGetOut then script.TransportDrop(passengerID) end -- check again
	end	
end

function ResupplyAmmoType(passengerID, weaponNum, ammoType)
	if ammoType then
		suppliedAmmos[ammoType] = false -- so the loop has something to go over
		local moreToDo = true
		while moreToDo do
			local amount = passengerInfo.burstLengths[weaponNum] or 1
			local tookSome = passengerEnv.ChangeAmmo(ammoType, amount)
			--if tookSome then Spring.Echo("Deduct " .. amount .. " " .. ammoType) end
			moreToDo = moreToDo and tookSome
			Sleep(1000)
		end
		suppliedAmmos[ammoType] = true
	end
end

function Resupply(passengerID)
	SetSignalMask(SIG_EXIT)
	local ammoTypes = passengerInfo.ammoTypes
	if passengerEnv.ChangeAmmo then
		for weaponNum, ammoType in pairs(ammoTypes) do
			StartThread(ResupplyAmmoType, passengerID, weaponNum, ammoType)
		end
	end
	while not resupplied do
		local allDone = true
		for ammoType, done in pairs(suppliedAmmos) do
			allDone = allDone and done
		end
		resupplied = allDone
		Sleep(1000)
	end
	if autoGetOut and repaired and restored then -- I'm the last task to finish, move out!
		Sleep(5000) -- always wait 5 seconds before shoving the mech out
		if autoGetOut then script.TransportDrop(passengerID) end -- check again
	end	
end

function script.TransportPickup (passengerID)
	if crateID and crateID == passengerID then return end
	if bayReady then
		repaired = false
		resupplied = false
		restored = false
		passengerDefID = GetUnitDefID(passengerID)
		passengerInfo = GG.lusHelper[passengerDefID]
		passengerEnv = Spring.UnitScript.GetScriptEnv(passengerID)
		if passengerEnv then
			Spring.UnitScript.CallAsUnit(passengerID, passengerEnv.script.StopMoving)
		end
		-- TODO: pickup animation
		Spring.UnitScript.AttachUnit(base, passengerID)
		bayReady = false
		StartThread(Repair, passengerID)
		StartThread(Resupply, passengerID)
		StartThread(Restore, passengerID)
	end
end

function script.TransportDrop (passengerID, x, y, z)
	if crateID and crateID == passengerID then return end
	local isTransporting = Spring.GetUnitIsTransporting(unitID)
	if isTransporting and #isTransporting > 0 then
		Signal(1) -- kill repair anim & threads
		passengerID = passengerID or isTransporting[1]
		if passengerID and Spring.ValidUnitID(passengerID) and not Spring.GetUnitIsDead(passengerID) then
			Spring.UnitScript.DropUnit(passengerID)
			Spring.SetUnitMoveGoal(passengerID, UNLOAD_X, 0, UNLOAD_Z, 50) -- bug out over here
		end
		-- reset states
		bayReady = true
		repaired = false
		resupplied = false
		restored = false
	end
	autoGetOut = true
end