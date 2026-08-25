--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  MCL Isometric Shooter Control
--  Revision 44 - Native Command Whitelist and Weapon Groups
--
--  UNSYNCED WIDGET
--
--  Controls:
--
--      E       = enter / leave shooter mode
--      W / S   = forward / reverse relative to current chassis heading
--      A / D   = left / right relative to current chassis heading
--      Mouse   = world-space torso aim point
--      RMB     = hold for camera look/pan; cancel native Jump Aim
--      J       = native MCL jump targeting
--      LMB     = fire all eligible offensive weapons / confirm an in-range jump
--      Wheel   = zoom within shooter-camera limits
--      1/2/3   = select Shooter weapon group
--      N / 0   = no group; all manageable weapons active
--      Alt     = hold for Unit Card / weapon-group configuration cursor
--      R       = native MCL Radar / Stealth state cycle
--
--  Camera:
--
--      * fixed north-up orientation
--      * approximately 45-degree downward angle
--      * zoom range = 50% to 100% of the original r6 camera height
--      * cursor-driven camera pan with a hard leash to the controlled unit
--
--  This widget still pairs with:
--
--      LuaRules/Gadgets/unit_shooter_control_r45.lua
--
--  Jump execution remains entirely owned by unit_jumpjets.lua.
--  Offensive firing uses per-weapon targets in the synced shooter gadget;
--  AMS/interceptor weapons remain autonomous and are never touched by LMB.
--
--  Message protocol:
--
--      SHOOTER45|ENTER|unitID
--      SHOOTER45|MOVE|strafe|forward
--      SHOOTER45|AIM|x|y|z|targetType|targetID
--      SHOOTER45|FIRE|0/1
--      SHOOTER45|RUN|0/1
--      SHOOTER45|EXIT
--
--  r45:
--      * fixes the nonfunctional r44 input bridge for weapon groups and Alt UI
--      * intercepts Recoil group/select actions before native lance selection
--      * polls GetModKeyState() for Alt so other Alt-bound actions cannot hide it
--      * suspends aim/highlight/reticle and restores the pointer during Alt UI mode
--      * F/G/P/default C actions are explicitly blocked while Shooter owns the Mech
--      * r44 group storage/native weapon toggles and r43 gameplay remain otherwise unchanged
--
--  r44:
--      * replaces Shooter's bespoke two-state radar toggle with native MCL
--        CMD.ONOFF pass-through, preserving Radar Off / On / Stealth cycling
--      * adds an explicit native-command whitelist: MCL Jump, CMD.ONOFF and
--        native Unit Card weapon toggles pass; other RTS command modes clear
--      * 1/2/3 select persistent per-loadout Shooter weapon groups; N or 0
--        selects the fixed all-weapons state
--      * holding Alt suspends aim/fire/look ownership, restores the mouse
--        cursor and lets the existing Unit Card buttons edit the selected group
--      * group application uses MCL's native weapon active/disabled state;
--        AMS/interceptors and internal sight weapons are never group-managed
--      * pre-Shooter weapon enable/disable states are restored on exit
--      * all r43 camera, firing-lane, aiming and weapon behavior is preserved
--
--  r43:
--      * cursor movement no longer pans the camera by default
--      * holding RMB enables the existing leash-based look/pan behavior
--      * releasing RMB smoothly recenters the camera pan offset
--      * RMB still cancels native Jump Aim and does not enter look/pan there
--      * look/pan uses a smaller activation deadzone because it is now explicit
--      * r42 render-space follow smoothing and all aiming/firing behavior remain
--        otherwise unchanged
--
--  r42:
--      * camera follow uses Recoil's render-space GetUnitViewPosition()
--        when available instead of raw simulation-step unit position
--      * a persistent follow anchor lightly filters X/Z and more strongly
--        filters Y before the independent cursor-leash offset is applied
--      * camera anchor initializes directly on the Mech to avoid entry lag
--      * reticle, firing lane, aiming, weapons and movement remain r41
--
--  r41:
--      * firing-lane heading no longer depends on model-piece emit axes
--      * synced code exports a simulated torso yaw advanced with the
--        same target angle and live torso traverse speed used by TurnPiece
--      * removes model-specific axis offsets and walk-cycle wobble
--      * all r40 lane styling and gameplay behavior are otherwise unchanged
--
--  r37:
--      * hover stickiness now applies only to enemy units
--      * friendly units and features clear immediately when the pointer leaves them
--      * firing, lock, minimum-range, camera, aircraft and missile behavior remains r36
--
--  r36:
--      * protocol/revision synchronized with unit_shooter_control_r36.lua
--      * no unsynced aircraft, camera, hover, convergence or input changes
--      * synced weapon layer restores MCL minimum ranges for positional fire
--      * SSRMs and other canAttackGround=false weapons require a highlighted
--        enemy unit instead of falling back to a positional/ground target
--      * internal sight weapons are excluded from manual offensive control
--
--  r35:
--      * preserves r34 aircraft acquisition, altitude-plane aiming, camera
--        decoupling and MCL projectile-target guidance behavior unchanged
--      * protocol/revision synchronized with unit_shooter_control_r35.lua
--      * no unsynced camera, hover, convergence or input behavior changes
--
--  r34:
--      * protocol/revision synchronized with unit_shooter_control_r34.lua
--      * no unsynced targeting, aircraft, camera, hover or input changes
--      * synced projectile bridge now ignores MCL Lua-spawned replacements
--
--  r33:
--      * preserves r32 aircraft acquisition, altitude-plane aim and camera
--        decoupling unchanged
--      * protocol/revision synchronized with the synced projectile-target bridge
--      * no unsynced camera, hover, convergence or direct-fire behavior changes
--
--  r32:
--      * camera leash direction is resolved from the raw ground mouse ray and
--        is completely independent of combat aim-height / highlighted targets
--      * mousing over high aircraft can no longer redirect or snap the camera
--      * highlighted-unit metadata remains available to the synced guided path
--
--  r31:
--      * highlighted units/features define a true horizontal aim-height plane
--        intersected by the actual mouse ray, fixing isometric air-target offset
--      * enemy aircraft receive a larger soft-acquisition radius and priority
--        over ground soft targets inside that air-only window
--      * AIM messages once again carry highlighted enemy unit identity as
--        metadata; direct-fire weapons still use only the manual point aim
--      * guided/tracking weapons may use that unit identity in the synced gadget
--
--  r30:
--      * protocol/revision synchronized with unit_shooter_control_r30.lua
--      * no unsynced aiming, camera, hover or input behavior changes
--      * synced takeover now hard-purges stale offensive weapon targets
--
--  r29:
--      * default aim height is half the controlled Mech's live model height
--      * a highlighted unit/feature contributes only its engine aimPos Y height
--      * mouse-derived X/Z remain fully manual; no horizontal snap/tracking
--      * the synced gadget projects very close convergence farther downrange
--        on the same aim ray to prevent extreme close-range weapon angles
--
--  r28:
--      * shooter aim now targets an elevated universal combat-height point
--        above the terrain under the mouse rather than the terrain itself
--      * the world-space X marker is drawn at that elevated aim point
--      * a broken vertical line is drawn back down to ground level so the
--        floating-height aim is immediately readable
--      * firing remains fully manual and positional with no unit snapping
--
--  r27:
--      * enlarges the cursor camera-pan dead zone from 25% to 40% of the
--        screen-centre-to-edge distance
--      * maximum camera leash and pan response remain unchanged
--      * aiming and firing behavior remain identical to r26
--
--  r26:
--      * offensive aiming is fully unassisted: the crosshair never snaps to units
--      * AIM sends only the raw world-space pointer position (x/y/z)
--      * LMB always assigns positional weapon targets, never unit targets
--      * enemy/friendly/feature highlighting remains visual-only and cannot
--        influence aim coordinates or weapon targeting
--
--  r25:
--      * LMB is a held fire control for all eligible non-AMS weapons
--      * Jump Aim retains exclusive LMB ownership while the native J command is active
--      * FIRE state is sent to the synced gadget; releasing LMB immediately clears it
--      * leaving direct control explicitly releases FIRE before EXIT
--
--  r24:
--      * fixes the direct-control HUD crash when weapon-arc RulesParams have
--        not yet produced a value by storing each result before tonumber()
--
--  r23:
--      * each non-AMS weapon has an independent geometric bearing state
--      * arm fallback elevation/depression = +/- 90 degrees
--      * torso/direct fallback elevation/depression = +/- 45 degrees
--      * explicit per-weapon min/max pitch data overrides those fallbacks
--      * UnitDef maindir/maxangledif restrictions are included in legality
--      * physical elevation pieces clamp at their resolved mechanical limit
--      * HUD reports how many offensive weapons can geometrically bear
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "MCL Isometric Shooter Control r45",
		desc      = "Mech-only direct control with native-command whitelist, configurable weapon groups, Alt UI mode, hold-RMB look/pan and native weapon behavior",
		author    = "SpringMCLegacy",
		date      = "2026",
		license   = "GPLv2 or later",
		layer     = -100000,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local TOGGLE_KEY = string.byte("e")

-- The engine already binds J to MCL's normal "jump" action. We deliberately
-- do not consume J ourselves; allowing it to fall through preserves the stock
-- range-circle / arc targeting UI from unit_jumpjets.lua.
local JUMP_KEY = string.byte("j")

-- Shift is a held Run modifier in direct control.
local LEFT_SHIFT_KEY =
	(KEYSYMS and KEYSYMS.LSHIFT)
	or 304

local RIGHT_SHIFT_KEY =
	(KEYSYMS and KEYSYMS.RSHIFT)
	or 303

-- Direct control uses the existing world-space cross as the pointer.
-- Recoil has a built-in null cursor named "none".
local DIRECT_CURSOR_NAME = "none"

-- Default direct-fire height follows the controlled Mech's actual engine model
-- height. This fallback is used only if GetUnitHeight() cannot provide a value.
local FALLBACK_CONTROLLED_MECH_HEIGHT = 84

-- World reticle presentation for the elevated aim point.
local AIM_MARKER_HALF_WIDTH = 16
local AIM_MARKER_HALF_HEIGHT = 18
local AIM_MARKER_CENTER_GAP = 4
local AIM_MARKER_GROUND_OFFSET = 3
local AIM_GUIDE_SEGMENT = 10
local AIM_GUIDE_GAP = 8

local LANE_DIR_X_PARAM = "shooter_lane_dir_x"
local LANE_DIR_Z_PARAM = "shooter_lane_dir_z"

-- LMB visual feedback.
local FIRE_FLASH_DURATION = 0.12
local FIRE_HOLD_PULSE_SPEED = 9.5

-- Ground firing-lane visualization.
local LANE_GROUND_OFFSET = 4
local LANE_MIN_LENGTH = 24
local LANE_MAX_LENGTH = 650
local LANE_FADE_START_DISTANCE = 90
local LANE_FADE_FULL_DISTANCE = 300
local LANE_START_OFFSET_MULT = 1.10
local LANE_EDGE_HALF_WIDTH_MULT = 1.00
local LANE_EDGE_HALF_WIDTH_ADD = 18
local LANE_END_FADE_FRACTION = 0.24
local LANE_END_FADE_MIN = 110
local LANE_CHEVRON_SPACING = 48
local LANE_CHEVRON_FORWARD_SIZE = 18
local LANE_CHEVRON_HALF_WIDTH_MULT = 0.35

--------------------------------------------------------------------------------
-- Camera
--------------------------------------------------------------------------------

local CAMERA_ANGLE = math.rad(45)
local CAMERA_FLIPPED = -1

-- r6 height remains the maximum zoom-out.
local CAMERA_HEIGHT_MAX = 1250

-- Allow zooming in to 50% of the r6 height.
local CAMERA_HEIGHT_MIN = CAMERA_HEIGHT_MAX * 0.50

local CAMERA_FOV = 45
local CAMERA_TARGET_HEIGHT = 45

-- Multiplicative wheel zoom.
local CAMERA_ZOOM_STEP = 0.90

