-- SpellMath core module
--
-- Implements the deterministic spell math engine and tooltip hook.  This
-- module depends on the data assembled by `bootstrap.lua`.  It exposes
-- a single method, `Compute(spellID, mode)`, which computes weighted
-- average hit, DPS and other values for a given spell rank.  All spell
-- definitions and talents live in separate modules and are merged
-- through the bootstrap.

local ADDON_NAME = ...

-- Require the bootstrap first so that ADDON.Data and constants are
-- available.  The bootstrap populates the global table with spells,
-- talents, reverse lookup and constants.
local ADDON = _G["SpellMath"]
if ADDON and ADDON.BuildReverse then ADDON:BuildReverse() end

-- Expose the addon on the global table under the provided name (or
-- fallback).  This allows `/run SpellMath:Compute(...)` to work in game.
_G[ADDON_NAME or "SpellMath"] = ADDON

-- Local references to improve lookup speed and clarify intention.
local GCD           = ADDON.GCD
local SpellDB       = ADDON.Data.Spells
local Talents       = ADDON.Data.Talents
local SCHOOL_INDEX  = ADDON.Data.SchoolIndex
local BaseMiss      = ADDON.Data.BaseSpellMiss
local HIT_CAP       = ADDON.Data.SpellHitHardCap or 0.99

-- ============================
-- Talent cache helpers
-- The talent cache stores ranks keyed by a signature of points spent
-- per tab.  Recomputing all talent ranks on every spell query is slow;
-- caching avoids redundant API calls as long as no talent‑changing
-- events have fired.
-- ============================
local TalentCache = { sig = nil, ranks = nil }

