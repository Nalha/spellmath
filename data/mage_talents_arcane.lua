-- Passive arcane talents for the Mage class.  Only always‑on, deterministic
-- effects are represented here.  Active abilities, procs and talents that
-- depend on random chance or target state are included as inert stubs.

local T = {}

T.list = {
  -- Deterministic arcane talents
  {
    name = "Arcane Instability",
    when = function(ctx) return ctx.school == "Arcane" end,
    apply = function(r, ctx)
      -- Increases damage by 1% per rank.  Ignores the crit chance portion.
      ctx.dmgMult = ctx.dmgMult * (1 + 0.01 * r)
    end,
  },
  {
    name = "Arcane Focus",
    when = function(ctx) return ctx.school == "Arcane" end,
    apply = function(r, ctx)
    end,
  },
  {
    name = "Arcane Meditation",
    when = function(ctx) return ctx.school == "Arcane" end,
    apply = function(r, ctx)
    end,
  },
  {
    name = "Improved Arcane Explosion",
    when = function(ctx) return ctx.spellName == "Arcane Explosion" end,
    apply = function(r, ctx)
    end,
  },

  -- Inert stubs for non‑deterministic or irrelevant arcane talents
  { name = "Arcane Concentration",    when = function() return false end, apply = function() end },
  { name = "Arcane Mind",             when = function() return false end, apply = function() end },
  { name = "Arcane Power",            when = function() return false end, apply = function() end },
  { name = "Arcane Resilience",       when = function() return false end, apply = function() end },
  { name = "Arcane Subtlety",         when = function() return false end, apply = function() end },
  { name = "Improved Arcane Missiles",when = function() return false end, apply = function() end },
  { name = "Improved Counterspell",   when = function() return false end, apply = function() end },
  { name = "Improved Mana Shield",    when = function() return false end, apply = function() end },
  { name = "Magic Absorption",        when = function() return false end, apply = function() end },
  { name = "Magic Attunement",        when = function() return false end, apply = function() end },
  { name = "Presence of Mind",         when = function() return false end, apply = function() end },
  { name = "Wand Specialization",     when = function() return false end, apply = function() end },
}

local ADDON = _G["SpellMath"]
if ADDON and ADDON.Data and ADDON.Data.Talents then
  for _, d in ipairs(T.list) do
    table.insert(ADDON.Data.Talents, d)
  end
end

return T
