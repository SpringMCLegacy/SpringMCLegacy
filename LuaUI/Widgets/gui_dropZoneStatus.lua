function widget:GetInfo()
   return {
      name     = "Dropzone Status Debug",
      desc     = "Displays dropzone status code",
      author   = "specing (Fedja Beader)",
      date     = "Jul 27, 2014",
      license  = "GNU AGPLv3",
      layer    = 0,
      enabled  = true
   }
end
-------------------------------------------------------------------------------------------------
--------------------------------------------- Data ----------------------------------------------
-------------------------------------------------------------------------------------------------
local GlDepthTest             = gl.DepthTest
local GlColor                 = gl.Color
local GlDrawFuncAtUnit        = gl.DrawFuncAtUnit
local GlTranslate             = gl.Translate
local GlBillboard             = gl.Billboard
local GlText                  = gl.Text

-- do not localize, it doesn't work otherwise
--local FhUseDefaultFont        = fontHandler.UseDefaultFont

local GetUnitDefID            = Spring.GetUnitDefID
local GetUnitRulesParam       = Spring.GetUnitRulesParam
-- variables
local flagUnitIDtoProdString  = {} -- maps all flags

-- constants
-------------------------------------------------------------------------------------------------
--------------------------------------------- Code ----------------------------------------------
-------------------------------------------------------------------------------------------------

if not fontHandler then
    fontHandler = VFS.Include("LuaUI/modfonts.lua")
end

-- generate a new production string (to be drawn on map) for every flag
local function GenNewFlagProdString(flagID)
  if flagID then
   flagUnitIDtoProdString[flagID] = Spring.GetTeamRulesParam(Spring.GetUnitTeam(flagID), "STATUS")
   end
end


-- draw on flags
function widget:DrawWorld()
   GlDepthTest(true)

   GlColor(1, 0, 0)
   fontHandler.UseDefaultFont()

   for flagID,prodStr in pairs(flagUnitIDtoProdString) do
      GlDrawFuncAtUnit(flagID, false, function(prodStr)
         GlTranslate(0, 80, -50)
         GlBillboard()
         GlText(prodStr, 0, 0, 16, "c")
      end, prodStr)
   end

   GlDepthTest(false)
end


function widget:GameFrame(n)
   if n then --% (60 * 30) == 1 then -- every minute, from first minute onwards
   --                  ^ gadget == 0
--    for _,unitID in ipairs(Spring.GetTeamUnitsByDefs(Spring.ALL_UNITS, flagDefID)i)  do
      for _,unitID in ipairs(Spring.GetAllUnits()) do
         local unitDefID = GetUnitDefID(unitID)
		 if unitDefID then
			local dropzone = UnitDefs[unitDefID].name:find("dropzone")
			if dropzone then
				local str = "Not known yet"
				flagUnitIDtoProdString[unitID] = str
			end
         end
      end

      for flagID,_ in pairs(flagUnitIDtoProdString) do
         GenNewFlagProdString(flagID)
      end
   end
end
