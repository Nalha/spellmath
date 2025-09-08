-- mage_spells_arcane.lua
--
-- Spell data for Mage arcane spells in WoW Classic (patch 1.12.1).
--
-- This module defines the base values and coefficients for arcane damage and
-- absorb abilities.  Only abilities that produce deterministically
-- calculable damage or shields are included; most utility spells such as
-- Polymorph, Teleport, Conjure Food/Water, Arcane Intellect and portals
-- have no direct damage component and are deliberately omitted.  For
-- reference, a full list of arcane spell IDs is provided in the project
-- documentation.  To fill in the base damage and mana values, consult
-- classic era sources (e.g. Wowhead or other database mirrors) for each
-- rank and populate the `baseMin`, `baseMax`, `mana` and `absorb.amount`
-- fields accordingly.

local M = {}

-- Arcane spells keyed by spell ID.  Each entry specifies the spell name,
-- rank, school, type and the coefficient used by the SpellMath engine.  For
-- channeled spells the `channeled` subtable stores the total base damage
-- over the full channel and its duration; for instant AoE spells we use
-- `baseCast=0.0` to indicate that they fire off the global cooldown.  The
-- coefficients here follow the 3.5 s rule with AoE penalties applied where
-- appropriate:
--   * Arcane Explosion: (1.5 / 3.5) / 3  ~= 14.29%
--   * Arcane Missiles:  (5.0 / 15.0)    = 33.33% per channel (100% total)
--   * Mana Shield:      10% of the absorbed amount (same as Ice Barrier)

