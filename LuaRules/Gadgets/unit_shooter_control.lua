--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  MCL Isometric Shooter Control
--  Revision 46 - Per-Weapon Maximum-Range Aim Clamping
--
--  SYNCED GADGET
--
--  Revision 8 synced baseline:
--
--      * entering direct control clears all existing commands/targets
--      * normal offensive weapons are prevented from autonomous target selection
--      * interceptor weapons remain fully autonomous for missile interception
--      * reverse forcing from r6 is retained
--      * cursor torso aim from r6 is retained
--
--  Weapon-fire policy while direct control is active:
--
--      interceptor > 0
--          autonomous operation allowed
--
--      interceptor == 0
--          autonomous unit targeting denied
--
--  Offensive weapons are manually fired while LuaUI reports LMB held.
--  Interceptor weapons remain autonomous and are never assigned shooter targets.
--
--  r20 additions:
--
--      * Shift requests the Mech.lua native Run() state
--      * A/D is moving chassis-yaw input rather than lateral translation
--      * moving yaw uses GG.GetUnitTurnRate() from revised unit_turn.lua
--      * running reduces effective moving yaw according to current speedMod
--      * stationary A/D still uses the native MCL CMD_TURN
--      * AIM messages carry the direct world-space pointer position
--
--  Mech-only validation, radar, jump ownership and weapon policy from r19
--  remain intact.
--
--  r21 fix:
--      Shooter locomotion yields whenever another gadget has enabled MoveCtrl,
--      preventing GroundMoveType writes during jumps and native turn pivots.
--
--  r22:
--      Direct pointer aim mirrors Mech.lua's weapon-piece routing.
--
--  r46:
--      * ordinary positional fire clamps beyond-range aim back along the same
--        aim ray to each weapon's own live maximum range
--      * visible aim remains unchanged and genuine UNIT targets stay native
--      * protocol remains SHOOTER45 because LuaUI is unchanged
--
--  r45:
--      * protocol/revision synchronized with gui_shooter_control_r45.lua
--      * no weapon, movement, torso, camera or projectile-policy changes
--      * retains r44 AllowDirectUnitControl denial for Shooter-owned units
--
--  r44:
--      * protocol/revision synchronized with gui_shooter_control_r45.lua
--      * removes Shooter's bespoke radar state toggle; native CMD.ONOFF now
--        remains authoritative for Radar Off / On / Stealth
--      * denies Recoil's built-in FPS/direct-unit-control takeover while a
--        Mech is already owned by Shooter Control
--      * weapon groups use MCL's existing CMD_WEAPON_TOGGLE path from LuaUI;
--        no synced weapon-fire, targeting, movement or guidance rules changed
--
--  r43:
--      * protocol/revision synchronized with gui_shooter_control_r43.lua
--      * no synced movement, firing, aiming, targeting or weapon-policy changes
--      * camera look/pan gating is entirely unsynced LuaUI behavior
--
--  r42:
--      * protocol/revision synchronized with gui_shooter_control_r42.lua
--      * no synced movement, aiming, firing, torso-yaw or weapon changes
--      * camera smoothing is entirely unsynced in the paired LuaUI widget
--
--  r41:
--      * protocol/revision synchronized with gui_shooter_control_r41.lua
--      * firing-lane direction no longer uses torso-piece emit direction
--      * tracks torso yaw relative to chassis using the same desired
--        relativeHeading and live TORSO_SPEED passed to TurnPiece
--      * exports that simulated world-space direction to LuaUI
--      * no weapon, movement, camera or firing-policy changes
--
--  r37:
--      * hover stickiness now applies only to enemy units
--      * friendly units and features clear immediately when the pointer leaves them
--      * firing, lock, minimum-range, camera, aircraft and missile behavior remains r36
--
--  r36:
--      * restores MCL custom minimum-range enforcement for Shooter positional
--        targets, which Mech.lua cannot measure without a queued CMD.ATTACK
--      * real UNIT targets remain owned by native Mech.lua BlockShot so its
--        minimum-range, ECM, TAG/NARC and other target-dependent rules remain
--        authoritative
--      * PPC Inhibitor remains functional for positional Shooter fire: an
--        in-minimum-range PPC may fire only when its live script inhibitor is
--        active, and GG.ApplyPPC is invoked on the actual projectile launch
--      * SSRM-class weapons require a highlighted enemy unit and can never
--        fall back to a ground/positional target
--      * any WeaponDef with canAttackGround=false likewise requires a real unit
--        target, covering MCL target-only systems such as NARC/TAG
--      * internal weaponclass=sight slots are excluded from Shooter offensive
--        targeting and arc counts
--      * r35 aircraft/camera, trajectory aim and missile guidance are unchanged
--
--  r35:
--      * preserves r34 aircraft targeting, camera behavior and missile guidance
--        bridge unchanged
--      * positive-trajectoryHeight weapons no longer have their physical
--        elevation piece forced to the straight Shooter convergence pitch
--      * Recoil's native wantedDir/AimWeapon solution again owns launcher/
--        launchpoint elevation for lofted missiles, matching stock MCL behavior
--      * direct/zero-trajectory weapons retain Shooter's existing articulation
--
--  r34:
--      * preserves all r33/r32 aircraft targeting and camera behavior
--      * fixes ProjectileCreated recursion/C-stack overflow by bridging only
--        projectiles whose WeaponDef is actually mounted on the controlled Mech
--      * MCL Lua-spawned lrm_guided/srm_guided/Arrow replacement projectiles
--        are never retargeted by Shooter Control and remain owned by game_weapons.lua
--
--  r33:
--      * preserves all r32 aircraft/camera behavior in the paired GUI
--      * adds a pre-game_weapons ProjectileCreated bridge for MCL missile classes
--      * LRM projectiles fired at the highlighted enemy are explicitly given
--        that UNIT target before game_weapons.lua (layer 4) processes them
--      * this repairs target identity at the projectile boundary instead of
--        recreating Artemis/TAG/NARC/special-ammo guidance in Shooter Control
--      * Artemis SRM and homing/ARAD/AD Arrow IV projectiles use the same bridge
--        only when their existing MCL runtime state requires a unit target
--      * per-weapon SetUnitTarget remains in place as the preferred native path;
--        the projectile bridge is a compatibility/retention fallback
--
--  r32:
--      * guided handoff is now MCL-aware rather than relying only on
--        WeaponDef.tracks
--      * normal engine-tracking weapons still receive the highlighted unit
--      * LRM-class weapons always receive a real unit target so MCL's existing
--        Artemis / TAG / NARC / special-ammo projectile logic sees the target
--        type it expects
--      * Artemis SRMs and homing/ARAD/AD Arrow IV ammunition receive unit
--        targets only when those existing MCL runtime states require them
--      * Shooter Control does not alter projectiles or reproduce guidance;
--        game_weapons.lua remains authoritative
--
--  r31:
--      * AIM may carry the currently highlighted enemy unit as metadata
--      * weapons whose WeaponDef.tracks flag is true receive that actual unit
--        target so normal Recoil homing/tracking behavior is preserved
--      * direct-fire and non-tracking weapons continue to receive only the
--        player's positional convergence point, so manual leading is unchanged
--      * guided weapons fall back to positional fire when no unit is highlighted
--
--  r30:
--      * direct-control takeover now claims the unit before STOP/cancel processing
--        so AllowWeaponTarget suppression is active during the handoff itself
--      * every offensive weapon slot is explicitly purged immediately on entry
--      * while LMB is not held, offensive weapon targets are continuously purged
--        so stale RTS/autotarget state can never retain firing autonomy
--      * AMS/interceptor weapons remain excluded and fully autonomous
--
--  r29:
--      * protocol/revision synchronized with gui_shooter_control_r29.lua
--      * very close aim points are projected outward along the same torso aim
--        ray before weapons receive their positional targets
--      * this hidden convergence floor reduces extreme close-range barrel/laser
--        angles without changing the visible player-controlled pointer
--      * each weapon caps the projection inside its own maximum range
--
--  r28:
--      * protocol/revision synchronized with gui_shooter_control_r28.lua
--      * synced logic is unchanged; the gadget simply receives the GUI
--        widget's elevated combat-height aim coordinates instead of ground aim
--
--  r27:
--      * protocol/revision synchronized with gui_shooter_control_r27.lua
--      * no synced movement, aim, firing, jump, run or weapon-policy changes
--
--  r26:
--      * removes unit identity from offensive direct-control targeting
--      * AIM carries only x/y/z and FIRE always uses positional targets
--      * weapons never receive an enemy unit as a shooter-controlled target
--      * native weapon readiness/reload/heat/ammo/BlockShot behavior is retained
--
--  r25:
--      * adds held LMB offensive firing
--      * every non-AMS weapon is targeted independently
--      * only weapons whose r23 weaponAimState.canBear is true receive targets
--      * the cursor point is used as the engine target
--      * Spring.SetUnitTarget(..., weaponNum) keeps the normal engine/MCL
--        AimWeapon, BlockShot, reload, range, line-of-fire, ammo and heat path
--      * Spring.UnitWeaponFire is deliberately NOT used
--      * releasing LMB, losing bearing or leaving direct control drops only
--        offensive weapon targets; AMS/interceptor targets remain untouched
--
--  r23:
--      * resolves an independent aim definition for every non-AMS weapon
--      * arm-mounted fallback pitch arc is +/-90 degrees
--      * torso/direct fallback pitch arc is +/-45 degrees
--      * existing per-weapon minpitches/maxpitches override fallback bounds
--      * Recoil UnitDef weapon-slot maindir/maxangledif is checked as a second,
--        independent directional legality constraint
--      * the cursor remains free while physical pieces clamp at their own arc
--      * bare flare_* and launchpoint_* pieces remain valid elevation pieces
--      * weaponAimState records requestedPitch, actualPitch and canBear
--      * AMS/interceptor weapons remain autonomous and are excluded
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "MCL Isometric Shooter Control r46",
		desc      = "Mech-only direct control with per-weapon maximum-range aim clamping, native-command whitelist/weapon groups, MCL minimum ranges and native guidance",
		author    = "zvero + ChatGPT",
		date      = "2026",
		license   = "GPLv2 or later",
		-- r33 must see newly created LRM projectiles before game_weapons.lua
		-- (layer 4) so MCL's existing Artemis/TAG/NARC/ammo logic receives the
		-- corrected UNIT target on its own ProjectileCreated call-in.
		layer     = 2,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if not gadgetHandler:IsSyncedCode() then
	return
end

--------------------------------------------------------------------------------
-- Message protocol
--------------------------------------------------------------------------------

local MESSAGE_PREFIX = "SHOOTER45|"

