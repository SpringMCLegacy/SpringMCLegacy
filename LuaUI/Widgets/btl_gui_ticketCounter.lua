function widget:GetInfo()
  return {
    name      = "BT:L - Tickets & Resources",
    desc      = "Displays Current Team Tickets and Resources",
    author    = "FLOZi",
    date      = "06/04/2011",
    license   = "GNU GPL, v2",
    layer     = -1,
    enabled   = true  --  loaded by default?
  }
end

local modOptions
if (Spring.GetModOptions) then
  modOptions = Spring.GetModOptions()
end
local START_TICKETS = tonumber(modOptions.start_tickets) or 100
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local GAIA_ALLY_ID = select(6, Spring.GetTeamInfo(GAIA_TEAM_ID))
local MY_TEAM_ID = Spring.GetMyTeamID()

-- localisations
local floor 			= math.floor
local format			= string.format
local GetGameRulesParam	= Spring.GetGameRulesParam
local GetTeamResources	= Spring.GetTeamResources

local allyTeams = Spring.GetAllyTeamList()
for i = 1, #allyTeams do
	local allyTeam = allyTeams[i]
	if allyTeam == GAIA_ALLY_ID then allyTeams[i] = nil; break end
end
local xMax, yMax = Spring.GetScreenGeometry()

local colors = {}
colors.red = "\255\255\001\001"
colors.yellow = "\255\255\255\001"
colors.green = "\255\001\255\001"
colors.white = "\255\255\255\255"
colors.black = "\255\001\001\001"
colors.grey = "\255\128\128\128"

local btFont
local text = "C-Bills: " .. colors.grey .. 0 .. colors.white .. "\t\tTonnage: " .. colors.yellow .. 0 .. colors.white .. " / " .. colors.yellow .. 0 .. colors.white .. "\t\tTime: 0:00:00"
local text2 = ""
local gameTime = ""

function widget:Initialize()
	if Game.modShortName ~= "MWS" then
		widgetHandler:RemoveWidget()
		return
	end
  
	Spring.SendCommands("resbar 0", "clock 0")
	btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", 16, 2, 30)
end

function widget:GameFrame(n)
	if n % 30 == 0 then
		local gameSecs = Spring.GetGameSeconds()
		local hours = format("%d",  floor(gameSecs / 3600))
		local minutes = format("%02d",  floor(gameSecs / 60))
		local seconds = format("%02d", gameSecs % 60)
		gameTime = colors.white .. "\t\tTime: " .. hours .. ":" .. minutes .. ":" .. seconds
	end
	if n % 32 == 0 then
		local cBills = floor(GetTeamResources(MY_TEAM_ID, "metal"))
		local tonnage, maxTonnage = GetTeamResources(MY_TEAM_ID, "energy")
		tonnage = floor(maxTonnage - tonnage)
		text = "C-Bills: " .. colors.grey .. cBills .. colors.white .. "\t\tTonnage: " .. colors.yellow .. tonnage .. colors.white .. " / " .. colors.yellow .. maxTonnage .. gameTime
		text2 = "Tickets\n"
		for i = 1, #allyTeams do
			local allyTeam = allyTeams[i]
			local tickets = GetGameRulesParam("tickets" .. allyTeam) or START_TICKETS
			if tickets > START_TICKETS * 0.75 then
				tickets = colors.green .. tickets
			elseif tickets > START_TICKETS * 0.25 then
				tickets = colors.yellow .. tickets
			elseif tickets == 0 then
				tickets = colors.black .. tickets
			else
				tickets = colors.red .. tickets
			end
			text2 = text2 .. colors.white .. "\nTeam " .. allyTeam .. ": " .. tickets
		end
	end
end

function widget:DrawScreen()
	btFont:Begin()
		btFont:Print(text, xMax/2, yMax - 32, 16, "cod")
		btFont:Print(text2, xMax - 90, yMax - 32, 16, "cod")
	btFont:End()
end