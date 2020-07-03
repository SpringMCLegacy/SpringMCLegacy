--piece defines
-- NB. local here means main script can't read them, may want to change that for e.g. Killed (or put Killed in here for per-unit death anims! But then other pieces need to be none-local)
local pelvis, torso, lupperleg, llowerleg, rupperleg, rlowerleg, lfoot, rfoot = piece ("pelvis", "torso", "lupperleg", "llowerleg", "rupperleg", "rlowerleg", "lfoot", "rfoot")
local rupperarm, lupperarm = piece ("rupperarm", "lupperarm")

--Turning/Movement Locals
local LEG_SPEED = rad(300) 
local LEG_TURN_SPEED = rad (300) 

function anim_Turn(clockwise)
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
	while true do
--		Spring.Echo("anim_Turn")
		--Left Leg Up...
		Turn(pelvis, z_axis, rad(2.5), LEG_TURN_SPEED * speedMod/ 2)
		Turn(lupperleg, x_axis, rad(-40), LEG_TURN_SPEED * speedMod/ 1.5)
		Turn(llowerleg, x_axis, rad(60), LEG_TURN_SPEED)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		--Left Leg Down...
		Turn(pelvis, z_axis, rad(0), LEG_TURN_SPEED)
		Turn(lupperleg, x_axis, rad(0), LEG_TURN_SPEED * speedMod/ 1.5)
		Turn(llowerleg, x_axis, rad(0), LEG_TURN_SPEED)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		PlaySound("stomp")
		--Right Leg Up...
		Turn(pelvis, z_axis, rad(-2.5), LEG_TURN_SPEED * speedMod/ 2)
		Turn(rupperleg, x_axis, rad(-40), LEG_TURN_SPEED * speedMod/ 1.5)
		Turn(rlowerleg, x_axis, rad(60), LEG_TURN_SPEED)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		--Right Leg Down...
		Turn(pelvis, z_axis, rad(0), LEG_TURN_SPEED * speedMod/ 2)
		Turn(rupperleg, x_axis, rad(0), LEG_TURN_SPEED * speedMod/ 1.5)
		Turn(rlowerleg, x_axis, rad(0), LEG_TURN_SPEED)
		--Wait for turns
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		PlaySound("stomp")
	end
end

function anim_PreJump()
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
--	Spring.Echo("anim_PreJump")
	anim_Reset()
		--Crouch...
		Turn(rupperleg, x_axis, rad(-30), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(60), LEG_SPEED * speedMod* 2)
		Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(60), LEG_SPEED * speedMod* 2)
		Move(pelvis, y_axis, -4, LEG_SPEED * speedMod* 8)
		Move(pelvis, z_axis, -3.3, LEG_SPEED * speedMod* 8)
		Turn(rupperarm, x_axis, rad(-20), LEG_SPEED)
		Turn(lupperarm, x_axis, rad(-20), LEG_SPEED)
		--Hold a bit...
		--Sleep(100)
		--Wait for turns...
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
--	Spring.Echo("anim_PreJump Completed")
end

function anim_StartJump()
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
--	Spring.Echo("anim_StartJump")
		--Jump!
		Turn(rupperleg, x_axis, rad(5), LEG_SPEED * speedMod* 4)
		Turn(rlowerleg, x_axis, rad(20), LEG_SPEED * speedMod* 4)
		Turn(lupperleg, x_axis, rad(5), LEG_SPEED * speedMod* 4)
		Turn(llowerleg, x_axis, rad(20), LEG_SPEED * speedMod* 4)
		Turn(rupperarm, x_axis, rad(20), LEG_SPEED * speedMod* 4)
		Turn(lupperarm, x_axis, rad(20), LEG_SPEED * speedMod* 4)
		Move(pelvis, y_axis, 0, LEG_SPEED * speedMod* 4)
		Move(pelvis, z_axis, 0, LEG_SPEED * speedMod* 4)
		--Wait for turns...
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
--	Spring.Echo("anim_StartJump Completed")
end

function anim_HalfJump()
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
--	Spring.Echo("anim_HalfJump")
		--Brace for impact...
		Turn(rupperleg, x_axis, rad(-30), LEG_SPEED * speedMod/ 4)
		Turn(rlowerleg, x_axis, rad(20), LEG_SPEED * speedMod/ 4)
		Turn(rfoot, x_axis, rad(-10), LEG_SPEED * speedMod/ 4)
		Turn(lupperleg, x_axis, rad(-30), LEG_SPEED * speedMod/ 4)
		Turn(llowerleg, x_axis, rad(20), LEG_SPEED * speedMod/ 4)
		Turn(lfoot, x_axis, rad(-10), LEG_SPEED * speedMod/ 4)
		Turn(rupperarm, x_axis, rad(0), LEG_SPEED)
		Turn(lupperarm, x_axis, rad(0), LEG_SPEED)
		--WaitForTurns...
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(llowerleg, x_axis)
--	Spring.Echo("anim_HalfJump Completed")
end

