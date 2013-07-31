function gadget:GetInfo()
        return {
                name      = "Auras",
                desc      = "Affects units around particular units",
                author    = "Gnome",
                date      = "October 2008",
                license   = "PD",
                layer     = 0,
                enabled   = true
        }
end
 
local GetAllUnits = Spring.GetAllUnits
local GetUnitTeam = Spring.GetUnitTeam
local GetUnitDefID = Spring.GetUnitDefID
local GetUnitSeparation = Spring.GetUnitSeparation
local ValidUnitID = Spring.ValidUnitID
local SetUnitRulesParam = Spring.SetUnitRulesParam
local SetUnitBuildSpeed = Spring.SetUnitBuildSpeed
local GetUnitHealth = Spring.GetUnitHealth
local SetUnitHealth = Spring.SetUnitHealth
local SetUnitMaxHealth = Spring.SetUnitMaxHealth
local GetUnitResources = Spring.GetUnitResources
local SetUnitResourcing = Spring.SetUnitResourcing
local SetUnitWeaponState = Spring.SetUnitWeaponState
local GetUnitPosition = Spring.GetUnitPosition
local GetUnitIsTransporting = Spring.GetUnitIsTransporting
local GetUnitsInCylinder = Spring.GetUnitsInCylinder
 
if (gadgetHandler:IsSyncedCode()) then
 
local auras = {}
local projectingUnits = {}
local affectedUnits = {}
 
function gadget:Initialize()
        raw = include("LuaRules/Configs/aura_defs.lua")
        for name,defs in pairs(raw) do
                local udid = UnitDefNames[name].id or nil
                if(udid) then auras[udid] = defs end
        end
 
        -- Loops through the units, calling g:UnitFinished() on each of them
        for _,unitID in ipairs(GetAllUnits()) do
                local teamID = GetUnitTeam(unitID)
                local unitDefID = GetUnitDefID(unitID)
                gadget:UnitFinished(unitID, unitDefID, teamID)
        end
end
 
function gadget:UnitFinished(uid, udid, tid)
        if(auras[udid]) then
                projectingUnits[uid] = {udid = udid, tid = tid}
        end
end
 
function gadget:UnitDestroyed(uid, udid, tid, aid, adid, atid)
        if(projectingUnits[uid]) then
                projectingUnits[uid] = nil
        elseif(affectedUnits[uid]) then
                affectedUnits[uid] = nil
        end
end
 
local function InCategory(mask, categories)
        for _,name in pairs(mask) do
                if(name == "all") then
                        return true
                elseif(categories[name]) then
                        return true
                end
        end
        return false
end
 
