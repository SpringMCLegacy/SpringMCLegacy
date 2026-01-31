--piece defines
-- NB. local here means main script can't read them, may want to change that for e.g. Killed (or put Killed in here for per-unit death anims! But then other pieces need to be none-local)
local pelvis, torso, lupperleg, llowerleg, rupperleg, rlowerleg, lfronttoes, rfronttoes, rfoot, lfoot = piece ("pelvis", "torso", "lupperleg", "llowerleg", "rupperleg", "rlowerleg", "lfronttoes", "rfronttoes", "rfoot", "lfoot")
local rupperarm, lupperarm = piece ("rupperarm", "lupperarm")

--Turning/Movement Locals
local LEG_SPEED = rad(350) 
local LEG_TURN_SPEED = rad (200) 

function anim_Turn(clockwise)
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
	while true do
--		Spring.Echo("anim_Turn")
		--Left Leg Up...
		Turn(pelvis, z_axis, rad(5), LEG_TURN_SPEED * speedMod * 2)
		Turn(lupperleg, x_axis, rad(40), LEG_TURN_SPEED * speedMod * 2)
		Turn(llowerleg, x_axis, rad(-60), LEG_TURN_SPEED * speedMod * 2)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		--Left Leg Down...
		Turn(pelvis, z_axis, rad(0), LEG_TURN_SPEED)
		Turn(lupperleg, x_axis, rad(0), LEG_TURN_SPEED * speedMod * 2)
		Turn(llowerleg, x_axis, rad(0), LEG_TURN_SPEED * speedMod * 2)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		PlaySound("stomp")
		GG.EmitSfxName(unitID, lfoot, "stomp_dust")
		--Right Leg Up...
		Turn(pelvis, z_axis, rad(-5), LEG_TURN_SPEED * speedMod * 2)
		Turn(rupperleg, x_axis, rad(40), LEG_TURN_SPEED * speedMod * 2)
		Turn(rlowerleg, x_axis, rad(-60), LEG_TURN_SPEED * speedMod * 2)
		--Wait for turns...
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		--Right Leg Down...
		Turn(pelvis, z_axis, rad(0), LEG_TURN_SPEED * speedMod * 2)
		Turn(rupperleg, x_axis, rad(0), LEG_TURN_SPEED * speedMod * 2)
		Turn(rlowerleg, x_axis, rad(0), LEG_TURN_SPEED * speedMod * 2)
		--Wait for turns
		WaitForTurn(pelvis, z_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		PlaySound("stomp")
		GG.EmitSfxName(unitID, rfoot, "stomp_dust")
	end
end

function anim_PreJump()
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
--	Spring.Echo("anim_PreJump")
	anim_Reset()
		--Crouch...
		Turn(rupperleg, x_axis, rad(30), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-30), LEG_SPEED)
		Turn(lupperleg, x_axis, rad(30), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-30), LEG_SPEED)
		Move(pelvis, y_axis, -5.6, LEG_SPEED * speedMod* 8)
		Move(pelvis, z_axis, -3.3, LEG_SPEED * speedMod* 8)
		--Hold a bit...
		Sleep(100)
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
		Turn(rfronttoes, x_axis, rad(-10), LEG_SPEED * speedMod/ 4)
		Turn(lupperleg, x_axis, rad(-30), LEG_SPEED * speedMod/ 4)
		Turn(llowerleg, x_axis, rad(20), LEG_SPEED * speedMod/ 4)
		Turn(lfronttoes, x_axis, rad(-10), LEG_SPEED * speedMod/ 4)
		--WaitForTurns...
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfronttoes, x_axis)
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(lfronttoes, x_axis)
		WaitForTurn(llowerleg, x_axis)
--	Spring.Echo("anim_HalfJump Completed")
end

function anim_StopJump()
	Signal(SIG_ANIMATE)
	SetSignalMask(SIG_ANIMATE)
