local	resources = {
		graphics = {
			-- Spring Defaults
			groundfx = {
				groundflash	= 'groundflash.tga',
				groundring	= 'groundring.tga',
				seismic		= 'circles.tga',
			},
			projectiletextures = {
				circularthingy		= 'circularthingy.tga',
				laserend			= 'laserend.tga',
				laserfalloff		= 'laserfalloff.tga',
				randdots			= 'randdots.tga',
				smoketrail			= 'smoketrail.tga',
				wake				= 'wake.tga',
				flare				= 'flare.tga',
				explo				= 'explo.tga',
				explofade			= 'explofade.tga',
				heatcloud			= 'explo.tga',
				flame				= 'flame.tga',
				muzzleside			= 'muzzleside.tga',
				muzzlefront			= 'muzzlefront.tga',
				largebeam			= 'largelaserfalloff.tga',
			},
		}
	}

local VFSUtils = VFS.Include('gamedata/VFSUtils.lua')

local function AutoAdd(subDir, map, filter)
  local dirList = RecursiveFileSearch("bitmaps/" .. subDir)
  for _, fullPath in ipairs(dirList) do
    local path, key, ext = fullPath:match("bitmaps/(.*/(.*)%.(.*))")
    if not fullPath:match("/%.svn") then
    local subTable = resources["graphics"][subDir] or {}
    resources["graphics"][subDir] = subTable
      if not filter or filter == ext then
        if not map then
          table.insert(subTable, path)
        else -- a mapped subtable
          subTable[key] = path
        end
      end
    end
  end
end

-- Add mod projectiletextures
AutoAdd("projectiletextures", true)

return resources