local function readAllTalentRanks()
  local tabs = (GetNumTalentTabs and GetNumTalentTabs()) or 0
  local sigParts = {}
  for t = 1, tabs do
    local tabName, _, spent = GetTalentTabInfo(t)
    sigParts[#sigParts+1] = (tabName or "?")..":"..(spent or 0)
  end
  local sig = table.concat(sigParts, "|")
  if TalentCache.sig == sig and TalentCache.ranks then return TalentCache.ranks end
  local map = {}
  for t = 1, tabs do
    local n = (GetNumTalents and GetNumTalents(t)) or 0
    for i = 1, n do
      local name, _, _, _, cur, max = GetTalentInfo(t, i)
      if name then map[name] = { r = cur or 0, max = max or 0 } end
    end
  end
  TalentCache.sig, TalentCache.ranks = sig, map
  return map
end

-- ============================
-- Deterministic modifiers
-- Applies passive talents to the computation context.  Talents can
-- adjust damage multiplier, mana cost multiplier, cast time offset and
-- critical damage bonus.  The result is packaged into a table and
-- returned to the caller.
-- ============================
local function getDeterministicModifiers(spellName, school)
  local ranks = readAllTalentRanks()
  local ctx = {
    spellName      = spellName,
    school         = school,
    dmgMult        = 1.0,
    costMult       = 1.0,
    castDelta      = 0.0,
    critBonusDelta = 0.0,
    hitBonus       = 0.0,
  }
  for _, t in ipairs(Talents) do
    local info = ranks[t.name]
    if info and info.r > 0 and t.when(ctx) then
      -- Pass the current rank and the maximum possible rank to the apply
      -- function so talents like Ice Shards can scale off the maximum.
      t.apply(info.r, ctx, info.max)
    end
  end
  return {
    dmgMult  = ctx.dmgMult,
    costMult = ctx.costMult,
    castDelta= ctx.castDelta,
    -- The baseline crit multiplier is 1.5x.  We add any bonus delta
    -- (e.g. from Ice Shards) to the baseline 0.5 (50% bonus) before adding
    -- 1.0 (the base hit).
    critMult = 1.0 + (0.5 + ctx.critBonusDelta),
    hitBonus = ctx.hitBonus,
  }
end

-- ============================
-- Player stat readers
-- Pull spell power, crit chance and haste from the game API per school.
-- Values are converted to fractions where appropriate.  Missing API
-- functions return zero.
-- ============================
local function readPlayerSpellStats(school)
  local idx = SCHOOL_INDEX[school]
  local sp = (idx and GetSpellBonusDamage and GetSpellBonusDamage(idx)) or 0
  local critPct = (idx and GetSpellCritChance and GetSpellCritChance(idx)) or 0
  local hastePct = (UnitSpellHaste and UnitSpellHaste("player")) or 0
  return sp, math.max(0, critPct / 100), math.max(0, hastePct / 100)
end

-- ============================
-- Core math functions
-- These functions implement the deterministic hit and DPS calculations
-- for direct, dot and channeled spells.  The formulas mirror the
-- original monolithic implementation.  See SpellMath.lua for details.
-- ============================
local function computeDirect(avgBase, coeff, sp, dmgMult, critChance, critMult, castTime, haste, hitChance)
  local nonCrit = (avgBase + sp * coeff) * dmgMult
  local crit    = nonCrit * critMult
  local wAvg    = nonCrit * (1.0 - critChance) + crit * critChance
  local effTime = (castTime > 0 and (castTime / (1.0 + haste))) or GCD
  local dps     = (wAvg / effTime) * hitChance
  return wAvg, dps, effTime, nonCrit, crit
end

local function computeDotOrChannel(totalBase, coeff, sp, dmgMult, duration, mode, hitChance)
  local total = (totalBase + sp * coeff) * dmgMult
  local time  = (mode == "application") and GCD or duration
  local dps   = (total / time) * hitChance
  return total, dps, time
end

-- ============================
-- Cache structure
-- The cache key is built from spell ID, player stats, modifiers and cost.
-- This ensures cached results are invalidated when any component changes.
-- ============================
ADDON._cache = ADDON._cache or {}

local function cacheKey(spellID, sp, crit, haste, mods, cost, hitChance)
  return table.concat({
    spellID,
    string.format("%.3f", sp),
    string.format("%.4f", crit),
    string.format("%.4f", haste),
    string.format("%.6f", mods.dmgMult or 1),
    string.format("%.6f", mods.costMult or 1),
    string.format("%.3f", mods.castDelta or 0),
    string.format("%.4f", mods.critMult or 1.5),
    string.format("%.4f", hitChance),
    cost or 0,
  }, ":")
end

local function expectedHitChance(levelDiff, hitBonus)
  local baseMiss = (BaseMiss and BaseMiss[levelDiff]) or 0.04
  local baseHit  = 1.0 - baseMiss
  local hit      = baseHit + (hitBonus or 0)
  if hit > HIT_CAP then hit = HIT_CAP end
  if hit < 0 then hit = 0 end
  return hit
end

-- ============================
-- Public API: compute a single spell rank by ID
-- mode: defaults to "sustained"; other modes are for dot/channel spells.
-- Returns nil if the spell is unknown or unsupported.  The returned
-- table contains fields: school, type, cost, crit, rank, name and
-- computed values (avgHit, avgCrit, weightedAvg, dps, time).
-- ============================
function ADDON:Compute(spellID, mode)
  --
  -- Compute deterministic results for the given spell rank.  Supports the
  -- legacy flat data structure (fields like `type`, `baseMin`, etc.) and
  -- the new bundled format where direct/dot/absorb components live in
  -- subtables keyed by `direct`, `dot` and `absorb`.  Multiple
  -- components will yield multiple result entries in the returned table.
  --
  mode = mode or "sustained"
  local e = SpellDB[spellID]
  if not e then return nil end
  local sp, crit, haste = readPlayerSpellStats(e.school)
  local mods = getDeterministicModifiers(e.name, e.school)
  -- Mana cost is always defined on the top‑level entry
  local cost = math.max(0, math.floor((e.mana or 0) * (mods.costMult or 1) + 0.5))
  local levelDiff = 0
  local hitChance = expectedHitChance(levelDiff, mods.hitBonus)
  local key = cacheKey(spellID, sp, crit, haste, mods, cost, hitChance)
  local cached = self._cache[key]
  if cached then return cached end

  -- Helper to compute a direct component
  local function computeDirectComponent(comp)
    local avgBase = ((comp.baseMin or 0) + (comp.baseMax or 0)) * 0.5
    local cast    = math.max(0, ((comp.baseCast ~= nil) and comp.baseCast or GCD) + (mods.castDelta or 0))
    local wAvg, dps, effTime, nonCrit, critHit =
      computeDirect(avgBase, comp.coeff or 0, sp, (mods.dmgMult or 1), crit, (mods.critMult or 1.5), cast, haste, hitChance)
    return {
      type       = "direct",
      avgHit     = nonCrit,
      avgCrit    = critHit,
      weightedAvg= wAvg,
      dps        = dps,
      time       = effTime,
      castTime   = cast,
    }
  end

  -- Helper to compute a dot or channeled component
  local function computeOverTimeComponent(comp, compMode)
    local total, dps, time =
      computeDotOrChannel(comp.baseTotal or 0, comp.coeff or 0, sp, (mods.dmgMult or 1), comp.duration or 0, compMode, hitChance)
    return {
      type  = comp.type or "dot",
      total = total,
      dps   = dps,
      time  = time,
      mode  = compMode,
    }
  end

  -- Helper for absorb/shield components
  local function computeAbsorbComponent(comp)
    -- Shields do not scale with spell power or crit; just report the absorb amount
    return {
      type     = "absorb",
      absorbMin= comp.baseMin or 0,
      absorbMax= comp.baseMax or 0,
      dps      = 0,
      time     = 0,
    }
  end

  local out = { school = e.school, cost = cost, crit = crit, rank = e.rank, name = e.name, results = {}, hit = hitChance }

  -- New bundled format: components stored in subtables
  local hasComponents = false
  if type(e.direct) == "table" then
    hasComponents = true
    local r = computeDirectComponent(e.direct)
    table.insert(out.results, r)
  end
  if type(e.dot) == "table" then
    hasComponents = true
    local r = computeOverTimeComponent(e.dot, mode)
    table.insert(out.results, r)
  end
  if type(e.channeled) == "table" then
    hasComponents = true
    -- For channeled spells we treat them the same as dot but label the type accordingly
    local comp = e.channeled
    comp.type = "channeled"
    local r = computeOverTimeComponent(comp, mode)
    table.insert(out.results, r)
  end
  if type(e.absorb) == "table" then
    hasComponents = true
    local r = computeAbsorbComponent(e.absorb)
    table.insert(out.results, r)
  end

  -- Fallback: legacy flat format
  if not hasComponents then
    -- Determine spell category
    if e.type == "direct" then
      local r = computeDirectComponent(e)
      table.insert(out.results, r)
    elseif e.type == "dot" or e.type == "channeled" then
      local comp = { baseTotal = e.baseTotal, coeff = e.coeff, duration = e.duration, type = e.type }
      local r = computeOverTimeComponent(comp, mode)
      table.insert(out.results, r)
    elseif e.type == "absorb" then
      local comp = { baseMin = e.baseMin, baseMax = e.baseMax }
      local r = computeAbsorbComponent(comp)
      table.insert(out.results, r)
    else
      return nil
    end
  end

  self._cache[key] = out
  return out
end

-- ============================
-- Tooltip resolution
-- Infer the spell ID from the tooltip.  This handles the two possible
-- signatures returned by `GameTooltip:GetSpell()`.  Falls back to
-- scanning the second line of the tooltip for "Rank X" when the API
-- does not provide the rank.
-- ============================
local function inferSpellFromTooltip(tt)
  if not tt.GetSpell then return nil end
  local name, sub, third = tt:GetSpell()
  local spellID, rankNum
  if type(sub) == "number" then spellID = sub end
  if not spellID and type(third) == "number" then spellID = third end
  local rankText = (type(sub) == "string") and sub or nil
  rankNum = (rankText and tonumber(rankText:match("(%d+)"))) or nil
  if not rankNum then
    local l2 = _G[tt:GetName().."TextLeft2"]
    local t2 = l2 and l2:GetText() or ""
    rankNum = tonumber(t2:match("(%d+)")) or nil
  end
  if spellID and SpellDB[spellID] then return spellID end
  if name and rankNum and ADDON.Rev[name] then
    local id = ADDON.Rev[name][rankNum]
    if id and SpellDB[id] then return id end
  end
  return nil
end

-- ============================
-- Tooltip hook
-- Append deterministic spell math information to the game tooltip.  The
-- hook prints average hit, crit, DPS and other values for direct
-- spells and total damage for dot/channel spells.  Values are
-- formatted similarly to the original monolithic implementation.
-- ============================
GameTooltip:HookScript("OnTooltipSetSpell", function(tt)
  -- When a tooltip is set for a spell, compute deterministic values and
  -- append them.  Supports multiple components per spell via
  -- s.results.  Falls back to the legacy single‑component behaviour.
  local spellID = inferSpellFromTooltip(tt)
  if not spellID then return end
  local s = ADDON:Compute(spellID, "sustained")
  if not s then return end
  local cost = s.cost or 0
  -- New multi‑result format
  if s.results and #s.results > 0 then
    for _, r in ipairs(s.results) do
      if r.type == "direct" then
        local dpm = 0
        if (r.weightedAvg or 0) > 0 then
          dpm = (r.weightedAvg or 0) / math.max(1, cost)
          dpm = dpm * (s.hitChance or 1)
        end
        tt:AddLine(string.format(
          "|cff80d0ffAvg %.0f (crit %.0f)  DPS %.1f  DPM %.2f  Crit %.1f%%  Hit %.1f%%|r",
          r.weightedAvg or 0,
          r.avgCrit or 0,
          r.dps or 0,
          dpm,
          (s.crit or 0) * 100,
          (s.hit or 0) * 100,
          r.time or GCD,
          cost
        ))
      elseif r.type == "dot" or r.type == "channeled" then
        local dpm = 0
        if (r.total or 0) > 0 then
          dpm = (r.total or 0) / math.max(1, cost)
          dpm = dpm * (s.hitChance or 1)
        end
        tt:AddLine(string.format(
          "|cff80d0ff%s DPS %.1f  Total %.0f  DPM %.2f  Hit %.1f%%|r",
          (r.mode == "application" and "Application" or "Sustained"),
          r.dps or 0,
          r.total or 0,
          dpm,
          (s.hitChance or 0) * 100,
          r.time or GCD,
          cost
        ))
      elseif r.type == "absorb" then
        local min = r.absorbMin or 0
        local max = r.absorbMax or min
        local absorbStr
        if min == max then
          absorbStr = string.format("%.0f", min)
        else
          absorbStr = string.format("%.0f–%.0f", min, max)
        end
        tt:AddLine(string.format(
          "|cff80d0ffAbsorb %s  Cost %d|r",
          absorbStr,
          cost
        ))
      end
    end
    return
  end
  -- Legacy behaviour for spells without results table
  if s.type == "direct" then
    tt:AddLine(string.format(
      "|cff80d0ffAvg %.0f (crit %.0f)  DPS %.1f  DPM %.2f  Crit %.1f%%  Time %.2fs  Cost %d|r",
      s.weightedAvg or 0, s.avgCrit or 0, s.dps or 0,
      ((s.weightedAvg or 0) / math.max(1, cost)),
      (s.crit or 0) * 100, s.time or GCD, cost
    ))
  elseif s.type == "dot" or s.type == "channeled" then
    local total = s.total or 0
    tt:AddLine(string.format(
      "|cff80d0ff%s DPS %.1f  Total %.0f  DPM %.2f  Time %.2fs  Cost %d|r",
      (s.mode == "application" and "Application" or "Sustained"),
      s.dps or 0, total, total / math.max(1, cost),
      s.time or GCD, cost
    ))
  elseif s.type == "absorb" then
    local min = s.baseMin or 0
    local max = s.baseMax or min
    local absorbStr
    if min == max then
      absorbStr = string.format("%.0f", min)
    else
      absorbStr = string.format("%.0f–%.0f", min, max)
    end
    tt:AddLine(string.format(
      "|cff80d0ffAbsorb %s  Cost %d|r",
      absorbStr,
      cost
    ))
  end
end)

-- ============================
-- Invalidation
-- Clear the cache and talent signatures when any event fires that
-- could change the computed values.  This includes equipment changes,
-- talent updates, level ups, aura changes and shapeshifts.  The
-- events mirror those in the original implementation.
-- ============================
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:SetScript("OnEvent", function(_, ev, arg1)
  if ev == "UNIT_AURA" and arg1 ~= "player" then return end
  wipe(ADDON._cache)
  TalentCache.sig, TalentCache.ranks = nil, nil
end)

-- ============================
-- Slash command for debug
-- Allows quick inspection of spell math via `/spellmath <spellID>`.
-- Only prints results for direct spells; dot/channel spells are
-- reported with a generic message.
-- ============================
SLASH_SPELLMATH1 = "/spellmath"
SlashCmdList.SPELLMATH = function(msg)

  -- toggle the extended spellbook UI
  if msg == "ui" or msg == "book" then
    if SpellMath.ToggleUI then
      SpellMath:ToggleUI()
    else
      print("SpellMath: UI not loaded.")
    end
    return
  end

  local id = tonumber(msg) or 116
  local s = ADDON:Compute(id, "sustained")
  if not s then
    print("SpellMath: unknown or unsupported spellID: "..tostring(id))
    return
  end
  -- Handle multi‑component results if present
  if s.results and #s.results > 0 then
    for _, r in ipairs(s.results) do
      if r.type == "direct" then
        local dpm = (r.weightedAvg or 0) / math.max(1, s.cost or 0)
        print(string.format("%s R%d — Avg %.0f (crit %.0f), DPS %.1f, DPM %.2f, Crit %.1f%%, Time %.2fs, Cost %d",
          s.name or "Spell",
          s.rank or 0,
          r.weightedAvg or 0,
          r.avgCrit or 0,
          r.dps or 0,
          dpm,
          (s.crit or 0) * 100,
          r.time or GCD,
          s.cost or 0))
      elseif r.type == "dot" or r.type == "channeled" then
        local dpm = (r.total or 0) / math.max(1, s.cost or 0)
        print(string.format("%s R%d — %s DPS %.1f, Total %.0f, DPM %.2f, Time %.2fs, Cost %d",
          s.name or "Spell",
          s.rank or 0,
          (r.type == "channeled" and "Chan" or "DOT"),
          r.dps or 0,
          r.total or 0,
          dpm,
          r.time or GCD,
          s.cost or 0))
      elseif r.type == "absorb" then
        local min = r.absorbMin or 0
        local max = r.absorbMax or min
        print(string.format("%s R%d — Absorb %s, Cost %d",
          s.name or "Spell",
          s.rank or 0,
          (min == max) and string.format("%.0f", min) or string.format("%.0f–%.0f", min, max),
          s.cost or 0))
      end
    end
    return
  end
  -- Fallback to legacy output
  if s.type == "direct" then
    print(string.format("%s R%d — Avg %.0f (crit %.0f), DPS %.1f, DPM %.2f, Crit %.1f%%, Time %.2fs, Cost %d",
      s.name or "Spell", s.rank or 0, s.weightedAvg or 0, s.avgCrit or 0, s.dps or 0,
      ((s.weightedAvg or 0) / math.max(1, s.cost or 0)), (s.crit or 0) * 100, s.time or GCD, s.cost or 0))
  elseif s.type == "dot" or s.type == "channeled" then
    local total = s.total or 0
    print(string.format("%s R%d — %s DPS %.1f, Total %.0f, DPM %.2f, Time %.2fs, Cost %d",
      s.name or "Spell", s.rank or 0,
      (s.type == "channeled" and "Chan" or "DOT"),
      s.dps or 0, total, total / math.max(1, s.cost or 0), s.time or GCD, s.cost or 0))
  elseif s.type == "absorb" then
    local min = s.baseMin or 0
    local max = s.baseMax or min
    print(string.format("%s R%d — Absorb %s, Cost %d",
      s.name or "Spell", s.rank or 0,
      (min == max) and string.format("%.0f", min) or string.format("%.0f–%.0f", min, max),
      s.cost or 0))
  else
    print("SpellMath: unsupported spell type")
  end
end