function gadget:GameFrame(n)
        if(n % 30 < 1) then
                -- remove bonuses if units are no longer within the aura
                for uid,defs in pairs(affectedUnits) do
                        local sep = GetUnitSeparation(uid, defs.parent.uid, true) or 10000
                        if(ValidUnitID(uid) and (ValidUnitID(defs.parent.uid) == false or sep > defs.parent.range)) then
                                for key, value in pairs(defs) do
                                        if(key == "buildSpeed") then
                                                SetUnitBuildSpeed(uid, value)
                                                SetUnitRulesParam(uid, "aurabuildspeed", 0)
 
                                        elseif(key == "hp") then
                                                local curHP, maxHP = GetUnitHealth(uid)
                                                local hpPct = curHP / maxHP
                                                SetUnitHealth(uid, value * hpPct)
                                                SetUnitMaxHealth(uid, value)
                                                SetUnitRulesParam(uid, "aurahp", 0)
 
                                        elseif(key == "energy") then
                                                SetUnitResourcing(uid, "cme", 0)
                                                SetUnitRulesParam(uid, "auraenergy", 0)
 
                                        elseif(key == "metal") then
                                                SetUnitResourcing(uid, "cmm", 0)
                                                SetUnitRulesParam(uid, "aurametal", 0)
 
                                        elseif(key == "weapons") then
                                                for weaponNum,orig in pairs(value) do
                                                        SetUnitWeaponState(uid, weaponNum - 1, {reloadtime = orig.reload, accuracy = orig.accuracy, range = orig.range, projectileSpeed = orig.speed})
                                                        SetUnitRulesParam(uid, "aurarange", 0)
                                                        SetUnitRulesParam(uid, "aurareloadtime", 0)
                                                        SetUnitRulesParam(uid, "auraaccuracy", 0)
                                                end
                                        end
                                end
                                affectedUnits[uid] = nil
                        end
                        if(defs.heal == true) then
                                SetUnitRulesParam(uid, "auraheal", 0)
                                affectedUnits[uid] = nil
                        end
                end
 
 
                -- apply auras
                for uid,pdat in pairs(projectingUnits) do
                        local ux, uy, uz = GetUnitPosition(uid)
                        local defs = auras[pdat.udid]
                        local team = GetUnitTeam(uid)
                        local affected = {}
 
                        if(defs.transport) then
                                affected = GetUnitIsTransporting(uid)
                        else
                                affected = GetUnitsInCylinder(ux,uz,defs.range,pdat.tid)
                        end
 
                        if(affected) then
                                for _,affectedid in ipairs(affected) do
 
                                        if(ValidUnitID(affectedid) and affectedid ~= uid) then
                                                if(not affectedUnits[affectedid]) then
                                                        local affectedudid = GetUnitDefID(affectedid)
                                                        local ad = UnitDefs[affectedudid]
                                                        affectedUnits[affectedid] = {}
                                                        affectedUnits[affectedid].parent = {uid = uid, udid = pdat.udid, range = defs.range}
                                                        local hasBeenAffected = false
 
                                                        local categories = ad.modCategories
 
                                                        --boost buildpower
                                                        local buildSpeed = ad.buildSpeed
                                                        if (defs.buildpower and buildSpeed and buildSpeed > 0) and
                                                                InCategory(defs.buildpower.mask, categories) then
 
                                                                hasBeenAffected = true
                                                                affectedUnits[affectedid].buildSpeed = buildSpeed
                                                                SetUnitBuildSpeed(affectedid, buildSpeed * defs.buildpower.rate)
                                                                SetUnitRulesParam(affectedid, "aurabuildspeed", defs.buildpower.rate)
                                                        end
 
                                                        --boost hp (armor)
                                                        if(defs.hp and InCategory(defs.hp.mask, categories)) then
                                                                local curHP, maxHP = GetUnitHealth(affectedid)
                                                                local hpPct = curHP / maxHP
                                                                hasBeenAffected = true
                                                                affectedUnits[affectedid].hp = maxHP
                                                                SetUnitMaxHealth(affectedid, maxHP * defs.hp.rate)
                                                                SetUnitHealth(affectedid, maxHP * defs.hp.rate * hpPct)
                                                                SetUnitRulesParam(affectedid, "aurahp", defs.hp.rate)
                                                        end
 
