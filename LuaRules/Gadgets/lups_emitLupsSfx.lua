function gadget:GetInfo()
  return {
    name      = "Emit Lups Sfx",
    desc      = "",
    author    = "FLOZi (C. Lawrence)",
    date      = "Feb. 2014",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true
  }
end


if (gadgetHandler:IsSyncedCode()) then

local unsyncedBuffer = {}
local bufferSize = 0

-- SYNCED

local function BlendJet(time, unitID, piecenum, ID, minWidth, minLength)
	minWidth = minWidth or 20
	minLength = minLength or 60
	for t = 0, (time/3) do
		local i = 1 - t / (time/3)
		if (i == 0) then
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", piecenum, {id = ID, repeatEffect = true, delay = t*3, width = minWidth, length = minLength})
		elseif (i > 0.33) then
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", piecenum, {id = ID, life = 3, delay = t*3, width = minWidth + i * 60, length = minLength + i * 190})
		else
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", piecenum, {id = ID, life = 1, delay = t*3,   width = minWidth + i * 60, length = minLength + i * 190})
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", piecenum, {id = ID, life = 2, delay = t*3+1, width = minWidth + i * 40, length = minLength + i * 90})
		end
	end
end
GG.BlendJet = BlendJet


local function EmitLupsSfx(unitID, effectName, pieceNum, options)
	bufferSize = bufferSize + 1
	unsyncedBuffer[bufferSize] = {"lups_emitsfx", unitID, effectName, pieceNum, options}
end
GG.EmitLupsSfx = EmitLupsSfx


local function RemoveLupsSfx(unitID, fxNameID)
	bufferSize = bufferSize + 1
	unsyncedBuffer[bufferSize] = {"lups_removesfx", unitID, fxNameID}
end
GG.RemoveLupsSfx = RemoveLupsSfx


local function EmitLupsSfxArray(unitID, effects)
	for i=1,#effects do
		local fx = effects[i]
		local fxPieces = fx[1]
		local fxName = fx[2]
		local fxOpts = fx[3]
		    if type(fxPieces) == "table" then
			for n=1,#fxPieces do
				EmitLupsSfx(unitID, fxName, fxPieces[n], fxOpts)
			end
		elseif type(fxPieces) == "number" then
			EmitLupsSfx(unitID, fxName, fxPieces, fxOpts)
		elseif fxPieces == "remove" then
			RemoveLupsSfx(unitID, fxName)
		end
	end
end
GG.EmitLupsSfxArray = EmitLupsSfxArray


function gadget:GameFrame(n)
	_G.unsyncedBuffer = unsyncedBuffer
	SendToUnsynced("lups_updatefx")
	_G.unsyncedBuffer = nil
	bufferSize = 0
	unsyncedBuffer = {}
end

else

-- UNSYNCED

local effects = include("LuaRules/Configs/lups_emit_fxs.lua")
local namedFXs = {}

local function foo(st, i, n, ...)
	if i == 0 then return ... end
	return foo(st,i-1,n, st[i], ...)
end

local function sunpack(st)
	if #st > 0 then return unpack(st) end
	local n = 1; while st[n] do n=n+1 end; n=n-1
	return foo(st, n, n)
end
GG.sunpack = sunpack

local function scopytable(_in, _out)
	for k,v in spairs(_in) do
		if type(v)=="table" then
			local t = {}
			_out[k] = t
			scopytable(v, t)
		else
			_out[k] = v
		end
	end
end
GG.scopytable = scopytable

local function EmitLupsSfx(unitID, effectName, pieceNum, options)
	local Lups = GG.Lups
	--Spring.Echo("Got this far!", Lups, unitID, effectName, pieceNum, options)

	local effect = effects[effectName]
	local opts = {}
	assert(effect)

	for k,v in pairs(effect.options) do
		opts[k] = v
	end
	if options then
		scopytable(options, opts)
	end
	if not opts.worldpos then
		opts.unit = unitID
		opts.piecenum = pieceNum
	else
		opts.pos = opts.pos or {}
		local x,y,z = Spring.GetUnitPiecePosDir(unitID, pieceNum)
		opts.pos[1] = opts.pos[1] + x; opts.pos[2] = opts.pos[2] + y; opts.pos[3] = opts.pos[3] + z;
	end

	local fxID = Lups.AddParticles(effect.class, opts)

	if opts.id then
		local tu = namedFXs[unitID]
		if not tu then tu = {}; namedFXs[unitID] = tu; end
		local t = tu[opts.id]
		if not t then t = {}; tu[opts.id] = t; end
		t[#t+1] = fxID
	end
end

local function RemoveLupsSfx(unitID, fxNameID)
	local Lups = GG.Lups
	local tu = namedFXs[unitID]
	if not tu then return end
	local t = tu[fxNameID]
	if not t then return end

	for i=1,#t do
		Lups.RemoveParticles(t[i])
	end
	tu[fxNameID] = nil
end
	
local function UpdateLupsSfx()
	local Lups = GG.Lups
	for i, callInfo in spairs(SYNCED.unsyncedBuffer) do
		--for k,v in spairs(callInfo) do Spring.Echo(k,v) end
		if callInfo[1] == "lups_emitsfx" then
			EmitLupsSfx(select(2, sunpack(callInfo)))
		elseif callInfo[1] == "lups_removesfx" then
			RemoveLupsSfx(select(2, sunpack(callInfo)))
		end
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("lups_updatefx", UpdateLupsSfx)
end

function gadget:Shutdown()
	gadgetHandler.RemoveSyncAction("lups_updatefx")
end

end