-- mage_spells_fire.lua
--
-- Spell data for Mage fire spells in WoW Classic (patch 1.12.1).
-- This file illustrates the new bundled format where multi‑component
-- spells (like Pyroblast and Flamestrike) contain separate `direct`
-- and `dot` subtables.  Single‑component spells continue to use
-- the legacy flat fields (type/baseMin/baseMax/etc.) for
-- backward compatibility.  Mana cost lives on the top level entry.

local M = {}

-- Fire Blast (instant, 8 s cooldown).  Uses GCD as cast time for
-- coefficient scaling (1.5 s/3.5 s = 0.428571).
-- Crit multiplier is handled by the core; `critMult` is unused.
M.spells = {
  [2136] = { id=2136, name="Fire Blast", rank=1, school="Fire", type="direct",
             baseMin=24,  baseMax=32,  baseCast=0.0, mana=40,  coeff=0.428571 },
  [2137] = { id=2137, name="Fire Blast", rank=2, school="Fire", type="direct",
             baseMin=57,  baseMax=71,  baseCast=0.0, mana=75,  coeff=0.428571 },
  [2138] = { id=2138, name="Fire Blast", rank=3, school="Fire", type="direct",
             baseMin=103, baseMax=127, baseCast=0.0, mana=115, coeff=0.428571 },
  [8412] = { id=8412, name="Fire Blast", rank=4, school="Fire", type="direct",
             baseMin=168, baseMax=202, baseCast=0.0, mana=165, coeff=0.428571 },
  [8413] = { id=8413, name="Fire Blast", rank=5, school="Fire", type="direct",
             baseMin=242, baseMax=290, baseCast=0.0, mana=220, coeff=0.428571 },
  [10197] = { id=10197, name="Fire Blast", rank=6, school="Fire", type="direct",
              baseMin=332, baseMax=394, baseCast=0.0, mana=280, coeff=0.428571 },
  [10199] = { id=10199, name="Fire Blast", rank=7, school="Fire", type="direct",
              baseMin=431, baseMax=509, baseCast=0.0, mana=340, coeff=0.428571 },

  -- Fire Ward (damage shield).  Does not benefit from spell power; no
  -- critical strikes.  Treated as an absorb component in the core.
  [543]   = { id=543,   name="Fire Ward", rank=1, school="Fire", type="absorb",
              baseMin=165, baseMax=165, baseCast=0.0, mana=85,  coeff=0.0 },
  [8457]  = { id=8457,  name="Fire Ward", rank=2, school="Fire", type="absorb",
              baseMin=290, baseMax=290, baseCast=0.0, mana=135, coeff=0.0 },
  [8458]  = { id=8458,  name="Fire Ward", rank=3, school="Fire", type="absorb",
              baseMin=470, baseMax=470, baseCast=0.0, mana=195, coeff=0.0 },
  [10223] = { id=10223, name="Fire Ward", rank=4, school="Fire", type="absorb",
              baseMin=675, baseMax=675, baseCast=0.0, mana=255, coeff=0.0 },
  [10225] = { id=10225, name="Fire Ward", rank=5, school="Fire", type="absorb",
              baseMin=920, baseMax=920, baseCast=0.0, mana=320, coeff=0.0 },

  -- Fireball.  Lower ranks have reduced cast times and thus lower
  -- coefficients.  Coefficient values follow the 3.5 s rule.
  [133]   = { id=133,   name="Fireball", rank=1,  school="Fire", type="direct",
              baseMin=14,  baseMax=22,  baseCast=1.5, mana=30,  coeff=0.428571 },
  [143]   = { id=143,   name="Fireball", rank=2,  school="Fire", type="direct",
              baseMin=31,  baseMax=45,  baseCast=2.0, mana=45,  coeff=0.571429 },
  [145]   = { id=145,   name="Fireball", rank=3,  school="Fire", type="direct",
              baseMin=53,  baseMax=73,  baseCast=2.5, mana=65,  coeff=0.714286 },
  [3140]  = { id=3140,  name="Fireball", rank=4,  school="Fire", type="direct",
              baseMin=84,  baseMax=116, baseCast=3.0, mana=95,  coeff=0.857143 },
  [8400]  = { id=8400,  name="Fireball", rank=5,  school="Fire", type="direct",
              baseMin=139, baseMax=187, baseCast=3.5, mana=140, coeff=1.0      },
  [8401]  = { id=8401,  name="Fireball", rank=6,  school="Fire", type="direct",
              baseMin=199, baseMax=265, baseCast=3.5, mana=185, coeff=1.0      },
  [8402]  = { id=8402,  name="Fireball", rank=7,  school="Fire", type="direct",
              baseMin=255, baseMax=335, baseCast=3.5, mana=220, coeff=1.0      },
  [10148] = { id=10148, name="Fireball", rank=8,  school="Fire", type="direct",
              baseMin=318, baseMax=414, baseCast=3.5, mana=260, coeff=1.0      },
  [10149] = { id=10149, name="Fireball", rank=9,  school="Fire", type="direct",
              baseMin=392, baseMax=506, baseCast=3.5, mana=305, coeff=1.0      },
  [10150] = { id=10150, name="Fireball", rank=10, school="Fire", type="direct",
              baseMin=475, baseMax=609, baseCast=3.5, mana=350, coeff=1.0      },
  [10151] = { id=10151, name="Fireball", rank=11, school="Fire", type="direct",
              baseMin=561, baseMax=715, baseCast=3.5, mana=395, coeff=1.0      },
  [25306] = { id=25306, name="Fireball", rank=12, school="Fire", type="direct",
              baseMin=596, baseMax=760, baseCast=3.5, mana=410, coeff=1.0      },

  -- Flamestrike (area of effect).  Each rank has a direct portion and
  -- a DoT portion lasting 8 seconds (4 ticks every 2 s).  Coefficients
  -- derived from TheoryCraft: direct ≈17.61%, DoT ≈6.81%.
  [2120]  = { id=2120,  name="Flamestrike", rank=1, school="Fire", mana=195,
              direct = { baseMin=52,  baseMax=68,  baseCast=3.0, coeff=0.1761 },
              dot    = { baseTotal=48, duration=8, coeff=0.0681 } },
  [2121]  = { id=2121,  name="Flamestrike", rank=2, school="Fire", mana=330,
              direct = { baseMin=96,  baseMax=122, baseCast=3.0, coeff=0.1761 },
              dot    = { baseTotal=88, duration=8, coeff=0.0681 } },
  [8422]  = { id=8422,  name="Flamestrike", rank=3, school="Fire", mana=490,
              direct = { baseMin=154, baseMax=192, baseCast=3.0, coeff=0.1761 },
              dot    = { baseTotal=140, duration=8, coeff=0.0681 } },
  [8423]  = { id=8423,  name="Flamestrike", rank=4, school="Fire", mana=650,
              direct = { baseMin=220, baseMax=272, baseCast=3.0, coeff=0.1761 },
              dot    = { baseTotal=196, duration=8, coeff=0.0681 } },
  [10215] = { id=10215, name="Flamestrike", rank=5, school="Fire", mana=815,
              direct = { baseMin=291, baseMax=359, baseCast=3.0, coeff=0.1761 },
              dot    = { baseTotal=264, duration=8, coeff=0.0681 } },
  [10216] = { id=10216, name="Flamestrike", rank=6, school="Fire", mana=990,
              direct = { baseMin=375, baseMax=459, baseCast=3.0, coeff=0.1761 },
              dot    = { baseTotal=340, duration=8, coeff=0.0681 } },

  -- Scorch (quick cast).  Coefficient uses GCD (1.5 s/3.5).
  [2948]  = { id=2948,  name="Scorch", rank=1, school="Fire", type="direct",
              baseMin=53,  baseMax=65,  baseCast=1.5, mana=50,  coeff=0.428571 },
  [8444]  = { id=8444,  name="Scorch", rank=2, school="Fire", type="direct",
              baseMin=77,  baseMax=93,  baseCast=1.5, mana=65,  coeff=0.428571 },
  [8445]  = { id=8445,  name="Scorch", rank=3, school="Fire", type="direct",
              baseMin=100, baseMax=120, baseCast=1.5, mana=80,  coeff=0.428571 },
  [8446]  = { id=8446,  name="Scorch", rank=4, school="Fire", type="direct",
              baseMin=133, baseMax=159, baseCast=1.5, mana=100, coeff=0.428571 },
  [10205] = { id=10205, name="Scorch", rank=5, school="Fire", type="direct",
              baseMin=162, baseMax=192, baseCast=1.5, mana=115, coeff=0.428571 },
  [10206] = { id=10206, name="Scorch", rank=6, school="Fire", type="direct",
              baseMin=200, baseMax=239, baseCast=1.5, mana=135, coeff=0.428571 },
  [10207] = { id=10207, name="Scorch", rank=7, school="Fire", type="direct",
              baseMin=233, baseMax=275, baseCast=1.5, mana=150, coeff=0.428571 },

  -- Pyroblast (6 s cast, 12 s DoT).  Each rank has a direct hit and a 12 s
  -- DoT that ticks every 3 seconds (4 ticks).  DoT coefficient is 70%.
  [11366] = { id=11366, name="Pyroblast", rank=1, school="Fire", mana=125,
              direct = { baseMin=141, baseMax=188, baseCast=6.0, coeff=1.0 },
              dot    = { baseTotal=56,  duration=12, coeff=0.70 } }, -- 14 * 4
  [12505] = { id=12505, name="Pyroblast", rank=2, school="Fire", mana=150,
              direct = { baseMin=180, baseMax=237, baseCast=6.0, coeff=1.0 },
              dot    = { baseTotal=72,  duration=12, coeff=0.70 } }, -- 18 * 4
  [12522] = { id=12522, name="Pyroblast", rank=3, school="Fire", mana=195,
              direct = { baseMin=255, baseMax=328, baseCast=6.0, coeff=1.0 },
              dot    = { baseTotal=96,  duration=12, coeff=0.70 } }, -- 24 * 4
  [12523] = { id=12523, name="Pyroblast", rank=4, school="Fire", mana=240,
              direct = { baseMin=329, baseMax=420, baseCast=6.0, coeff=1.0 },
              dot    = { baseTotal=124, duration=12, coeff=0.70 } }, -- 31 * 4
  [12524] = { id=12524, name="Pyroblast", rank=5, school="Fire", mana=285,
              direct = { baseMin=407, baseMax=515, baseCast=6.0, coeff=1.0 },
              dot    = { baseTotal=156, duration=12, coeff=0.70 } }, -- 39 * 4
  [12525] = { id=12525, name="Pyroblast", rank=6, school="Fire", mana=335,
              direct = { baseMin=503, baseMax=631, baseCast=6.0, coeff=1.0 },
              dot    = { baseTotal=188, duration=12, coeff=0.70 } }, -- 47 * 4
  [12526] = { id=12526, name="Pyroblast", rank=7, school="Fire", mana=385,
              direct = { baseMin=600, baseMax=751, baseCast=6.0, coeff=1.0 },
              dot    = { baseTotal=228, duration=12, coeff=0.70 } }, -- 57 * 4
  [18809] = { id=18809, name="Pyroblast", rank=8, school="Fire", mana=440,
              direct = { baseMin=716, baseMax=891, baseCast=6.0, coeff=1.0 },
              dot    = { baseTotal=268, duration=12, coeff=0.70 } }, -- 67 * 4
}

-- Register spells with the global addon table when loaded in game.  This
-- is executed at file load time by the WoW client.  Outside of WoW it
-- simply populates ADDON.Data.Spells.
local ADDON = _G["SpellMath"]
if ADDON and ADDON.Data and ADDON.Data.Spells then
  for id, spell in pairs(M.spells) do
    ADDON.Data.Spells[id] = spell
  end
end

return M