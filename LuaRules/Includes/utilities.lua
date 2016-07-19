function string.tobool(val)
  local t = type(val)
  if (t == 'nil') then
    return false
  elseif (t == 'boolean') then
    return val
  elseif (t == 'number') then
    return (val ~= 0)
  elseif (t == 'string') then
    return ((val ~= '0') and (val ~= 'false'))
  end
  return false
end

if System then System.tobool = tobool end

function table.echo(def)
	for k,v in pairs(def) do 
		if type(v) == "table" then
			Spring.Echo(k .. " = {")
			table.echo(v)
			Spring.Echo("},")
		else
			Spring.Echo(k .. " = ", v) 
		end
	end
end

function table.copy(input, output)
	for k,v in pairs(input) do
		if type(v) == "table" then
			output[k] = {}
			table.copy(v, output[k])
		else
			output[k] = v
		end
	end
end

function table.contains(input, element)
	for key, value in pairs(input) do
		if value == element then
			return key
		end
	end
	return false
end

function table.removeElement(input, element)
	local key = table.contains(input, element)
	if key then
		table.remove(input, key)
	end
end

function table.unserialize(input)
	return loadstring("return " .. (input or "{}"))()
end

-- function to serialize tables (and bools) to strings
-- used to convert customparams subtables for Spring
function table.serialize(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then 
		if tonumber(name) then -- wrap number indices
			tmp = tmp .. "[" .. name .. "] = " 
		else
			tmp = tmp .. name .. " = " 
		end
	end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. table.serialize(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
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

	-- TODO: figure out if this hack is really required (Euler Angles, Handedness, etc)
	Spring.MoveCtrl = Spring.MoveCtrl or {}
	local origMcSetUnitRotation = Spring.MoveCtrl.SetRotation
	local origMcSetUnitRotationVelocity = Spring.MoveCtrl.SetRotationVelocity

	local function newMcSetUnitRotation(unitID, x, y, z)
		return origMcSetUnitRotation(unitID, -x, -y, -z)
	end

	local function newMcSetUnitRotationVelocity(unitID, x, y, z)
		return origMcSetUnitRotationVelocity(unitID, -x, -y, -z)
	end
	
	Spring.MoveCtrl.SetRotation = newMcSetUnitRotation
	Spring.MoveCtrl.SetRotationVelocity = newMcSetUnitRotationVelocity