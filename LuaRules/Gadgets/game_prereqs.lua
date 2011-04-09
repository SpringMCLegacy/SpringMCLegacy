function gadget:GetInfo()
  return {
    name      = "Prerequisites",
    desc      = "Prerequisites for building certain units.",
    author    = "Evil4Zerggin",
    date      = "21 July 2008",
    license   = "GNU LGPL, v2.1 or later",
    layer     = -5,
    enabled   = true  --  loaded by default?
  }
end

--synced only

if not gadgetHandler:IsSyncedCode() then return end
----------------------------------------------------------------
--speedups
----------------------------------------------------------------

local GetUnitCmdDescs = Spring.GetUnitCmdDescs
local EditUnitCmdDesc = Spring.EditUnitCmdDesc
local GetUnitIsStunned = Spring.GetUnitIsStunned
local AreTeamsAllied = Spring.AreTeamsAllied
local GetUnitAllyTeam = Spring.GetUnitAllyTeam
local GetUnitDefID = Spring.GetUnitDefID
local GetUnitTeam = Spring.GetUnitTeam
local GetTeamUnits = Spring.GetTeamUnits

local FindUnitCmdDesc = Spring.FindUnitCmdDesc
local EditUnitCmdDesc = Spring.EditUnitCmdDesc

----------------------------------------------------------------
--locals
----------------------------------------------------------------
--unitDefID = { teamID = buildable, ... }
local buildables = {}

--unitDefID = { units enabled by unitDefID }
local enables = {}

local prereqDefs = VFS.Include("LuaRules/Configs/prereq_defs.lua")

for unitname, prereqs in pairs(prereqDefs) do
  local unitDefID = UnitDefNames[unitname].id
  buildables[unitDefID] = {}
  
  for i = 1, #prereqs do
    local prereqName = prereqs[i]
    local prereqID = UnitDefNames[prereqName].id
    local enable = enables[prereqID]
    if enable then
      enable[#enable+1] = unitDefID
    else
      enables[prereqID] = {
        unitDefID,
      }
    end
  end
end

local function SetBuildoptionDisabled(unitDefID, teamID, disable)
  local teamUnits = GetTeamUnits(teamID)
  for i = 1, #teamUnits do
    local unitID = teamUnits[i]
    local cmdDescID = FindUnitCmdDesc(unitID, -unitDefID)
    if cmdDescID then
      EditUnitCmdDesc(unitID, cmdDescID, {disabled = disable})
    end
  end
end

----------------------------------------------------------------
--callins
----------------------------------------------------------------

function gadget:Initialize()
  local allUnits = Spring.GetAllUnits()
  local allTeams = Spring.GetTeamList()
  for unitDefID, _ in pairs(buildables) do
	for i = 1, #allTeams do
	  local teamID = allTeams[i]
	  SetBuildoptionDisabled(unitDefID, teamID, true)
	end
  end

  for i = 1, #allUnits do
	local unitID = allUnits[i]
	local unitDefID = GetUnitDefID(unitID)
	local unitTeam = GetUnitTeam(unitID)
	gadget:UnitCreated(unitID, unitDefID, unitTeam)
  end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
  local enable = enables[unitDefID]
  if enable then
    for i = 1, #enable do
      local enableID = enable[i]
      local buildabilty = buildables[enableID]
      if buildabilty[unitTeam] then
        buildabilty[unitTeam] = buildabilty[unitTeam] + 1
      else
        buildabilty[unitTeam] = 1
        --enable
        SetBuildoptionDisabled(enableID, unitTeam, false)
      end
    end
  end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  --enable/disable for the constructor
	local ud = UnitDefs[unitDefID]
	if ud.buildDistance and ud.speed > 0 then
		--Spring.Echo("Builder! ", unitTeam)
		for buildDefID, buildability in pairs(buildables) do
			--Spring.Echo(unitTeam, " : ", (buildability[unitTeam] or "nil"))
			local cmdDescID = FindUnitCmdDesc(unitID, -buildDefID)
			if cmdDescID then
				if not buildability[unitTeam] then
					--Spring.Echo("Disabling unit!")
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = true})
				else
					--Spring.Echo("Enabling unit!")
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false})
				end
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  local _, _, inBuild = GetUnitIsStunned(unitID)
  
  if inBuild then return end
	
  --update prereqs
  local enable = enables[unitDefID]
  if enable then
    for i = 1, #enable do
      local enableID = enable[i]
      local buildabilty = buildables[enableID]

      if (buildabilty[unitTeam] or 1) >= 1 then
        if buildabilty[unitTeam] == 1 then
          --disable
          buildabilty[unitTeam] = nil
          SetBuildoptionDisabled(enableID, unitTeam, true)
        else
				  buildabilty[unitTeam] = buildabilty[unitTeam] - 1
				end
      else
        Spring.Echo("<prereqs>: Counting error", UnitDefs[enableID].name, buildabilty[unitTeam])
      end
    end
  end
end

-- problem is when units without a rax are transferred to team with rax?

function gadget:UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	if enables[unitDefID] then
		local _, _, inBuild = GetUnitIsStunned(unitID)
		if not inBuild then
			gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
			gadget:UnitFinished(unitID, unitDefID, newTeam)
		end
	else
		gadget:UnitCreated(unitID, unitDefID, newTeam)
  end
end
