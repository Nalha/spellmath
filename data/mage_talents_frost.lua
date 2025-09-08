local T = {}

T.list = {
  { name = "Piercing Ice",
    when = function(ctx) return ctx.school == "Frost" end,
    apply = function(r, ctx) ctx.dmgMult = ctx.dmgMult * (1 + 0.02 * r) end },
  { name = "Frost Channeling",
    when = function(ctx) return ctx.school == "Frost" end,
    apply = function(r, ctx) ctx.costMult = ctx.costMult * (1 - 0.05 * r) end },
  { name = "Improved Frostbolt",
    when = function(ctx) return ctx.spellName == "Frostbolt" end,
    apply = function(r, ctx) ctx.castDelta = ctx.castDelta - 0.1 * r end },
  { name = "Ice Shards",
    when = function(ctx) return ctx.school == "Frost" end,
    apply = function(r, ctx)
      ctx.critBonusDelta = ctx.critBonusDelta + (0.2 * r)
    end },
  { name = "Elemental Precision",
    when = function(ctx) return ctx.school == "Frost" or ctx.school == "Fire" end,
    apply = function(r, ctx)
      ctx.hitBonus = ctx.hitBonus + (0.02 * r)
    end },
  { name = "Improved Cone of Cold",
    when = function(ctx) return ctx.spellName == "Cone of Cold" end,
    apply = function(r, ctx) ctx.dmgMult = ctx.dmgMult * (1 + 0.05 * r) end },

  { name = "Ice Barrier",        when = function() return false end, apply = function() end },
  { name = "Winter's Chill",     when = function() return false end, apply = function() end },
  { name = "Ice Block",          when = function() return false end, apply = function() end },
  { name = "Cold Snap",          when = function() return false end, apply = function() end },
  { name = "Frost Warding",      when = function() return false end, apply = function() end },
  { name = "Improved Frost Nova",when = function() return false end, apply = function() end },
  { name = "Shatter",            when = function() return false end, apply = function() end },
  { name = "Frostbite",          when = function() return false end, apply = function() end },
  { name = "Permafrost",         when = function() return false end, apply = function() end },
  { name = "Improved Blizzard",  when = function() return false end, apply = function() end },
  { name = "Arctic Reach",       when = function() return false end, apply = function() end },
}

local ADDON = _G["SpellMath"]
if ADDON and ADDON.Data and ADDON.Data.Talents then
  for _, d in ipairs(T.list) do
    table.insert(ADDON.Data.Talents, d)
  end
end

return T