--	Spring.Echo("anim_StopJump")
		--Touchdown!
		Turn(rupperleg, x_axis, rad(20), LEG_SPEED * speedMod* 4)
		Turn(rlowerleg, x_axis, rad(-25), LEG_SPEED * speedMod* 4)
		Turn(rfronttoes, x_axis, rad(5), LEG_SPEED * speedMod* 4)
		Turn(lupperleg, x_axis, rad(20), LEG_SPEED * speedMod* 4)
		Turn(llowerleg, x_axis, rad(-25), LEG_SPEED * speedMod* 4)
		Turn(lfronttoes, x_axis, rad(5), LEG_SPEED * speedMod* 4)
		Move(pelvis, y_axis, -5.6, LEG_SPEED * speedMod* 18)
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

		--STARTWALK SETUP
		--Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
		--Turn(llowerleg, x_axis, rad(-5), LEG_SPEED)
		--Turn(lfoot, x_axis, rad(15), LEG_SPEED)
		
		--Turn(rupperleg, x_axis, rad(20), LEG_SPEED)
		--Turn(rlowerleg, x_axis, rad(10), LEG_SPEED)
		--Turn(rfoot, x_axis, rad(-30), LEG_SPEED)
		
		--Spring.Echo("START")
		--STEP 1, Left Foot Comes Down...
		--STEP 1, Right Leg Comes Up...
		Move(pelvis, y_axis, 0, LEG_SPEED * speedMod* 4)
		Turn(pelvis, z_axis, rad(0), LEG_SPEED * speedMod/ 3)
		
		Turn(lupperleg, x_axis, rad(-45), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(20), LEG_SPEED)
		Turn(lfoot, x_axis, rad(25), LEG_SPEED)
		
		Turn(rupperleg, x_axis, rad(35), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-15), LEG_SPEED)
		Turn(rfoot, x_axis, rad(0), LEG_SPEED)
		
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		PlaySound("stomp")
		GG.EmitSfxName(unitID, lfoot, "stomp_dust")
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		
		--STEP 2, Left Leg Moves Back Slowly - Halfway point
		--STEP 2, Right Leg Moves Forward Slowly - Halfway Point
		Move(pelvis, y_axis, 5, LEG_SPEED)
		Turn(pelvis, z_axis, rad(-2), LEG_SPEED * speedMod/ 2)
		
		Turn(lupperleg, x_axis, rad(5), LEG_SPEED * speedMod* 1)
		Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
		Turn(lfoot, x_axis, rad(-5), LEG_SPEED)
		
		Turn(rupperleg, x_axis, rad(-5), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-20), LEG_SPEED)
		Turn(rfoot, x_axis, rad(10), LEG_SPEED)
		
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		
		--STEP 3, Left Leg Moves Back Slowly - All the way Back
		--STEP 3, Right Leg Moves All the way Forward
		
		Turn(lupperleg, x_axis, rad(20), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(10), LEG_SPEED)
		Turn(lfoot, x_axis, rad(-30), LEG_SPEED)
		
		Turn(rupperleg, x_axis, rad(-30), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(-5), LEG_SPEED)
		Turn(rfoot, x_axis, rad(15), LEG_SPEED)
		
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		
		--STEP 4, Left Leg Lifts Up...
		--STEP 4, Right Foot Comes Down..
		Move(pelvis, y_axis, 0, LEG_SPEED * speedMod* 4)
		Turn(pelvis, z_axis, rad(0), LEG_SPEED * speedMod/ 3)
		
		Turn(lupperleg, x_axis, rad(35), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-15), LEG_SPEED)
		Turn(lfoot, x_axis, rad(0), LEG_SPEED)
		
		Turn(rupperleg, x_axis, rad(-45), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(20), LEG_SPEED)
		Turn(rfoot, x_axis, rad(25), LEG_SPEED)
		
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		PlaySound("stomp")
		GG.EmitSfxName(unitID, rfoot, "stomp_dust")
		
		--STEP 5, Left Leg Moves Forward Slowly... - Halfway Point
		--STEP 5, Right Leg Moves Back Slowly - Halfway Point
		Move(pelvis, y_axis, 5, LEG_SPEED)
		Turn(pelvis, z_axis, rad(2), LEG_SPEED * speedMod/ 2)
		
		Turn(lupperleg, x_axis, rad(-5), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-20), LEG_SPEED)
		Turn(lfoot, x_axis, rad(10), LEG_SPEED)
		
		Turn(rupperleg, x_axis, rad(5), LEG_SPEED * speedMod* 1)
		Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
		Turn(rfoot, x_axis, rad(-5), LEG_SPEED)
		
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		
		--STEP 6, Left Leg Moves Forward Slowly... Fully forward and RESET
		--STEP 6, Right Leg Moves Back Slowly... All the way back and RESET
		
		Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
		Turn(llowerleg, x_axis, rad(-5), LEG_SPEED)
		Turn(lfoot, x_axis, rad(15), LEG_SPEED)
		
		Turn(rupperleg, x_axis, rad(20), LEG_SPEED)
		Turn(rlowerleg, x_axis, rad(10), LEG_SPEED)
		Turn(rfoot, x_axis, rad(-30), LEG_SPEED)
		
		WaitForTurn(lupperleg, x_axis)
		WaitForTurn(llowerleg, x_axis)
		WaitForTurn(lfoot, x_axis)
		WaitForTurn(rupperleg, x_axis)
		WaitForTurn(rlowerleg, x_axis)
		WaitForTurn(rfoot, x_axis)
		--WaitForTurn(lupperleg, x_axis)
		--WaitForTurn(llowerleg, x_axis)
		--WaitForTurn(lfoot, x_axis)
		--WaitForTurn(rupperleg, x_axis)
		--WaitForTurn(rlowerleg, x_axis)
		--WaitForTurn(rfoot, x_axis)
		
		
	end
end

function anim_Reset()
	Signal(SIG_ANIMATE)
--	Spring.Echo("anim_Reset")
	Turn(pelvis, z_axis, rad(0), LEG_SPEED * 2)
	Move(pelvis, y_axis, 0, LEG_SPEED * 2)
	Turn(lupperleg, x_axis, rad(0), LEG_SPEED * 2)
	Turn(llowerleg, x_axis, rad(0), LEG_SPEED * 2)
	Turn(lfoot, x_axis, rad(0), LEG_SPEED * 2)
	Turn(lfronttoes, x_axis, rad(0), LEG_SPEED * 2)
	Turn(rupperleg, x_axis, rad(0), LEG_SPEED * 2)
	Turn(rlowerleg, x_axis, rad(0), LEG_SPEED * 2)
	Turn(rfronttoes, x_axis, rad(0), LEG_SPEED * 2)
	Turn(rfoot, x_axis, rad(0), LEG_SPEED * 2)
	Move(lupperarm, y_axis, 0, LEG_SPEED * 2)
	Move(rupperarm, y_axis, 0, LEG_SPEED * 2)
	PlaySound("stomp")
	Sleep(100)
end