-- Role-based camera leash presets.
--
-- Unit descriptions are expected to follow MCL's convention:
--
--     [Weight Class] [Role]
--
-- Examples:
--     Light Scout
--     Heavy Brawler
--     Assault Sniper
--
-- The first token is ignored and the remainder is treated as the role.
--
-- r7's 450-elmo leash is retained as the Sniper baseline.
local ROLE_CAMERA_LEASH = {
    ["sniper"]       = 450,
    ["missile boat"] = 425,
    ["fire support"] = 425,
    ["scout"]        = 375,
    ["support"]      = 350,
    ["striker"]      = 325,
    ["skirmisher"]   = 325,
    ["brawler"]      = 250,
    ["juggernaut"]   = 225,
}

local DEFAULT_CAMERA_LEASH = 325
local cameraLeashMax = DEFAULT_CAMERA_LEASH
local controlledUnitRole = "default"

-- Fixed north-up isometric view foreshortens the useful aiming/panning space
-- toward map-south (+Z). Give only that direction extra leash.
--
-- Pure south receives the full multiplier. South-east / south-west blend
-- smoothly toward it based on their +Z component. North/east/west are
-- unchanged.
local CAMERA_SOUTH_LEASH_MULTIPLIER = 2.0

-- Mouse screen-space dead zone. No panning until the mouse is this fraction
-- of the way from screen centre to the screen edge.
local CAMERA_LEASH_DEADZONE = 0.18

-- Full leash is reached by this normalized screen distance.
local CAMERA_LEASH_FULL = 0.90

-- Smooth response speed for camera pan.
local CAMERA_PAN_RESPONSE = 8.0

-- Follow the rendered/interpolated unit position rather than the raw simulation
-- step. The second-stage filter is intentionally fast: it removes residual
-- tracking jitter without turning direct control into a trailing chase camera.
local CAMERA_FOLLOW_RESPONSE_XZ = 20.0
local CAMERA_FOLLOW_RESPONSE_Y = 11.0

--------------------------------------------------------------------------------
-- Update rates
--------------------------------------------------------------------------------

local MOVEMENT_SEND_RATE = 0.05
local AIM_SEND_RATE      = 0.033

--------------------------------------------------------------------------------
-- Spring aliases
--------------------------------------------------------------------------------

local spGetSelectedUnits   = Spring.GetSelectedUnits
local spGetUnitPosition    = Spring.GetUnitPosition
local spGetUnitViewPosition = Spring.GetUnitViewPosition
local spGetUnitTeam        = Spring.GetUnitTeam
local spGetMyTeamID        = Spring.GetMyTeamID
local spGetSpectatingState = Spring.GetSpectatingState

local spGetCameraState     = Spring.GetCameraState
local spGetCameraPosition  = Spring.GetCameraPosition
local spSetCameraState     = Spring.SetCameraState
local spSetCameraTarget    = Spring.SetCameraTarget

local spGetMouseState      = Spring.GetMouseState
local spTraceScreenRay     = Spring.TraceScreenRay
local spGetViewGeometry    = Spring.GetViewGeometry
local spGetGroundHeight    = Spring.GetGroundHeight
local spGetMouseCursor     = Spring.GetMouseCursor
local spSetMouseCursor     = Spring.SetMouseCursor

local spGetActiveCommand   = Spring.GetActiveCommand
local spSetActiveCommand   = Spring.SetActiveCommand

local spGetUnitDefID       = Spring.GetUnitDefID
local spGetUnitNeutral     = Spring.GetUnitNeutral
local spGetUnitRulesParam  = Spring.GetUnitRulesParam
local spGetUnitBasePosition = Spring.GetUnitBasePosition
local spGetUnitHeight      = Spring.GetUnitHeight
local spGetUnitRadius      = Spring.GetUnitRadius
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetFeatureTeam     = Spring.GetFeatureTeam
local spAreTeamsAllied     = Spring.AreTeamsAllied
local spGetUnitsInScreenRectangle = Spring.GetUnitsInScreenRectangle
local spWorldToScreenCoords = Spring.WorldToScreenCoords

local spSendLuaRulesMsg    = Spring.SendLuaRulesMsg

local spValidUnitID        = Spring.ValidUnitID
local spGetUnitIsDead      = Spring.GetUnitIsDead

local spEcho               = Spring.Echo

local sqrt  = math.sqrt
local exp   = math.exp
local max   = math.max
local min   = math.min
local sin   = math.sin

--------------------------------------------------------------------------------
-- Role-derived camera leash
--------------------------------------------------------------------------------

local function NormalizeRole(role)
    if not role then
        return nil
    end

    role = string.lower(role)
    role = role:gsub("^%s+", "")
    role = role:gsub("%s+$", "")
    role = role:gsub("%s+", " ")

    return role
end

local function GetUnitRoleAndLeash(unitID)
    local unitDefID = spGetUnitDefID(unitID)

    if not unitDefID then
        return "default", DEFAULT_CAMERA_LEASH
    end

    local ud = UnitDefs[unitDefID]

    if not ud then
        return "default", DEFAULT_CAMERA_LEASH
    end

    local description = ud.description or ""

    -- Drop the first whitespace-delimited token (the weight class) and treat
    -- the rest of the description as the role. This also supports multi-word
    -- roles such as "Missile Boat" and "Fire Support".
    local role =
        description:match("^%s*%S+%s+(.+)%s*$")

    role = NormalizeRole(role)

    if not role or role == "" then
        return "default", DEFAULT_CAMERA_LEASH
    end

    return role, ROLE_CAMERA_LEASH[role] or DEFAULT_CAMERA_LEASH
end

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local active = false
local controlledUnitID = nil

local previousCameraState = nil

-- Cursor state restored when direct control ends.
local previousCursorName = nil
local previousCursorScale = nil

-- Native Jump command state. We do not own the command itself; these values
-- only let the shooter widget decide which clicks/commands may pass through.
local jumpAimActive = false
local jumpCommandID = nil

-- Shift is a requested run state; synced code only engages native Mech Run()
-- while there is actual forward movement.
local leftShiftDown = false
local rightShiftDown = false
local runRequested = false

-- LMB is a held fire request outside native Jump Aim. The synced gadget owns
-- weapon targeting and all actual firing legality.
local fireRequested = false

-- When a valid jump click is allowed through, also let the matching mouse
-- release reach the engine even if the active command clears on mouse-down.
local passJumpMouseRelease = false

local cameraHeight = CAMERA_HEIGHT_MAX

-- Current smoothed leash offset in world X/Z.
local cameraPanX = 0
local cameraPanZ = 0
local lookPanRequested = false

-- Render-space follow anchor. Cursor leash stays independent so smoothing the
-- Mech does not soften or delay mouse-driven camera panning.
local cameraFollowX = nil
local cameraFollowY = nil
local cameraFollowZ = nil

local keyW = false
local keyA = false
local keyS = false
local keyD = false

local movementTimer = 0
local aimTimer = 0

local lastStrafe = nil
local lastForward = nil

local aimX = nil
local aimY = nil
local aimZ = nil
local aimGroundY = nil

local fireFlashTimer = 0
local fireHeldVisualTimer = 0

-- Object currently under the mouse cursor.
local hoverType = nil       -- "unit" / "feature" / nil
local hoverID = nil
local hoverLastSeen = 0

-- Target highlight colours.
local COLOR_FRIENDLY = {0.15, 1.00, 0.25, 0.95}
local COLOR_ENEMY    = {1.00, 0.12, 0.08, 0.98}
local COLOR_NEUTRAL  = {0.78, 0.78, 0.78, 0.92}

-- Enemy soft-target acquisition radius, in screen pixels. Ground targets
-- keep the existing window; aircraft deliberately receive a much larger one.
local ENEMY_ACQUIRE_RADIUS = 70
local AIR_ENEMY_ACQUIRE_RADIUS = 175

-- Retain the last highlighted target briefly after the cursor leaves it.
local TARGET_STICK_TIME = 1.0


-- Shooter-only UI/input state is deliberately encapsulated in one table. The
-- r43 widget is already close to Lua 5.1's 200 top-level-local limit.
local ShooterUI = {
    keyNone = string.byte("n"),
    keyZero = string.byte("0"),
    keyOne = string.byte("1"),
    keyTwo = string.byte("2"),
    keyThree = string.byte("3"),
    altKey = (KEYSYMS and (KEYSYMS.ALT or KEYSYMS.LALT)) or 0x134,
    configMode = false,

    -- Actions which must never escape into ordinary RTS command modes while
    -- Shooter owns the unit. The group/select actions are handled separately
    -- because they are repurposed for weapon-group selection.
    blockedActions = {
        "fight",
        "guard",
        "patrol",
        "controlunit",
        "directcontrol",
        "directunitcontrol",
    },

    weaponGroupsByLoadout = {},
    activeWeaponGroup = 0,
    activeWeaponGroupKey = nil,
    preShooterWeaponStates = nil,
    pendingWeaponStates = {},
}

--------------------------------------------------------------------------------
-- Validation
--------------------------------------------------------------------------------

local function IsMechUnitDefID(unitDefID)
	local ud =
		unitDefID
		and UnitDefs[unitDefID]

	local baseClass =
		ud
		and ud.customParams
		and ud.customParams.baseclass

	return
		type(baseClass) == "string"
		and string.lower(baseClass) == "mech"
end

local function UnitCanBeControlled(unitID)
	if not unitID then
		return false
	end

	if not spValidUnitID(unitID) then
		return false
	end

	if spGetUnitIsDead(unitID) then
		return false
	end

	if spGetUnitTeam(unitID) ~= spGetMyTeamID() then
		return false
	end

	return
		IsMechUnitDefID(
			spGetUnitDefID(unitID)
		)
end

--------------------------------------------------------------------------------
-- LuaUI -> LuaRules
--------------------------------------------------------------------------------

local function SendEnter(unitID)
	spSendLuaRulesMsg(
		"SHOOTER45|ENTER|" ..
		tostring(unitID)
	)
end

local function SendExit()
	spSendLuaRulesMsg("SHOOTER45|EXIT")
end

local function SendMove(strafe, forward)
	spSendLuaRulesMsg(
		"SHOOTER45|MOVE|" ..
		string.format("%.4f", strafe) ..
		"|" ..
		string.format("%.4f", forward)
	)
end

local function SendAim(x, y, z, targetType, targetID)
    local encodedType = targetType or "N"
    local encodedID = tonumber(targetID) or 0

	spSendLuaRulesMsg(
		"SHOOTER45|AIM|" ..
		string.format("%.3f", x) ..
		"|" ..
		string.format("%.3f", y) ..
		"|" ..
		string.format("%.3f", z) ..
        "|" .. encodedType ..
        "|" .. tostring(encodedID)
	)
end

local function SendFire(enable)
	spSendLuaRulesMsg(
		"SHOOTER45|FIRE|" ..
		(enable and "1" or "0")
	)
end

local function SendRun(enable)
	spSendLuaRulesMsg(
		"SHOOTER45|RUN|" ..
		(enable and "1" or "0")
	)
end


--------------------------------------------------------------------------------
-- Camera
--------------------------------------------------------------------------------

local function GetCameraFollowSourcePosition()
    if not controlledUnitID then
        return nil
    end

    -------------------------------------------------------------------------
    -- GetUnitViewPosition returns Recoil's render-space drawPos, which is
    -- interpolated for visual presentation between simulation updates.
    -------------------------------------------------------------------------

    if spGetUnitViewPosition then
        local x, y, z =
            spGetUnitViewPosition(
                controlledUnitID,
                false
            )

        if x then
            return x, y, z
        end
    end

    return spGetUnitPosition(controlledUnitID)
end

local function ResetCameraFollowAnchor()
    local x, y, z =
        GetCameraFollowSourcePosition()

    if x then
        cameraFollowX = x
        cameraFollowY = y
        cameraFollowZ = z
        return true
    end

    cameraFollowX = nil
    cameraFollowY = nil
    cameraFollowZ = nil
    return false
end

