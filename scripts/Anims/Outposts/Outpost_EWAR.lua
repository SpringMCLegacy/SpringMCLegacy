-- EWAR pieces
local tagbase1, tagstand1, tagbase2, tagstand2 = piece("tagbase1", "tagstand1", "tagbase2", "tagstand2")
local bapstand, bapmantlet, bapturret = piece("bapstand", "bapmantlet", "bapturret")
		
function Setup()
	Spring.SetUnitRulesParam(unitID, "FXOFF", 1, {public = true})
	Turn(bapstand, x_axis, math.rad(-90))
	Turn(bapmantlet, x_axis, math.rad(135))	
	Turn(tagbase1, z_axis, math.rad(90))
	Turn(tagstand1, z_axis, math.rad(90))
	Turn(tagbase2, z_axis, math.rad(-90))
	Turn(tagstand2, z_axis, math.rad(-90))
end

function Deploy()
	local console2 = piece("console2")
	Move(console2, z_axis, 7, CRATE_SPEED)
	local bapstand, bapmantlet = piece("bapstand", "bapmantlet")
	Turn(bapstand, x_axis, 0, CRATE_SPEED/4)
	Turn(bapmantlet, x_axis, 0, CRATE_SPEED/2)
	WaitForTurn(bapstand, x_axis)
	WaitForTurn(bapmantlet, x_axis)
	WaitForMove(console2, z_axis)
	StartThread(ECM)
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end

function Upgrade2()
	-- Angel
	local ecm, ecmdoor1, ecmdoor2, console1 = piece("ecm", "ecmdoor1", "ecmdoor2", "console1")
	Move(console1, z_axis, -7, CRATE_SPEED)
	Move(ecmdoor1, x_axis, 5, CRATE_SPEED)
	Move(ecmdoor2, x_axis, -5, CRATE_SPEED)
	WaitForMove(ecmdoor2, x_axis)
	Move(ecm, y_axis, 11, CRATE_SPEED)
	WaitForMove(ecm, y_axis)
	GG.angels[unitID] = true
end

function Upgrade3()
	-- CumOnFeelTheNoise
	Turn(tagbase1, z_axis, 0, CRATE_SPEED)
	Turn(tagbase2, z_axis, 0, CRATE_SPEED)
	WaitForTurn(tagbase2, z_axis)
	Turn(tagstand1, z_axis, 0, CRATE_SPEED)
	Turn(tagstand2, z_axis, 0, CRATE_SPEED)
	WaitForTurn(tagstand2, z_axis)

	local noiseRange = 1000
	local noiseDelay = 5000
	local noiseNum = 10
	local bx, by, bz = Spring.GetUnitBasePosition(unitID)
	local x, z
	local noiseID = Spring.CreateUnit("noise", bx,by,bz, 0, teamID, false, false)
	
	while true do
		for i = 1, noiseNum do
			-- TODO: add anim here
			x = math.max(math.min(bx + math.random(-noiseRange, noiseRange), Game.mapSizeX), 0)
			z = math.max(math.min(bz + math.random(-noiseRange, noiseRange), Game.mapSizeZ), 0)
			local y = Spring.GetGroundHeight(x, z) - 15
			Spring.SetUnitPosition(noiseID, x,y,z)
			Spring.SetUnitVelocity(noiseID, math.random() * 50, 0, math.random() * 50)
			Sleep(math.random(500, 1500))
		end
		Sleep(noiseDelay)
	end
end
	
function ECM()
	Sleep(2000)
	GG.SetUnitECMRadius(unitID, nil, 1000)
	while true do
		Turn(bapmantlet, x_axis, math.rad(math.random(-15, 15)), CRATE_SPEED/2)
		Turn(bapturret, y_axis, math.rad(math.random(-180, 180)), CRATE_SPEED/2)
		WaitForTurn(bapmantlet, x_axis)
		WaitForTurn(bapturret, y_axis)
		Sleep(math.random(2000, 5000))
	end
end