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

local alt = {"alt"}
local shift = {"shift"}
local empty = {}
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
	["cl_elemental_prime"] = true,
	["is_standard_ba"] = true,
}
local droneOwners = {} -- droneOwners[ownerID] = {drone_1_ID, ...}
local ownerStatus = {} -- ownerStatus[ownerID] = true -- implies drones out

local function LaunchDroneAsWeapon(u, team, target, drone, number, piece, rotation, pitch)
	if ownerStatus[u] then return end -- drones are already out, ignore
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
	Spring.SetUnitRulesParam(u, "dronesout", 1)
	Spring.GiveOrderToUnit(u, CMD.STOP, {}, empty)
end

function gadget:GameFrame(f)
	for i,d in pairs(spawnList) do
		local nu = spCreateUnit(d.drone,d.x,d.y,d.z,0,d.team)
		if nu then
			local h = spGetHeadingFromVector(d.dx,d.dz)
			SendToUnsynced("VEHICLE_UNLOADED", nu, d.team) -- caught by unit_vehiclePad.lua
			Spring.MoveCtrl.Enable(nu)
			Spring.MoveCtrl.SetPosition(nu, d.x, d.y, d.z)
			Spring.MoveCtrl.SetRotation(nu,d.pitch/32768 * math.pi, h /32768 * math.pi,d.rotation)
			Spring.MoveCtrl.SetRelativeVelocity(nu,0,0,4)
			local x,y,z = Spring.GetUnitPosition(d.target)
			if d.target > 0 then
				--spGiveOrderToUnit(nu, CMD.FIGHT, {x,y,z},{})
				GG.Delay.DelayCall(spGiveOrderToUnit, {nu, CMD_ATTACK, {d.target}, shift}, 5)
			elseif d.target == -1 then
				spGiveOrderToUnit(nu, CMD_GUARD, {d.parent},empty)
			else
				spGiveOrderToUnit(nu, CMD_MOVE, {d.x-45+math.random(90),d.y,d.z-45+math.random(90)},empty)
			end
			--Spring.Echo(x,y,z, d.target)
			--Spring.SetUnitMoveGoal(nu, x,y,z, 150)
			Spring.MoveCtrl.Disable(nu)
			ownerStatus[d.parent] = true
			if not droneOwners[d.parent] then
				droneOwners[d.parent] = {}
			end
			table.insert(droneOwners[d.parent], nu)
		end
		spawnList[i]=nil
	end
end

function ComeHome(unitID)
	local drones = droneOwners[unitID]
	if drones and ownerStatus[unitID] then
		-- check if APC is targetting anything
		local target, userTarget, params = Spring.GetUnitWeaponTarget(unitID, 1)
		--Spring.Echo("Idle", drones, ownerStatus[unitID], target)
		if target and target > 0 then -- there is a target, redirect drones
			if target == 1 then -- a unit
				Spring.GiveOrderToUnitArray(drones, CMD.ATTACK, {params}, empty)	
			end
		elseif Spring.GetUnitRulesParam(unitID, "fighting") == 0 then -- no target, come home
			--Spring.Echo("COME HOME")
			local x,y,z = Spring.GetUnitPosition(unitID)
			Spring.GiveOrderToUnitArray(drones, CMD.LOAD_ONTO, {unitID}, empty)
		end
	end
end
GG.ComeHome = ComeHome

function gadget:UnitLoaded(unitID, unitDefID, teamID, transportID)
	local unitDef = UnitDefs[unitDefID]
	if droneTypes[unitDef.name] then
		Spring.DestroyUnit(unitID, false, true) --not selfd, reclaimed
		-- FIXME: the following loop is really terrible
		-- instead need a table where we can remove drones when they have died or returned
		-- but that can't be passed to GiveOrderArrayToUnitArray
		-- is there GiveOrderArrayToUnitMap?
		local allDead = true
		for i, droneID in pairs(droneOwners[transportID]) do
			local droneDead = Spring.GetUnitIsDead(droneID)
			if droneDead == nil then droneDead = true end -- horrible
			allDead = allDead and droneDead
			--Spring.Echo(allDead, droneID, Spring.GetUnitIsDead(droneID))
		end
		if allDead then
			--Spring.Echo("All my boys are back in!")
			ownerStatus[transportID] = false
			droneOwners[transportID] = {}
			Spring.SetUnitRulesParam(transportID, "dronesout", 0)
			GG.Delay.DelayCall(GG.Wander, {transportID}, 1)
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	droneOwners[unitID] = nil
	ownerStatus[unitID] = nil
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