local function ApplyCameraState()
    if not active or not controlledUnitID then
        return
    end

    if not cameraFollowX then
        ResetCameraFollowAnchor()
    end

    if not cameraFollowX then
        return
    end

    spSetCameraState({
        name    = "ta",
        mode    = 1,

        px      = cameraFollowX + cameraPanX,
        py      = cameraFollowY + CAMERA_TARGET_HEIGHT,
        pz      = cameraFollowZ + cameraPanZ,

        angle   = CAMERA_ANGLE,
        flipped = CAMERA_FLIPPED,
        height  = cameraHeight,
        fov     = CAMERA_FOV,
    }, 0)
end

local function CalculateLeashTarget()
	if not controlledUnitID then
		return 0, 0
	end

	local ux, uy, uz =
		GetCameraFollowSourcePosition()

	if not ux then
		return 0, 0
	end

	local mx, my = spGetMouseState()
	local vsx, vsy = spGetViewGeometry()

	if not vsx or not vsy or vsx <= 0 or vsy <= 0 then
		return 0, 0
	end

	-------------------------------------------------------------------------
	-- Pan AMOUNT comes from screen-space mouse displacement.
	--
	-- This avoids a feedback loop where camera panning changes the cursor's
	-- traced world range, which would then demand still more panning.
	-------------------------------------------------------------------------

	local halfX = vsx * 0.5
	local halfY = vsy * 0.5

	local normX = (mx - halfX) / halfX
	local normY = (my - halfY) / halfY

	local screenRadius =
		sqrt(
			normX * normX +
			normY * normY
		)

	local panFactor = 0

	if screenRadius > CAMERA_LEASH_DEADZONE then
		panFactor =
			(screenRadius - CAMERA_LEASH_DEADZONE) /
			(CAMERA_LEASH_FULL - CAMERA_LEASH_DEADZONE)

		panFactor = max(0, min(1, panFactor))

		-- Smoothstep.
		panFactor =
			panFactor * panFactor *
			(3 - 2 * panFactor)
	end

	if panFactor <= 0 then
		return 0, 0
	end

	-------------------------------------------------------------------------
	-- Pan DIRECTION comes from the RAW ground mouse ray, not aimX/aimZ.
	--
	-- Combat aim can jump to a very high horizontal plane when an aircraft is
	-- highlighted. Using that elevated point for the camera leash caused the
	-- camera direction itself to jump. A ground-only trace is stable across
	-- highlight/altitude changes while preserving the same cursor-driven pan.
	-------------------------------------------------------------------------

	local resultA, resultB =
		spTraceScreenRay(
			mx,
			my,
			true,
			false,
			false,
			true
		)

	local leashPos = nil

	if type(resultB) == "table" then
		leashPos = resultB
	elseif type(resultA) == "table" then
		leashPos = resultA
	end

	if not leashPos or leashPos[1] == nil or leashPos[3] == nil then
		return 0, 0
	end

	local leashX = leashPos[1]
	local leashZ = leashPos[3]

	local dx = leashX - ux
	local dz = leashZ - uz

	local worldLength =
		sqrt(
			dx * dx +
			dz * dz
		)

	if worldLength < 0.001 then
		return 0, 0
	end

	dx = dx / worldLength
	dz = dz / worldLength

	-------------------------------------------------------------------------
	-- Directional south compensation.
	--
	-- Spring map coordinates use +Z toward map-south in this fixed north-up
	-- camera. Blend extra leash by the normalized southward component:
	--
	--     north / east / west = 1.00x
	--     pure south          = 1.35x
	--     south diagonals     = smoothly between
	-------------------------------------------------------------------------

	local southFactor =
		max(
			0,
			dz
		)

	local directionalLeashMultiplier =
		1 +
		(CAMERA_SOUTH_LEASH_MULTIPLIER - 1) *
		southFactor

	local leash =
		cameraLeashMax *
		directionalLeashMultiplier *
		panFactor

	return dx * leash, dz * leash
end

local function UpdateCamera(dt)
	if not active or not controlledUnitID then
		return
	end

    local sourceX, sourceY, sourceZ =
        GetCameraFollowSourcePosition()

    if not sourceX then
        return
    end

    if not cameraFollowX then
        cameraFollowX = sourceX
        cameraFollowY = sourceY
        cameraFollowZ = sourceZ
    else
        ---------------------------------------------------------------------
        -- Filter only the Mech-follow anchor. X/Z stay tight to fast movement;
        -- Y is softer because vertical stepping is especially visible in the
        -- fixed 45-degree isometric camera.
        ---------------------------------------------------------------------

        local followAlphaXZ =
            1 - exp(-CAMERA_FOLLOW_RESPONSE_XZ * dt)

        local followAlphaY =
            1 - exp(-CAMERA_FOLLOW_RESPONSE_Y * dt)

        cameraFollowX =
            cameraFollowX +
            (sourceX - cameraFollowX) * followAlphaXZ

        cameraFollowY =
            cameraFollowY +
            (sourceY - cameraFollowY) * followAlphaY

        cameraFollowZ =
            cameraFollowZ +
            (sourceZ - cameraFollowZ) * followAlphaXZ
    end

	local desiredPanX = 0
	local desiredPanZ = 0

	if lookPanRequested then
		desiredPanX, desiredPanZ =
			CalculateLeashTarget()
	end

	-------------------------------------------------------------------------
	-- Look/pan smoothing remains independent from Mech-follow smoothing.
	-- When RMB is released, desiredPan returns to zero and this same filter
	-- provides the smooth recenter instead of snapping the camera home.
	-------------------------------------------------------------------------

	local panAlpha =
		1 - exp(-CAMERA_PAN_RESPONSE * dt)

	cameraPanX =
		cameraPanX +
		(desiredPanX - cameraPanX) * panAlpha

	cameraPanZ =
		cameraPanZ +
		(desiredPanZ - cameraPanZ) * panAlpha

	spSetCameraTarget(
		cameraFollowX + cameraPanX,
		cameraFollowY + CAMERA_TARGET_HEIGHT,
		cameraFollowZ + cameraPanZ,
		0
	)
end

--------------------------------------------------------------------------------
-- Unit-relative movement input
--------------------------------------------------------------------------------

local function CalculateMovement()
	local strafe = 0
	local forward = 0

	if keyW then
		forward = forward + 1
	end

	if keyS then
		forward = forward - 1
	end

	if keyA then
		strafe = strafe - 1
	end

	if keyD then
		strafe = strafe + 1
	end

	if strafe == 0 and forward == 0 then
		return 0, 0
	end

	local length =
		sqrt(
			strafe * strafe +
			forward * forward
		)

	return strafe / length, forward / length
end

local function UpdateMovement(force)
	local strafe, forward =
		CalculateMovement()

	if
		force
		or strafe ~= lastStrafe
		or forward ~= lastForward
	then
		SendMove(strafe, forward)

		lastStrafe = strafe
		lastForward = forward
	end
end

--------------------------------------------------------------------------------
-- Mouse aim
--------------------------------------------------------------------------------

local function ExtractGroundPosition(a, b)
	if type(b) == "table" then
		return b[1], b[2], b[3]
	end

	if type(a) == "table" then
		return a[1], a[2], a[3]
	end

	return nil
end

local function GetControlledDefaultAimHeight()
    local modelHeight = nil

    if
        controlledUnitID
        and spGetUnitHeight
    then
        local rawModelHeight =
            spGetUnitHeight(
                controlledUnitID
            )

        modelHeight =
            tonumber(
                rawModelHeight
            )
    end

    if
        not modelHeight
        or modelHeight <= 0
    then
        modelHeight = FALLBACK_CONTROLLED_MECH_HEIGHT
    end

    return modelHeight * 0.5
end

local function GetObjectAimPosition(objectType, objectID)
    if
        not objectType
        or not objectID
    then
        return nil
    end

    if objectType == "unit" then
        if
            not spValidUnitID(objectID)
            or spGetUnitIsDead(objectID)
        then
            return nil
        end

        local baseX, baseY, baseZ, aimPosX, aimPosY, aimPosZ =
            spGetUnitPosition(
                objectID,
                false,
                true
            )

        if baseX then
            return
                aimPosX or baseX,
                aimPosY or baseY,
                aimPosZ or baseZ
        end

        return nil
    end

    if
        objectType == "feature"
        and spGetFeaturePosition
    then
        local baseX, baseY, baseZ, aimPosX, aimPosY, aimPosZ =
            spGetFeaturePosition(
                objectID,
                false,
                true
            )

        if baseX then
            return
                aimPosX or baseX,
                aimPosY or baseY,
                aimPosZ or baseZ
        end
    end

    return nil
end

local function ResolveMouseRayAtHeight(mx, my, planeY)
    if
        not spGetCameraPosition
        or planeY == nil
    then
        return nil
    end

    local resultA, resultB =
        spTraceScreenRay(
            mx,
            my,
            true,
            false,
            false,
            true
        )

    local groundX, groundY, groundZ =
        ExtractGroundPosition(
            resultA,
            resultB
        )

    if not groundX then
        return nil
    end

    local camX, camY, camZ =
        spGetCameraPosition()

    if
        not camX
        or not camY
        or not camZ
    then
        return nil
    end

    local rayDY = groundY - camY

    if math.abs(rayDY) < 0.0001 then
        return nil
    end

    local t =
        (planeY - camY) /
        rayDY

    -- A valid target-height plane must lie in front of the camera on the same
    -- mouse ray. If not, retain the ordinary ground-derived fallback.
    if t <= 0 then
        return nil
    end

    local x =
        camX +
        (groundX - camX) * t

    local z =
        camZ +
        (groundZ - camZ) * t

    return x, planeY, z
end

local function ResolveCombatAimPoint(mx, my)
    local resultA, resultB =
        spTraceScreenRay(
            mx,
            my,
            true,
            false,
            false,
            true
        )

    local groundX, groundY, groundZ =
        ExtractGroundPosition(
            resultA,
            resultB
        )

    if not groundX then
        return nil
    end

    -------------------------------------------------------------------------
    -- Highlighted targets define an absolute horizontal aim-height plane.
    -- Intersecting the actual mouse ray with that plane keeps the world-space
    -- reticle genuinely beneath the pointer even for high-flying aircraft.
    -- Target X/Z are never used for direct-fire aim.
    -------------------------------------------------------------------------

    local targetAimX, targetAimY, targetAimZ =
        GetObjectAimPosition(
            hoverType,
            hoverID
        )

    if targetAimY then
        local x, y, z =
            ResolveMouseRayAtHeight(
                mx,
                my,
                targetAimY
            )

        if x then
            local localGroundY =
                spGetGroundHeight(
                    x,
                    z
                )

            return x, y, z, localGroundY
        end
    end

    -------------------------------------------------------------------------
    -- No highlighted object: preserve r29/r30's default manual convergence at
    -- half the controlled Mech's model height above the terrain under mouse.
    -------------------------------------------------------------------------

    local y =
        groundY +
        GetControlledDefaultAimHeight()

    return
        groundX,
        y,
        groundZ,
        groundY
end


local function IsFriendlyUnit(unitID)
    local targetTeam = spGetUnitTeam(unitID)

    if targetTeam == nil then
        return false
    end

    local myTeam = spGetMyTeamID()

    return
        targetTeam == myTeam
        or (
            spAreTeamsAllied
            and spAreTeamsAllied(myTeam, targetTeam)
        )
end

local function IsEnemyUnit(unitID)
    if spGetUnitNeutral and spGetUnitNeutral(unitID) then
        return false
    end

    local targetTeam = spGetUnitTeam(unitID)

    if targetTeam == nil then
        return false
    end

    local myTeam = spGetMyTeamID()

    if targetTeam == myTeam then
        return false
    end

    if
        spAreTeamsAllied
        and spAreTeamsAllied(myTeam, targetTeam)
    then
        return false
    end

    return true
end

local function IsAirUnit(unitID)
    if
        not unitID
        or not spGetUnitDefID
    then
        return false
    end

    local unitDefID =
        spGetUnitDefID(
            unitID
        )

    local ud =
        unitDefID
        and UnitDefs[unitDefID]

    if not ud then
        return false
    end

    return
        ud.isAirUnit == true
        or ud.canFly == true