function anim_StopJump()
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
--	Spring.Echo("anim_StopJump")
		--Touchdown!
		Turn(rupperleg, x_axis, rad(-30), LEG_SPEED * speedMod* 4)
		Turn(rlowerleg, x_axis, rad(35), LEG_SPEED * speedMod* 4)
		Turn(rfoot, x_axis, rad(5), LEG_SPEED * speedMod* 4)
		Turn(lupperleg, x_axis, rad(-30), LEG_SPEED * speedMod* 4)
		Turn(llowerleg, x_axis, rad(35), LEG_SPEED * speedMod* 4)
		Turn(lfoot, x_axis, rad(5), LEG_SPEED * speedMod* 4)
		Move(pelvis, y_axis, -4, LEG_SPEED * speedMod* 18)
		Move(pelvis, z_axis, -3.3, LEG_SPEED * speedMod* 18)
		Sleep (100)
		--Recover
		Move(pelvis, y_axis, 0, LEG_SPEED * speedMod* 8)
		Move(pelvis, z_axis, 0, LEG_SPEED * speedMod* 8)
		anim_Reset()
--		Spring.Echo("anim_StopJump Completed")
end

-- Walk script
function anim_Walk()
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
	anim_Reset()
	while true do
--		Spring.Echo("anim_Walk")
		--STEP 1
		Turn(pelvis, z_axis, rad(2), LEG_SPEED)
		Turn(rupperleg, x_axis, rad(-45), LEG_SPEED * speedMod/ 1.5)
		Turn(rlowerleg, x_axis, rad(45), LEG_SPEED)
		Turn(lupperleg, x_axis, rad(20), LEG_SPEED * speedMod/ 1.5)
		Turn(llowerleg, x_axis, rad(-5), LEG_SPEED)
		
		Turn(rupperarm, x_axis, rad(35), LEG_SPEED)
		Turn(lupperarm, x_axis, rad(0), LEG_SPEED)
		
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		
		--STEP 2
		Turn(pelvis, z_axis, rad(0), LEG_SPEED)
		Turn(rupperleg, x_axis, rad(-30), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(20), LEG_SPEED)
		Turn(lupperleg, x_axis, rad(15), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(50), LEG_SPEED)
		
		Turn(rupperarm, x_axis, rad(45), LEG_SPEED)
		Turn(lupperarm, x_axis, rad(-20), LEG_SPEED)
		
		PlaySound("stomp")
		
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		
		-- STEP 3
		Turn(pelvis, z_axis, rad(-2), LEG_SPEED)
		Turn(rupperleg, x_axis, rad(20), LEG_SPEED * speedMod/ 1.5)
		Turn(rlowerleg, x_axis, rad(-5), LEG_SPEED)
		Turn(lupperleg, x_axis, rad(-45), LEG_SPEED * speedMod/ 1.5)
		Turn(llowerleg, x_axis, rad(45), LEG_SPEED)
		
		Turn(rupperarm, x_axis, rad(0), LEG_SPEED)
		Turn(lupperarm, x_axis, rad(35), LEG_SPEED)
		
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		
		--STEP 4
		Turn(pelvis, z_axis, rad(0), LEG_SPEED)
		Turn(rupperleg, x_axis, rad(15), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(50), LEG_SPEED)
		Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(20), LEG_SPEED)
		
		Turn(rupperarm, x_axis, rad(-20), LEG_SPEED)
		Turn(lupperarm, x_axis, rad(45), LEG_SPEED)

		PlaySound("stomp")
		
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		
	end
end

function anim_Reset()
	Signal(SIG_ANIMATE)
--	Spring.Echo("anim_Reset")
	Move(pelvis, y_axis, 0, LEG_SPEED * speedMod* 8)
	Move(pelvis, z_axis, 0, LEG_SPEED * speedMod* 8)
	Turn(pelvis, z_axis, rad(0), LEG_SPEED)
	Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
	Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
	Turn(lfoot, x_axis, rad(0), LEG_SPEED)
	Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
	Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
	Turn(rfoot, x_axis, rad(0), LEG_SPEED)
	Move(lupperarm, y_axis, 0, LEG_SPEED)
	Move(rupperarm, y_axis, 0, LEG_SPEED)
	Turn(rupperarm, x_axis, rad(0), LEG_SPEED)
	Turn(lupperarm, x_axis, rad(0), LEG_SPEED)
	PlaySound("stomp")
	Sleep(100)
end