--[[ this isn't working correctly right now
                                                        --boost energy production
                                                        local mmake,_,emake,_ = GetUnitResources(affectedid)
                                                        if(defs.energy and emake > 0) then
                                                                hasBeenAffected = true
                                                                affectedUnits[affectedid].energy = emake
                                                                SetUnitResourcing(affectedid, "ume", emake * defs.energy)
                                                                SetUnitRulesParam(affectedid, "aurapower", defs.energy.rate)
                                                        end
 
                                                        --boost metal production
                                                        if(defs.metal and mmake > 0) then
                                                                hasBeenAffected = true
                                                                affectedUnits[affectedid].metal = mmake
                                                                SetUnitResourcing(affectedid, "umm", mmake * defs.metal)
                                                                SetUnitRulesParam(affectedid, "aurareq", defs.metal.rate)
                                                        end
]]
 
                                                        --boost weapon stats
                                                        local weapons = ad.weapons
                                                        if(defs.weapons and (defs.weapons.reloadtime or defs.weapons.range or defs.weapons.accuracy) and weapons and InCategory(defs.weapons.mask, categories)) then
                                                                hasBeenAffected = true
                                                                affectedUnits[affectedid].weapons = {}
                                                                for i=1,#weapons do
                                                                        local wdat = WeaponDefs[weapons[i].weaponDef]
                                                                        defs.weapons.accuracy = defs.weapons.accuracy or 1
                                                                        defs.weapons.range = defs.weapons.range or 1
                                                                        defs.weapons.reloadtime = defs.weapons.reloadtime or 1
																		Spring.Echo("accuracy: " .. wdat.accuracy .. " mult: " .. defs.weapons.accuracy)
                                                                        affectedUnits[affectedid].weapons[i] = {reload = wdat.reload, accuracy = wdat.accuracy, range = wdat.range, speed = wdat.projectilespeed}
                                                                        SetUnitWeaponState(affectedid, i - 1, {
                                                                                reloadTime = wdat.reload * defs.weapons.reloadtime,
                                                                                range = wdat.range * defs.weapons.range,
                                                                                accuracy = wdat.accuracy * defs.weapons.accuracy,
                                                                                projectileSpeed = wdat.projectilespeed * defs.weapons.range,    --prevent laser falloff
                                                                        })
                                                                        if(wdat.range) then SetUnitRulesParam(affectedid, "aurarange", defs.weapons.range) end
                                                                        if(wdat.reloadtime) then SetUnitRulesParam(affectedid, "aurareload", defs.weapons.reloadtime) end
                                                                        if(wdat.accuracy) then SetUnitRulesParam(affectedid, "auraaccuracy", defs.weapons.accuracy) end
                                                                end
                                                        end
 
                                                        --heal a unit
                                                        --since this just adds HP, we don't need to track the unit in affectedUnits
                                                        if(defs.heal and InCategory(defs.heal.mask, categories)) then
                                                                local curHP, maxHP = GetUnitHealth(affectedid)
                                                                if(curHP ~= maxHP) then
                                                                        local newHP = math.min(curHP + maxHP * defs.heal.rate, maxHP)
                                                                        hasBeenAffected = true
                                                                        affectedUnits[affectedid].heal = true
                                                                        SetUnitHealth(affectedid, newHP)
                                                                        SetUnitRulesParam(affectedid, "auraheal", defs.heal.rate)
                                                                end
                                                        end
 
                                                        -- take the unit back out of the affectedUnits table if it's not actually affected in any way
                                                        if(hasBeenAffected == false) then
                                                                affectedUnits[affectedid] = nil
                                                        end
                                                end
                                        end
                                end
                        end
                end
        end
end
 
else -- end synced
 
local GetTeamUnits = Spring.GetTeamUnits
local GetLocalTeamID = Spring.GetLocalTeamID
local GetUnitDefID = Spring.GetUnitDefID
local IsUnitSelected = Spring.IsUnitSelected
local GetUnitPosition = Spring.GetUnitPosition
local glDepthTest = gl.DepthTest
local glColor = gl.Color
local glDrawGroundCircle = gl.DrawGroundCircle
 
local auras = {}
 
function gadget:Initialize()
        raw, auraColors = include("LuaRules/Configs/aura_defs.lua")
        for name,defs in pairs(raw) do
                local udid = UnitDefNames[name].id or nil
                if(udid) then auras[udid] = defs end
        end
end
 
function gadget:DrawWorldPreUnit()
        local units = GetTeamUnits(GetLocalTeamID())
        for _,uid in ipairs(units) do
                local udid = GetUnitDefID(uid)
                if(auras[udid] and IsUnitSelected(uid)) then
                        local x, y, z = GetUnitPosition(uid)
                        glDepthTest(true)
                        glColor(0,0.6,0,1)
                        glDrawGroundCircle(x,y,z,auras[udid].range,24)
						glColor(1,1,0)
						glDrawGroundCircle(x,y,z,tonumber(UnitDefs[udid].customParams.supplyradius),24)
                        glDepthTest(false)
                        glColor(1,1,1,1)
                end
        end
end
 
end -- end unsynced