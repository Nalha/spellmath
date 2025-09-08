-- bootstrap.lua
local ADDON_NAME = ...
local ADDON = _G[ADDON_NAME or "SpellMath"] or {}
_G[ADDON_NAME or "SpellMath"] = ADDON

ADDON.Data = ADDON.Data or { Spells = {}, Talents = {} }
ADDON.GCD = ADDON.GCD or 1.5
ADDON.Data.SchoolIndex = {
  Holy=2, Fire=3, Nature=4, Frost=5, Shadow=6, Arcane=7
}
ADDON.Data.BaseSpellMiss = {
  [0] = 0.04,  -- vs same level
  [1] = 0.05,  -- +1 level
  [2] = 0.06,  -- +2 level
  [3] = 0.17,  -- +3 (skull/boss)
}
ADDON.Data.SpellHitHardCap = 0.99 -- keep at least 1% innate miss

-- BuildReverse is invoked by core/SpellMath.lua after all data files load.
function ADDON:BuildReverse()
  self.Rev = {}
  for id, s in pairs(self.Data.Spells) do
    if s and s.name and s.rank then
      local t = self.Rev[s.name] or {}
      self.Rev[s.name] = t
      t[s.rank] = id
    end
  end
end