end

local function FindSoftEnemyTarget(mx, my)
    if
        not spGetUnitsInScreenRectangle
        or not spWorldToScreenCoords
    then
        return nil
    end

    local searchRadius =
        AIR_ENEMY_ACQUIRE_RADIUS

    local units =
        spGetUnitsInScreenRectangle(
            mx - searchRadius,
            my - searchRadius,
            mx + searchRadius,
            my + searchRadius
        )

    if not units then
        return nil
    end

    local bestAirID = nil
    local bestAirDistSq =
        AIR_ENEMY_ACQUIRE_RADIUS *
        AIR_ENEMY_ACQUIRE_RADIUS

    local bestGroundID = nil
    local bestGroundDistSq =
        ENEMY_ACQUIRE_RADIUS *
        ENEMY_ACQUIRE_RADIUS

    for i = 1, #units do
        local unitID = units[i]

        if
            unitID ~= controlledUnitID
            and IsEnemyUnit(unitID)
        then
            local ux, uy, uz =
                GetObjectAimPosition(
                    "unit",
                    unitID
                )

            if ux then
                local sx, sy =
                    spWorldToScreenCoords(
                        ux,
                        uy,
                        uz
                    )

                if sx and sy then
                    local dx = sx - mx
                    local dy = sy - my
                    local distSq =
                        dx * dx +
                        dy * dy

                    if IsAirUnit(unitID) then
                        if distSq < bestAirDistSq then
                            bestAirDistSq = distSq
                            bestAirID = unitID
                        end
                    elseif distSq < bestGroundDistSq then
                        bestGroundDistSq = distSq
                        bestGroundID = unitID
                    end
                end
            end
        end
    end

    -- Aircraft deliberately win soft acquisition whenever one lies inside the
    -- expanded air-only window. This prevents terrain/ground units beneath an
    -- aircraft from stealing its altitude plane or guided-weapon target.
    return bestAirID or bestGroundID
end


local function UpdateAim()
    if ShooterUI.configMode then
        return
    end

    local mx, my =
        spGetMouseState()

    local now =
        Spring.GetTimer()

    -------------------------------------------------------------------------
    -- Highlight acquisition.
    --
    -- Ground enemies keep the existing soft window. Aircraft get a larger
    -- air-only window and soft-acquisition priority. Highlight identity may
    -- select the aim-height plane and may be handed to guided weapons, but it
    -- never supplies direct-fire X/Z coordinates.
    -------------------------------------------------------------------------

    local objectType, objectData =
        spTraceScreenRay(
            mx,
            my,
            false,
            false,
            false,
            true
        )

    local candidateType = nil
    local candidateID = nil

    if objectType == "unit" and objectData then
        candidateType = "unit"
        candidateID = objectData
    end

    local softEnemy =
        FindSoftEnemyTarget(mx, my)

    if softEnemy then
        candidateType = "unit"
        candidateID = softEnemy

    elseif
        not candidateID
        and objectType == "feature"
        and objectData
    then
        candidateType = "feature"
        candidateID = objectData
    end

    if candidateID then
        hoverType = candidateType
        hoverID = candidateID
        hoverLastSeen = now

    elseif hoverID then
        ---------------------------------------------------------------------
        -- Enemy-only sticky retention.
        --
        -- The soft enemy-acquisition window benefits from a short grace
        -- period as the cursor moves across/around a target. Friendly units
        -- and features are exact-hover presentation only and must disappear
        -- immediately once the pointer leaves them.
        ---------------------------------------------------------------------

        local retainEnemy =
            hoverType == "unit"
            and IsEnemyUnit(hoverID)

        if retainEnemy then
            local age =
                Spring.DiffTimers(
                    now,
                    hoverLastSeen
                )

            if age > TARGET_STICK_TIME then
                hoverType = nil
                hoverID = nil
            end
        else
            hoverType = nil
            hoverID = nil
        end
    end

    -------------------------------------------------------------------------
    -- Dynamic 3D point aim.
    --
    -- With no highlight, r29/r30's half-Mech-height convergence remains. With
    -- a highlight, the mouse ray is intersected with the target's aimPos-height
    -- plane. This fixes isometric displacement for aircraft while preserving
    -- manual horizontal leading.
    -------------------------------------------------------------------------

    local x, y, z, groundY =
        ResolveCombatAimPoint(
            mx,
            my
        )

    if not x then
        aimX = nil
        aimY = nil
        aimZ = nil
        aimGroundY = nil
        return
    end

    aimX = x
    aimY = y
    aimZ = z
    aimGroundY = groundY

    local guidedTargetType = "N"
    local guidedTargetID = 0

    if
        hoverType == "unit"
        and hoverID
        and IsEnemyUnit(hoverID)
    then
        guidedTargetType = "U"
        guidedTargetID = hoverID
    end

    SendAim(
        x,
        y,
        z,
        guidedTargetType,
        guidedTargetID
    )
end

--------------------------------------------------------------------------------
-- Direct-control cursor + native jump integration
--------------------------------------------------------------------------------

local function ForceDirectCursor()
	if
		not active
		or ShooterUI.configMode
		or not spSetMouseCursor
	then
		return
	end

	-- Cursor presentation is non-critical. Never allow a cursor failure to
	-- interrupt direct-control movement/aim call-ins.
	pcall(
		spSetMouseCursor,
		DIRECT_CURSOR_NAME,
		1
	)
end

local function RestoreCursor()
	if not spSetMouseCursor then
		return
	end

	pcall(
		spSetMouseCursor,
		previousCursorName or "",
		previousCursorScale or 1
	)
end

local function ControlledUnitHasJumpJets()
	if
		not controlledUnitID
		or not spGetUnitDefID
	then
		return false
	end

	local unitDefID =
		spGetUnitDefID(
			controlledUnitID
		)

	local ud =
		unitDefID
		and UnitDefs[unitDefID]

	local rawJumpJets =
		ud
		and ud.customParams
		and ud.customParams.jumpjets

	if rawJumpJets == nil then
		return false
	end

	local jumpJets =
		tonumber(
			rawJumpJets
		)

	return
		jumpJets ~= nil
		and jumpJets > 0
end

local function GetNativeJumpCommand()
	if
		not ControlledUnitHasJumpJets()
		or not spGetActiveCommand
	then
		return false, nil
	end

	local cmdIndex, cmdID, cmdType, cmdName =
		spGetActiveCommand()

	local normalizedName =
		cmdName
		and string.lower(
			tostring(cmdName)
		)

	if
		cmdID
		and normalizedName
		and string.find(
			normalizedName,
			"jump",
			1,
			true
		)
	then
		return true, cmdID
	end

	return false, nil
end

local function RefreshJumpAimState()
	local isJump, cmdID =
		GetNativeJumpCommand()

	jumpAimActive =
		isJump

	if
		isJump
		and cmdID
	then
		jumpCommandID =
			cmdID
	else
		jumpCommandID = nil
	end

	return isJump, cmdID
end

local function CancelJumpAim()
	if
		RefreshJumpAimState()
		and spSetActiveCommand
	then
		spSetActiveCommand(nil)
	end

	jumpAimActive = false
	passJumpMouseRelease = false
end

local function GetCurrentJumpRange()
	if
		not controlledUnitID
		or not spGetUnitDefID
	then
		return nil
	end

	-------------------------------------------------------------------------
	-- Prefer unit_jumpjets.lua's live RulesParam because perks/modifiers can
	-- alter range after UnitDef creation.
	-------------------------------------------------------------------------

	if spGetUnitRulesParam then
		local rawLiveRange =
			spGetUnitRulesParam(
				controlledUnitID,
				"jumpRange"
			)

		local liveRange =
			rawLiveRange ~= nil
			and tonumber(
				rawLiveRange
			)
			or nil

		if
			liveRange
			and liveRange > 0
		then
			return liveRange
		end
	end

	-------------------------------------------------------------------------
	-- Defensive fallback: unit_jumpjets.lua initializes range to
	--
	--     150 * customParams.jumpjets
	-------------------------------------------------------------------------

	local unitDefID =
		spGetUnitDefID(
			controlledUnitID
		)

	local ud =
		unitDefID
		and UnitDefs[unitDefID]

	local jumpjets =
		ud
		and ud.customParams
		and tonumber(
			ud.customParams.jumpjets
		)

	if
		jumpjets
		and jumpjets > 0
	then
		return 150 * jumpjets
	end

	return nil
end

local function GetJumpOrigin()
	if not controlledUnitID then
		return nil
	end

	if spGetUnitBasePosition then
		local x, y, z =
			spGetUnitBasePosition(
				controlledUnitID
			)

		if x then
			return x, y, z
		end
	end

	return
		spGetUnitPosition(
			controlledUnitID
		)
end

local function TraceGroundAtScreen(x, y)
	local resultA, resultB =
		spTraceScreenRay(
			x,
			y,
			true,
			false,
			false,
			true
		)

	return
		ExtractGroundPosition(
			resultA,
			resultB
		)
end

local function JumpPointIsInRange(x, z)
	if
		not x
		or not z
	then
		return false
	end

	local range =
		GetCurrentJumpRange()

	if not range then
		return false
	end

	local ux, uy, uz =
		GetJumpOrigin()

	if not ux then
		return false
	end

	local dx =
		x - ux

	local dz =
		z - uz

	local distSq =
		dx * dx +
		dz * dz

	-- Match unit_jumpjets.lua exactly: strict "<", not "<=".
	return
		distSq <
		(range * range)
end

local function JumpCommandParamsAreInRange(cmdParams)
	if
		not cmdParams
		or not cmdParams[1]
		or not cmdParams[3]
	then
		return false
	end

	return
		JumpPointIsInRange(
			cmdParams[1],
			cmdParams[3]
		)
end

--------------------------------------------------------------------------------
-- Native weapon groups / Alt UI configuration
--------------------------------------------------------------------------------

function ShooterUI.GetWeaponToggleCommandID()
    if not Spring.GetGameRulesParam then
        return nil
    end

    return tonumber(
        Spring.GetGameRulesParam("CMD_WEAPON_TOGGLE")
    )
end

function ShooterUI.IsManageableWeapon(unitID, weaponNum)
    if not unitID or not weaponNum then
        return false
    end

    local unitDefID = spGetUnitDefID(unitID)
    local unitDef = unitDefID and UnitDefs[unitDefID]
    local slot = unitDef and unitDef.weapons and unitDef.weapons[weaponNum]
    local weaponDef = slot and WeaponDefs[slot.weaponDef]

    if not weaponDef then
        return false
    end

    if (weaponDef.interceptor or 0) > 0 then
        return false
    end

    local cp = weaponDef.customParams or {}
    local weaponClass = string.lower(tostring(cp.weaponclass or ""))

    return weaponClass ~= "sight"
end

function ShooterUI.BuildLoadoutKey(unitID)
    local unitDefID = unitID and spGetUnitDefID(unitID)
    local unitDef = unitDefID and UnitDefs[unitDefID]

    if not unitDef then
        return nil
    end

    local parts = {
        tostring(unitDef.name or unitDefID or "unknown"),
    }

    local weapons = unitDef.weapons or {}

    for weaponNum = 1, #weapons do
        local slot = weapons[weaponNum]
        local weaponDef = slot and WeaponDefs[slot.weaponDef]

        parts[#parts + 1] = tostring(
            weaponDef and weaponDef.name
            or slot and slot.weaponDef
            or "none"
        )
    end

    return table.concat(parts, "|")
end

