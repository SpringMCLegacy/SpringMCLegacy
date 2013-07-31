--piece defines
-- NB. local here means main script can't read them, may want to change that for e.g. Killed (or put Killed in here for per-unit death anims! But then other pieces need to be none-local)
local pelvis, torso, lupperleg, llowerleg, rupperleg, rlowerleg, lfoot, rfoot = piece ("pelvis", "torso", "lupperleg", "llowerleg", "rupperleg", "rlowerleg", "lfoot", "rfoot")

--Turning/Movement Locals
local LEG_SPEED = rad(600)
local LEG_TURN_SPEED = rad (400)

function anim_Turn(signal)
	SetSignalMask(signal)
	while true do
		--Left Leg Up...
		Turn(pelvis, z_axis, rad(-5), LEG_TURN_SPEED)
		Turn(lupperleg, x_axis, rad(30), LEG_TURN_SPEED)
		Turn(llowerleg, x_axis, rad(-40), LEG_TURN_SPEED)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		--Left Leg Down...
		Turn(pelvis, z_axis, rad(0), LEG_TURN_SPEED)
		Turn(lupperleg, x_axis, rad(0), LEG_TURN_SPEED)
		Turn(llowerleg, x_axis, rad(0), LEG_TURN_SPEED)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		--Right Leg Up...
		Turn(pelvis, z_axis, rad(5), LEG_TURN_SPEED)
		Turn(rupperleg, x_axis, rad(30), LEG_TURN_SPEED)
		Turn(rlowerleg, x_axis, rad(-40), LEG_TURN_SPEED)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		--Right Leg Down...
		Turn(pelvis, z_axis, rad(0), LEG_TURN_SPEED)
		Turn(rupperleg, x_axis, rad(0), LEG_TURN_SPEED)
		Turn(rlowerleg, x_axis, rad(0), LEG_TURN_SPEED)
		--Wait for turns
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
	end
end
		
function anim_PreJump()
	while true do
		--Crouch...
		Turn(rupperleg, x_axis, rad(30), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-30), LEG_SPEED)
		Turn(lupperleg, x_axis, rad(30), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-30), LEG_SPEED)
		Move(pelvis, y_axis, 7.6, LEG_SPEED)
		Move(pelvis, z_axis, 4.3, LEG_SPEED)
		--Hold a bit...
		Sleep(100)
		--Wait for turns...
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
	end
end

function anim_Jump()
	while true do
		--Jump!
		Turn(rupperleg, x_axis, rad(5), LEG_SPEED * 4)
		Turn(rlowerleg, x_axis, rad(20), LEG_SPEED * 4)
		Turn(lupperleg, x_axis, rad(5), LEG_SPEED * 4)
		Turn(llowerleg, x_axis, rad(20), LEG_SPEED * 4)
		Move(pelvis, y_axis, 0, LEG_SPEED * 4)
		Move(pelvis, z_axis, 0, LEG_SPEED * 4)
		--Wait for turns...
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
	end
end

function anim_JumpInProgress()
	while true do
		--Brace for impact...
		Turn(rupperleg, x_axis, rad(-15), LEG_SPEED / 4)
		Turn(rlowerleg, x_axis, rad(20), LEG_SPEED / 4)
		Turn(rfoot, x_axis, rad(-10), LEG_SPEED / 4)
		Turn(lupperleg, x_axis, rad(-15), LEG_SPEED / 4)
		Turn(llowerleg, x_axis, rad(20), LEG_SPEED / 4)
		Turn(lfoot, x_axis, rad(-10), LEG_SPEED / 4)
		--WaitForTurns...
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(llowerleg, x_axis)
	end
end

function anim_Land()
	while true do
		--Touchdown!
		Turn(rupperleg, x_axis, rad(20), LEG_SPEED * 4)
		Turn(rlowerleg, x_axis, rad(-25), LEG_SPEED * 4)
		Turn(rfoot, x_axis, rad(5), LEG_SPEED * 4)
		Turn(lupperleg, x_axis, rad(20), LEG_SPEED * 4)
		Turn(llowerleg, x_axis, rad(-25), LEG_SPEED * 4)
		Turn(lfoot, x_axis, rad(5), LEG_SPEED * 4)
		--Wait for turns...
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		--Recover
		Turn(rupperleg, x_axis, rad(0), LEG_SPEED / 4)
		Turn(rlowerleg, x_axis, rad(0), LEG_SPEED / 4)
		Turn(rfoot, x_axis, rad(0), LEG_SPEED / 4)
		Turn(lupperleg, x_axis, rad(0), LEG_SPEED / 4)
		Turn(llowerleg, x_axis, rad(0), LEG_SPEED / 4)
		Turn(lfoot, x_axis, rad(0), LEG_SPEED / 4)
		--Wait for turns?
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(llowerleg, x_axis)
	end
end