-- Messages:
--   ENTER unitID
--   EXIT
--   MOVE strafe forward
--   AIM x y z targetType targetID
--   FIRE 0/1
--   RUN 0/1

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local MOVE_LOOKAHEAD = 300
local MOVE_GOAL_RADIUS = 16
local MOVE_UPDATE_FRAMES = 3

-- Stationary A/D still uses the existing MCL Turn command.
local TURN_TARGET_DISTANCE = 300

-- While translating, A/D asks GroundMoveType to steer 90 degrees left/right
-- from current chassis heading. The moving turnRate itself is overridden from
-- GG.GetUnitTurnRate(), so A/D is yaw authority rather than lateral motion.
local MOVING_STEER_ANGLE = math.rad(90)

local MIN_RUN_SPEED_MULTIPLIER = 1.0

local SHOOTER_TORSO_SPEED = math.rad(180)
local SHOOTER_ELEVATION_SPEED = math.rad(120)
local AIM_POSITION_EPSILON = 2

-- Weapons should never be asked to converge onto an extremely close point.
-- If the player's desired point is nearer than this, the synced firing target
-- is projected farther along the exact same aim ray.
local MIN_WEAPON_CONVERGENCE_DISTANCE = 150

-- A very short-ranged weapon must still receive a target inside its legal range.
local WEAPON_RANGE_CONVERGENCE_FRACTION = 0.90

-- Fallback mechanical pitch arcs. Explicit per-weapon content data wins.
local ARM_MIN_PITCH = math.rad(-90)
local ARM_MAX_PITCH = math.rad(90)
local TORSO_MIN_PITCH = math.rad(-45)
local TORSO_MAX_PITCH = math.rad(45)

local ARC_EPSILON = math.rad(0.25)

local ARC_PARAM_IN = "shooter_weapons_in_arc"
local ARC_PARAM_TOTAL = "shooter_weapons_total"
local LANE_DIR_X_PARAM = "shooter_lane_dir_x"
local LANE_DIR_Z_PARAM = "shooter_lane_dir_z"

--------------------------------------------------------------------------------
-- Forced reverse
--------------------------------------------------------------------------------

local FORCED_REVERSE_DIST  = MOVE_LOOKAHEAD + 128
local FORCED_REVERSE_ANGLE = 90

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local TWO_PI = math.pi * 2
local HEADING_TO_RAD = TWO_PI / 65536
local SIM_FRAMES_PER_SECOND = (Game and Game.gameSpeed) or 30
local X_AXIS = 1
local Y_AXIS = 2

-- Recoil projectile target type uses the ASCII code for 'u'.
local PROJECTILE_TARGET_UNIT = string.byte("u")
local WEAPON_TARGET_UNIT = 1

--------------------------------------------------------------------------------
-- Spring aliases
--------------------------------------------------------------------------------

local spGetPlayerInfo   = Spring.GetPlayerInfo
local spGetUnitTeam     = Spring.GetUnitTeam
local spGetUnitNeutral  = Spring.GetUnitNeutral
local spAreTeamsAllied  = Spring.AreTeamsAllied
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitHeading  = Spring.GetUnitHeading
local spGetUnitPieceMap = Spring.GetUnitPieceMap
local spGetUnitPiecePosDir = Spring.GetUnitPiecePosDir
local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitDefID    = Spring.GetUnitDefID
local spGetUnitRulesParam = Spring.GetUnitRulesParam

local spGetScriptEnv =
	Spring.UnitScript.GetScriptEnv

local spValidUnitID     = Spring.ValidUnitID
local spGetUnitIsDead   = Spring.GetUnitIsDead

local spSetUnitMoveGoal = Spring.SetUnitMoveGoal
local spClearUnitGoal   = Spring.ClearUnitGoal
local spSetUnitTarget   = Spring.SetUnitTarget
local spGetUnitWeaponTarget = Spring.GetUnitWeaponTarget
local spGetUnitWeaponState = Spring.GetUnitWeaponState
local spGetProjectileTarget = Spring.GetProjectileTarget
local spGetProjectileDefID = Spring.GetProjectileDefID
local spSetProjectileTarget = Spring.SetProjectileTarget
local spUnitWeaponHoldFire = Spring.UnitWeaponHoldFire
local spGetGameFrame = Spring.GetGameFrame
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spSetUnitRulesParam = Spring.SetUnitRulesParam

local spCallAsUnit      = Spring.UnitScript.CallAsUnit
local spUnitScriptTurn  = Spring.UnitScript.Turn

local spSetGMTData =
	Spring.MoveCtrl
	and Spring.MoveCtrl.SetGroundMoveTypeData

local spMoveCtrlIsEnabled =
	Spring.MoveCtrl
	and Spring.MoveCtrl.IsEnabled

local sin   = math.sin
local cos   = math.cos
local atan2 = math.atan2
local sqrt  = math.sqrt
local abs   = math.abs
local max   = math.max
local min   = math.min

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local controllers = {}
local controlledUnits = {}

-- Avoid log spam if an engine build refuses/loses either target handoff.
local weaponTargetWarned = {}
local projectileBridgeWarned = {}

--------------------------------------------------------------------------------
-- Utility
--------------------------------------------------------------------------------