function ShooterUI.EnsureGroups(unitID)
    local key = ShooterUI.BuildLoadoutKey(unitID)

    if not key then
        return nil, nil
    end

    local groups = ShooterUI.weaponGroupsByLoadout[key]

    if type(groups) ~= "table" then
        groups = {}
        ShooterUI.weaponGroupsByLoadout[key] = groups
    end

    for groupNum = 1, 3 do
        if type(groups[groupNum]) ~= "table" then
            groups[groupNum] = {}
        end
    end

    local unitDefID = spGetUnitDefID(unitID)
    local unitDef = unitDefID and UnitDefs[unitDefID]
    local weapons = unitDef and unitDef.weapons or {}

    for weaponNum = 1, #weapons do
        if ShooterUI.IsManageableWeapon(unitID, weaponNum) then
            for groupNum = 1, 3 do
                if groups[groupNum][weaponNum] == nil then
                    groups[groupNum][weaponNum] = true
                else
                    groups[groupNum][weaponNum] = groups[groupNum][weaponNum] == true
                end
            end
        end
    end

    return groups, key
end

function ShooterUI.GetWeaponStatus(unitID, weaponNum)
    if not unitID or not weaponNum then
        return nil
    end

    return spGetUnitRulesParam(
        unitID,
        "weapon_" .. tostring(weaponNum)
    )
end

function ShooterUI.ApplyDesiredWeaponState(unitID, weaponNum, desiredActive)
    if not ShooterUI.IsManageableWeapon(unitID, weaponNum) then
        return false
    end

    local status = ShooterUI.GetWeaponStatus(unitID, weaponNum)

    if status == "destroyed" then
        ShooterUI.pendingWeaponStates[weaponNum] = nil
        return false
    end

    if status ~= "active" and status ~= "disabled" then
        return false
    end

    local currentActive = status == "active"
    desiredActive = desiredActive == true

    if currentActive == desiredActive then
        ShooterUI.pendingWeaponStates[weaponNum] = nil
        return true
    end

    local cmdID = ShooterUI.GetWeaponToggleCommandID()

    if not cmdID or not Spring.GiveOrderToUnit then
        return false
    end

    Spring.GiveOrderToUnit(
        unitID,
        cmdID,
        {weaponNum},
        0
    )

    ShooterUI.pendingWeaponStates[weaponNum] = desiredActive
    return true
end

function ShooterUI.ApplyActiveGroup()
    if not active or not controlledUnitID then
        return
    end

    local groups, key = ShooterUI.EnsureGroups(controlledUnitID)
    ShooterUI.activeWeaponGroupKey = key

    if not groups then
        return
    end

    local unitDefID = spGetUnitDefID(controlledUnitID)
    local unitDef = unitDefID and UnitDefs[unitDefID]
    local weapons = unitDef and unitDef.weapons or {}

    for weaponNum = 1, #weapons do
        if ShooterUI.IsManageableWeapon(controlledUnitID, weaponNum) then
            local desiredActive = true

            if ShooterUI.activeWeaponGroup > 0 then
                desiredActive =
                    groups[ShooterUI.activeWeaponGroup][weaponNum] ~= false
            end

            ShooterUI.ApplyDesiredWeaponState(
                controlledUnitID,
                weaponNum,
                desiredActive
            )
        end
    end
end

function ShooterUI.SelectWeaponGroup(groupNum)
    groupNum = tonumber(groupNum)

    if not groupNum or groupNum < 0 or groupNum > 3 then
        return false
    end

    groupNum = math.floor(groupNum)

    if not active or not controlledUnitID then
        return false
    end

    ShooterUI.activeWeaponGroup = groupNum
    ShooterUI.ApplyActiveGroup()
    return true
end

function ShooterUI.CapturePreShooterWeaponStates(unitID)
    ShooterUI.preShooterWeaponStates = {}

    local unitDefID = unitID and spGetUnitDefID(unitID)
    local unitDef = unitDefID and UnitDefs[unitDefID]
    local weapons = unitDef and unitDef.weapons or {}

    for weaponNum = 1, #weapons do
        if ShooterUI.IsManageableWeapon(unitID, weaponNum) then
            local status = ShooterUI.GetWeaponStatus(unitID, weaponNum)

            if status == "active" or status == "disabled" then
                ShooterUI.preShooterWeaponStates[weaponNum] = status
            end
        end
    end
end

function ShooterUI.RestorePreShooterWeaponStates(unitID)
    if not ShooterUI.preShooterWeaponStates or not unitID then
        return
    end

    for weaponNum, desiredStatus in pairs(ShooterUI.preShooterWeaponStates) do
        if ShooterUI.IsManageableWeapon(unitID, weaponNum) then
            local currentStatus = ShooterUI.GetWeaponStatus(unitID, weaponNum)

            if
                currentStatus ~= "destroyed"
                and (currentStatus == "active" or currentStatus == "disabled")
                and currentStatus ~= desiredStatus
            then
                ShooterUI.ApplyDesiredWeaponState(
                    unitID,
                    weaponNum,
                    desiredStatus == "active"
                )
            end
        end
    end
end

function ShooterUI.UpdateGroupEditing()
    if not active or not controlledUnitID then
        return
    end

    local groups = ShooterUI.EnsureGroups(controlledUnitID)

    if not groups then
        return
    end

    local unitDefID = spGetUnitDefID(controlledUnitID)
    local unitDef = unitDefID and UnitDefs[unitDefID]
    local weapons = unitDef and unitDef.weapons or {}

    for weaponNum = 1, #weapons do
        if ShooterUI.IsManageableWeapon(controlledUnitID, weaponNum) then
            local status = ShooterUI.GetWeaponStatus(controlledUnitID, weaponNum)

            if status == "destroyed" then
                ShooterUI.pendingWeaponStates[weaponNum] = nil

            elseif status == "active" or status == "disabled" then
                local actualActive = status == "active"
                local pending = ShooterUI.pendingWeaponStates[weaponNum]

                if pending ~= nil then
                    if actualActive == pending then
                        ShooterUI.pendingWeaponStates[weaponNum] = nil
                    end

                elseif ShooterUI.activeWeaponGroup == 0 then
                    -- N/0 has a fixed meaning: all manageable weapons active.
                    if not actualActive then
                        ShooterUI.ApplyDesiredWeaponState(
                            controlledUnitID,
                            weaponNum,
                            true
                        )
                    end

                else
                    local desiredActive =
                        groups[ShooterUI.activeWeaponGroup][weaponNum] ~= false

                    if actualActive ~= desiredActive then
                        if ShooterUI.configMode then
                            -- The existing Unit Card changed this native MCL
                            -- weapon state while Alt configuration was active.
                            -- Learn that state into the selected group.
                            groups[ShooterUI.activeWeaponGroup][weaponNum] = actualActive
                        else
                            -- Outside configuration the selected group remains
                            -- authoritative if another UI action diverges.
                            ShooterUI.ApplyDesiredWeaponState(
                                controlledUnitID,
                                weaponNum,
                                desiredActive
                            )
                        end
                    end
                end
            end
        end
    end
end

function ShooterUI.ExtractGroupNumber(optLine, optWords)
    if type(optWords) == "table" then
        for i = #optWords, 1, -1 do
            local value = tonumber(optWords[i])
            if value then
                value = math.floor(value)
                if value >= 0 and value <= 3 then
                    return value
                end
            end
        end
    end

    if type(optLine) == "string" then
        local inGroup = optLine:match("[Ii]n[Gg]roup_(%d+)")
        local value = tonumber(inGroup)

        if not value then
            value = tonumber(optLine:match("(%d+)%s*$"))
        end

        if value then
            value = math.floor(value)
            if value >= 0 and value <= 3 then
                return value
            end
        end
    end

    return nil
end

function ShooterUI.HandleGroupAction(cmd, optLine, optWords, data, isRepeat)
    if not active then
        return false
    end

    if not isRepeat then
        local groupNum = ShooterUI.ExtractGroupNumber(optLine, optWords)
        if groupNum ~= nil then
            ShooterUI.SelectWeaponGroup(groupNum)
        end
    end

    -- Consume every native control-group action while Shooter is active so
    -- number keys cannot change the selected lance underneath direct control.
    return true
end

function ShooterUI.HandleSelectAction(cmd, optLine, optWords, data, isRepeat)
    if not active then
        return false
    end

    if not isRepeat then
        local groupNum = ShooterUI.ExtractGroupNumber(optLine, optWords)
        if groupNum ~= nil then
            ShooterUI.SelectWeaponGroup(groupNum)
        end
    end

    -- Some MCL/Recoil keymaps express control groups as select filters rather
    -- than the native group action. Direct control owns selection completely.
    return true
end

function ShooterUI.HandleBlockedAction()
    return active == true
end

function ShooterUI.RegisterInputActions()
    if not widgetHandler or not widgetHandler.AddAction then
        return
    end

    widgetHandler:AddAction(
        "group",
        ShooterUI.HandleGroupAction,
        nil,
        "pR"
    )

    widgetHandler:AddAction(
        "select",
        ShooterUI.HandleSelectAction,
        nil,
        "pR"
    )

    for i = 1, #ShooterUI.blockedActions do
        widgetHandler:AddAction(
            ShooterUI.blockedActions[i],
            ShooterUI.HandleBlockedAction,
            nil,
            "pR"
        )
    end
end

function ShooterUI.PollAltConfigMode()
    if not active or not Spring.GetModKeyState then
        return
    end

    local altDown = Spring.GetModKeyState()
    altDown = altDown == true

    if altDown ~= ShooterUI.configMode then
        ShooterUI.SetConfigMode(altDown)
    end
end

function ShooterUI.SetConfigMode(enabled)
    enabled = enabled == true

    if not active or ShooterUI.configMode == enabled then
        return
    end

    if enabled then
        if fireRequested then
            fireRequested = false
            SendFire(false)
        end

        lookPanRequested = false
        CancelJumpAim()
        ShooterUI.configMode = true
        hoverType = nil
        hoverID = nil
        RestoreCursor()
    else
        ShooterUI.configMode = false
        UpdateAim()
        ForceDirectCursor()
    end
end

--------------------------------------------------------------------------------
-- Input reset
--------------------------------------------------------------------------------

local function ResetInput()
	keyW = false
	keyA = false
	keyS = false
	keyD = false

	leftShiftDown = false
	rightShiftDown = false
	runRequested = false
	ShooterUI.configMode = false
	fireRequested = false
	lookPanRequested = false
	fireFlashTimer = 0
	fireHeldVisualTimer = 0

	lastStrafe = nil
	lastForward = nil
end

--------------------------------------------------------------------------------
-- Shooter-mode lifecycle
--------------------------------------------------------------------------------

local function EnterShooterMode()
	if active then
		return
	end

	local spectating =
		spGetSpectatingState()

	if spectating then
		spEcho("[Shooter] Spectators cannot enter shooter mode.")
		return
	end

	local selectedUnits =
		spGetSelectedUnits()

	if not selectedUnits or #selectedUnits ~= 1 then
		spEcho("[Shooter] Select exactly one unit first.")
		return
	end

	local unitID =
		selectedUnits[1]

	if not UnitCanBeControlled(unitID) then
		spEcho("[Shooter] Selected unit is not controllable.")
		return
	end

	previousCameraState =
		spGetCameraState()

	if spGetMouseCursor then
		local ok, cursorName, cursorScale =
			pcall(
				spGetMouseCursor
			)

		if ok then
			previousCursorName = cursorName
			previousCursorScale = cursorScale
		end
	end

	-- Clear any stale RTS command mode before direct control takes ownership.
	if spSetActiveCommand then
		spSetActiveCommand(nil)
	end

	controlledUnitID = unitID
	active = true

	controlledUnitRole, cameraLeashMax =
		GetUnitRoleAndLeash(controlledUnitID)

	cameraHeight = CAMERA_HEIGHT_MAX
	cameraPanX = 0
	cameraPanZ = 0
	cameraFollowX = nil
	cameraFollowY = nil
	cameraFollowZ = nil
	ResetCameraFollowAnchor()
	hoverType = nil
	hoverID = nil
	hoverLastSeen = Spring.GetTimer()

	ResetInput()

	movementTimer = 0
	aimTimer = 0

	aimX = nil
	aimY = nil
	aimZ = nil
	aimGroundY = nil
	fireFlashTimer = 0
	fireHeldVisualTimer = 0
	hoverType = nil
	hoverID = nil
	hoverLastSeen = Spring.GetTimer()

	ShooterUI.pendingWeaponStates = {}
	ShooterUI.CapturePreShooterWeaponStates(controlledUnitID)
	ShooterUI.EnsureGroups(controlledUnitID)
	ShooterUI.activeWeaponGroup = 0

	SendEnter(controlledUnitID)
	ShooterUI.ApplyActiveGroup()

	ApplyCameraState()
	UpdateMovement(true)
	UpdateAim()
	UpdateCamera(1)
	RefreshJumpAimState()
	ForceDirectCursor()

	spEcho("[Shooter] Control engaged.")
