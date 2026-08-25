--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  MCL Shooter Weapon Group Selector
--  Revision 4
--
--  Companion LuaUI widget for gui_shooter_control_r45.lua.
--
--  Adds a compact N / 1 / 2 / 3 selector over the otherwise-unused strip
--  immediately above the stock Unit Card weapon list. The stock
--  mcl_gui_unitcard.lua remains untouched and continues to own the actual
--  single-column weapon buttons and native CMD_WEAPON_TOGGLE behavior.
--
--  N = no group / all manageable offensive weapons active.
--  1-3 = persistent Shooter weapon groups for the current Mech loadout.
--
--  The selector is visible only during Shooter Control. It is clickable only
--  while Shooter Control's Alt configuration mode is active; keyboard
--  selection remains owned by gui_shooter_control_r45.lua.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
    return {
        name      = "MCL Shooter Weapon Groups r4",
        desc      = "Compact N/1/2/3 weapon-group selector for Shooter Control r45",
        author    = "SpringMCLegacy",
        date      = "2026",
        license   = "GPLv2 or later",
        layer     = 6,
        enabled   = true,
    }
end

local Chili = nil
local selectorPanel = nil
local groupButtons = {}
local mounted = false
local lastGroup = nil
local lastConfigMode = nil

local SELECTED_COLOR = {0.68, 0.74, 0.18, 1.00}
local UNSELECTED_COLOR = {0.05, 0.05, 0.05, 0.78}
local CONFIG_COLOR = {0.18, 0.20, 0.08, 0.92}
local PASSIVE_COLOR = {0.08, 0.08, 0.08, 0.72}

local function GetShooter()
    return WG and WG.MCLShooterControl
end

local function ShooterIsActive()
    local shooter = GetShooter()

    if not shooter or not shooter.IsActive then
        return false
    end

    local ok, result = pcall(shooter.IsActive)
    return ok and result == true
end

local function ShooterIsConfigMode()
    local shooter = GetShooter()

    if not shooter or not shooter.IsConfigMode then
        return false
    end

    local ok, result = pcall(shooter.IsConfigMode)
    return ok and result == true
end

local function GetActiveGroup()
    local shooter = GetShooter()

    if not shooter or not shooter.GetActiveWeaponGroup then
        return 0
    end

    local ok, result = pcall(shooter.GetActiveWeaponGroup)

    if not ok then
        return 0
    end

    result = tonumber(result) or 0

    if result < 0 or result > 3 then
        return 0
    end

    return math.floor(result)
end

local function SelectGroup(groupNum)
    local shooter = GetShooter()

    if
        not shooter
        or not shooter.SelectWeaponGroup
        or not ShooterIsConfigMode()
    then
        return
    end

    pcall(
        shooter.SelectWeaponGroup,
        groupNum
    )
end

local function SetMounted(shouldMount)
    if not Chili or not selectorPanel then
        return
    end

    if shouldMount and not mounted then
        Chili.Screen0:AddChild(selectorPanel)
        mounted = true

    elseif not shouldMount and mounted then
        Chili.Screen0:RemoveChild(selectorPanel)
        mounted = false
    end
end

local function RefreshPresentation(force)
    if not selectorPanel then
        return
    end

    local activeGroup = GetActiveGroup()
    local configMode = ShooterIsConfigMode()

    if
        not force
        and activeGroup == lastGroup
        and configMode == lastConfigMode
    then
        return
    end

    lastGroup = activeGroup
    lastConfigMode = configMode

    selectorPanel.backgroundColor =
        configMode
        and CONFIG_COLOR
        or PASSIVE_COLOR

    selectorPanel:Invalidate()

    for groupNum = 0, 3 do
        local button = groupButtons[groupNum]

        if button then
            button.backgroundColor =
                groupNum == activeGroup
                and SELECTED_COLOR
                or UNSELECTED_COLOR

            button:Invalidate()
        end
    end
end

function widget:Initialize()
    Chili = WG and WG.Chili

    if not Chili then
        widgetHandler:RemoveWidget()
        return
    end

    selectorPanel = Chili.Panel:New{
        name = "shooter weapon groups",
        right = "0.91875%",
        y = "40.65625%",
        width = "3.675%",
        height = "2.625%",
        padding = {0, 0, 0, 0},
        backgroundColor = PASSIVE_COLOR,
    }

    local captions = {
        [0] = "N",
        [1] = "1",
        [2] = "2",
        [3] = "3",
    }

    for groupNum = 0, 3 do
        local thisGroup = groupNum

        groupButtons[thisGroup] = Chili.Button:New{
            parent = selectorPanel,
            name = "shooter weapon group " .. tostring(thisGroup),
            caption = captions[thisGroup],
            x = tostring(thisGroup * 25) .. "%",
            y = "0%",
            width = "25%",
            height = "100%",
            padding = {0, 0, 0, 0},
            backgroundColor = UNSELECTED_COLOR,
            tooltip =
                thisGroup == 0
                and "Shooter weapon group N: all manageable weapons active"
                or "Shooter weapon group " .. tostring(thisGroup),
            OnClick = {
                function()
                    SelectGroup(thisGroup)
                end,
            },
        }
    end

    RefreshPresentation(true)
end

function widget:Update(dt)
    local active = ShooterIsActive()

    SetMounted(active)

    if active then
        RefreshPresentation(false)
    else
        lastGroup = nil
        lastConfigMode = nil
    end
end

function widget:Shutdown()
    SetMounted(false)
    selectorPanel = nil
    groupButtons = {}
    Chili = nil
end
