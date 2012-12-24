-- function to serialize tables (and bools) to strings
-- used to convert customparams subtables for Spring
function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. "[" .. name .. "] = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end

local RAMP_DISTANCE = 156 -- 206
local HANGAR_DISTANCE = 256

for name, ud in pairs(UnitDefs) do
	-- convert all customparams subtables back into strings for Spring
	if ud.customparams then
		for k, v in pairs (ud.customparams) do
			if type(v) == "table" or type(v) == "boolean" then
				ud.customparams[k] = serializeTable(v)
			end
		end
	end
	-- no OTA nanoframes please
	ud.shownanoframe = false
	-- set buildtimes based on walking speed, so units roll off the ramp at their correct speed
	local speed = (ud.maxvelocity or 0) * 30
	if speed > 0 then
		if ud.customparams.unittype == "mech" then
			ud.buildtime = RAMP_DISTANCE / speed
		elseif ud.canfly then
			ud.buildtime = HANGAR_DISTANCE / (speed * 0.5)
		end
	end
	-- set velocity by modoption
	ud.maxvelocity = (ud.maxvelocity or 0) * (modOptions.speed or 1)
	ud.maxreversevelocity = (ud.maxreversevelocity or 0) * (modOptions.speed or 1)
end