end

local function LeaveShooterMode()
	if not active then
		return
	end

	local leavingUnitID =
		controlledUnitID

	local resumeX, resumeY, resumeZ = nil, nil, nil

	if leavingUnitID then
		resumeX, resumeY, resumeZ =
			spGetUnitPosition(
				leavingUnitID
			)

		if resumeX then
			resumeY =
				spGetGroundHeight(
					resumeX,
					resumeZ
				)
		end
	end

	CancelJumpAim()
	ShooterUI.configMode = false

	SendFire(false)
	SendRun(false)
	SendMove(0, 0)
	ShooterUI.RestorePreShooterWeaponStates(leavingUnitID)
	SendExit()

	active = false
	controlledUnitID = nil

	aimX = nil
	aimY = nil
	aimZ = nil
	aimGroundY = nil

	cameraPanX = 0
	cameraPanZ = 0
	cameraFollowX = nil
	cameraFollowY = nil
	cameraFollowZ = nil
	cameraLeashMax = DEFAULT_CAMERA_LEASH
	controlledUnitRole = "default"
	ShooterUI.activeWeaponGroup = 0
	ShooterUI.activeWeaponGroupKey = nil
	ShooterUI.preShooterWeaponStates = nil
	ShooterUI.pendingWeaponStates = {}

	jumpAimActive = false
	jumpCommandID = nil
	passJumpMouseRelease = false

	ResetInput()

	if previousCameraState then
		local resumeCameraState = {}

		for key, value
		in pairs(previousCameraState)
		do
			resumeCameraState[key] =
				value
		end

		-- In Recoil CameraState, px/py/pz are the world/ground point at the
		-- center of the screen. Replace only that point, retaining the player's
		-- old RTS camera controller, zoom and orientation.
		if resumeX then
			resumeCameraState.px = resumeX
			resumeCameraState.py = resumeY
			resumeCameraState.pz = resumeZ
		end

		spSetCameraState(
			resumeCameraState,
			0.25
		)
	end

	previousCameraState = nil

	RestoreCursor()
	previousCursorName = nil
	previousCursorScale = nil

	spEcho("[Shooter] Control released.")
end

--------------------------------------------------------------------------------
-- Reticle helpers
--------------------------------------------------------------------------------

local function Clamp01(value)
    if value <= 0 then
        return 0
    end

    if value >= 1 then
        return 1
    end

    return value
end

local function GetControlledUnitVisualData()
    if not controlledUnitID then
        return nil
    end

    local x, y, z =
        spGetUnitBasePosition(controlledUnitID)

    if not x then
        x, y, z =
            spGetUnitPosition(controlledUnitID)
    end

    if not x then
        return nil
    end

    local radius = nil

    if spGetUnitRadius then
        local ok, value =
            pcall(
                spGetUnitRadius,
                controlledUnitID
            )

        if ok then
            radius = value
        end
    end

    if not radius or radius <= 0 then
        local fallbackHeight =
            spGetUnitHeight(controlledUnitID)
            or FALLBACK_CONTROLLED_MECH_HEIGHT

        radius = fallbackHeight * 0.50
    end

    return x, y, z, radius
end

local function GetReticleFireVisuals()
    local flash = Clamp01(fireFlashTimer / FIRE_FLASH_DURATION)
    local holdPulse = 0

    if fireRequested then
        holdPulse =
            0.5 +
            0.5 * sin(fireHeldVisualTimer * FIRE_HOLD_PULSE_SPEED)
    end

    return flash, holdPulse
end

--------------------------------------------------------------------------------
-- Shared LuaUI state
--------------------------------------------------------------------------------
--
-- mcl_gui_rings_r1.lua reads this tiny interface so it can display the normal
-- attack-range rings for the directly controlled Mech without faking an
-- active CMD.ATTACK command.
--------------------------------------------------------------------------------

local shooterWGInterface = {
	IsActive =
		function()
			return active
		end,

	GetControlledUnitID =
		function()
			return controlledUnitID
		end,

	IsControlledUnit =
		function(unitID)
			return
				active
				and controlledUnitID ~= nil
				and unitID == controlledUnitID
		end,

	IsConfigMode =
		function()
			return active and ShooterUI.configMode
		end,

	GetActiveWeaponGroup =
		function()
			return active and ShooterUI.activeWeaponGroup or 0
		end,

	SelectWeaponGroup =
		function(groupNum)
			return ShooterUI.SelectWeaponGroup(groupNum)
		end,

	IsWeaponGroupManageable =
		function(weaponNum)
			return
				active
				and controlledUnitID ~= nil
				and ShooterUI.IsManageableWeapon(controlledUnitID, weaponNum)
		end,
}

--------------------------------------------------------------------------------
-- Widget call-ins
--------------------------------------------------------------------------------

function widget:Initialize()
	if WG then
		WG.MCLShooterControl =
			shooterWGInterface
	end

    ShooterUI.RegisterInputActions()
end

function widget:GetConfigData()
	return {
		weaponGroupsByLoadout = ShooterUI.weaponGroupsByLoadout,
	}
end

function widget:SetConfigData(data)
	if
		type(data) == "table"
		and type(data.weaponGroupsByLoadout) == "table"
	then
		ShooterUI.weaponGroupsByLoadout = data.weaponGroupsByLoadout
	end
end

function widget:SelectionChanged(selectedUnits)
	if
		active
		and controlledUnitID
		and Spring.SelectUnitArray
	then
		if
			not selectedUnits
			or #selectedUnits ~= 1
			or selectedUnits[1] ~= controlledUnitID
		then
			Spring.SelectUnitArray(
				{controlledUnitID},
				false
			)
		end
	end
end

function widget:Shutdown()
	if active then
		LeaveShooterMode()
	end

	if
		WG
		and WG.MCLShooterControl == shooterWGInterface
	then
		WG.MCLShooterControl = nil
	end
end

function widget:Update(dt)
	if not active then
		return
	end

	if not UnitCanBeControlled(controlledUnitID) then
		LeaveShooterMode()
		return
	end

	ShooterUI.PollAltConfigMode()
	ShooterUI.UpdateGroupEditing()

	-------------------------------------------------------------------------
	-- Aim first, then use the current aim direction for camera leash.
	-- Alt UI mode intentionally freezes the last aim solution and does not
	-- send new AIM messages while the pointer is being used for Chili UI.
	-------------------------------------------------------------------------

	if fireFlashTimer > 0 then
		fireFlashTimer = max(0, fireFlashTimer - dt)
	end

	if fireRequested then
		fireHeldVisualTimer = fireHeldVisualTimer + dt
	else
		fireHeldVisualTimer = 0
	end

	if not ShooterUI.configMode then
		aimTimer = aimTimer + dt

		if aimTimer >= AIM_SEND_RATE then
			aimTimer = 0
			UpdateAim()
		end
	else
		aimTimer = 0
	end

	UpdateCamera(dt)

	movementTimer = movementTimer + dt

	if movementTimer >= MOVEMENT_SEND_RATE then
		movementTimer = 0
		UpdateMovement(false)
	end
end

--------------------------------------------------------------------------------
-- Keyboard
--------------------------------------------------------------------------------

function widget:KeyPress(key, mods, isRepeat, label, unicode, scanCode, actions)
	if key == TOGGLE_KEY and not isRepeat then
		if active then
			LeaveShooterMode()
		else
			EnterShooterMode()
		end

		return true
	end

	if not active then
		return false
	end

    -- GetModKeyState polling is authoritative, but consume the physical Alt
    -- key as an immediate fallback when it reaches this widget.
    if
        key == ShooterUI.altKey
        or label == "alt"
    then
        ShooterUI.SetConfigMode(true)
        return true
    end

    -- Default physical bindings are blocked as a backup to the action-layer
    -- whitelist. Rebound fight/guard/patrol/direct-control actions are caught
    -- by ShooterUI.RegisterInputActions().
    if
        key == string.byte("f")
        or key == string.byte("g")
        or key == string.byte("p")
        or key == string.byte("c")
    then
        return true
    end


	if not isRepeat then
		if key == ShooterUI.keyOne then
			ShooterUI.SelectWeaponGroup(1)
			return true
		elseif key == ShooterUI.keyTwo then
			ShooterUI.SelectWeaponGroup(2)
			return true
		elseif key == ShooterUI.keyThree then
			ShooterUI.SelectWeaponGroup(3)
			return true
		elseif key == ShooterUI.keyZero or key == ShooterUI.keyNone then
			ShooterUI.SelectWeaponGroup(0)
			return true
		end
	end

	-- Alt configuration deliberately owns the pointer/UI. Do not allow the
	-- native Jump cursor mode to become armed underneath that UI state.
	if ShooterUI.configMode and key == JUMP_KEY then
		return true
	end

	-------------------------------------------------------------------------
	-- Let the engine/MCL process J only for a Mech that unit_jumpjets.lua
	-- actually recognizes as a jumper.
	--
	-- The global "jump" action can otherwise become the active command even
	-- when the selected Mech has no jumpjets, producing a false Jump Aim state
	-- with no arc. Consume J in that case and clear any stale command mode.
	-------------------------------------------------------------------------
	if
		key == LEFT_SHIFT_KEY
		or key == RIGHT_SHIFT_KEY
	then
		if key == LEFT_SHIFT_KEY then
			leftShiftDown = true
		else
			rightShiftDown = true
		end

		local shouldRun =
			leftShiftDown
			or rightShiftDown

		if
			shouldRun ~= runRequested
			and not isRepeat
		then
			runRequested = shouldRun
			SendRun(runRequested)
		end

		return true
	end


	if key == JUMP_KEY then
		if ControlledUnitHasJumpJets() then
			if fireRequested then
				fireRequested = false
				SendFire(false)
			end

			return false
		end

		jumpAimActive = false
		jumpCommandID = nil
		passJumpMouseRelease = false

		if spSetActiveCommand then
			pcall(
				spSetActiveCommand,
				nil
			)
		end

		return true
	end

	if key == string.byte("w") then
		keyW = true
		UpdateMovement(true)
		return true
	end

	if key == string.byte("a") then
		keyA = true
		UpdateMovement(true)
		return true
	end

	if key == string.byte("s") then
		keyS = true
		UpdateMovement(true)
		return true
	end

	if key == string.byte("d") then
		keyD = true
		UpdateMovement(true)
		return true
	end

	return false
end

function widget:KeyRelease(key, mods, label, unicode, scanCode, actions)
	if not active then
		return false
	end

    if
        key == ShooterUI.altKey
        or label == "alt"
    then
        ShooterUI.SetConfigMode(false)
        return true
    end


	if
		key == LEFT_SHIFT_KEY
		or key == RIGHT_SHIFT_KEY
	then
		if key == LEFT_SHIFT_KEY then
			leftShiftDown = false
		else
			rightShiftDown = false
		end

		local shouldRun =
			leftShiftDown
			or rightShiftDown

		if shouldRun ~= runRequested then
			runRequested = shouldRun
			SendRun(runRequested)
		end

		return true
	end


	if
		key == JUMP_KEY
		and not ControlledUnitHasJumpJets()
	then
		return true
	end

	if key == string.byte("w") then
		keyW = false
		UpdateMovement(true)
		return true
	end

	if key == string.byte("a") then
		keyA = false
		UpdateMovement(true)
		return true
	end

	if key == string.byte("s") then
		keyS = false
		UpdateMovement(true)
		return true
	end

	if key == string.byte("d") then
		keyD = false
		UpdateMovement(true)
		return true
	end

	return false
end

--------------------------------------------------------------------------------
-- Mouse
--------------------------------------------------------------------------------

