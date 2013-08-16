-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--local auras = {
--      reb_commander = {
--              range = 300,            --range of the aura (applies to all effects)
--              transport = true,       --only applies to units being transported by this unit (you should also set range to 0 if this is true)
--              buildpower = {
--                      rate = 2,       --buildspeed multiplier
--                      mask = {"infantry","factories"},
--                                      --A mask will only apply this effect to these categories of units
--                                      --To apply to all (applicable) units, use the keyword "all"
--                                      --All masks work this way. The values are the same as those in the "Category" tag in the unit's fbi
--                                      --(you may need to add the new keywords. Remember there's a max of 32 categories)
--                                      --Do not use any caps
--              },
--              hp = {
--                      rate = 2,       --armor multiplier
--                      mask = {"all"},
--              },
--              heal = {
--                      rate = 0.1,     --heals the unit by maxHP * rate per second. The per second is non-negotiable
--                      mask = {"infantry"},
--              },
--              weapons = {
--                      reloadtime = 0.5,       --reloadtime multiplier
--						accuracy = 2,			--accuracy multiplier
--                      range = 2,              --Range multiplier. This also increases the projectile speed so lasers don't fade out.
--                                              --Missiles and artillery may have problems with excessive range increases
--                      mask = {"infantry","droid"},
--              },
--      },
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
 
 
local auras = {
        cl_dropship = {
                range = 300,
                transport = false,
                heal = {
						rate = 0.1,     --heals the unit by maxHP * rate per second. The per second is non-negotiable
						mask = {"all"},
				},
--				weapons = {
--						reloadtime = 0.5,       --reloadtime multiplier
--						accuracy = 0.01,			--accuracy multiplier
--						range = 0,              --Range multiplier. This also increases the projectile speed so lasers don't fade out.
--                                             --Missiles and artillery may have problems with excessive range increases
--						mask = {"all"},
--             },
        },
		is_dropship = {
                range = 300,
                transport = false,
                heal = {
						rate = 0.1,     --heals the unit by maxHP * rate per second. The per second is non-negotiable.
						mask = {"all"},
				},
        },
}
 
return auras