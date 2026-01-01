function gadget:GetInfo()
	return {
		name = "LUS - Sounds",
		desc = "Sound functions for LUS",
		author = "FLOZi (C. Lawrence)",
		date = "12/10/2025", -- split from lus_helper
		license = "GNU GPL v2",
		layer = 2, -- must be after flagManager
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations
GG.Sounds = VFS.Include("gamedata/sounds.lua")

-- Synced Read
local GetUnitPosition		= Spring.GetUnitPosition
local GetTeamList			= Spring.GetTeamList
local AreTeamsAllied		= Spring.AreTeamsAllied
-- Synced Ctrl
local PlaySoundFile			= Spring.PlaySoundFile

-- Unsynced Ctrl
-- Constants
-- Variables


local function PlaySoundAtUnit(unitID, sound, volume, sx, sy, sz, channel)
	local x,y,z = GetUnitPosition(unitID)
	local ud = UnitDefs[Spring.GetUnitDefID(unitID)]
	volume = volume or (ud and ud.customParams.tonnage or 5)
	channel = channel or "sfx"
	PlaySoundFile(sound, volume, x, y, z, sx, sy, sz, channel)
end
GG.PlaySoundAtUnit = PlaySoundAtUnit

local unsyncedBuffer = {}
local function PlaySoundForTeam(teamID, sound, volume, enemy)
	--sound = sound:lower()
	local exists = GG.Sounds.SoundItems[sound]
	if exists then -- To check for missing sounds, remove this
		if not enemy then
			table.insert(unsyncedBuffer, {teamID, sound, volume})
		else -- play for enemy teams only
			for _, enemyTeamID in pairs(GetTeamList()) do
				if not AreTeamsAllied(teamID, enemyTeamID) then
					table.insert(unsyncedBuffer, {enemyTeamID, sound, volume})
				end
			end
		end
	else
		Spring.Echo("[unit_script_sounds.lua] Requested sound", sound, "does not exist")
	end
end
GG.PlaySoundForTeam = PlaySoundForTeam

function gadget:GameFrame(n)
	for _, callInfo in pairs(unsyncedBuffer) do
		SendToUnsynced("SOUND", callInfo[1], callInfo[2], callInfo[3])
	end
	unsyncedBuffer = {}
end

else
-- UNSYNCED

local PlaySoundFile	= Spring.PlaySoundFile

function PlayTeamSound(eventID, teamID, sound, volume)
	if teamID == Spring.GetMyTeamID() then
		PlaySoundFile(sound, volume, "ui")
	end
end

function SetTeamMessage(eventID, teamID, x, y, z)
	if teamID == Spring.GetMyTeamID() then
		Spring.SetLastMessagePosition(x, y, z)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("SOUND", PlayTeamSound)
	gadgetHandler:AddSyncAction("MESSAGE", SetTeamMessage)
end

end
