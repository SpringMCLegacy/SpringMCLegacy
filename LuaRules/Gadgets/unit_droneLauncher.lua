local CMD_ATTACK             = CMD.ATTACK
local CMD_MOVE               = CMD.MOVE
local CMD_GUARD				 = CMD.GUARD
local spCreateUnit           = Spring.CreateUnit
local spGetHeadingFromVector = Spring.GetHeadingFromVector
local spGetUnitDefID		 = Spring.GetUnitDefID
local spGetUnitIsDead        = Spring.GetUnitIsDead
local spGetUnitPiecePosDir   = Spring.GetUnitPiecePosDir
local spGetUnitScriptPiece   = Spring.GetUnitScriptPiece
local spGiveOrderToUnit      = Spring.GiveOrderToUnit

local pairs					 = pairs
local table	       			 = table

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "Drone Launcher",
		desc = "Handles Drone launching",
		author = "KDR_11k (David Becker)",
		date = "2008-04-09",
		license = "Public Domain",
		layer = 28,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED
local spawnList={}
local droneTypes = {
	[1] = "cl_elemental_prime",
	[2] = "is_standard_ba",
}

local function LaunchDroneAsWeapon(u, team, target, drone, number, piece, rotation, pitch)
	local x,y,z,dx,dy,dz
	local lus = Spring.UnitScript.GetScriptEnv(u)
	if lus then
		x,y,z,dx,dy,dz=spGetUnitPiecePosDir(u,piece)
	else
		x,y,z,dx,dy,dz=spGetUnitPiecePosDir(u,spGetUnitScriptPiece(u,piece))
		--x,y,z,dx,dy,dz=spGetUnitPiecePosDir(u,piece)
	end
	if (target > 0 and not spGetUnitIsDead(target)) or target == -1 then
		for i = 1, number do
			table.insert(spawnList, {
				drone=drone, parent=u, target = target, rotation = math.pi*.5*rotation, pitch = pitch or 0, team = team,
				x=x,y=y,z=z,dx=dx,dy=dy,dz=dz,
			})
		end
	end
end

function gadget:GameFrame(f)
	for i,d in pairs(spawnList) do
		local nu = spCreateUnit(droneTypes[d.drone],d.x,d.y,d.z,0,d.team)
		if nu then
			local h = spGetHeadingFromVector(d.dx,d.dz)
			Spring.MoveCtrl.Enable(nu)
			Spring.MoveCtrl.SetPosition(nu, d.x, d.y, d.z)
			Spring.MoveCtrl.SetRotation(nu,d.pitch/32768 * math.pi, h /32768 * math.pi,d.rotation)
			Spring.MoveCtrl.SetRelativeVelocity(nu,0,0,4)
			if d.target > 0 then
				spGiveOrderToUnit(nu, CMD_ATTACK, {d.target},{})
			elseif d.target == -1 and not (droneTypes[d.drone]:find("torpedo")) then
				spGiveOrderToUnit(nu, CMD_GUARD, {d.parent},{})
			else
				spGiveOrderToUnit(nu, CMD_MOVE, {d.x-45+math.random(90),d.y,d.z-45+math.random(90)},{})
			end
			local x,y,z = Spring.GetUnitPosition(d.target)
			--Spring.Echo(x,y,z, d.target)
			--Spring.SetUnitMoveGoal(nu, x,y,z, 150)
			Spring.MoveCtrl.Disable(nu)
		end
		spawnList[i]=nil
	end
end

function gadget:Initialize()
	gadgetHandler:RegisterGlobal("LaunchDroneWeapon", LaunchDroneAsWeapon)
	GG.LaunchDroneAsWeapon = LaunchDroneAsWeapon
	_G.LaunchDroneAsWeapon = LaunchDroneAsWeapon
end

else

--UNSYNCED

return false

end