local function Split(message)
	local result = {}

	for token in string.gmatch(message, "([^|]+)") do
		result[#result + 1] = token
	end

	return result
end

local function NormalizeAngle(angle)
	while angle > math.pi do
		angle = angle - TWO_PI
	end

	while angle < -math.pi do
		angle = angle + TWO_PI
	end

	return angle
end

local function IsInterceptorWeaponDef(weaponDefID)
	if not weaponDefID then
		return false
	end

	local wd =
		WeaponDefs[weaponDefID]

	return
		wd
		and (wd.interceptor or 0) > 0
end

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

local function IsValidOwnedUnit(playerID, unitID)
	if not unitID then
		return false
	end

	if not spValidUnitID(unitID) then
		return false
	end

	if spGetUnitIsDead(unitID) then
		return false
	end

	local playerName, active, spectator, teamID =
		spGetPlayerInfo(playerID, false)

	if not playerName or spectator then
		return false
	end

	if spGetUnitTeam(unitID) ~= teamID then
		return false
	end

	if
		not IsMechUnitDefID(
			spGetUnitDefID(unitID)
		)
	then
		return false
	end

	return true, teamID
end

--------------------------------------------------------------------------------
-- Command cancellation
--------------------------------------------------------------------------------

local function CancelExistingOrders(unitID)
	if
		not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return
	end

	-------------------------------------------------------------------------
	-- Cancel queued MOVE / ATTACK / FIGHT / PATROL / etc.
	-------------------------------------------------------------------------

	spGiveOrderToUnit(
		unitID,
		CMD.STOP,
		{},
		0
	)

	-------------------------------------------------------------------------
	-- MCL's unit_setTarget.lua supports priority targets that may explicitly
	-- ignore STOP. Direct control must own the unit completely, so explicitly
	-- cancel that target list as well when the custom command ID is available.
	--
	-- CMD_UNIT_CANCEL_TARGET is exported globally by unit_setTarget.lua.
	-------------------------------------------------------------------------

	if CMD_UNIT_CANCEL_TARGET then
		spGiveOrderToUnit(
			unitID,
			CMD_UNIT_CANCEL_TARGET,
			{},
			0
		)
	end

	-------------------------------------------------------------------------
	-- Clear raw Lua movement and any engine-level forced/user target.
	-------------------------------------------------------------------------

	spClearUnitGoal(unitID)
	spSetUnitTarget(unitID, nil)
end

--------------------------------------------------------------------------------
-- Autonomous offensive target suppression
--------------------------------------------------------------------------------
--
-- Recoil's normal unit auto-target path calls AllowWeaponTarget for candidate
-- unit targets.
--
-- While a unit is directly controlled, offensive weapons are denied normal
-- unit targets here.
--
-- Interceptors are exempt. Their projectile interception uses the engine's
-- interceptor system, identified by WeaponDef.interceptor > 0.
--------------------------------------------------------------------------------

function gadget:AllowWeaponTarget(
	attackerID,
	targetID,
	attackerWeaponNum,
	attackerWeaponDefID,
	defPriority
)
	-------------------------------------------------------------------------
	-- IMPORTANT:
	--
	-- MCL has another AllowWeaponTarget call-in in unit_setTarget.lua.
	-- GadgetHandler combines returned target priorities numerically, so the
	-- second return value must NEVER be nil. MCL itself uses "defPriority or 1".
	-------------------------------------------------------------------------

	local priority =
		tonumber(defPriority) or 1

	if not controlledUnits[attackerID] then
		return true, priority
	end

	if IsInterceptorWeaponDef(attackerWeaponDefID) then
		return true, priority
	end

	return false, priority
end

--------------------------------------------------------------------------------
-- Deny Recoil's built-in FPS/direct-unit-control mode for Shooter-owned units
--------------------------------------------------------------------------------

function gadget:AllowDirectUnitControl(unitID, unitDefID, unitTeam, playerID)
	if controlledUnits[unitID] then
		return false
	end

	return true
end

--------------------------------------------------------------------------------
-- Native GroundMoveType reverse override
--------------------------------------------------------------------------------

local function SetForcedReverse(controller, enabled)
	if not controller then
		return
	end

	if controller.reverseOverride == enabled then
		return
	end

	controller.reverseOverride = enabled

	if not spSetGMTData then
		return
	end

	local unitID = controller.unitID

	if
		not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return
	end

	if enabled then
		spSetGMTData(
			unitID,
			"maxReverseDist",
			FORCED_REVERSE_DIST
		)

		spSetGMTData(
			unitID,
			"minReverseAngle",
			FORCED_REVERSE_ANGLE
		)
	else
		spSetGMTData(
			unitID,
			"maxReverseDist",
			0
		)

		spSetGMTData(
			unitID,
			"minReverseAngle",
			0
		)
	end
end

--------------------------------------------------------------------------------
-- Direct-control Mech aim + per-weapon bearing legality
--------------------------------------------------------------------------------
--
-- Mech.lua and unit_script_helper.lua already provide the authoritative
-- relationship between weapon slots and model pieces. r23 keeps that mapping,
-- but stores one aim definition per offensive weapon so future firing can ask
-- whether a particular weapon can geometrically bear on the pointer.
--
-- IMPORTANT:
--      canBear here means "the requested direction lies inside this weapon's
--      geometric arc." It does NOT yet mean reloaded, cool, supplied, aligned,
--      unobstructed, or ready to fire.
--------------------------------------------------------------------------------

local function TurnPiece(pieceNum, axis, angle, speed)
	spUnitScriptTurn(
		pieceNum,
		axis,
		angle,
		speed
	)
end

local function ResolvePiece(pieceMap, pieceName)
	if
		not pieceMap
		or not pieceName
	then
		return nil
	end

	return
		pieceMap[pieceName]
		or pieceMap[string.lower(pieceName)]
end

local function Clamp(value, lower, upper)
	return
		max(
			lower,
			min(
				upper,
				value
			)
		)
end

local function GetIndexedValue(input, index)
	if type(input) ~= "table" then
		return nil
	end

	return
		input[index]
		or input[tostring(index)]
end

local function TryUnserializeCustomTable(rawValue)
	if type(rawValue) == "table" then
		return rawValue
	end

	if
		not rawValue
		or type(rawValue) ~= "string"
		or not table.unserialize
	then
		return nil
	end

	local ok, decoded =
		pcall(
			table.unserialize,
			rawValue
		)

	if
		ok
		and type(decoded) == "table"
	then
		return decoded
	end

	return nil
end

local function GetExplicitPitchValue(info, unitDef, tableName, weaponID)
	-------------------------------------------------------------------------
	-- Current MCL unit_script_helper.lua exposes info.minpitches. r23 also
	-- accepts maxpitches if content or a later helper revision provides it.
	-- If the helper did not decode the table, try the UnitDef customParam.
	-------------------------------------------------------------------------

	local helperTable =
		info
		and info[tableName]

	local value =
		GetIndexedValue(
			helperTable,
			weaponID
		)

	if value ~= nil then
		return tonumber(value)
	end

	local rawTable =
		unitDef
		and unitDef.customParams
		and unitDef.customParams[tableName]

	local decoded =
		TryUnserializeCustomTable(
			rawTable
		)

	return
		tonumber(
			GetIndexedValue(
				decoded,
				weaponID
			)
		)
end

local function ResolveWeaponPitchLimits(info, unitDef, weaponID, mountType)
	local minPitch
	local maxPitch

	if mountType == "arm" then
		minPitch = ARM_MIN_PITCH
		maxPitch = ARM_MAX_PITCH
	else
		minPitch = TORSO_MIN_PITCH
		maxPitch = TORSO_MAX_PITCH
	end

	-------------------------------------------------------------------------
	-- MCL customParams are authored in degrees. Treat minpitches/maxpitches as
	-- signed engine weapon pitch: negative = depression, positive = elevation.
	-------------------------------------------------------------------------

	local explicitMin =
		GetExplicitPitchValue(
			info,
			unitDef,
			"minpitches",
			weaponID
		)

	local explicitMax =
		GetExplicitPitchValue(
			info,
			unitDef,
			"maxpitches",
			weaponID
		)

	if explicitMin ~= nil then
		minPitch =
			math.rad(
				explicitMin
			)
	end

	if explicitMax ~= nil then
		maxPitch =
			math.rad(
				explicitMax
			)
	end

	-- Malformed content must never create an inverted interval.
	if minPitch > maxPitch then
		minPitch, maxPitch =
			maxPitch, minPitch
	end

	return
		minPitch,
		maxPitch,
		explicitMin ~= nil,
		explicitMax ~= nil
end

local function FindLowestWeaponID(weaponSet, numWeapons)
	if type(weaponSet) ~= "table" then
		return nil
	end

	for weaponID = 1, numWeapons do
		if weaponSet[weaponID] then
			return weaponID
		end
	end

	return nil
end

local function GetWeaponMountType(info, weaponID)
	local isLeftArm =
		info
		and info.leftArmIDs
		and info.leftArmIDs[weaponID]

	local isRightArm =
		info
		and info.rightArmIDs
		and info.rightArmIDs[weaponID]

	if
		isLeftArm
		or isRightArm
	then
		return
			"arm",
			isLeftArm and "left" or "right"
	end

	return
		"torso",
		nil
end

local function AddPieceToList(pieceList, pieceNum)
	if not pieceNum then
		return
	end

	for i = 1, #pieceList do
		if pieceList[i] == pieceNum then
			return
		end
	end

	pieceList[#pieceList + 1] =
		pieceNum
end

local function ResolveDirectWeaponPieces(
	info,
	pieceMap,
	weaponID,
	mountType,
	armSide,
	leftArmMasterID,
	rightArmMasterID
)
	local pieces = {}
	local drivesPieces = true
	local articulationType = "direct"

	-------------------------------------------------------------------------
	-- If unit_script_helper established that a weapon physically lives under
	-- an upper arm, that upper arm is the elevation mechanism. Only the arm's
	-- master weapon commands the shared arm piece; follower weapons still get
	-- their own legality state.
	-------------------------------------------------------------------------

	if mountType == "arm" then
		local armPieceName =
			armSide == "left"
			and "lupperarm"
			or "rupperarm"

		local armPiece =
			ResolvePiece(
				pieceMap,
				armPieceName
			)

		if armPiece then
			AddPieceToList(
				pieces,
				armPiece
			)

			articulationType = "arm"

			local armMasterID =
				armSide == "left"
				and leftArmMasterID
				or rightArmMasterID

			drivesPieces =
				weaponID == armMasterID

			return
				pieces,
				drivesPieces,
				articulationType
		end

		-- A malformed/unusual model can be classified as arm-mounted without a
		-- usable upper-arm piece. Fall through to its actual weapon pieces.
	end

	local isMissile =
		info.missileWeaponIDs
		and info.missileWeaponIDs[weaponID]

	if isMissile then
		local hasLauncher =
			info.launcherIDs
			and info.launcherIDs[weaponID]

		if hasLauncher then
			AddPieceToList(
				pieces,
				ResolvePiece(
					pieceMap,
					"launcher_" ..
					weaponID
				)
			)

			articulationType = "launcher"
		else
			local burstLength =
				tonumber(
					info.burstLengths
					and info.burstLengths[weaponID]
				)
				or 1

			for launchPoint = 1, burstLength do
				AddPieceToList(
					pieces,
					ResolvePiece(
						pieceMap,
						"launchpoint_" ..
						weaponID ..
						"_" ..
						launchPoint
					)
				)
			end

			-- Bare launchpoints are valid articulation pieces.
			articulationType = "launchpoint"
		end

		return
			pieces,
			true,
			articulationType
	end

	local hasMantlet =
		info.mantletIDs
		and info.mantletIDs[weaponID]

	if hasMantlet then
		AddPieceToList(
			pieces,
			ResolvePiece(
				pieceMap,
				"mantlet_" ..
				weaponID
			)
		)

		articulationType = "mantlet"
	else
		-- On models without a distinct arm/mantlet/launcher, the flare itself
		-- can be the elevation/depression mechanism.
		AddPieceToList(
			pieces,
			ResolvePiece(
				pieceMap,
				"flare_" ..
				weaponID
			)
		)

		articulationType = "flare"
	end

	return
		pieces,
		true,
		articulationType
end

local function BuildWeaponAimDefinitions(unitID, unitDefID, pieceMap)
	local weaponAimDefs = {}
	local pieceDrivers = {}
	local seenDriverPieces = {}

	local info =
		GG
		and GG.lusHelper
		and GG.lusHelper[unitDefID]

	local unitDef =
		unitDefID
		and UnitDefs[unitDefID]

	if
		not info
		or not unitDef
	then
		Spring.Echo(
			"[Shooter] WARNING: missing weapon aiming data for unitDef:",
			unitDefID
		)

		return
			weaponAimDefs,
			pieceDrivers,
			0
	end

	local numWeapons =
		tonumber(info.numWeapons)
		or 0

	-- Recompute actual arm masters from the populated arm sets. The helper's
	-- legacy GetArmMasterWeapon() uses 32 as an empty sentinel, so validating
	-- against the real set avoids phantom arm masters on armless Mechs.
	local leftArmMasterID =
		FindLowestWeaponID(
			info.leftArmIDs,
			numWeapons
		)

	local rightArmMasterID =
		FindLowestWeaponID(
			info.rightArmIDs,
			numWeapons
		)

	local offensiveWeaponCount = 0

	for weaponID = 1, numWeapons do
		local weaponSlot =
			unitDef.weapons
			and unitDef.weapons[weaponID]

		local weaponDefID =
			weaponSlot
			and weaponSlot.weaponDef

		local isAMS =
			(
				info.amsIDs
				and info.amsIDs[weaponID]
			)
			or IsInterceptorWeaponDef(
				weaponDefID
			)

		if not isAMS then
			local mountType, armSide =
				GetWeaponMountType(
					info,
					weaponID
				)

			local minPitch, maxPitch, hasExplicitMin, hasExplicitMax =
				ResolveWeaponPitchLimits(
					info,
					unitDef,
					weaponID,
					mountType
				)

			local pieces, drivesPieces, articulationType =
				ResolveDirectWeaponPieces(
					info,
					pieceMap,
					weaponID,
					mountType,
					armSide,
					leftArmMasterID,
					rightArmMasterID
				)

			local weaponDef =
				weaponDefID
				and WeaponDefs[weaponDefID]

            local weaponCustomParams =
                weaponDef
                and weaponDef.customParams
                or {}

            local weaponClass =
                string.lower(
                    tostring(
                        weaponCustomParams.weaponclass
                        or ""
                    )
                )

            local weaponName =
                string.lower(
                    tostring(
                        weaponDef
                        and weaponDef.name
                        or ""
                    )
                )

            local engineTracks =
                weaponDef
                and weaponDef.tracks == true
                or false

            -- Recoil changes a MissileLauncher's wantedDir when
            -- trajectoryHeight > 0 before it calls the unit script's
            -- AimWeapon(). MCL Mech.lua uses that native pitch to turn the
            -- launcher/launchpoint. Shooter must not overwrite those pieces
            -- with the straight geometric convergence pitch.
            local trajectoryHeight =
                tonumber(
                    weaponDef
                    and weaponDef.trajectoryHeight
                )
                or 0

            local nativeTrajectoryAim =
                trajectoryHeight > 0

            -- MCL's canonical per-slot minimum range is pre-parsed by
            -- unit_script_helper.lua into info.minRanges. Use that same table
            -- so Shooter and Mech.lua agree on the configured value.
            local minRange =
                tonumber(
                    info.minRanges
                    and info.minRanges[weaponID]
                )

            local canAttackGround =
                not (
                    weaponDef
                    and weaponDef.canAttackGround == false
                )

            -- Streak SRMs are explicitly lock-only in direct control. Recoil
            -- also exposes canAttackGround=false for other target-only weapons
            -- such as TAG/NARC, which likewise must never fall back to a point.
            local requiresUnitTarget =
                weaponClass == "ssrm"
                or not canAttackGround

            local internalSight =
                weaponClass == "sight"

			local aimDef = {
				weaponID = weaponID,
				weaponDefID = weaponDefID,

				-- WeaponDefs exposes the engine's internal manualfire flag to Lua
				-- as manualFire. It corresponds to the UnitDef input tag commandfire.
				manualFire =
					weaponDef
					and weaponDef.manualFire == true
					or false,

                -- Store both engine and MCL weapon identity. r32 decides at
                -- fire-time whether this slot needs a real unit target; all
                -- actual projectile guidance remains in MCL game_weapons.lua.
                engineTracks = engineTracks,
                weaponClass = weaponClass,
                weaponName = weaponName,
                trajectoryHeight = trajectoryHeight,
                nativeTrajectoryAim = nativeTrajectoryAim,
                minRange = minRange,
                canAttackGround = canAttackGround,
                requiresUnitTarget = requiresUnitTarget,
                internalSight = internalSight,

				mountType = mountType,
				armSide = armSide,
				articulationType = articulationType,

				minPitch = minPitch,
				maxPitch = maxPitch,
				hasExplicitMinPitch = hasExplicitMin,
				hasExplicitMaxPitch = hasExplicitMax,

				pieces = pieces,
				drivesPieces = drivesPieces,

				-- Recoil exposes these UnitDef weapon-slot values directly.
				-- maxAngleDif is already cos(halfArc), not degrees.
				mainDirX =
					tonumber(
						weaponSlot
						and weaponSlot.mainDirX
					)
					or 0,

				mainDirY =
					tonumber(
						weaponSlot
						and weaponSlot.mainDirY
					)
					or 0,

				mainDirZ =
					tonumber(
						weaponSlot
						and weaponSlot.mainDirZ
					)
					or 1,

				maxAngleDif =
					tonumber(
						weaponSlot
						and weaponSlot.maxAngleDif
					)
					or -1,
			}

            if not internalSight then
				weaponAimDefs[weaponID] =
					aimDef

				offensiveWeaponCount =
					offensiveWeaponCount + 1

				if drivesPieces then
					for i = 1, #pieces do
						local pieceNum =
							pieces[i]

						if
							pieceNum
							and not seenDriverPieces[pieceNum]
						then
							seenDriverPieces[pieceNum] = true

							pieceDrivers[#pieceDrivers + 1] = {
								pieceNum = pieceNum,
								weaponID = weaponID,
							}
						end
					end
				end
            end
		end
	end

	return
		weaponAimDefs,
		pieceDrivers,
		offensiveWeaponCount
end

local function GetDirectAimSpeeds(unitID, unitDefID)
	local torsoSpeed =
		SHOOTER_TORSO_SPEED

	local elevationSpeed =
		SHOOTER_ELEVATION_SPEED

	-------------------------------------------------------------------------
	-- Mech.lua exposes TORSO_SPEED and ELEVATION_SPEED as globals and existing
	-- equipment/perks can modify them. Use the live script values when present.
	-------------------------------------------------------------------------

	local env =
		spGetScriptEnv
		and spGetScriptEnv(
			unitID
		)

	if env then
		torsoSpeed =
			tonumber(env.TORSO_SPEED)
			or torsoSpeed

		elevationSpeed =
			tonumber(env.ELEVATION_SPEED)
			or elevationSpeed
	end

	return
		torsoSpeed,
		elevationSpeed
end

local function IsInsideEngineDirection(aimDef, relativeHeading, pitch)
	if not aimDef then
		return false
	end

	local threshold =
		tonumber(
			aimDef.maxAngleDif
		)

	-------------------------------------------------------------------------
	-- Recoil uses -1 for a full 360-degree UnitDef weapon arc. Anything at or
	-- below that threshold is unrestricted.
	-------------------------------------------------------------------------

	if
		not threshold
		or threshold <= -0.999999
	then
		return true
	end

	local cosPitch =
		cos(pitch)

	-- Desired target vector in the unit's local coordinates.
	local targetX =
		sin(relativeHeading) *
		cosPitch

	local targetY =
		sin(pitch)

	local targetZ =
		cos(relativeHeading) *
		cosPitch

	local mainX =
		aimDef.mainDirX or 0

	local mainY =
		aimDef.mainDirY or 0

	local mainZ =
		aimDef.mainDirZ or 1

	local mainLength =
		sqrt(
			mainX * mainX +
			mainY * mainY +
			mainZ * mainZ
		)

	if mainLength <= 0.000001 then
		return true
	end

	mainX = mainX / mainLength
	mainY = mainY / mainLength
	mainZ = mainZ / mainLength

	local dot =
		mainX * targetX +
		mainY * targetY +
		mainZ * targetZ

	return
		dot + 0.000001 >= threshold
end

local function SetArcSummary(controller, inArc, total)
	if
		not controller
		or not controller.unitID
		or not spSetUnitRulesParam
	then
		return
	end

	inArc =
		tonumber(inArc)
		or 0

	total =
		tonumber(total)
		or 0

	if
		controller.lastArcIn == inArc
		and controller.lastArcTotal == total
	then
		return
	end

	controller.lastArcIn = inArc
	controller.lastArcTotal = total

	spSetUnitRulesParam(
		controller.unitID,
		ARC_PARAM_IN,
		inArc,
		{
			public = true,
		}
	)

	spSetUnitRulesParam(
		controller.unitID,
		ARC_PARAM_TOTAL,
		total,
		{
			public = true,
		}
	)
end

local function ApplyAim(controller)
	if not controller or not controller.aimX then
		return
	end

	local unitID =
		controller.unitID

	if
		not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return
	end

	-------------------------------------------------------------------------
	-- Aim origin is the torso. MCL sets the Mech's engine aim/mid position to
	-- this same piece, and it gives correct pitch to elevated targets.
	-------------------------------------------------------------------------

	local ox, oy, oz =
		spGetUnitPiecePosDir(
			unitID,
			controller.torsoPiece
		)

	if not ox then
		ox, oy, oz =
			spGetUnitPosition(
				unitID
			)
	end

	if not ox then
		return
	end

	local rawDX =
		controller.aimX - ox

	local rawDY =
		controller.aimY - oy

	local rawDZ =
		controller.aimZ - oz

	local rawDistance =
		sqrt(
			rawDX * rawDX +
			rawDY * rawDY +
			rawDZ * rawDZ
		)

	local springHeading =
		spGetUnitHeading(unitID) or 0

	local chassisHeading =
		springHeading * HEADING_TO_RAD

	local dirX, dirY, dirZ

	if rawDistance > 0.001 then
		dirX = rawDX / rawDistance
		dirY = rawDY / rawDistance
		dirZ = rawDZ / rawDistance
	else
		-- If the pointer somehow resolves directly onto the torso origin, keep
		-- the convergence ray safely pointed along the current chassis facing.
		dirX = sin(chassisHeading)
		dirY = 0
		dirZ = cos(chassisHeading)
		rawDistance = 0
	end

	local convergenceDistance =
		max(
			rawDistance,
			MIN_WEAPON_CONVERGENCE_DISTANCE
		)

	local convergenceX =
		ox + dirX * convergenceDistance

	local convergenceY =
		oy + dirY * convergenceDistance

	local convergenceZ =
		oz + dirZ * convergenceDistance

	controller.fireOriginX = ox
	controller.fireOriginY = oy
	controller.fireOriginZ = oz
	controller.fireDirX = dirX
	controller.fireDirY = dirY
	controller.fireDirZ = dirZ
	controller.rawAimDistance = rawDistance
	controller.convergenceX = convergenceX
	controller.convergenceY = convergenceY
	controller.convergenceZ = convergenceZ

	local dx =
		convergenceX - ox

	local dy =
		convergenceY - oy

	local dz =
		convergenceZ - oz

	local horizontalDistance =
		sqrt(
			dx * dx +
			dz * dz
		)

	local targetWorldHeading =
		atan2(
			dx,
			dz
		)

	local relativeHeading =
		NormalizeAngle(
			targetWorldHeading -
			chassisHeading
		)

	local requestedPitch =
		atan2(
			dy,
			max(
				horizontalDistance,
				0.001
			)
		)

	local torsoSpeed, elevationSpeed =
		GetDirectAimSpeeds(
			unitID,
			controller.unitDefID
		)

	-------------------------------------------------------------------------
	-- Torso yaw remains visually unrestricted. Individual weapons can still
	-- fail their UnitDef mainDir/maxAngleDif check below.
	-------------------------------------------------------------------------

	if controller.torsoPiece then
		spCallAsUnit(
			unitID,
			TurnPiece,
			controller.torsoPiece,
			Y_AXIS,
			relativeHeading,
			torsoSpeed
		)
	end

	if spSetUnitRulesParam then
		local frame =
			spGetGameFrame()
			or 0

		local simulatedRelativeYaw =
			controller.laneTorsoYaw

		if simulatedRelativeYaw == nil then
			-- Direct control normally begins from the neutral torso pose. Starting
			-- here also avoids inheriting any model-specific piece-axis convention.
			simulatedRelativeYaw = 0
		end

		local previousFrame =
			controller.laneTorsoYawFrame
			or frame

		local deltaFrames =
			max(
				0,
				frame - previousFrame
			)

		if deltaFrames > 0 then
			local deltaSeconds =
				deltaFrames /
				SIM_FRAMES_PER_SECOND

			local yawError =
				NormalizeAngle(
					relativeHeading -
					simulatedRelativeYaw
				)

			local maxYawStep =
				max(0, torsoSpeed) *
				deltaSeconds

			if abs(yawError) <= maxYawStep then
				simulatedRelativeYaw =
					relativeHeading
			elseif yawError > 0 then
				simulatedRelativeYaw =
					NormalizeAngle(
						simulatedRelativeYaw +
						maxYawStep
					)
			else
				simulatedRelativeYaw =
					NormalizeAngle(
						simulatedRelativeYaw -
						maxYawStep
					)
			end
		end

		controller.laneTorsoYaw =
			simulatedRelativeYaw

		controller.laneTorsoYawFrame =
			frame

		local simulatedWorldYaw =
			chassisHeading +
			simulatedRelativeYaw

		local laneDirX =
			sin(simulatedWorldYaw)

		local laneDirZ =
			cos(simulatedWorldYaw)

		spSetUnitRulesParam(
			unitID,
			LANE_DIR_X_PARAM,
			laneDirX,
			{
				public = true,
			}
		)

		spSetUnitRulesParam(
			unitID,
			LANE_DIR_Z_PARAM,
			laneDirZ,
			{
				public = true,
			}
		)
	end

	-------------------------------------------------------------------------
	-- Physically articulate each independently driven elevation piece.
	--
	-- The pointer itself is NOT clamped. Each piece instead stops at the limit
	-- belonging to the weapon that owns that articulation mechanism.
	-------------------------------------------------------------------------

	local weaponAimDefs =
		controller.weaponAimDefs

	local pieceDrivers =
		controller.pieceDrivers

	if
		weaponAimDefs
		and pieceDrivers
	then
		for i = 1, #pieceDrivers do
			local driver =
				pieceDrivers[i]

			local aimDef =
				weaponAimDefs[
					driver.weaponID
				]

			if
				aimDef
				and not aimDef.nativeTrajectoryAim
			then
				local actualPitch =
					Clamp(
						requestedPitch,
						aimDef.minPitch,
						aimDef.maxPitch
					)

				spCallAsUnit(
					unitID,
					TurnPiece,
					driver.pieceNum,
					X_AXIS,
					-actualPitch,
					elevationSpeed
				)
			end
		end
	end

	-------------------------------------------------------------------------
	-- Resolve independent geometric bearing state for every offensive weapon.
	-------------------------------------------------------------------------

	local inArcCount = 0
	local totalWeapons =
		controller.offensiveWeaponCount
		or 0

	local weaponAimState =
		controller.weaponAimState

	for weaponID, aimDef
	in pairs(weaponAimDefs or {})
	do
		local actualPitch =
			Clamp(
				requestedPitch,
				aimDef.minPitch,
				aimDef.maxPitch
			)

		local inPitchArc =
			requestedPitch >= (
				aimDef.minPitch -
				ARC_EPSILON
			)
			and requestedPitch <= (
				aimDef.maxPitch +
				ARC_EPSILON
			)

		local inDirectionArc =
			IsInsideEngineDirection(
				aimDef,
				relativeHeading,
				requestedPitch
			)

		local canBear =
			inPitchArc
			and inDirectionArc

		weaponAimState[weaponID] = {
			requestedPitch = requestedPitch,
			actualPitch = actualPitch,
			relativeHeading = relativeHeading,

			inPitchArc = inPitchArc,
			inDirectionArc = inDirectionArc,
			canBear = canBear,

		}

		if canBear then
			inArcCount =
				inArcCount + 1
		end
	end

	SetArcSummary(
		controller,
		inArcCount,
		totalWeapons
	)
end

--------------------------------------------------------------------------------
-- Manual offensive firing
--------------------------------------------------------------------------------
--
-- The shooter does NOT force projectiles or call Spring.UnitWeaponFire().
-- Instead, while LMB is held, each eligible offensive weapon receives its own
-- ordinary positional engine target through Spring.SetUnitTarget(..., weaponNum).
--
-- This deliberately re-enters the normal Recoil/MCL weapon pipeline:
--
--      TryTarget / range / line-of-fire
--      AimWeapon
--      BlockShot
--      reload / burst timing / ammo / heat / other MCL readiness logic
--
-- r23's canBear remains an extra direct-control geometric gate in front of
-- that native pipeline. AMS/interceptor slots never appear in weaponAimDefs.
--------------------------------------------------------------------------------

local function ClearOffensiveWeaponTargets(controller)
	if
		not controller
		or not spUnitWeaponHoldFire
	then
		return
	end

	local unitID =
		controller.unitID

	if
		not unitID
		or not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return
	end

	for weaponID in pairs(
		controller.weaponAimDefs
		or {}
	) do
		spUnitWeaponHoldFire(
			unitID,
			weaponID
		)
	end

    controller.ppcInhibitorPending = {}
end

local function ClearOffensiveWeaponTarget(controller, weaponID)
	if
		not controller
		or not weaponID
		or not spUnitWeaponHoldFire
	then
		return
	end

	local unitID =
		controller.unitID

	if
		not unitID
		or not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return
	end

	spUnitWeaponHoldFire(
		unitID,
		weaponID
	)

    if controller.ppcInhibitorPending then
        controller.ppcInhibitorPending[weaponID] = nil
    end
end

local function IsValidGuidedEnemyTarget(controller, targetID)
    if
        not controller
        or not targetID
        or targetID == controller.unitID
        or not spValidUnitID(targetID)
        or spGetUnitIsDead(targetID)
    then
        return false
    end

    if
        spGetUnitNeutral
        and spGetUnitNeutral(targetID)
    then
        return false
    end

    local targetTeam =
        spGetUnitTeam(targetID)

    if targetTeam == nil then
        return false
    end

    if targetTeam == controller.teamID then
        return false
    end

    if
        spAreTeamsAllied
        and spAreTeamsAllied(
            controller.teamID,
            targetTeam
        )
    then
        return false
    end

    return true
end

local function ShouldUseNativeUnitTarget(controller, aimDef)
    if not controller or not aimDef then
        return false
    end

    -------------------------------------------------------------------------
    -- Lock-required weapons (SSRM and canAttackGround=false systems) must
    -- receive a real unit target. They are never allowed to degrade to point
    -- fire when the highlight/lock is absent.
    -------------------------------------------------------------------------

    if aimDef.requiresUnitTarget == true then
        return true
    end

    -------------------------------------------------------------------------
    -- Engine-native tracking weapons use the real unit whenever one is
    -- highlighted, but may still fall back to positional fire unless the
    -- weapon is explicitly lock-required above.
    -------------------------------------------------------------------------

    if aimDef.engineTracks == true then
        return true
    end

    local weaponClass = aimDef.weaponClass or ""
    local weaponName = aimDef.weaponName or ""

    -------------------------------------------------------------------------
    -- MCL LRM family.
    --
    -- game_weapons.lua keys Artemis, TAG/NARC-assisted homing and LRM special
    -- ammunition from customParams.weaponclass == "lrm", and its replacement
    -- logic requires the original projectile target type to be UNIT. Give all
    -- LRM-class weapons that native unit target even if a particular engine
    -- build/derived definition does not expose tracks as expected.
    -------------------------------------------------------------------------

    if weaponClass == "lrm" then
        return true
    end

    -------------------------------------------------------------------------
    -- Artemis SRM. Ordinary dumb SRMs stay manually point-aimed. Only when
    -- MCL has actually enabled Artemis for SRMs do we hand the engine a unit.
    -------------------------------------------------------------------------

    if
        weaponClass == "srm"
        and GG
        and GG.artemisUnits
        and GG.artemisUnits[controller.unitID]
        and GG.artemisUnits[controller.unitID]["srm"]
    then
        return true
    end

    -------------------------------------------------------------------------
    -- Arrow IV special ammunition. game_weapons.lua can convert homing, ARAD
    -- and AD ammunition only when the original Arrow has a unit target.
    -------------------------------------------------------------------------

    if
        weaponName == "arrowiv"
        and GG
        and GG.unitSpecialAmmos
        and GG.unitSpecialAmmos[controller.unitID]
    then
        local ammo =
            GG.unitSpecialAmmos[controller.unitID]["arrowiv"]

        if
            ammo == "homing"
            or ammo == "arad"
            or ammo == "ad"
        then
            return true
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Shooter positional range helpers + PPC Inhibitor bridge
--------------------------------------------------------------------------------

local function GetShooterWeaponMaxRange(controller, aimDef, weaponID)
    local range

    if spGetUnitWeaponState then
        range = tonumber(spGetUnitWeaponState(controller.unitID, weaponID, "range"))
    end

    if range and range > 0 then
        return range
    end

    local weaponDef =
        aimDef
        and aimDef.weaponDefID
        and WeaponDefs[aimDef.weaponDefID]

    range = weaponDef and tonumber(weaponDef.range)

    if range and range > 0 then
        return range
    end

    return nil
end

local function IsInsideShooterMinRange(controller, aimDef)
    local minRange =
        aimDef
        and tonumber(aimDef.minRange)

    local distance =
        controller
        and tonumber(controller.rawAimDistance)

    return
        minRange
        and minRange > 0
        and distance
        and distance < minRange
        or false
end

local function IsPPCInhibitorActive(controller, weaponID)
    if
        not controller
        or not weaponID
        or not spGetScriptEnv
    then
        return false
    end

    local env =
        spGetScriptEnv(
            controller.unitID
        )

    return
        env
        and env.inhibitors
        and env.inhibitors[weaponID]
        and true
        or false
end

local function ArmPPCInhibitorEffect(controller, weaponID)
    if
        not controller
        or not weaponID
    then
        return
    end

    controller.ppcInhibitorPending =
        controller.ppcInhibitorPending
        or {}

    if controller.ppcInhibitorPending[weaponID] then
        return
    end

    -------------------------------------------------------------------------
    -- BlockShot normally calls GG.ApplyPPC once when a ready PPC begins a
    -- firing cycle inside minRange. Shooter's positional target hides the
    -- distance from BlockShot, so arm the same side effect only while the
    -- weapon is actually ready to begin a new cycle. Once the first projectile
    -- appears, ProjectileCreated consumes this flag. During burst/reload the
    -- future reloadState prevents accidental re-arming.
    -------------------------------------------------------------------------

    if
        spGetUnitWeaponState
        and spGetGameFrame
    then
        local reloadState =
            tonumber(
                spGetUnitWeaponState(
                    controller.unitID,
                    weaponID,
                    "reloadState"
                )
            )

        local frame =
            spGetGameFrame()

        if
            reloadState
            and frame
            and reloadState > frame
        then
            return
        end
    end

    controller.ppcInhibitorPending[weaponID] = true
end

local function ApplyPendingPPCInhibitorEffect(controller, weaponDefID)
    if
        not controller
        or not weaponDefID
        or not GG
        or not GG.ApplyPPC
        or not controller.ppcInhibitorPending
    then
        return
    end

    for weaponID, pending in pairs(
        controller.ppcInhibitorPending
    ) do
        local aimDef =
            controller.weaponAimDefs
            and controller.weaponAimDefs[weaponID]

        if
            pending
            and aimDef
            and aimDef.weaponClass == "ppc"
            and aimDef.weaponDefID == weaponDefID
        then
            controller.ppcInhibitorPending[weaponID] = nil

            GG.ApplyPPC(
                controller.unitID,
                controller.unitDefID
            )

            return
        end
    end
end

--------------------------------------------------------------------------------
-- Native MCL projectile target bridge
--------------------------------------------------------------------------------
--
-- Recoil exposes weapon targets and projectile targets as separate pieces of
-- state. On some engine/MCL combinations, a weapon can accept a per-weapon UNIT
-- target yet the spawned missile still arrives in ProjectileCreated carrying a
-- positional target. That breaks both native LRM homing and game_weapons.lua's
-- ChangeMissile() path, because the latter explicitly requires target type 'u'.
--
-- Shooter Control therefore repairs only the target identity of relevant newly
-- created missiles. This gadget deliberately runs at layer 2, before
-- game_weapons.lua at layer 4. MCL remains authoritative for Artemis, TAG,
-- NARC, ARAD, AD ammunition, tracking error, replacement projectiles, etc.
--
-- IMPORTANT: game_weapons.lua can synchronously SpawnProjectile() a replacement
-- guided missile from inside its own ProjectileCreated call-in. r33 also saw that
-- replacement at layer 2, assigned it a UNIT target, and caused game_weapons.lua
-- to replace it again recursively. r34 only bridges WeaponDefs that are actually
-- mounted in one of the controlled Mech's offensive weapon slots.
--------------------------------------------------------------------------------

local function ProjectileIsMountedShooterWeapon(controller, weaponDefID)
    if
        not controller
        or not weaponDefID
    then
        return false
    end

    for _, aimDef in pairs(
        controller.weaponAimDefs
        or {}
    ) do
        if
            aimDef
            and aimDef.weaponDefID == weaponDefID
        then
            return true
        end
    end

    return false
end

local function ProjectileNeedsMCLUnitTarget(controller, weaponDefID)
    if
        not controller
        or not weaponDefID
    then
        return false
    end

    local wd = WeaponDefs[weaponDefID]

    if not wd then
        return false
    end

    local cp = wd.customParams or {}
    local weaponClass =
        string.lower(
            tostring(cp.weaponclass or "")
        )

    -- Native lock-on classes that must leave the launcher carrying the real
    -- target. SSRMs use Recoil homing directly; NARC likewise tracks a unit and
    -- must not degrade to a ground point.
    if
        weaponClass == "ssrm"
        or weaponClass == "narc"
    then
        return true
    end

    -- Every MCL LRM is a unit-guided weapon at the engine level. Smart/Artemis
    -- variants then optionally enter game_weapons.lua's replacement logic.
    if weaponClass == "lrm" then
        return true
    end

    -- Ordinary SRMs remain dumbfire. Artemis SRMs are the existing exception.
    if
        weaponClass == "srm"
        and GG
        and GG.artemisUnits
        and GG.artemisUnits[controller.unitID]
        and GG.artemisUnits[controller.unitID]["srm"]
    then
        return true
    end

    -- Preserve MCL's existing Arrow IV guided-ammunition cases.
    if
        weaponClass == "arrowiv"
        and GG
        and GG.unitSpecialAmmos
        and GG.unitSpecialAmmos[controller.unitID]
    then
        local ammo =
            GG.unitSpecialAmmos[controller.unitID]["arrowiv"]

        return
            ammo == "homing"
            or ammo == "arad"
            or ammo == "ad"
    end

    return false
end

function gadget:ProjectileCreated(projectileID, ownerID, weaponDefID)
    local playerID =
        ownerID
        and controlledUnits[ownerID]

    if not playerID then
        return
    end

    local controller =
        controllers[playerID]

    if
        not controller
        or controller.unitID ~= ownerID
    then
        return
    end

    -- Recoil may omit weaponDefID for later projectiles in a burst. Resolve it
    -- from the projectile itself so PPC inhibitor and MCL missile bridges both
    -- remain reliable for burst weapons.
    if
        not weaponDefID
        and spGetProjectileDefID
    then
        weaponDefID =
            spGetProjectileDefID(
                projectileID
            )
    end

    if not weaponDefID then
        return
    end

    -------------------------------------------------------------------------
    -- Positional PPC minimum-range exception. Native Mech.lua BlockShot cannot
    -- see Shooter's point coordinates, so consume the armed PPC Inhibitor
    -- effect on the real projectile launch. This keeps the effect tied to an
    -- actual shot instead of applying every Shooter update while LMB is held.
    -------------------------------------------------------------------------

    ApplyPendingPPCInhibitorEffect(
        controller,
        weaponDefID
    )

    -------------------------------------------------------------------------
    -- Existing r34/r35 missile target bridge. This remains unit-target-only and
    -- ignores MCL Lua-spawned replacement projectiles through the mounted-slot
    -- check below.
    -------------------------------------------------------------------------

    if
        controller.aimTargetType ~= "unit"
        or not controller.aimTargetID
    then
        return
    end

    local targetID =
        controller.aimTargetID

    if
        not IsValidGuidedEnemyTarget(
            controller,
            targetID
        )
        or not ProjectileIsMountedShooterWeapon(
            controller,
            weaponDefID
        )
        or not ProjectileNeedsMCLUnitTarget(
            controller,
            weaponDefID
        )
    then
        return
    end

    if spGetProjectileTarget then
        local targetType, currentTarget =
            spGetProjectileTarget(
                projectileID
            )

        if
            targetType == PROJECTILE_TARGET_UNIT
            and currentTarget == targetID
        then
            return
        end
    end

    if not spSetProjectileTarget then
        return
    end

    local success =
        spSetProjectileTarget(
            projectileID,
            targetID,
            PROJECTILE_TARGET_UNIT
        )

    if
        success == false
        and not projectileBridgeWarned[weaponDefID]
    then
        projectileBridgeWarned[weaponDefID] = true

        Spring.Echo(
            "[Shooter] WARNING: projectile unit-target bridge failed for WeaponDef",
            weaponDefID
        )
    end
end

local function ApplyFireTargets(controller)
	if
		not controller
		or not controller.fireRequested
		or not controller.aimX
	then
		return
	end

	local unitID =
		controller.unitID

	if
		not unitID
		or not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return
	end

	for weaponID, aimDef
	in pairs(
		controller.weaponAimDefs
		or {}
	) do
		local aimState =
			controller.weaponAimState
			and controller.weaponAimState[weaponID]

		if
			aimState
			and aimState.canBear
		then
			local manualFire =
				aimDef
				and aimDef.manualFire == true

            local guidedTargetID =
                ShouldUseNativeUnitTarget(
                    controller,
                    aimDef
                )
                and controller.aimTargetType == "unit"
                and controller.aimTargetID
                or nil

            local hasValidUnitTarget =
                guidedTargetID
                and IsValidGuidedEnemyTarget(
                    controller,
                    guidedTargetID
                )
                or false

            if hasValidUnitTarget then
                -- A genuine unit target keeps Mech.lua BlockShot authoritative:
                -- native minRange, ECM, stealth, TAG/NARC and lock state all see
                -- the same targetID they would under ordinary RTS control.
                if controller.ppcInhibitorPending then
                    controller.ppcInhibitorPending[weaponID] = nil
                end

                local targetAccepted =
                    spSetUnitTarget(
                        unitID,
                        guidedTargetID,
                        manualFire,
                        true,
                        weaponID
                    )

                local targetRetained =
                    targetAccepted ~= false

                if
                    targetRetained
                    and spGetUnitWeaponTarget
                then
                    local targetType, isUserTarget, currentTargetID =
                        spGetUnitWeaponTarget(
                            unitID,
                            weaponID
                        )

                    targetRetained =
                        targetType == WEAPON_TARGET_UNIT
                        and currentTargetID == guidedTargetID
                end

                if
                    not targetRetained
                    and not weaponTargetWarned[aimDef.weaponDefID]
                then
                    weaponTargetWarned[aimDef.weaponDefID] = true

                    Spring.Echo(
                        "[Shooter] WARNING: per-weapon UNIT target did not persist for WeaponDef",
                        aimDef.weaponDefID
                    )
                end

            elseif aimDef.requiresUnitTarget == true then
                -----------------------------------------------------------------
                -- SSRMs and all canAttackGround=false systems are lock-only.
                -- Holding LMB without a highlighted enemy cannot give them a
                -- positional target and therefore cannot launch them.
                -----------------------------------------------------------------

                ClearOffensiveWeaponTarget(
                    controller,
                    weaponID
                )

            else
                local insideMinRange =
                    IsInsideShooterMinRange(
                        controller,
                        aimDef
                    )

                local allowPositionalFire = true

                if insideMinRange then
                    if
                        aimDef.weaponClass == "ppc"
                        and IsPPCInhibitorActive(
                            controller,
                            weaponID
                        )
                    then
                        -- Native BlockShot cannot derive distance from Shooter's
                        -- position target. Permit the PPC Inhibitor exception and
                        -- arm its existing GG.ApplyPPC side effect for the actual
                        -- projectile launch.
                        ArmPPCInhibitorEffect(
                            controller,
                            weaponID
                        )
                    else
                        allowPositionalFire = false
                    end
                elseif controller.ppcInhibitorPending then
                    controller.ppcInhibitorPending[weaponID] = nil
                end

                if allowPositionalFire then
                    local targetX = controller.aimX
                    local targetY = controller.aimY
                    local targetZ = controller.aimZ

                    local rawDistance =
                        controller.rawAimDistance
                        or MIN_WEAPON_CONVERGENCE_DISTANCE

                    if
                        rawDistance < MIN_WEAPON_CONVERGENCE_DISTANCE
                        and controller.fireOriginX
                        and controller.fireDirX
                    then
                        local projectedDistance =
                            MIN_WEAPON_CONVERGENCE_DISTANCE

                        local weaponDef =
                            aimDef
                            and aimDef.weaponDefID
                            and WeaponDefs[aimDef.weaponDefID]

                        local weaponRange =
                            weaponDef
                            and tonumber(weaponDef.range)

                        if
                            weaponRange
                            and weaponRange > 0
                        then
                            projectedDistance =
                                min(
                                    projectedDistance,
                                    weaponRange * WEAPON_RANGE_CONVERGENCE_FRACTION
                                )

                            projectedDistance =
                                max(
                                    projectedDistance,
                                    rawDistance
                                )
                        end

                        targetX =
                            controller.fireOriginX +
                            controller.fireDirX * projectedDistance

                        targetY =
                            controller.fireOriginY +
                            controller.fireDirY * projectedDistance

                        targetZ =
                            controller.fireOriginZ +
                            controller.fireDirZ * projectedDistance
                    end

                    -----------------------------------------------------------------
                    -- r46: positional maximum-range forgiveness. The reticle stays
                    -- where the player aimed; only this weapon's hidden engine target
                    -- is pulled back along the exact same ray. Real UNIT targets use
                    -- the native branch above and are never clamped here.
                    -----------------------------------------------------------------

                    local weaponRange =
                        GetShooterWeaponMaxRange(
                            controller,
                            aimDef,
                            weaponID
                        )

                    if
                        weaponRange
                        and rawDistance > weaponRange
                        and controller.fireOriginX
                        and controller.fireDirX
                    then
                        targetX =
                            controller.fireOriginX +
                            controller.fireDirX * weaponRange

                        targetY =
                            controller.fireOriginY +
                            controller.fireDirY * weaponRange

                        targetZ =
                            controller.fireOriginZ +
                            controller.fireDirZ * weaponRange
                    end

                    spSetUnitTarget(
                        unitID,
                        targetX,
                        targetY,
                        targetZ,
                        manualFire,
                        true,
                        weaponID
                    )
                else
                    ClearOffensiveWeaponTarget(
                        controller,
                        weaponID
                    )
                end
            end
		else
			ClearOffensiveWeaponTarget(
				controller,
				weaponID
			)
		end
	end
end

local function ResetAimPieces(controller)
	if not controller then
		return
	end

	local unitID =
		controller.unitID

	if
		not unitID
		or not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return
	end

	local torsoSpeed, elevationSpeed =
		GetDirectAimSpeeds(
			unitID,
			controller.unitDefID
		)

	if controller.torsoPiece then
		spCallAsUnit(
			unitID,
			TurnPiece,
			controller.torsoPiece,
			Y_AXIS,
			0,
			torsoSpeed
		)
	end

	local pieceDrivers =
		controller.pieceDrivers

	if pieceDrivers then
		for i = 1, #pieceDrivers do
			spCallAsUnit(
				unitID,
				TurnPiece,
				pieceDrivers[i].pieceNum,
				X_AXIS,
				0,
				elevationSpeed
			)
		end
	end
end

--------------------------------------------------------------------------------
-- Run state and chassis yaw authority
--------------------------------------------------------------------------------

local function GetMechScriptEnv(unitID)
	if not spGetScriptEnv then
		return nil
	end

	return
		spGetScriptEnv(
			unitID
		)
end

local function SetDirectRun(controller, enable)
	if not controller then
		return false
	end

	local unitID =
		controller.unitID

	if
		not unitID
		or not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return false
	end

	enable =
		enable == true

	if controller.runApplied == enable then
		return true
	end

	local env =
		GetMechScriptEnv(
			unitID
		)

	if
		not env
		or not env.Run
	then
		return false
	end

	spCallAsUnit(
		unitID,
		env.Run,
		enable
	)

	controller.runApplied = enable

	return true
end

local function GetCurrentChassisTurnRate(unitID, unitDefID)
	if
		GG
		and GG.GetUnitTurnRate
	then
		local current =
			tonumber(
				GG.GetUnitTurnRate(
					unitID
				)
			)

		if
			current
			and current > 0
		then
			return current
		end
	end

	local ud =
		unitDefID
		and UnitDefs[unitDefID]

	return
		ud
		and ud.turnRate
		or 0
end

local function GetRunningSpeedMultiplier(unitID)
	local rawRunning =
		spGetUnitRulesParam
		and spGetUnitRulesParam(
			unitID,
			"running"
		)

	local running =
		tonumber(
			rawRunning
			or 0
		)
		or 0

	if running <= 0 then
		return 1
	end

	-- Mech.lua deliberately leaves speedMod in its script environment. It is
	-- the authoritative final movement multiplier after ordinary running,
	-- MASC, TSM, Supercharger and the global speed mod have been composed.
	local env =
		GetMechScriptEnv(
			unitID
		)

	local currentSpeedMod =
		tonumber(
			env
			and env.speedMod
		)

	if
		not currentSpeedMod
		or currentSpeedMod <= 0
	then
		return 1
	end

	-- Remove the global game-speed multiplier so the handling penalty measures
	-- only how much faster this particular Mech is moving than its normal gait.
	local globalSpeedMod =
		tonumber(
			GG
			and GG.modOptions
			and GG.modOptions.speed
		)
		or 1

	if globalSpeedMod <= 0 then
		globalSpeedMod = 1
	end

	return
		max(
			MIN_RUN_SPEED_MULTIPLIER,
			currentSpeedMod /
			globalSpeedMod
		)
end

local function GetEffectiveMovingTurnRate(unitID, unitDefID)
	local chassisTurnRate =
		GetCurrentChassisTurnRate(
			unitID,
			unitDefID
		)

	if chassisTurnRate <= 0 then
		return 0
	end

	local runSpeedMultiplier =
		GetRunningSpeedMultiplier(
			unitID
		)

	-- Increased speed enlarges turning radius. Explicit agility modifiers have
	-- already been folded into chassisTurnRate by unit_turn.lua and therefore
	-- still increase yaw authority instead of being mistaken for speed.
	return
		chassisTurnRate /
		max(
			1,
			runSpeedMultiplier
		)
end

local function UnitIsUsingMoveCtrl(unitID)
	if
		not spMoveCtrlIsEnabled
		or not unitID
	then
		return false
	end

	return
		spMoveCtrlIsEnabled(
			unitID
		) == true
end

local function ApplyMovingTurnRate(unitID, unitDefID)
	if
		not spSetGMTData
		or UnitIsUsingMoveCtrl(unitID)
	then
		return
	end

	local effectiveTurnRate =
		GetEffectiveMovingTurnRate(
			unitID,
			unitDefID
		)

	if effectiveTurnRate <= 0 then
		return
	end

	spSetGMTData(
		unitID,
		"turnRate",
		effectiveTurnRate
	)
end

--------------------------------------------------------------------------------
-- Movement
--------------------------------------------------------------------------------

local function GetTurnCommandID()
	if
		GG
		and GG.CustomCommands
		and GG.CustomCommands.GetCmdID
	then
		return
			GG.CustomCommands.GetCmdID(
				"CMD_TURN"
			)
	end

	return nil
end

local function CancelDirectTurn(controller)
	if
		not controller
		or not controller.directTurnActive
	then
		return
	end

	local unitID =
		controller.unitID

	-- unit_turn.lua cancels an active Turn command when it receives another
	-- direct command such as STOP, then disables its temporary MoveCtrl state.
	if
		unitID
		and spValidUnitID(unitID)
		and not spGetUnitIsDead(unitID)
		and GG
		and GG.turning
		and GG.turning[unitID]
	then
		spGiveOrderToUnit(
			unitID,
			CMD.STOP,
			{},
			0
		)
	end

	controller.directTurnActive = false
end

local function ApplyTurnInPlace(controller, strafe)
	if
		not controller
		or abs(strafe) < 0.01
	then
		return false
	end

	local unitID =
		controller.unitID

	if
		not unitID
		or not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return false
	end

	local cmdTurn =
		GetTurnCommandID()

	if not cmdTurn then
		return false
	end

	-------------------------------------------------------------------------
	-- If our previous 90-degree Turn command is still running, simply leave
	-- it alone. When it completes, the next shooter update while A/D remains
	-- held starts the next 90-degree turn.
	-------------------------------------------------------------------------

	if
		GG
		and GG.turning
		and GG.turning[unitID]
	then
		controller.directTurnActive = true
		return true
	end

	local springHeading =
		spGetUnitHeading(unitID) or 0

	local heading =
		springHeading * HEADING_TO_RAD

	-- Use the exact same unit-local right basis as normal direct movement so
	-- A and D continue turning toward the same side they previously steered.
	local rightX =
		-cos(heading)

	local rightZ =
		sin(heading)

	local ux, uy, uz =
		spGetUnitPosition(unitID)

	if not ux then
		return false
	end

	local tx =
		ux +
		rightX *
		strafe *
		TURN_TARGET_DISTANCE

	local tz =
		uz +
		rightZ *
		strafe *
		TURN_TARGET_DISTANCE

	tx =
		max(
			0,
			min(
				Game.mapSizeX,
				tx
			)
		)

	tz =
		max(
			0,
			min(
				Game.mapSizeZ,
				tz
			)
		)

	local ty =
		spGetGroundHeight(
			tx,
			tz
		)

	SetForcedReverse(
		controller,
		false
	)

	spClearUnitGoal(unitID)

	spGiveOrderToUnit(
		unitID,
		cmdTurn,
		{
			tx,
			ty,
			tz,
		},
		0
	)

	controller.directTurnActive = true

	return true
end

local function StopMovement(controller)
	if not controller then
		return
	end

	SetDirectRun(
		controller,
		false
	)

	CancelDirectTurn(
		controller
	)

	SetForcedReverse(
		controller,
		false
	)

	local unitID =
		controller.unitID

	if
		unitID
		and spValidUnitID(unitID)
		and not spGetUnitIsDead(unitID)
	then
		spClearUnitGoal(unitID)
	end
end

local function ApplyMovement(controller)
	if not controller then
		return
	end

	local unitID =
		controller.unitID

	if
		not spValidUnitID(unitID)
		or spGetUnitIsDead(unitID)
	then
		return
	end

	-------------------------------------------------------------------------
	-- Yield to ScriptMoveType / MoveCtrl ownership.
	--
	-- unit_jumpjets.lua enables MoveCtrl while crouching/flying/landing, and
	-- unit_turn.lua enables it during stationary CMD_TURN pivots. While that
	-- is active the Mech no longer has a GroundMoveType, so any call to
	-- SetGroundMoveTypeData would be invalid.
	--
	-- Do not clear input or alter movement state here. The player's WASD/Shift
	-- state remains latched and resumes naturally once MoveCtrl is disabled.
	-------------------------------------------------------------------------

	if UnitIsUsingMoveCtrl(unitID) then
		return
	end

	local strafe =
		controller.strafe or 0

	local forward =
		controller.forward or 0

	local hasTurnInput =
		abs(strafe) >= 0.01

	local hasDriveInput =
		abs(forward) >= 0.01

	if
		not hasTurnInput
		and not hasDriveInput
	then
		SetDirectRun(
			controller,
			false
		)

		CancelDirectTurn(
			controller
		)

		SetForcedReverse(
			controller,
			false
		)

		spClearUnitGoal(unitID)
		return
	end

	-------------------------------------------------------------------------
	-- A/D without W/S: pivot in place using the original MCL turn system.
	-------------------------------------------------------------------------

	if
		not hasDriveInput
		and hasTurnInput
	then
		SetDirectRun(
			controller,
			false
		)

		if
			ApplyTurnInPlace(
				controller,
				strafe
			)
		then
			return
		end
	end

	-------------------------------------------------------------------------
	-- W/S supplies translation. A/D now supplies yaw only.
	--
	-- Shift-run is permitted only while moving forward. Reverse automatically
	-- returns to normal movement exactly as Mech.lua expects.
	-------------------------------------------------------------------------

	local shouldRun =
		controller.runRequested == true
		and forward > 0.01

	SetDirectRun(
		controller,
		shouldRun
	)

	CancelDirectTurn(
		controller
	)

	SetForcedReverse(
		controller,
		forward < -0.01
	)

	local unitDefID =
		spGetUnitDefID(
			unitID
		)

	ApplyMovingTurnRate(
		unitID,
		unitDefID
	)

	local springHeading =
		spGetUnitHeading(unitID) or 0

	local heading =
		springHeading * HEADING_TO_RAD

	-- Preserve r19 A/D direction semantics: A (-1) requests +90 degrees;
	-- D (+1) requests -90 degrees.
	local steerAngle = 0

	if hasTurnInput then
		steerAngle =
			-strafe *
			MOVING_STEER_ANGLE
	end

	local desiredFacing =
		heading +
		steerAngle

	local movementHeading =
		desiredFacing

	if forward < -0.01 then
		-- Reverse goal lies behind the requested chassis facing; forced-reverse
		-- MoveType settings keep the Mech backing while yaw direction stays
		-- consistent with A/D.
		movementHeading =
			movementHeading +
			math.pi
	end

	local moveX =
		sin(
			movementHeading
		)

	local moveZ =
		cos(
			movementHeading
		)

	local ux, uy, uz =
		spGetUnitPosition(unitID)

	if not ux then
		return
	end

	local goalX =
		ux +
		moveX *
		MOVE_LOOKAHEAD

	local goalZ =
		uz +
		moveZ *
		MOVE_LOOKAHEAD

	goalX =
		max(
			0,
			min(
				Game.mapSizeX,
				goalX
			)
		)

	goalZ =
		max(
			0,
			min(
				Game.mapSizeZ,
				goalZ
			)
		)

	local goalY =
		spGetGroundHeight(
			goalX,
			goalZ
		)

	spSetUnitMoveGoal(
		unitID,
		goalX,
		goalY,
		goalZ,
		MOVE_GOAL_RADIUS
	)
end

--------------------------------------------------------------------------------
-- Controller lifecycle
--------------------------------------------------------------------------------

local function ReleaseController(playerID)
	local controller =
		controllers[playerID]

	if not controller then
		return
	end

	ClearOffensiveWeaponTargets(controller)
	StopMovement(controller)
	ResetAimPieces(controller)

	if
		controller.unitID
		and spSetUnitRulesParam
	then
		spSetUnitRulesParam(
			controller.unitID,
			ARC_PARAM_IN,
			0,
			{
				public = true,
			}
		)

		spSetUnitRulesParam(
			controller.unitID,
			ARC_PARAM_TOTAL,
			0,
			{
				public = true,
			}
		)

		spSetUnitRulesParam(
			controller.unitID,
			LANE_DIR_X_PARAM,
			0,
			{
				public = true,
			}
		)

		spSetUnitRulesParam(
			controller.unitID,
			LANE_DIR_Z_PARAM,
			1,
			{
				public = true,
			}
		)
	end

	if controller.unitID then
		controlledUnits[
			controller.unitID
		] = nil
	end

	controllers[playerID] = nil
end

local function CreateController(playerID, unitID)
	ReleaseController(playerID)

	local valid, teamID =
		IsValidOwnedUnit(
			playerID,
			unitID
		)

	if not valid then
		return
	end

	if controlledUnits[unitID] then
		return
	end

	-------------------------------------------------------------------------
	-- Resolve the unit before claiming it. Once claimed, AllowWeaponTarget must
	-- already suppress offensive reacquisition while STOP / target-cancel
	-- processing runs, otherwise an existing attack order can leak a stale
	-- per-weapon target into the first moments of direct control.
	-------------------------------------------------------------------------

	local pieceMap =
		spGetUnitPieceMap(unitID)

	local torsoPiece =
		pieceMap
		and (
			pieceMap.torso
			or pieceMap.Torso
		)

	if not torsoPiece then
		Spring.Echo(
			"[Shooter] Unit has no torso piece:",
			unitID
		)

		return
	end

	local unitDefID =
		spGetUnitDefID(unitID)

	local unitDef =
		unitDefID
		and UnitDefs[unitDefID]

	if
		not unitDef
		or (unitDef.rSpeed or 0) <= 0
	then
		Spring.Echo(
			"[Shooter] WARNING: unit has no native reverse speed; S cannot be forced to reverse:",
			unitID
		)
	end

	local weaponAimDefs, pieceDrivers, offensiveWeaponCount =
		BuildWeaponAimDefinitions(
			unitID,
			unitDefID,
			pieceMap
		)

	-------------------------------------------------------------------------
	-- Claim first, then cancel. This makes AllowWeaponTarget return false for
	-- offensive weapons during the command handoff itself.
	-------------------------------------------------------------------------

	controlledUnits[unitID] =
		playerID

	CancelExistingOrders(unitID)

	controllers[playerID] = {
		unitID = unitID,
		unitDefID = unitDefID,
		teamID = teamID,

		strafe = 0,
		forward = 0,

		aimX = nil,
		aimY = nil,
		aimZ = nil,
        aimTargetType = "none",
        aimTargetID = nil,

		fireOriginX = nil,
		fireOriginY = nil,
		fireOriginZ = nil,
		fireDirX = nil,
		fireDirY = nil,
		fireDirZ = nil,
		rawAimDistance = nil,
		convergenceX = nil,
		convergenceY = nil,
		convergenceZ = nil,

		torsoPiece = torsoPiece,

		weaponAimDefs = weaponAimDefs,
		pieceDrivers = pieceDrivers,
		weaponAimState = {},
        ppcInhibitorPending = {},
		offensiveWeaponCount = offensiveWeaponCount,

		lastArcIn = nil,
		lastArcTotal = nil,

		laneTorsoYaw = 0,
		laneTorsoYawFrame = spGetGameFrame() or 0,

		reverseOverride = false,
		directTurnActive = false,

		runRequested = false,
		runApplied = false,

		fireRequested = false,
	}

	local controller =
		controllers[playerID]

	-------------------------------------------------------------------------
	-- STOP and SetUnitTarget(nil) are unit-level operations. Recoil weapons can
	-- retain their own current target independently, so explicitly hold every
	-- offensive slot here before direct control becomes interactive.
	-------------------------------------------------------------------------

	ClearOffensiveWeaponTargets(controller)

	SetArcSummary(
		controller,
		0,
		offensiveWeaponCount
	)

	Spring.Echo(
		"[Shooter] Direct weapon aim:",
		unitID,
		"weapons=" .. tostring(offensiveWeaponCount),
		"drivers=" .. tostring(#pieceDrivers)
	)
end

--------------------------------------------------------------------------------
-- Message handlers
--------------------------------------------------------------------------------

local function HandleEnter(playerID, args)
	local unitID =
		tonumber(args[3])

	if not unitID then
		return
	end

	CreateController(
		playerID,
		unitID
	)
end

local function HandleExit(playerID)
	ReleaseController(
		playerID
	)
end

local function HandleMove(playerID, args)
	local controller =
		controllers[playerID]

	if not controller then
		return
	end

	local strafe =
		tonumber(args[3])

	local forward =
		tonumber(args[4])

	if
		not strafe
		or not forward
	then
		return
	end

	strafe =
		max(-1, min(1, strafe))

	forward =
		max(-1, min(1, forward))

	controller.strafe = strafe
	controller.forward = forward

	ApplyMovement(controller)
end

local function HandleRun(playerID, args)
	local controller =
		controllers[playerID]

	if not controller then
		return
	end

	local requested =
		tonumber(
			args[3]
		)

	if requested == nil then
		return
	end

	controller.runRequested =
		requested > 0

	ApplyMovement(
		controller
	)
end

local function HandleFire(playerID, args)
	local controller =
		controllers[playerID]

	if not controller then
		return
	end

	local requested =
		tonumber(
			args[3]
		)

	if requested == nil then
		return
	end

	local shouldFire =
		requested > 0

	if
		controller.fireRequested
		== shouldFire
	then
		return
	end

	controller.fireRequested =
		shouldFire

	if shouldFire then
		-- Refresh direct bearing state before assigning the first targets so a
		-- fresh click cannot use stale geometry from the previous aim update.
		ApplyAim(controller)
		ApplyFireTargets(controller)
	else
		ClearOffensiveWeaponTargets(controller)
	end
end

local function HandleAim(playerID, args)
    local controller =
        controllers[playerID]

    if not controller then
        return
    end

    local x =
        tonumber(args[3])

    local y =
        tonumber(args[4])

    local z =
        tonumber(args[5])

    if
        not x
        or not y
        or not z
    then
        return
    end

    controller.aimX = x
    controller.aimY = y
    controller.aimZ = z

    local encodedType =
        args[6]

    local encodedID =
        tonumber(args[7])

    if
        encodedType == "U"
        and IsValidGuidedEnemyTarget(
            controller,
            encodedID
        )
    then
        controller.aimTargetType = "unit"
        controller.aimTargetID = encodedID
    else
        controller.aimTargetType = "none"
        controller.aimTargetID = nil
    end

    ApplyAim(controller)

    if controller.fireRequested then
        ApplyFireTargets(controller)
    end
end


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function gadget:Initialize()
    if
        not Script
        or not Script.SetWatchProjectile
    then
        return
    end

    for weaponDefID, wd in pairs(WeaponDefs) do
        local cp = wd.customParams or {}
        local weaponClass =
            string.lower(
                tostring(cp.weaponclass or "")
            )

        if
            weaponClass == "lrm"
            or weaponClass == "srm"
            or weaponClass == "ssrm"
            or weaponClass == "narc"
            or weaponClass == "arrowiv"
            or weaponClass == "ppc"
        then
            Script.SetWatchProjectile(
                weaponDefID,
                true
            )
        end
    end
end

--------------------------------------------------------------------------------
-- LuaUI -> LuaRules
--------------------------------------------------------------------------------

function gadget:RecvLuaMsg(message, playerID)
	if
		string.sub(
			message,
			1,
			#MESSAGE_PREFIX
		)
		~= MESSAGE_PREFIX
	then
		return false
	end

	local args =
		Split(message)

	local command =
		args[2]

	if command == "ENTER" then
		HandleEnter(playerID, args)

	elseif command == "EXIT" then
		HandleExit(playerID)

	elseif command == "MOVE" then
		HandleMove(playerID, args)

	elseif command == "AIM" then
		HandleAim(playerID, args)

	elseif command == "FIRE" then
		HandleFire(playerID, args)


	elseif command == "RUN" then
		HandleRun(playerID, args)

	else
		return false
	end

	return true
end

--------------------------------------------------------------------------------
-- Continuous update
--------------------------------------------------------------------------------

function gadget:GameFrame(frame)
	if
		frame % MOVE_UPDATE_FRAMES
		~= 0
	then
		return
	end

	for playerID, controller
	in pairs(controllers)
	do
		local valid =
			IsValidOwnedUnit(
				playerID,
				controller.unitID
			)

		if not valid then
			ReleaseController(playerID)
		else
			ApplyMovement(controller)
			ApplyAim(controller)

			if controller.fireRequested then
				ApplyFireTargets(controller)
			else
				-----------------------------------------------------------------
				-- Hard direct-control invariant: offensive weapons have no target
				-- unless the player is actively holding LMB. This continuously
				-- flushes any stale RTS/autotarget state that survives takeover.
				-----------------------------------------------------------------
				ClearOffensiveWeaponTargets(controller)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Cleanup
--------------------------------------------------------------------------------

function gadget:UnitDestroyed(unitID)
	local playerID =
		controlledUnits[unitID]

	if playerID then
		ReleaseController(playerID)
	end
end

function gadget:UnitTaken(unitID)
	local playerID =
		controlledUnits[unitID]

	if playerID then
		ReleaseController(playerID)
	end
end

function gadget:UnitGiven(unitID)
	local playerID =
		controlledUnits[unitID]

	if playerID then
		ReleaseController(playerID)
	end
end

function gadget:PlayerRemoved(playerID)
	ReleaseController(playerID)
end

function gadget:Shutdown()
	local playerIDs = {}

	for playerID in pairs(controllers) do
		playerIDs[#playerIDs + 1] =
			playerID
	end

	for i = 1, #playerIDs do
		ReleaseController(
			playerIDs[i]
		)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
