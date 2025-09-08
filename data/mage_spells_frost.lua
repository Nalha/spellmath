-- mage_spells_frost.lua
--
-- Spell data for Mage frost spells in WoW Classic (patch 1.12.1).
-- This file follows the same conventions used in the fire spell data:
--
--  • Simple, single‑component spells (e.g. Frostbolt, Frost Nova, Cone
--    of Cold) use the legacy flat fields: `type`, `baseMin`,
--    `baseMax`, `baseCast`, `mana` and `coeff`.  These fields mirror
--    the values found in Classic era tooltips.
--  • Multi‑component spells store their additional pieces inside
--    subtables.  Blizzard is treated as a channeled AoE and has a
--    `channeled` subtable with the total base damage over its full
--    duration.  Ice Barrier and Frost Ward are absorb shields and use
--    an `absorb` subtable with the shield amount and coefficient.  The
--    core will correctly compute and display each component in the
--    tooltip.

local M = {}

-- Frost spells keyed by spell ID.  Rank, mana cost and base damage
-- values are taken from Classic era sources.  Cast times follow the
-- progression shown on the Frostbolt tooltips (lower ranks have
-- shorter cast times).  All coefficients are pre‑computed from the
-- 3.5 second rule with AoE penalties applied where appropriate.
M.spells = {
  -------------------------------------------------------------------
  -- Frostbolt (direct).  Cast time increases with rank and the
  -- coefficient is fixed at 81.43% (3/3.5 * 0.95) for all ranks【971831249770757†L75-L82】.
  --
  -- Source: TwinStar/Turtle WoW classic database pages.  For example,
  -- rank 1 deals 18–21 damage【971831249770757†L75-L82】, rank 2 deals 31–36【762399169715077†L75-L82】,
  -- rank 3 deals 51–58【215824915508979†L75-L82】, rank 4 deals 74–83【525394691199442†L75-L82】,
  -- rank 5 deals 126–139【861723562953165†L80-L82】, rank 6 deals 174–191【499310660155369†L80-L82】,
  -- rank 7 deals 227–248【312801654063571†L80-L82】, rank 8 deals 292–317【410641559272314†L80-L82】,
  -- rank 9 deals 353–384【857537490677841†L80-L82】, rank 10 deals 429–464【729433986873881†L80-L82】,
  -- and rank 11 deals 515–556 damage【165835498145304†L80-L82】.
  [116]   = { id=116,   name="Frostbolt", rank=1,  school="Frost", type="direct",
               baseMin=18,  baseMax=21,  baseCast=1.5, mana=25,  coeff=0.8142857 },
  [205]   = { id=205,   name="Frostbolt", rank=2,  school="Frost", type="direct",
               baseMin=31,  baseMax=36,  baseCast=1.8, mana=35,  coeff=0.8142857 },
  [837]   = { id=837,   name="Frostbolt", rank=3,  school="Frost", type="direct",
               baseMin=51,  baseMax=58,  baseCast=2.2, mana=50,  coeff=0.8142857 },
  [7322]  = { id=7322,  name="Frostbolt", rank=4,  school="Frost", type="direct",
               baseMin=74,  baseMax=83,  baseCast=2.6, mana=65,  coeff=0.8142857 },
  [8406]  = { id=8406,  name="Frostbolt", rank=5,  school="Frost", type="direct",
               baseMin=126, baseMax=139, baseCast=3.0, mana=100, coeff=0.8142857 },
  [8407]  = { id=8407,  name="Frostbolt", rank=6,  school="Frost", type="direct",
               baseMin=174, baseMax=191, baseCast=3.0, mana=130, coeff=0.8142857 },
  [8408]  = { id=8408,  name="Frostbolt", rank=7,  school="Frost", type="direct",
               baseMin=227, baseMax=248, baseCast=3.0, mana=160, coeff=0.8142857 },
  [10179] = { id=10179, name="Frostbolt", rank=8,  school="Frost", type="direct",
               baseMin=292, baseMax=317, baseCast=3.0, mana=195, coeff=0.8142857 },
  [10180] = { id=10180, name="Frostbolt", rank=9,  school="Frost", type="direct",
               baseMin=353, baseMax=384, baseCast=3.0, mana=225, coeff=0.8142857 },
  [10181] = { id=10181, name="Frostbolt", rank=10, school="Frost", type="direct",
               baseMin=429, baseMax=464, baseCast=3.0, mana=260, coeff=0.8142857 },
  [25304] = { id=25304, name="Frostbolt", rank=11, school="Frost", type="direct",
               baseMin=515, baseMax=556, baseCast=3.0, mana=290, coeff=0.8142857 },

  -------------------------------------------------------------------
  -- Frost Nova (instant AoE).  Deals a small burst of damage and
  -- applies a root.  Coefficient uses the 1.5 s AoE rule
  -- (1.5/3.5/3 * 0.95 ≈ 13.57%).  All ranks share the same
  -- coefficient and have zero cast time.
  [122]   = { id=122,   name="Frost Nova", rank=1, school="Frost", type="direct",
               baseMin=19,  baseMax=22,  baseCast=0.0, mana=55,  coeff=0.1357143 }, -- 【390741124988780†L104-L110】
  [865]   = { id=865,   name="Frost Nova", rank=2, school="Frost", type="direct",
               baseMin=33,  baseMax=38,  baseCast=0.0, mana=85,  coeff=0.1357143 }, -- 【961635728855306†L106-L113】
  [6131]  = { id=6131,  name="Frost Nova", rank=3, school="Frost", type="direct",
               baseMin=52,  baseMax=59,  baseCast=0.0, mana=115, coeff=0.1357143 }, -- 【919346625631662†L105-L111】
  [10230] = { id=10230, name="Frost Nova", rank=4, school="Frost", type="direct",
               baseMin=71,  baseMax=80,  baseCast=0.0, mana=145, coeff=0.1357143 }, -- 【910366177469817†L105-L110】

  -------------------------------------------------------------------
  -- Cone of Cold (instant cone).  Each rank hits all enemies in a
  -- 10‑yard cone.  Coefficient identical to Frost Nova.  The spell
  -- is instant and thus uses GCD for cast time when computing DPS.
  [120]   = { id=120,   name="Cone of Cold", rank=1, school="Frost", type="direct",
               baseMin=98,  baseMax=108, baseCast=0.0, mana=210, coeff=0.1357143 }, -- 【821628875768625†L105-L110】
  [8492]  = { id=8492,  name="Cone of Cold", rank=2, school="Frost", type="direct",
               baseMin=146, baseMax=161, baseCast=0.0, mana=290, coeff=0.1357143 }, -- 【414909144775498†L105-L110】
  [10159] = { id=10159, name="Cone of Cold", rank=3, school="Frost", type="direct",
               baseMin=203, baseMax=224, baseCast=0.0, mana=380, coeff=0.1357143 }, -- 【479066798824452†L105-L109】
  [10160] = { id=10160, name="Cone of Cold", rank=4, school="Frost", type="direct",
               baseMin=264, baseMax=291, baseCast=0.0, mana=465, coeff=0.1357143 }, -- 【504815548001455†L106-L110】
  [10161] = { id=10161, name="Cone of Cold", rank=5, school="Frost", type="direct",
               baseMin=335, baseMax=366, baseCast=0.0, mana=555, coeff=0.1357143 }, -- 【449792901465406†L106-L110】

  -------------------------------------------------------------------
  -- Blizzard (channeled AoE).  Each rank channels for 8 seconds,
  -- dealing damage every second (8 ticks).  The total base damage
  -- listed below is the sum of all ticks.  Coefficient uses 33.33%
  -- (3.5/3.5/3) and is applied to the full channel【939327492820651†L109-L111】.
  [10]    = { id=10,    name="Blizzard", rank=1, school="Frost", mana=320,
               channeled = { baseTotal=200, duration=8, coeff=0.3333333 } }, -- 【939327492820651†L109-L111】
  [6141]  = { id=6141,  name="Blizzard", rank=2, school="Frost", mana=520,
               channeled = { baseTotal=352, duration=8, coeff=0.3333333 } }, -- 【424754676951614†L106-L111】
  [8427]  = { id=8427,  name="Blizzard", rank=3, school="Frost", mana=720,
               channeled = { baseTotal=520, duration=8, coeff=0.3333333 } }, -- 【198483895252034†L109-L112】
  [10185] = { id=10185, name="Blizzard", rank=4, school="Frost", mana=935,
               channeled = { baseTotal=720, duration=8, coeff=0.3333333 } }, -- 【592801770470130†L107-L110】
  [10186] = { id=10186, name="Blizzard", rank=5, school="Frost", mana=1160,
               channeled = { baseTotal=936, duration=8, coeff=0.3333333 } }, -- 【75385129794574†L107-L111】
  [10187] = { id=10187, name="Blizzard", rank=6, school="Frost", mana=1400,
               channeled = { baseTotal=1192, duration=8, coeff=0.3333333 } }, -- 【105091891945433†L107-L110】

  -------------------------------------------------------------------
  -- Ice Barrier (absorb shield).  Each rank places a shield that
  -- absorbs a fixed amount of damage.  Shields scale with 10% of
  -- frost spell power.  These entries use an `absorb` subtable
  -- containing minimum and maximum absorb amounts (identical for
  -- shields) and the scaling coefficient.  Duration is 1 minute.
  [11426] = { id=11426, name="Ice Barrier", rank=1, school="Frost", mana=305,
               absorb = { baseMin=438, baseMax=438, coeff=0.10 } }, -- 【7892969246031†L106-L110】
  [13031] = { id=13031, name="Ice Barrier", rank=2, school="Frost", mana=360,
               absorb = { baseMin=549, baseMax=549, coeff=0.10 } }, -- 【510849432967086†L106-L110】
  [13032] = { id=13032, name="Ice Barrier", rank=3, school="Frost", mana=420,
               absorb = { baseMin=678, baseMax=678, coeff=0.10 } }, -- 【153247623289379†L109-L110】
  [13033] = { id=13033, name="Ice Barrier", rank=4, school="Frost", mana=480,
               absorb = { baseMin=818, baseMax=818, coeff=0.10 } }, -- 【225245171060257†L107-L110】

  -------------------------------------------------------------------
  -- Frost Ward (absorb shield).  Provides a shield against frost
  -- damage.  These shields do not scale with spell power (coeff=0).
  [6143]  = { id=6143,  name="Frost Ward", rank=1, school="Frost", mana=85,
               absorb = { baseMin=165, baseMax=165, coeff=0.0 } }, -- 【109513874483077†L105-L110】
  [8461]  = { id=8461,  name="Frost Ward", rank=2, school="Frost", mana=135,
               absorb = { baseMin=290, baseMax=290, coeff=0.0 } }, -- 【930234772395482†L105-L110】
  [8462]  = { id=8462,  name="Frost Ward", rank=3, school="Frost", mana=195,
               absorb = { baseMin=470, baseMax=470, coeff=0.0 } }, -- 【108757591983721†L105-L110】
  [10177] = { id=10177, name="Frost Ward", rank=4, school="Frost", mana=255,
               absorb = { baseMin=675, baseMax=675, coeff=0.0 } }, -- 【925017231063285†L105-L110】
}

-- Register spells with the global addon table when loaded in game.
local ADDON = _G["SpellMath"]
if ADDON and ADDON.Data and ADDON.Data.Spells then
  for id, spell in pairs(M.spells) do
    ADDON.Data.Spells[id] = spell
  end
end

return M