function widget:MousePress(x, y, button)
	if not active then
		return false
	end

	if ShooterUI.configMode then
		return false
	end

	local hasJumpJets =
		ControlledUnitHasJumpJets()

	local isJump = false
	local cmdID = nil

	if hasJumpJets then
		isJump, cmdID =
			GetNativeJumpCommand()

		jumpAimActive =
			isJump

		if
			isJump
			and cmdID
		then
			jumpCommandID =
				cmdID
		end
	else
		jumpAimActive = false
		jumpCommandID = nil
		passJumpMouseRelease = false
	end

	-------------------------------------------------------------------------
	-- Native Jump targeting owns LMB while the J command is active.
	--
	-- LMB is passed through ONLY when the clicked terrain point is already
	-- within the Mech's current jump range. This prevents unit_jumpjets.lua
	-- from ever receiving an out-of-range CMD_JUMP, so its Approach() branch
	-- cannot create a move-into-range order.
	-------------------------------------------------------------------------

	if
		button == 1
		and isJump
	then
		if fireRequested then
			fireRequested = false
			SendFire(false)
		end

		local gx, gy, gz =
			TraceGroundAtScreen(
				x,
				y
			)

		if
			gx
			and JumpPointIsInRange(
				gx,
				gz
			)
		then
			passJumpMouseRelease = true

			-- Let the native command handler receive the click. It will create
			-- the ordinary MCL CMD_JUMP and unit_jumpjets.lua remains fully
			-- authoritative for landing validation, heat, crouch, turning,
			-- flight, reload, etc.
			return false
		end

		-- Out of range (or no valid terrain trace): consume the click and leave
		-- native Jump targeting active so the player can choose another point.
		passJumpMouseRelease = false
		return true
	end

	-------------------------------------------------------------------------
	-- RMB while Jump is active explicitly cancels the native command because
	-- ordinary shooter input consumes RMB.
	-------------------------------------------------------------------------

	if
		button == 3
		and isJump
	then
		lookPanRequested = false
		CancelJumpAim()
		ForceDirectCursor()
		return true
	end

	-------------------------------------------------------------------------
	-- Explicit look/pan mode.
	--
	-- RMB no longer behaves as a generic consumed button during ordinary
	-- Shooter Control. Holding it enables the existing cursor-leash camera
	-- offset; releasing it lets UpdateCamera smoothly drive that offset home.
	-------------------------------------------------------------------------

	if button == 3 then
		lookPanRequested = true
		return true
	end

	-------------------------------------------------------------------------
	-- Manual offensive firing.
	--
	-- Outside Jump Aim, LMB is a held fire request. LuaUI does not select,
	-- target or force individual weapons; it only tells synced code whether
	-- the trigger is currently down.
	-------------------------------------------------------------------------

	if button == 1 then
		if not fireRequested then
			fireRequested = true
			fireFlashTimer = FIRE_FLASH_DURATION
			fireHeldVisualTimer = 0
			SendFire(true)
		end

		return true
	end

	if button == 2 then
		return true
	end

	return false
end

function widget:MouseRelease(x, y, button)
	if not active then
		return false
	end

	if ShooterUI.configMode then
		return false
	end

	if
		button == 1
		and passJumpMouseRelease
	then
		passJumpMouseRelease = false

		-- Complete the valid native click even if the command was cleared on
		-- mouse-down after Spring issued it.
		return false
	end

	if button == 1 then
		if fireRequested then
			fireRequested = false
			SendFire(false)
		end

		return true
	end

	if button == 3 then
		lookPanRequested = false
		return true
	end

	if button == 2 then
		return true
	end

	return false
end

function widget:MouseWheel(up, value)
	if not active then
		return false
	end

    if ShooterUI.configMode then
        return false
    end

	if up then
		cameraHeight =
			cameraHeight * CAMERA_ZOOM_STEP
	else
		cameraHeight =
			cameraHeight / CAMERA_ZOOM_STEP
	end

	cameraHeight =
		max(
			CAMERA_HEIGHT_MIN,
			min(
				CAMERA_HEIGHT_MAX,
				cameraHeight
			)
		)

	-- Apply the new height while retaining the fixed camera orientation.
	ApplyCameraState()

	return true
end

--------------------------------------------------------------------------------
-- Suppress ordinary RTS commands while shooter mode is active.
--------------------------------------------------------------------------------

function widget:CommandNotify(cmdID, cmdParams, cmdOptions)
	if not active then
		return false
	end

	-------------------------------------------------------------------------
	-- Explicit native-command whitelist.
	--
	-- Shooter owns ordinary RTS orders. The only native command paths allowed
	-- through are MCL systems intentionally retained during direct control:
	--
	--   CMD.ONOFF          Radar Off / Radar On / Stealth
	--   CMD_WEAPON_TOGGLE  existing Unit Card weapon buttons
	--   native Jump        exact captured command, still range-guarded
	-------------------------------------------------------------------------

	if cmdID == CMD.ONOFF then
		return false
	end

	local weaponToggleCmdID = ShooterUI.GetWeaponToggleCommandID()

	if weaponToggleCmdID and cmdID == weaponToggleCmdID then
		return false
	end

	if
		jumpCommandID
		and cmdID == jumpCommandID
		and JumpCommandParamsAreInRange(cmdParams)
	then
		return false
	end

	return true
end

function widget:ActiveCommandChanged(cmdID, cmdType)
	if not active or not cmdID then
		return
	end

	if cmdID == CMD.ONOFF then
		return
	end

	local weaponToggleCmdID = ShooterUI.GetWeaponToggleCommandID()

	if weaponToggleCmdID and cmdID == weaponToggleCmdID then
		return
	end

	local isJump, activeJumpID = GetNativeJumpCommand()

	if isJump and activeJumpID == cmdID then
		jumpCommandID = cmdID
		jumpAimActive = true
		return
	end

	-- Fight/Guard/Patrol/Attack/etc. may become active cursor modes before an
	-- order exists for CommandNotify. Clearing every non-whitelisted mode also
	-- handles rebound keys rather than relying on the default F/G/P bindings.
	if spSetActiveCommand then
		pcall(
			spSetActiveCommand,
			nil
		)
	end
end

--------------------------------------------------------------------------------
-- Target highlighting
--------------------------------------------------------------------------------

local function GetHoverColor()
    if not hoverType or not hoverID then
        return nil
    end

    if hoverType == "feature" then
        return COLOR_NEUTRAL
    end

    if hoverType == "unit" then
        if spGetUnitNeutral and spGetUnitNeutral(hoverID) then
            return COLOR_NEUTRAL
        end

        if IsFriendlyUnit(hoverID) then
            return COLOR_FRIENDLY
        end

        return COLOR_ENEMY
    end

    return nil
end

local function DrawHighlightedObject()
    if ShooterUI.configMode then
        return
    end

    if not active or not hoverType or not hoverID then
        return
    end

    local color =
        GetHoverColor()

    if not color then
        return
    end

    -------------------------------------------------------------------------
    -- Bright additive model overlay.
    --
    -- Recoil exposes gl.Unit and gl.Feature for drawing the actual live model
    -- geometry. Drawing the hovered object again with additive blending gives
    -- a luminous silhouette/tint without changing its simulation state.
    -------------------------------------------------------------------------

    gl.PushAttrib(GL.ALL_ATTRIB_BITS)

    gl.DepthTest(true)
    gl.DepthMask(false)
    gl.Texture(false)
    gl.Lighting(false)
    gl.Blending(GL.SRC_ALPHA, GL.ONE)
    gl.Color(color[1], color[2], color[3], 0.42)

    if hoverType == "unit" then
        gl.Unit(hoverID, true)
    elseif hoverType == "feature" then
        gl.Feature(hoverID, true)
    end

    -------------------------------------------------------------------------
    -- Add a bright wireframe skin over the same geometry. This remains
    -- readable on dark models and helps approximate a silhouette outline.
    -------------------------------------------------------------------------

    gl.PolygonMode(GL.FRONT_AND_BACK, GL.LINE)
    gl.LineWidth(3)
    gl.DepthTest(false)
    gl.Color(color[1], color[2], color[3], color[4])

    if hoverType == "unit" then
        gl.Unit(hoverID, true)
    elseif hoverType == "feature" then
        gl.Feature(hoverID, true)
    end

    gl.PopAttrib()
end

function widget:DrawWorldPreUnit()
    DrawHighlightedObject()
end

--------------------------------------------------------------------------------
-- Aim marker
--------------------------------------------------------------------------------