M.spells = {
  ---------------------------------------------------------------------
  -- Arcane Explosion (instant AoE).  This spell has no cast time and
  -- deals the same type of burst damage across all ranks.  The
  -- coefficient is based on the 1.5 s GCD divided by 3 (AoE penalty).
  [1449]  = { id=1449,  name="Arcane Explosion", rank=1, school="Arcane", type="direct",
               baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.1428571 },
  [8437]  = { id=8437,  name="Arcane Explosion", rank=2, school="Arcane", type="direct",
               baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.1428571 },
  [8438]  = { id=8438,  name="Arcane Explosion", rank=3, school="Arcane", type="direct",
               baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.1428571 },
  [10201] = { id=10201, name="Arcane Explosion", rank=4, school="Arcane", type="direct",
               baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.1428571 },
  [10202] = { id=10202, name="Arcane Explosion", rank=5, school="Arcane", type="direct",
               baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.1428571 },

  ---------------------------------------------------------------------
  -- Arcane Missiles (channeled).  Each rank channels for approximately
  -- 5 seconds and fires five missiles.  The coefficient shown below
  -- reflects the full channel (100% of spell power distributed across
  -- the missiles).  Set the `baseTotal` field to the total damage over
  -- the channel and the `duration` to the channel time.  Cast time is
  -- effectively equal to the channel duration.
  [5143]  = { id=5143,  name="Arcane Missiles", rank=1, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },
  [5144]  = { id=5144,  name="Arcane Missiles", rank=2, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },
  [5145]  = { id=5145,  name="Arcane Missiles", rank=3, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },
  [8416]  = { id=8416,  name="Arcane Missiles", rank=4, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },
  [8417]  = { id=8417,  name="Arcane Missiles", rank=5, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },
  [10211] = { id=10211, name="Arcane Missiles", rank=6, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },
  [10212] = { id=10212, name="Arcane Missiles", rank=7, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },
  [25345] = { id=25345, name="Arcane Missiles", rank=8, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },

  ---------------------------------------------------------------------
  -- Mana Shield (absorb).  This spell converts mana into a shield
  -- absorbing incoming damage.  The coefficient is set to 10% (like
  -- Ice Barrier).  Fill in the `amount` with the shield value for each
  -- rank and set the mana cost accordingly.
  [1463]  = { id=1463,  name="Mana Shield", rank=1, school="Arcane", mana=0,
               absorb = { amount=0, coeff=0.10 } },
  [8494]  = { id=8494,  name="Mana Shield", rank=2, school="Arcane", mana=0,
               absorb = { amount=0, coeff=0.10 } },
  [8495]  = { id=8495,  name="Mana Shield", rank=3, school="Arcane", mana=0,
               absorb = { amount=0, coeff=0.10 } },
  [10191] = { id=10191, name="Mana Shield", rank=4, school="Arcane", mana=0,
               absorb = { amount=0, coeff=0.10 } },
  [10192] = { id=10192, name="Mana Shield", rank=5, school="Arcane", mana=0,
               absorb = { amount=0, coeff=0.10 } },
  [10193] = { id=10193, name="Mana Shield", rank=6, school="Arcane", mana=0,
               absorb = { amount=0, coeff=0.10 } },

  ---------------------------------------------------------------------
  -- Utility and buff spells.  Many arcane spells do not cause damage
  -- and instead provide teleports, portals, buffs or crowd control.
  -- These entries use zero base values so that they are registered
  -- with the addon but do not contribute to damage calculations.
  -- If you wish to add actual mana costs or durations for these
  -- spells, replace the `mana` and `baseCast` fields as appropriate.

  -- Teleports
  [3561] = { id=3561, name="Teleport: Stormwind", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [3562] = { id=3562, name="Teleport: Ironforge", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [3563] = { id=3563, name="Teleport: Undercity", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [3565] = { id=3565, name="Teleport: Darnassus", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [3566] = { id=3566, name="Teleport: Thunder Bluff", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [3567] = { id=3567, name="Teleport: Orgrimmar", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },

  -- Portals
  [10059] = { id=10059, name="Portal: Stormwind", school="Arcane", type="utility",
               baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [11416] = { id=11416, name="Portal: Ironforge", school="Arcane", type="utility",
               baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [11417] = { id=11417, name="Portal: Orgrimmar", school="Arcane", type="utility",
               baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [11418] = { id=11418, name="Portal: Undercity", school="Arcane", type="utility",
               baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [11419] = { id=11419, name="Portal: Darnassus", school="Arcane", type="utility",
               baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [11420] = { id=11420, name="Portal: Thunder Bluff", school="Arcane", type="utility",
               baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [22782] = { id=22782, name="Portal: Stonard", school="Arcane", type="utility",
               baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },
  [22783] = { id=22783, name="Portal: Theramore", school="Arcane", type="utility",
               baseMin=0, baseMax=0, baseCast=10.0, mana=0, coeff=0.0 },

  -- Buffs
  [1459] = { id=1459, name="Arcane Intellect", rank=1, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [1460] = { id=1460, name="Arcane Intellect", rank=2, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [1461] = { id=1461, name="Arcane Intellect", rank=3, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10156] = { id=10156, name="Arcane Intellect", rank=4, school="Arcane", type="buff",
               baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10157] = { id=10157, name="Arcane Intellect", rank=5, school="Arcane", type="buff",
               baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10140] = { id=10140, name="Arcane Intellect", rank=6, school="Arcane", type="buff",
               baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [23028] = { id=23028, name="Arcane Brilliance", rank=1, school="Arcane", type="buff",
               baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10194] = { id=10194, name="Arcane Brilliance", rank=2, school="Arcane", type="buff",
               baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },

  -- Amplify Magic
  [1008]  = { id=1008,  name="Amplify Magic", rank=1, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [8455]  = { id=8455,  name="Amplify Magic", rank=2, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [10169] = { id=10169, name="Amplify Magic", rank=3, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [10170] = { id=10170, name="Amplify Magic", rank=4, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },

  -- Dampen Magic
  [604]   = { id=604,   name="Dampen Magic", rank=1, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [8450]  = { id=8450,  name="Dampen Magic", rank=2, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [8451]  = { id=8451,  name="Dampen Magic", rank=3, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [10173] = { id=10173, name="Dampen Magic", rank=4, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [10174] = { id=10174, name="Dampen Magic", rank=5, school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },

  -- Conjure Water/Food (utility)
  [5504]  = { id=5504,  name="Conjure Water", rank=1, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [5505]  = { id=5505,  name="Conjure Water", rank=2, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [5506]  = { id=5506,  name="Conjure Water", rank=3, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [6127]  = { id=6127,  name="Conjure Water", rank=4, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10138] = { id=10138, name="Conjure Water", rank=5, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10139] = { id=10139, name="Conjure Water", rank=6, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10140] = { id=10140, name="Conjure Water", rank=7, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },

  -- Conjure Food (utility)
  [587]   = { id=587,   name="Conjure Food", rank=1, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [597]   = { id=597,   name="Conjure Food", rank=2, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [990]   = { id=990,   name="Conjure Food", rank=3, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [6129]  = { id=6129,  name="Conjure Food", rank=4, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10144] = { id=10144, name="Conjure Food", rank=5, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10145] = { id=10145, name="Conjure Food", rank=6, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },

  -- Conjure Mana Gem (utility)
  [759]   = { id=759,   name="Conjure Mana Gem", rank=1, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [3552]  = { id=3552,  name="Conjure Mana Gem", rank=2, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10053] = { id=10053, name="Conjure Mana Gem", rank=3, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [10054] = { id=10054, name="Conjure Mana Gem", rank=4, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },
  [22782] = { id=22782, name="Conjure Mana Gem", rank=5, school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=3.0, mana=0, coeff=0.0 },

  -- Crowd control (Polymorph variants)
  [118]   = { id=118,   name="Polymorph", rank=1, school="Arcane", type="crowd-control",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [12824] = { id=12824, name="Polymorph: Pig", school="Arcane", type="crowd-control",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [12825] = { id=12825, name="Polymorph: Turtle", school="Arcane", type="crowd-control",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [12826] = { id=12826, name="Polymorph", rank=2, school="Arcane", type="crowd-control",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [28270] = { id=28270, name="Polymorph: Cow", school="Arcane", type="crowd-control",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [28271] = { id=28271, name="Polymorph: Turtle", school="Arcane", type="crowd-control",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },
  [28272] = { id=28272, name="Polymorph: Pig", school="Arcane", type="crowd-control",
              baseMin=0, baseMax=0, baseCast=1.5, mana=0, coeff=0.0 },

  -- Other utility spells
  [1953]  = { id=1953,  name="Blink", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.0 },
  [2139]  = { id=2139,  name="Counterspell", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.0 },
  [475]   = { id=475,   name="Remove Curse", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.0 },
  [130]   = { id=130,   name="Slow Fall", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.0 },
  [6117]  = { id=6117,  name="Mage Armor", school="Arcane", type="buff",
              baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.0 },
  [12051] = { id=12051, name="Evocation", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=8.0, mana=0, coeff=0.0 },

  -- Additional damage ranks and unknown spells
  -- Arcane Explosion rank 6 (placeholder values)
  [12600] = { id=12600, name="Arcane Explosion", rank=6, school="Arcane", type="direct",
               baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.1428571 },

  -- Arcane Missiles higher rank (placeholder values).  Follows the same
  -- 5 second channel as earlier ranks.
  [28612] = { id=28612, name="Arcane Missiles", rank=9, school="Arcane", mana=0,
               channeled = { baseTotal=0, duration=5.0, coeff=1.0 } },

  -- Unknown or unimplemented spells supplied by the user.  These
  -- identifiers correspond to arcane spells that have no direct
  -- damage component.  They are registered here with zero values so
  -- that the addon recognises them without affecting DPS output.
  [2855]  = { id=2855,  name="Unknown Arcane Spell", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.0 },
  [8439]  = { id=8439,  name="Unknown Arcane Spell", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.0 },
  [12604] = { id=12604, name="Unknown Arcane Spell", school="Arcane", type="utility",
              baseMin=0, baseMax=0, baseCast=0.0, mana=0, coeff=0.0 }
}

-- Register spells with the global addon table when loaded in game.  This
-- mirrors the behaviour of the frost and fire modules so that arcane
-- spells become available through `SpellMath.Data.Spells` without
-- requiring explicit loading order.
local ADDON = _G["SpellMath"]
if ADDON and ADDON.Data and ADDON.Data.Spells then
  for id, spell in pairs(M.spells) do
    ADDON.Data.Spells[id] = spell
  end
end

return M
