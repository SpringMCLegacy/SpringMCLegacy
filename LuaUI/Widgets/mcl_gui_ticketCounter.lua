function widget:GetInfo()
  return {
    name      = "MC:L - Tickets & Resources",
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

local UPLINK_ID = UnitDefNames["upgrade_uplink"].id

-- localisations
-- lua
local floor 			= math.floor
local format			= string.format
-- SyncedRead
local GetFPS 			= Spring.GetFPS
local GetGameRulesParam	= Spring.GetGameRulesParam
local GetGameSeconds 	= Spring.GetGameSeconds
local GetTeamResources	= Spring.GetTeamResources
local GetTeamRulesParam	= Spring.GetTeamRulesParam

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
colors.slategray = "\255\198\226\255"

local btFont

local ticketText
local cBillsText = "C-Bills: " .. colors.grey .. 0
local tonnageText= "Tonnage: " .. colors.yellow .. 0
local gameTime = "Time: 0:00:00"
local artyTime = ""
local haveArty = 0
local fps = "fps: " .. colors.slategray .. GetFPS()

local function FramesToMinutesAndSeconds(frames)
	local gameSecs = floor(frames / 30)
	local minutes = format("%02d",  floor(gameSecs / 60))
	local seconds = format("%02d", gameSecs % 60)
	return minutes, seconds
end

local function TicketText()
	ticketText = "Tickets\n"
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
		ticketText = ticketText .. colors.white .. "\nTeam " .. allyTeam .. ": " .. tickets
	end
end

function widget:Initialize()
	Spring.SendCommands("resbar 0", "clock 0", "fps 0")
	btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", 16, 2, 30)
	TicketText()
	haveArty = Spring.GetTeamUnitsCounts(MY_TEAM_ID)[UPLINK_ID] or 0
end

function widget:PlayerChanged()
	MY_TEAM_ID = Spring.GetMyTeamID()
	haveArty = Spring.GetTeamUnitsCounts(MY_TEAM_ID)[UPLINK_ID] or 0 
end

function widget:UnitCreated(unitID, unitDefID, teamID)
	if teamID == MY_TEAM_ID and unitDefID == UPLINK_ID then
		haveArty = haveArty + 1
	end
end

function widget:UnitDestroyed(unitID, unitDefID, teamID)
	if teamID == MY_TEAM_ID and unitDefID == UPLINK_ID then
		haveArty = haveArty - 1
	end
end

function widget:GameFrame(n)
	if n % 30 == 0 then
		local gameSecs = GetGameSeconds()
		local hours = format("%d",  floor(gameSecs / 3600))
		local minutes = format("%02d",  floor(gameSecs / 60))
		local seconds = format("%02d", gameSecs % 60)
		gameTime = "Time: " .. colors.slategray .. hours .. colors.white .. ":" .. colors.slategray .. minutes .. colors.white .. ":" .. colors.slategray .. seconds
		if haveArty > 0 then
			local frames = math.max(tonumber(GetTeamRulesParam(MY_TEAM_ID, "UPLINK_ARTILLERY") or 0) - n, 0)
			minutes, seconds = FramesToMinutesAndSeconds(frames)
			artyTime = "Artillery: " .. colors.red .. minutes .. colors.white .. ":" .. colors.red .. seconds
		end
		fps = "fps: " .. colors.slategray .. GetFPS()
	end
	if n % 32 == 0 then
		local cBills = floor(GetTeamResources(MY_TEAM_ID, "metal"))
		cBillsText = "C-Bills: " .. colors.grey .. cBills
		local tonnage, maxTonnage = GetTeamResources(MY_TEAM_ID, "energy")
		maxTonnage = floor(maxTonnage) 
		tonnage = floor(maxTonnage - (tonnage))
		tonnageText = "Tonnage: " .. colors.yellow .. tonnage .. colors.white .. " / " .. colors.yellow .. maxTonnage
		TicketText()
	end
end

local timeHeight = yMax - 80 - (16 * #allyTeams)

function widget:DrawScreen()
	btFont:Begin()
		btFont:Print(cBillsText, xMax * 0.25, yMax - 32, 16, "od")
		btFont:Print(tonnageText, xMax * 0.45, yMax - 32, 16, "od")
		if (haveArty or 0) > 0 then
			btFont:Print(artyTime, xMax * 0.65, yMax - 32, 16, "od")
		end
		btFont:Print(ticketText, xMax - 148, yMax - 32, 16, "od")
		btFont:Print(gameTime, xMax - 148, timeHeight, 12, "od")
		btFont:Print(fps, xMax - 148, timeHeight - 16, 12, "od")
	btFont:End()
end