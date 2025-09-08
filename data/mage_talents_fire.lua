-- mage_fire.lua
--
-- Passive fire talents for the Mage class.  Only always‑on, deterministic
-- effects are represented here.  Active abilities, procs and talents that
-- depend on target state are included as inert stubs.  If a talent
-- does nothing here, it’s because its effect can’t be folded into
-- deterministic spell math without simulation.

local T = {}

T.list = {
  -- Deterministic fire talents
  {
    name = "Fire Power",
    when = function(ctx) return ctx.school == "Fire" end,
    apply = function(r, ctx) ctx.dmgMult = ctx.dmgMult * (1 + 0.02 * r) end,
  },
  {
    name = "Improved Fireball",
    when = function(ctx) return ctx.spellName == "Fireball" end,
    apply = function(r, ctx) ctx.castDelta = ctx.castDelta - 0.1 * r end,
  },
  {
    name = "Master of Elements",
    when = function(ctx) return ctx.school == "Fire" end,
    apply = function(r, ctx) ctx.costMult = ctx.costMult * (1 - 0.1 * r) end,
  },
  {
    name = "Critical Mass",
    when = function(ctx) return ctx.school == "Fire" end,
    apply = function(r, ctx) ctx.dmgMult = ctx.dmgMult * (1 + 0.02 * r) end,
  },
  {
    name = "Improved Flamestrike",
    when = function(ctx) return ctx.spellName == "Flamestrike" end,
    apply = function(r, ctx) ctx.dmgMult = ctx.dmgMult * (1 + 0.15 * r) end,
  },

  -- Inert stubs for non‑deterministic fire talents
  { name = "Pyroblast",          when = function() return false end, apply = function() end },
  { name = "Ignite",             when = function() return false end, apply = function() end },
  { name = "Combustion",         when = function() return false end, apply = function() end },
  { name = "Improved Scorch",    when = function() return false end, apply = function() end },
  { name = "Flame Throwing",     when = function() return false end, apply = function() end },
  { name = "Impact",             when = function() return false end, apply = function() end },
  { name = "Incinerate",         when = function() return false end, apply = function() end },
  { name = "Improved Fire Ward", when = function() return false end, apply = function() end },
  { name = "Improved Fire Blast",when = function() return false end, apply = function() end },
  { name = "Burning Soul",       when = function() return false end, apply = function() end },
  { name = "Blast Wave",         when = function() return false end, apply = function() end },
}

local ADDON = _G["SpellMath"]
if ADDON and ADDON.Data and ADDON.Data.Talents then
  for _, d in ipairs(T.list) do
    table.insert(ADDON.Data.Talents, d)
  end
end

return T
