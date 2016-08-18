--- Valid entries used by engine: IncomingChat, MultiSelect, MapPoint
--- other than that, you can give it any name and access it like before with filenames
local Sounds = {
	SoundItems = {
		IncomingChat = {
			--- always play on the front speaker(s)
			file = "sounds/IncomingChat.wav",
			in3d = "false",
		},
		MultiSelect = {
			--- always play on the front speaker(s)
			file = "sounds/MultiSelect.wav",
			in3d = "false",
		},
		MapPoint = {
			--- respect where the point was set, but don't attuenuate in distace
			--- also, when moving the camera, don't pitch it
			file = "sounds/MapPoint.wav",
			rolloff = 0,
			dopplerscale = 0,
		},
		FailedCommand = {
			file = "sounds/beep3.wav",
		},

		default = {
			--- new since 89.0
			--- you can overwrite the fallback profile here (used when no corresponding SoundItem is defined for a sound)
			gainmod = 0.35,
			pitchmod = 0.1,
		},
		
		-- BTL Unit Animation Sounds
		stomp = {
			file = "sounds/unit/stomp.wav",
			maxconcurrent = 12,
			gainmod = 0.35,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 6000,
			rolloff = 5.0,
		},
		turret_deploy = {
			file = "sounds/unit/turret_deploy.wav",
			maxconcurrent = 12,
			gainmod = 0.4,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 6000,
			rolloff = 1.0,
		},
		outpost_unbox = {
			file = "sounds/unit/outpost_unbox.wav",
			maxconcurrent = 12,
			gainmod = 0.0,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 6000,
			rolloff = 2.0,
		},
		dropship_liftoff = {
			file = "sounds/unit/dropship_liftoff.wav",
			maxconcurrent = 12,
			gainmod = 1.0,
			pitchmod = 0.1,
			priority = 1,
			maxdist = 10000,
			rolloff = 0.2,
		},
		dropship_burn = {
			file = "sounds/unit/dropship_burn.wav",
			maxconcurrent = 12,
			gainmod = 1.0,
			pitchmod = 0.1,
			priority = 1,
			maxdist = 8000,
			rolloff = 0.2,
		},
		dropship_rumble = {
			file = "sounds/unit/dropship_rumble.wav",
			maxconcurrent = 12,
			gainmod = 1.0,
			pitchmod = 0.1,
			priority = 1,
			maxdist = 8000,
			rolloff = 0.2,
			looptime = 10000,
			gain = 0.7,
		},
		dropship_entry = {
			file = "sounds/unit/dropship_entry.wav",
			maxconcurrent = 12,
			gainmod = 1.0,
			pitchmod = 0.1,
			priority = 1,
			maxdist = 10000,
			rolloff = 0.2,
			gain = 1.5,
		},
		dropship_stomp = {
			file = "sounds/unit/dropship_stomp.wav",
			maxconcurrent = 12,
			gainmod = 1.0,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 8000,
			rolloff = 0.4,
		},
		dropship_dooropen = {
			file = "sounds/unit/dropship_dooropen.wav",
			maxconcurrent = 12,
			gainmod = 0.0,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 6000,
			rolloff = 0.5,
		},
		dropship_doorclose = {
			file = "sounds/unit/dropship_doorclose.wav",
			maxconcurrent = 12,
			gainmod = 0.0,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 6000,
			rolloff = 0.5,
		},
		NavBeacon_Land = {
			file = "sounds/beacon/land.wav",
			maxconcurrent = 12,
			gainmod = 0.35,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 5000,
			rolloff = 10.0,
		},
		NavBeacon_Beep = {
			file = "sounds/beacon/beep.wav",
			maxconcurrent = 12,
			gainmod = 0,
			pitchmod = 0,
			priority = -0.1,
			maxdist = 3000,
			rolloff = 10.0,
		},
		NavBeacon_Descend = {
			file = "sounds/beacon/descend.wav",
			maxconcurrent = 2,
			gainmod = 0.35,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 5000,
			rolloff = 10.0,
			--looptime = 10000, -- 10s, 5s x2
		},
		NavBeacon_Pop = {
			file = "sounds/beacon/pop.wav",
			maxconcurrent = 12,
			gainmod = 0.35,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 5000,
			rolloff = 10.0,
		},
		--UNIT SOUNDS
		--TURRETS
		Turret = {
			file = "sounds/turret/Turret.wav",
			in3d = "false",
		},
		TurretHeavy = {
			file = "sounds/turret/TurretHeavy.wav",
			in3d = "false",
		},
		--OUTPOSTS
		C3Array = {
			file = "sounds/outpost/C3Array.wav",
			in3d = "false",
		},
		Garrison = {
			file = "sounds/outpost/Garrison.wav",
			in3d = "false",
		},
		Mechbay = {
			file = "sounds/outpost/Mechbay.wav",
			in3d = "false",
		},
		Seismic = {
			file = "sounds/outpost/Seismic.wav",
			in3d = "false",
		},
		TurretControl = {
			file = "sounds/outpost/TurretControl.wav",
			in3d = "false",
		},
		Uplink = {
			file = "sounds/outpost/Uplink.wav",
			in3d = "false",
		},
		VehiclePad = {
			file = "sounds/outpost/VehiclePad.wav",
			in3d = "false",
		},
		SeismicStomp = {
			file = "sounds/outpost/SeismicStomp.wav",
			maxconcurrent = 12,
			gainmod = 0.75,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 10000,
			rolloff = 5.0,
		},
		MechbayWorking = {
			file = "sounds/outpost/MechbayWorking.wav",
			maxconcurrent = 12,
			gainmod = 0.5,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 6000,
			rolloff = 2.0,
		},
		MechbayWelding = {
			file = "sounds/outpost/MechbayWelding.wav",
			maxconcurrent = 12,
			gainmod = 0.5,
			pitchmod = 0.1,
			priority = -0.1,
			maxdist = 6000,
			rolloff = 2.0,
		},
	},
}

----BITCHING BETTY----
local bettyPath = "sounds/betty/"
local bettyFiles = VFS.DirList(bettyPath)
for _, fileName in pairs(bettyFiles) do
	local name = "BB_" .. fileName:sub(bettyPath:len() + 1,-5)
	--Spring.Echo("Adding SoundItem: " .. name)
	Sounds.SoundItems[name] = {
		file = fileName,
		in3d = false,
	}
end
	

return Sounds
