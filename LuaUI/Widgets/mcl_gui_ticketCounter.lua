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
local MY_ALLY_ID = select(6, Spring.GetTeamInfo(MY_TEAM_ID))

local UPLINK_ID = UnitDefNames["upgrade_uplink"].id

-- user settings
local clockConfig
local fpsConfig

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
colors.teamGreen = "\255\153\204\000"
colors.teamRed = "\255\172\089\089"

local btFont

local ticketText
local cBillsText = "C-Bills: " .. colors.grey .. 0
local tonnageText= "Tonnage: " .. colors.yellow .. 0
local gameTime = "Time: 0:00:00"
local dropTime = "Dropship: 00:00"
local artyTime = ""
local haveArty = 0
local fps = "fps: " .. colors.slategray .. GetFPS()
local tempAmbient = ""
local tempWater = ""

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
		local textCol = allyTeam == MY_ALLY_ID and colors.teamGreen or colors.teamRed
		ticketText = ticketText .. textCol .. "\nTeam " .. allyTeam .. colors.white .. ": " .. tickets
	end
end

function widget:GamePreload()
	tempAmbient = "Ambient: " .. GetGameRulesParam("MAP_TEMP_AMBIENT") .. " \'C"
	tempWater = "Water: " .. GetGameRulesParam("MAP_TEMP_WATER") .. " \'C"
end

function widget:Initialize()
	clockConfig = Spring.GetConfigInt('ShowClock')
	fpsConfig = Spring.GetConfigInt('ShowFPS')
	Spring.SendCommands("resbar 0", "clock 0", "fps 0")
	btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", 16, 2, 30)
	TicketText()
	haveArty = Spring.GetTeamUnitsCounts(MY_TEAM_ID)[UPLINK_ID] or 0
	if Spring.GetGameFrame() > 0 then
		widget:GamePreload()
	end
end

function widget:Shutdown()
	Spring.SetConfigInt('ShowClock', clockConfig)
	Spring.SetConfigInt('FPSClock', fpsConfig)
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
		local coolDownFrame = tonumber(GetTeamRulesParam(MY_TEAM_ID, "DROPSHIP_COOLDOWN") or 0)
		local countColour
		if coolDownFrame >= 0 then
			local frames = math.max(coolDownFrame - n, 0)
			countColour = frames == 0 and colors.green or colors.red		
			minutes, seconds = FramesToMinutesAndSeconds(frames)
		else -- dropship is currently ingame
			countColour = colors.red
			minutes, seconds = "00", "00"
		end
		dropTime = "Dropship: " .. countColour .. minutes .. colors.white .. ":" .. countColour ..seconds		
		if haveArty > 0 then
			frames = math.max(tonumber(GetTeamRulesParam(MY_TEAM_ID, "UPLINK_ARTILLERY") or 0) - n, 0)
			countColour = frames == 0 and colors.green or colors.red
			minutes, seconds = FramesToMinutesAndSeconds(frames)
			artyTime = "Artillery: " .. countColour .. minutes .. colors.white .. ":" .. countColour .. seconds
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

local tempHeight = yMax - 80 - (16 * #allyTeams)
local timeHeight = tempHeight - 48


function widget:ViewResize(viewSizeX, viewSizeY)
	xMax, yMax = viewSizeX, viewSizeY
end

function widget:DrawScreen()
	btFont:Begin()
		btFont:Print(cBillsText, xMax * 0.25, yMax - 32, 16, "od")
		btFont:Print(tonnageText, xMax * 0.45, yMax - 32, 16, "od")
		btFont:Print(dropTime, xMax * 0.75, yMax - 32, 16, "odr")
		if (haveArty or 0) > 0 then
			btFont:Print(artyTime, xMax * 0.75, yMax - 48, 16, "odr")
		end
		btFont:Print(ticketText, xMax - 148, yMax - 32, 16, "od")
		btFont:Print(tempAmbient, xMax - 16, tempHeight, 12, "odr")
		btFont:Print(tempWater, xMax - 16, tempHeight - 16, 12, "odr")

		btFont:Print(gameTime, xMax - 16, timeHeight, 12, "odr")
		btFont:Print(fps, xMax - 16, timeHeight - 16, 12, "odr")
	btFont:End()
end