function widget:DrawWorld()
	if ShooterUI.configMode then
		return
	end

	if not active or not aimX then
		return
	end

    local mechX, mechY, mechZ, mechRadius =
        GetControlledUnitVisualData()

    if not mechX then
        return
    end

    local markerY = aimY
    local groundGuideY = aimGroundY or aimY
    local guideBaseY = groundGuideY + AIM_MARKER_GROUND_OFFSET
    local flash, holdPulse = GetReticleFireVisuals()

    local baseAlpha =
        min(
            1,
            0.78 +
            0.22 * flash +
            0.10 * holdPulse
        )

    local laneDistX = aimX - mechX
    local laneDistZ = aimZ - mechZ
    local laneDist =
        sqrt(
            laneDistX * laneDistX +
            laneDistZ * laneDistZ
        )

    local faceX = mechX - aimX
    local faceZ = mechZ - aimZ
    local faceLen = sqrt(faceX * faceX + faceZ * faceZ)

    if faceLen < 0.001 then
        faceX = 0
        faceZ = 1
        faceLen = 1
    end

    local normalX = faceX / faceLen
    local normalZ = faceZ / faceLen
    local rightX = -normalZ
    local rightZ = normalX

    local reticleHalfWidth =
        AIM_MARKER_HALF_WIDTH +
        3 * flash +
        1.5 * holdPulse

    local reticleHalfHeight =
        AIM_MARKER_HALF_HEIGHT +
        3 * flash +
        1.5 * holdPulse

    local centerGap =
        AIM_MARKER_CENTER_GAP +
        1.0 * flash

    gl.DepthTest(false)
    gl.LineWidth(2.4 + 0.8 * flash)
    gl.Color(1.0, 0.98, 0.95, baseAlpha)

    gl.BeginEnd(
        GL.LINES,
        function()
            gl.Vertex(
                aimX + rightX * centerGap,
                markerY,
                aimZ + rightZ * centerGap
            )
            gl.Vertex(
                aimX + rightX * reticleHalfWidth,
                markerY,
                aimZ + rightZ * reticleHalfWidth
            )

            gl.Vertex(
                aimX - rightX * centerGap,
                markerY,
                aimZ - rightZ * centerGap
            )
            gl.Vertex(
                aimX - rightX * reticleHalfWidth,
                markerY,
                aimZ - rightZ * reticleHalfWidth
            )

            gl.Vertex(
                aimX,
                markerY + centerGap,
                aimZ
            )
            gl.Vertex(
                aimX,
                markerY + reticleHalfHeight,
                aimZ
            )

            gl.Vertex(
                aimX,
                markerY - centerGap,
                aimZ
            )
            gl.Vertex(
                aimX,
                markerY - reticleHalfHeight,
                aimZ
            )
        end
    )

    if markerY > guideBaseY then
        gl.Color(1.0, 0.96, 0.90, 0.58 + 0.18 * flash)
        gl.LineWidth(1.8)

        gl.BeginEnd(
            GL.LINES,
            function()
                local seg = AIM_GUIDE_SEGMENT
                local gap = AIM_GUIDE_GAP
                local step = seg + gap
                local y = guideBaseY

                while y < markerY do
                    local y2 = min(
                        y + seg,
                        markerY
                    )

                    gl.Vertex(
                        aimX,
                        y,
                        aimZ
                    )

                    gl.Vertex(
                        aimX,
                        y2,
                        aimZ
                    )

                    y = y + step
                end
            end
        )
    end

    if laneDist > 0.001 then
        local dirX = nil
        local dirZ = nil
        local laneParamX =
            spGetUnitRulesParam(
                controlledUnitID,
                LANE_DIR_X_PARAM
            )
        local laneParamZ =
            spGetUnitRulesParam(
                controlledUnitID,
                LANE_DIR_Z_PARAM
            )

        if laneParamX and laneParamZ then
            local laneParamLen =
                sqrt(
                    laneParamX * laneParamX +
                    laneParamZ * laneParamZ
                )

            if laneParamLen > 0.001 then
                dirX = laneParamX / laneParamLen
                dirZ = laneParamZ / laneParamLen
            end
        end

        if not dirX then
            dirX = laneDistX / laneDist
            dirZ = laneDistZ / laneDist
        end

        local laneRightX = -dirZ
        local laneRightZ = dirX
        local laneStart = mechRadius * LANE_START_OFFSET_MULT
        local laneEnd = min(laneDist, LANE_MAX_LENGTH)
        local laneLength = laneEnd - laneStart

        if laneLength >= LANE_MIN_LENGTH then
            local fadeStart = max(LANE_FADE_START_DISTANCE, mechRadius * 1.5)
            local fadeFull = max(LANE_FADE_FULL_DISTANCE, mechRadius * 4.5)
            local laneFade = Clamp01((laneDist - fadeStart) / max(1, (fadeFull - fadeStart)))

            if laneFade > 0 then
                local laneHalfWidth =
                    mechRadius * LANE_EDGE_HALF_WIDTH_MULT +
                    LANE_EDGE_HALF_WIDTH_ADD
                local borderAlpha = laneFade * (0.24 + 0.10 * holdPulse + 0.12 * flash)
                local chevronAlpha = laneFade * (0.12 + 0.05 * holdPulse + 0.06 * flash)
                local fillAlpha = laneFade * (0.045 + 0.015 * holdPulse + 0.02 * flash)
                local sampleStep = 28
                local fadeTail = max(LANE_END_FADE_MIN, laneLength * LANE_END_FADE_FRACTION)

                local function tailAlpha(distanceAlongLane)
                    local remain = laneEnd - distanceAlongLane
                    if remain <= 0 then
                        return 0
                    end
                    if remain >= fadeTail then
                        return 1
                    end
                    return Clamp01(remain / fadeTail)
                end

                gl.Color(1.0, 0.98, 0.94, 1)
                gl.BeginEnd(
                    GL.TRIANGLE_STRIP,
                    function()
                        local d = laneStart
                        while d <= laneEnd do
                            local tail = tailAlpha(d)
                            local alpha = fillAlpha * tail
                            local cx = mechX + dirX * d
                            local cz = mechZ + dirZ * d

                            local lx = cx + laneRightX * laneHalfWidth
                            local lz = cz + laneRightZ * laneHalfWidth
                            local rx = cx - laneRightX * laneHalfWidth
                            local rz = cz - laneRightZ * laneHalfWidth

                            local ly = spGetGroundHeight(lx, lz) + LANE_GROUND_OFFSET
                            local ry = spGetGroundHeight(rx, rz) + LANE_GROUND_OFFSET

                            gl.Color(1.0, 0.98, 0.94, alpha)
                            gl.Vertex(lx, ly, lz)
                            gl.Color(1.0, 0.98, 0.94, alpha)
                            gl.Vertex(rx, ry, rz)

                            d = d + sampleStep
                        end

                        if (laneEnd - (d - sampleStep)) > 0.01 then
                            local tail = tailAlpha(laneEnd)
                            local alpha = fillAlpha * tail
                            local cx = mechX + dirX * laneEnd
                            local cz = mechZ + dirZ * laneEnd
                            local lx = cx + laneRightX * laneHalfWidth
                            local lz = cz + laneRightZ * laneHalfWidth
                            local rx = cx - laneRightX * laneHalfWidth
                            local rz = cz - laneRightZ * laneHalfWidth
                            local ly = spGetGroundHeight(lx, lz) + LANE_GROUND_OFFSET
                            local ry = spGetGroundHeight(rx, rz) + LANE_GROUND_OFFSET

                            gl.Color(1.0, 0.98, 0.94, alpha)
                            gl.Vertex(lx, ly, lz)
                            gl.Color(1.0, 0.98, 0.94, alpha)
                            gl.Vertex(rx, ry, rz)
                        end
                    end
                )

                gl.LineWidth(4.8)
                gl.BeginEnd(
                    GL.LINE_STRIP,
                    function()
                        local d = laneStart
                        while d <= laneEnd do
                            local tail = tailAlpha(d)
                            local alpha = borderAlpha * tail
                            local px = mechX + dirX * d + laneRightX * laneHalfWidth
                            local pz = mechZ + dirZ * d + laneRightZ * laneHalfWidth
                            local py = spGetGroundHeight(px, pz) + LANE_GROUND_OFFSET

                            gl.Color(1.0, 0.97, 0.92, alpha)
                            gl.Vertex(px, py, pz)
                            d = d + sampleStep
                        end

                        if (laneEnd - (d - sampleStep)) > 0.01 then
                            local tail = tailAlpha(laneEnd)
                            local alpha = borderAlpha * tail
                            local px = mechX + dirX * laneEnd + laneRightX * laneHalfWidth
                            local pz = mechZ + dirZ * laneEnd + laneRightZ * laneHalfWidth
                            local py = spGetGroundHeight(px, pz) + LANE_GROUND_OFFSET
                            gl.Color(1.0, 0.97, 0.92, alpha)
                            gl.Vertex(px, py, pz)
                        end
                    end
                )

                gl.BeginEnd(
                    GL.LINE_STRIP,
                    function()
                        local d = laneStart
                        while d <= laneEnd do
                            local tail = tailAlpha(d)
                            local alpha = borderAlpha * tail
                            local px = mechX + dirX * d - laneRightX * laneHalfWidth
                            local pz = mechZ + dirZ * d - laneRightZ * laneHalfWidth
                            local py = spGetGroundHeight(px, pz) + LANE_GROUND_OFFSET

                            gl.Color(1.0, 0.97, 0.92, alpha)
                            gl.Vertex(px, py, pz)
                            d = d + sampleStep
                        end

                        if (laneEnd - (d - sampleStep)) > 0.01 then
                            local tail = tailAlpha(laneEnd)
                            local alpha = borderAlpha * tail
                            local px = mechX + dirX * laneEnd - laneRightX * laneHalfWidth
                            local pz = mechZ + dirZ * laneEnd - laneRightZ * laneHalfWidth
                            local py = spGetGroundHeight(px, pz) + LANE_GROUND_OFFSET
                            gl.Color(1.0, 0.97, 0.92, alpha)
                            gl.Vertex(px, py, pz)
                        end
                    end
                )

                gl.LineWidth(3.2)
                gl.BeginEnd(
                    GL.LINES,
                    function()
                        local chevronHalfWidth = laneHalfWidth * LANE_CHEVRON_HALF_WIDTH_MULT
                        local chevronSpacing = LANE_CHEVRON_SPACING
                        local chevronForward = LANE_CHEVRON_FORWARD_SIZE
                        local d = laneStart + chevronSpacing * 0.75

                        while d < laneEnd - chevronForward * 0.5 do
                            local tail = tailAlpha(d + chevronForward * 0.5)
                            local alpha = chevronAlpha * tail
                            local baseCenterX = mechX + dirX * d
                            local baseCenterZ = mechZ + dirZ * d
                            local tipX = mechX + dirX * (d + chevronForward)
                            local tipZ = mechZ + dirZ * (d + chevronForward)

                            local leftX = baseCenterX - laneRightX * chevronHalfWidth
                            local leftZ = baseCenterZ - laneRightZ * chevronHalfWidth
                            local rightX2 = baseCenterX + laneRightX * chevronHalfWidth
                            local rightZ2 = baseCenterZ + laneRightZ * chevronHalfWidth

                            local leftY = spGetGroundHeight(leftX, leftZ) + LANE_GROUND_OFFSET
                            local rightY = spGetGroundHeight(rightX2, rightZ2) + LANE_GROUND_OFFSET
                            local tipY = spGetGroundHeight(tipX, tipZ) + LANE_GROUND_OFFSET

                            gl.Color(1.0, 0.98, 0.96, alpha)
                            gl.Vertex(leftX, leftY, leftZ)
                            gl.Color(1.0, 0.98, 0.96, alpha)
                            gl.Vertex(tipX, tipY, tipZ)
                            gl.Color(1.0, 0.98, 0.96, alpha)
                            gl.Vertex(rightX2, rightY, rightZ2)
                            gl.Color(1.0, 0.98, 0.96, alpha)
                            gl.Vertex(tipX, tipY, tipZ)

                            d = d + chevronSpacing
                        end
                    end
                )
            end
        end
    end

    gl.Color(1, 1, 1, 1)
	gl.LineWidth(1)
    gl.DepthTest(false)
end

--------------------------------------------------------------------------------
-- Diagnostic HUD
--------------------------------------------------------------------------------

function widget:DrawScreen()
	if not active then
		return
	end

	-- UI-only state maintenance. Alt configuration deliberately restores the
	-- ordinary cursor and suppresses Shooter's hidden-cursor enforcement.
    if ShooterUI.configMode then
        RestoreCursor()
    else
        RefreshJumpAimState()
        ForceDirectCursor()
    end

	local vsx, vsy =
		spGetViewGeometry()

	gl.Text(
		"SHOOTER CONTROL r45",
		24,
		vsy - 40,
		16,
		"o"
	)

	gl.Text(
		"W/S Forward-Reverse   A/D Yaw   Shift Run   Mouse Aim   LMB Fire   RMB Look/Pan   Alt Unit Card   1/2/3 Groups   0/N All   J Jump   R Radar/Stealth   E Exit",
		24,
		vsy - 62,
		13,
		"o"
	)

	gl.Text(
		"LMB MANUAL OFFENSIVE FIRE / AUTOFIRE SUPPRESSED / INTERCEPTORS AUTOMATIC",
		24,
		vsy - 84,
		13,
		"o"
	)

    if ShooterUI.configMode then
        gl.Text(
            "WEAPON GROUP CONFIG: " .. (
                ShooterUI.activeWeaponGroup == 0
                and "N / ALL"
                or tostring(ShooterUI.activeWeaponGroup)
            ) .. "   CLICK UNIT-CARD WEAPONS TO RECORD THIS GROUP",
            24,
            vsy - 106,
            13,
            "o"
        )
    elseif jumpAimActive then
		gl.Text(
			"JUMP AIM: LMB CONFIRM IN-RANGE TARGET   RMB CANCEL",
			24,
			vsy - 106,
			13,
			"o"
		)
	elseif fireRequested then
		gl.Text(
			"FIRE REQUESTED",
			24,
			vsy - 106,
			13,
			"o"
		)
	elseif runRequested then
		gl.Text(
			"RUN REQUESTED",
			24,
			vsy - 106,
			13,
			"o"
		)
	end

	local weaponsInArc = 0
	local weaponsTotal = 0

	if
		controlledUnitID
		and spGetUnitRulesParam
	then
		local weaponsInArcRaw =
			spGetUnitRulesParam(
				controlledUnitID,
				"shooter_weapons_in_arc"
			)

		local weaponsTotalRaw =
			spGetUnitRulesParam(
				controlledUnitID,
				"shooter_weapons_total"
			)

		weaponsInArc = tonumber(weaponsInArcRaw) or 0
		weaponsTotal = tonumber(weaponsTotalRaw) or 0
	end

	if weaponsTotal > 0 then
		gl.Text(
			"WEAPONS IN ARC: " ..
			tostring(math.floor(weaponsInArc)) ..
			" / " ..
			tostring(math.floor(weaponsTotal)),
			24,
			vsy - 128,
			13,
			"o"
		)
	end

	gl.Text(
		"Role: " .. tostring(controlledUnitRole) ..
		"   Camera leash: " .. tostring(math.floor(cameraLeashMax)) ..
		"   South: " .. tostring(math.floor(cameraLeashMax * CAMERA_SOUTH_LEASH_MULTIPLIER)),
		24,
		vsy - 150,
		13,
		"o"
	)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
