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
local xMax, yMax = Spring.GetViewGeometry()

local colors = {}
colors.red = "\255\255\101\101"
colors.yellow = "\255\255\255\001"
colors.green = "\255\001\255\001"
colors.white = "\255\255\255\255"
colors.black = "\255\001\001\001"
colors.grey = "\255\160\160\160"

local btFont
local text = "C-Bills: " .. colors.grey .. 0 .. colors.white .. "\t\tTonnage: " .. colors.yellow .. 0 .. colors.white .. " / " .. colors.yellow .. 0 .. colors.white .. "\t\tTime: 0:00:00"
local text2
local gameTime = ""
local artyTime = ""
local haveArty = 0
local fps = colors.yellow .. "fps: " ..Spring.GetFPS()

local function FramesToMinutesAndSeconds(frames)
	local gameSecs = floor(frames / 30)
	local minutes = format("%02d",  floor(gameSecs / 60))
	local seconds = format("%02d", gameSecs % 60)
	return minutes, seconds
end

local function Text2()
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

function widget:Initialize()
	Spring.SendCommands("resbar 0", "clock 0", "fps 0")
	btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", 16, 2, 30)
	Text2()
end

function widget:PlayerChanged()
	MY_TEAM_ID = Spring.GetMyTeamID()
end

function widget:UnitCreated(unitID, unitDefID, teamID)
	if teamID == MY_TEAM_ID and unitDefID == UnitDefNames["upgrade_uplink"].id then
		haveArty = haveArty + 1 -- TODO: won't carry over on PlayerChanged atm
	end
end

function widget:UnitDestroyed(unitID, unitDefID, teamID)
	if teamID == MY_TEAM_ID and unitDefID == UnitDefNames["upgrade_uplink"].id then
		haveArty = haveArty - 1 -- TODO: won't carry over on PlayerChanged atm
	end
end

function widget:GameFrame(n)
	if n % 30 == 0 then
		local gameSecs = Spring.GetGameSeconds()
		local hours = format("%d",  floor(gameSecs / 3600))
		local minutes = format("%02d",  floor(gameSecs / 60))
		local seconds = format("%02d", gameSecs % 60)
		gameTime = colors.white .. "\t\tTime: " .. hours .. ":" .. minutes .. ":" .. seconds
		if haveArty > 0 then
			local frames = math.max(tonumber(Spring.GetTeamRulesParam(MY_TEAM_ID, "UPLINK_ARTILLERY") or 0) - n, 0)
			minutes, seconds = FramesToMinutesAndSeconds(frames)
			artyTime = colors.red .. "Artillery: " .. minutes .. ":" .. seconds
		end
		fps = colors.yellow .. "fps: " ..Spring.GetFPS()
	end
	if n % 32 == 0 then
		local cBills = floor(GetTeamResources(MY_TEAM_ID, "metal"))
		local tonnage, maxTonnage = GetTeamResources(MY_TEAM_ID, "energy")
		maxTonnage = floor(maxTonnage) 
		tonnage = floor(maxTonnage - (tonnage))
		text = "C-Bills: " .. colors.grey .. cBills .. colors.white .. "\t\tTonnage: " .. colors.yellow .. tonnage .. colors.white .. " / " .. colors.yellow .. maxTonnage .. gameTime
		Text2()
	end
end

function widget:DrawScreen()
	btFont:Begin()
		btFont:Print(text, xMax/2, yMax - 32, 16, "cod")
		if haveArty > 0 then
			btFont:Print(artyTime, xMax * 0.75, yMax - 32, 16, "cod")
		end
		btFont:Print(text2, xMax - 148, yMax - 32, 16, "od")
		btFont:Print(fps, xMax - 148, yMax - 72 - (16 * #allyTeams), 12, "od")
	btFont:End()
end