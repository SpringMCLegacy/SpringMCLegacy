function widget:GetInfo()
  return {
    name      = "BT:L - Ticket Counter",
    desc      = "displays Current Team Tickets",
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

local GetGameRulesParam = Spring.GetGameRulesParam

local btFont
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

function widget:Initialize()
	btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", 16, 2, 30)
end

function widget:DrawScreen()
	btFont:Begin()
		local text = "Tickets\n"
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
			text = text .. colors.white .. "\nTeam " .. allyTeam .. ": " .. tickets
		end
		btFont:Print(text, xMax - 90, yMax * 0.90, 16, "cod")
	btFont:End()
end