-- Walk script
function anim_Walk(signal)
	SetSignalMask(signal)
	while true do
		--Spring.Echo("START")
		Turn(pelvis, z_axis, rad(5), LEG_SPEED / 10)
		--Left Leg--
		Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
		Turn(lfoot, x_axis, rad(0), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(10), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-20), LEG_SPEED)
		Turn(rfoot, x_axis, rad(0), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
		--Spring.Echo("Step .5")
		Turn(pelvis, z_axis, rad(5), LEG_SPEED / 10)
		--Left Leg--
		Turn(lupperleg, x_axis, rad(10), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(2.5), LEG_SPEED)
		Turn(lfoot, x_axis, rad(-12.5), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(-10), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-20), LEG_SPEED)
		Turn(rfoot, x_axis, rad(5), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
	
		--Spring.Echo("Step 1")
		--Torso--
		Turn(pelvis, z_axis, rad(-5), LEG_SPEED / 10)
		--Left Leg--
		Turn(lupperleg, x_axis, rad(20), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(5), LEG_SPEED)
		Turn(lfoot, x_axis, rad(-25), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(-30), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
		Turn(rfoot, x_axis, rad(10), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
			
		--Spring.Echo("Step 1.5")
		--Torso--
		Turn(pelvis, z_axis, rad(-5), LEG_SPEED / 10)
		--Left Leg--
		Turn(lupperleg, x_axis, rad(30), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(7.5), LEG_SPEED)
		Turn(lfoot, x_axis, rad(-25), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(-35), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
		Turn(rfoot, x_axis, rad(10), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
		--Spring.Echo("Step 2")
		--Torso--
		Turn(pelvis, z_axis, rad(-5), LEG_SPEED / 10)
		--Left Leg--
		Turn(lupperleg, x_axis, rad(40), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(10), LEG_SPEED)
		Turn(lfoot, x_axis, rad(-25), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(-40), LEG_SPEED * 2)
		Turn(rlowerleg, x_axis, rad(25), LEG_SPEED * 2)
		Turn(rfoot, x_axis, rad(10), LEG_SPEED * 2)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
			
		--Spring.Echo("Step 2.5")
		--Torso--
		Turn(pelvis, z_axis, rad(-5), LEG_SPEED / 10)
		--Left Leg--
		Turn(lupperleg, x_axis, rad(45), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-10), LEG_SPEED)
		Turn(lfoot, x_axis, rad(-12.5), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(-20), LEG_SPEED * 2)
		Turn(rlowerleg, x_axis, rad(12.5), LEG_SPEED * 2)
		Turn(rfoot, x_axis, rad(5), LEG_SPEED * 2)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
		--Spring.Echo("Step 3")
		--Left Leg--
		Turn(lupperleg, x_axis, rad(50), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-30), LEG_SPEED)
		Turn(lfoot, x_axis, rad(0), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(0), LEG_SPEED * 2)
		Turn(rlowerleg, x_axis, rad(0), LEG_SPEED * 2)
		Turn(rfoot, x_axis, rad(0), LEG_SPEED * 2)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
			
		--Spring.Echo("Step 3.5")
		--Left Leg--
		Turn(lupperleg, x_axis, rad(30), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-25), LEG_SPEED)
		Turn(lfoot, x_axis, rad(0), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(10), LEG_SPEED * 2)
		Turn(rlowerleg, x_axis, rad(2.5), LEG_SPEED * 2)
		Turn(rfoot, x_axis, rad(-25), LEG_SPEED * 2)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
		--Spring.Echo("Step 4")
		--Left Leg--
		Turn(lupperleg, x_axis, rad(10), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-20), LEG_SPEED)
		Turn(lfoot, x_axis, rad(0), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(20), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(5), LEG_SPEED)
		Turn(rfoot, x_axis, rad(-25), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
		--Spring.Echo("Step 4.5")
		--Left Leg--
		Turn(lupperleg, x_axis, rad(-10), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-10), LEG_SPEED)
		Turn(lfoot, x_axis, rad(5), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(30), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(7.5), LEG_SPEED)
		Turn(rfoot, x_axis, rad(-25), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
		--Spring.Echo("Step 5")
		--Torso--
		Turn(pelvis, z_axis, rad(5), LEG_SPEED / 10)
		--Left Leg--
		Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
		Turn(lfoot, x_axis, rad(10), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(40), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(10), LEG_SPEED)
		Turn(rfoot, x_axis, rad(-25), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
		--Spring.Echo("Step 5.5")
		--Torso--
		Turn(pelvis, z_axis, rad(5), LEG_SPEED / 10)
		--Left Leg--
		Turn(lupperleg, x_axis, rad(-35), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(12.5), LEG_SPEED)
		Turn(lfoot, x_axis, rad(10), LEG_SPEED)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(45), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-10), LEG_SPEED)
		Turn(rfoot, x_axis, rad(-12.5), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
		
		--Spring.Echo("Step SIX")
		--Left Leg--
		Turn(lupperleg, x_axis, rad(-40), LEG_SPEED * 2)
		Turn(llowerleg, x_axis, rad(25), LEG_SPEED * 2)
		Turn(lfoot, x_axis, rad(10), LEG_SPEED * 2)
		--Right Leg--
		Turn(rupperleg, x_axis, rad(50), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-30), LEG_SPEED)
		Turn(rfoot, x_axis, rad(0), LEG_SPEED)
		--Wait For Turns...--
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--Sleep(10)
	end
end

function anim_Reset()
	Turn(pelvis, z_axis, rad(0), LEG_SPEED)
	Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
	Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
	Turn(lfoot, x_axis, rad(0), LEG_SPEED)
	Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
	Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
	Turn(rfoot, x_axis, rad(0), LEG_SPEED)
	Sleep(100)
end