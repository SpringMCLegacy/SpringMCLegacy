--piece defines
-- NB. local here means main script can't read them, may want to change that for e.g. Killed (or put Killed in here for per-unit death anims! But then other pieces need to be none-local)
local pelvis, lupperleg, llowerleg, rupperleg, rlowerleg, rfoot, lfoot = piece ("pelvis", "lupperleg", "llowerleg", "rupperleg", "rlowerleg", "rfoot", "lfoot")

--Turning/Movement Locals
local LEG_SPEED = rad(450)

-- Walk script
function MotionControl()
	while true do
		if walking then
			--Spring.Echo("Step 0.5")
			--Pelvis--
			Turn(pelvis, z_axis, rad(2), LEG_SPEED)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(7.5), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(2.5), LEG_SPEED)
			Turn(lfoot, x_axis, rad(-7.5), LEG_SPEED / 4)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-22.5), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(37.5), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Spring.Echo("Step ONE")
			--Pelvis--
			Turn(pelvis, z_axis, rad(2), LEG_SPEED)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(15), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(5), LEG_SPEED)
			Turn(lfoot, x_axis, rad(-15), LEG_SPEED / 4)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(75), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step 1.5")
			--Pelvis--
			Turn(pelvis, z_axis, rad(2), LEG_SPEED)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(17.5), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(7.5), LEG_SPEED)
			Turn(lfoot, x_axis, rad(-17.5), LEG_SPEED / 4)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-47.5), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(50), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Spring.Echo("Step TWO")
			--Pelvis--
			Turn(pelvis, z_axis, rad(3), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(20), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(10), LEG_SPEED)
			Turn(lfoot, x_axis, rad(-20), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-50), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(25), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step 2.5")
			--Pelvis--
			Turn(pelvis, z_axis, rad(3), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(10), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(42.5), LEG_SPEED)
			Turn(lfoot, x_axis, rad(-10), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-40), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(20), LEG_SPEED)
			Turn(rfoot, x_axis, rad(7.5), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step THREE")
			--Pelvis--
			Turn(pelvis, z_axis, rad(-2), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(75), LEG_SPEED)
			Turn(lfoot, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-30), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rfoot, x_axis, rad(15), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step 3.5")
			--Pelvis--
			Turn(pelvis, z_axis, rad(-2), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-22.5), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(75), LEG_SPEED)
			Turn(lfoot, x_axis, rad(15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-15), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(10), LEG_SPEED)
			Turn(rfoot, x_axis, rad(7.5), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step FOUR")
			--Pelvis--
			Turn(pelvis, z_axis, rad(-3), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(75), LEG_SPEED)
			Turn(lfoot, x_axis, rad(30), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(5), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step 4.5")
			--Pelvis--
			Turn(pelvis, z_axis, rad(-3), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-47.5), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(50), LEG_SPEED)
			Turn(lfoot, x_axis, rad(15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(10), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(7.5), LEG_SPEED)
			Turn(rfoot, x_axis, rad(-10), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step FIVE")
			--Pelvis--
			Turn(pelvis, z_axis, rad(-3), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-50), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(25), LEG_SPEED)
			Turn(lfoot, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(20), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(10), LEG_SPEED)
			Turn(rfoot, x_axis, rad(-20), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step 5.5")
			--Pelvis--
			Turn(pelvis, z_axis, rad(-3), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-40), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(20), LEG_SPEED)
			Turn(lfoot, x_axis, rad(7.5), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(10), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(42.5), LEG_SPEED)
			Turn(rfoot, x_axis, rad(-10), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step SIX")
			--Pelvis--
			Turn(pelvis, z_axis, rad(2), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(lfoot, x_axis, rad(15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(75), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step 6.5")
			--Pelvis--
			Turn(pelvis, z_axis, rad(2), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-15), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(7.5), LEG_SPEED)
			Turn(lfoot, x_axis, rad(7.5), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-22.5), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(75), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
			--Spring.Echo("Step SEVEN")
			--Pelvis--
			Turn(pelvis, z_axis, rad(3), LEG_SPEED / 4)
			--Left Leg--
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(lfoot, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(75), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			--Sleep(10)
		else
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(lfoot, x_axis, rad(0), LEG_SPEED)
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			Sleep(10)
		end
	end
end