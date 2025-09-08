-- ui_spellbook.lua - a simple scrollable “extended spellbook” for SpellMath
local ADDON = _G["SpellMath"]
if not ADDON then return end

local GCD = ADDON.GCD or 1.5
-- Sorting state
local SortState = { key = "name", dir = "asc" }
local cols = {
  {text="Name",   w=100, key="name"},
  {text="Rank",   w=40,  key="rank"},
  {text="Avg",    w=80,  key="avg"},
  {text="Total",  w=80,  key="total"},
  {text="DPS",    w=70,  key="dps"},
  {text="DPM",    w=70,  key="dpm"},
  {text="Crit%",  w=60,   key="critPct"},
  {text="Time",   w=60,  key="time"},
  {text="Cost",   w=60,  key="cost"},
}
local uiRows = uiRows or {}
local buildRows

-- ========= Helpers =========
local function computeDisplayRow(spellID)
  local s = ADDON:Compute(spellID, "sustained")
  if not s then return end

  local name = s.name or ("Spell "..spellID)
  local rank = s.rank or 0
  local cost = s.cost or 0
  local critPct = (s.crit or 0) * 100

  local dps, dpm, avg, total, time = 0, 0, 0, 0, 0

  if s.results and #s.results > 0 then
    for _, r in ipairs(s.results) do
      if r.type == "direct" then
        dps = dps + (r.dps or 0)
        avg = math.max(avg, r.weightedAvg or 0)
        time = math.max(time, r.time or 0)
        if (r.weightedAvg or 0) > 0 then
          dpm = dpm + (r.weightedAvg or 0) / math.max(1, cost)
        end
      elseif r.type == "dot" or r.type == "channeled" then
        dps = dps + (r.dps or 0)
        total = total + (r.total or 0)
        time = math.max(time, r.time or 0)
        if (r.total or 0) > 0 then
          dpm = dpm + (r.total or 0) / math.max(1, cost)
        end
      end
    end
  else
    -- legacy single-component fallback
    if s.type == "direct" then
      dps = s.dps or 0
      avg = s.weightedAvg or 0
      time = s.time or GCD
      dpm = (s.weightedAvg or 0) / math.max(1, cost)
    elseif s.type == "dot" or s.type == "channeled" then
      dps = s.dps or 0
      total = s.total or 0
      time = s.time or GCD
      dpm = (s.total or 0) / math.max(1, cost)
    end
  end

  -- If you later add hitChance to s (e.g., s.hit = 0.96), you can apply it to throughput only:
  if s.hit then
    dps = dps * s.hit
    dpm = dpm * s.hit
  end

  return {
    id = spellID, name = name, rank = rank, cost = cost,
    critPct = critPct, avg = avg, total = total, dps = dps, dpm = dpm, time = time,
  }
end

local function collectKnownSpellIDs()
  local known = {}
  local i = 1
  while true do
    local name, rank = GetSpellBookItemName(i, BOOKTYPE_SPELL)
    if not name then break end
    local spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
    if spellType == "SPELL" and spellID then
      known[spellID] = true
    end
    i = i + 1
  end
  return known
end

-- Gather & sort spell ids once
local ids = {}
local known = collectKnownSpellIDs()

for id, spell in pairs(ADDON.Data.Spells or {}) do
  if known[id] then  -- only include if known
    ids[#ids+1] = id
  end
end

table.sort(ids, function(a,b)
  local A = ADDON.Data.Spells[a]; local B = ADDON.Data.Spells[b]
  if A and B then
    if A.name == B.name then return (A.rank or 0) < (B.rank or 0) end
    return (A.name or "") < (B.name or "")
  end
  return a < b
end)

-- ========= Window =========
local f = CreateFrame("Frame", "SpellMathBook", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
f:SetSize(700, 480)
f:SetPoint("CENTER")
f:SetMovable(true); f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()

f:SetBackdrop({ bgFile="Interface/Tooltips/UI-Tooltip-Background", edgeFile="Interface/DialogFrame/UI-DialogBox-Border",
  tile=true, tileSize=16, edgeSize=16, insets={left=3,right=3,top=3,bottom=3}})
f:SetBackdropColor(0,0,0,0.85)

local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOPLEFT", 16, -12)
title:SetText("SpellMath — Extended Spellbook")

local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", 2, 2)

-- Column headers (click to sort)
local header = CreateFrame("Frame", nil, f)
header:SetPoint("TOPLEFT", 12, -36)
header:SetSize(676, 20)

local function applyArrowTexture(tex, dir)
  -- Try atlases first (Retail/SoD)
  local atlasOK = false
  if tex.SetAtlas then
    local atlas = (dir == "asc") and "common-icon-sort-up" or "common-icon-sort-down"
    local ok = tex:SetAtlas(atlas, true)   -- returns true if atlas exists
    if ok then
      if tex.SetRotation then tex:SetRotation(0) end
      tex:SetTexCoord(0,1,0,1)
      atlasOK = true
    end
  end

  if not atlasOK then
    -- Classic-safe fallback
    tex:SetTexture("Interface\\Buttons\\UI-SortArrow") -- built-in down arrow on most clients
    if tex.SetRotation then
      if dir == "asc" then tex:SetRotation(math.pi) else tex:SetRotation(0) end
      tex:SetTexCoord(0,1,0,1)
    else
      -- Last-ditch flip using texcoords (some builds don’t have SetRotation)
      if dir == "asc" then
        tex:SetTexCoord(0,1,1,0)  -- flip vertically to fake "up"
      else
        tex:SetTexCoord(0,1,0,1)
      end
    end
  end
  tex:Show()
end


local headerButtons = {}
local function updateHeaderArrows()
  for i, btn in ipairs(headerButtons) do
    local isActive = (SortState.key == cols[i].key)

    btn.text:SetText(cols[i].text)
    btn.Arrow:Hide()

    if isActive then
      applyArrowTexture(btn.Arrow, (SortState.dir == "asc") and "asc" or "desc")

      -- If neither atlas nor file texture exists on this client, fall back to ASCII.
      -- (After SetTexture/SetAtlas, GetTexture() should be non-nil when it worked.)
      if not btn.Arrow:GetTexture() then
        btn.Arrow:Hide()
        btn.text:SetText(cols[i].text .. ((SortState.dir == "asc") and " ^" or " v"))
      end
    end
  end
end


local function setSort(key)
  if SortState.key == key then
    SortState.dir = (SortState.dir == "asc") and "desc" or "asc"
  else
    SortState.key, SortState.dir = key, "asc"
  end
  updateHeaderArrows()
  buildRows()
end

local x = 0
for i,c in ipairs(cols) do
  local btn = CreateFrame("Button", nil, header)
  btn:SetPoint("LEFT", header, "LEFT", x, 0)
  btn:SetSize(c.w, 20)

  btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  btn.text:SetPoint("LEFT", btn, "LEFT", 0, 0)
  btn.text:SetWidth(c.w)
  btn.text:SetJustifyH("LEFT")

  btn.Arrow = btn:CreateTexture(nil, "ARTWORK")
  btn.Arrow:SetSize(10, 10)
  btn.Arrow:SetPoint("RIGHT", btn, "RIGHT", 0, 0)  -- always inside the column
  btn.Arrow:Hide()

  btn:SetScript("OnClick", function() setSort(c.key) end)

  headerButtons[i] = btn
  x = x + c.w + 4
end
updateHeaderArrows()

-- Scroll area
local scroll = CreateFrame("ScrollFrame", "SpellMathBookScroll", f, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, 12)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(650, 400)
scroll:SetScrollChild(content)

-- Row builder
local ROW_H = 18
local rows = {}

local function setCell(fs, text, width, justify)
  fs:SetWidth(width); fs:SetJustifyH(justify or "LEFT"); fs:SetText(text)
end

local function formatNum(n, decimals)
  if not n then return "" end
  local m = 10 ^ (decimals or 0)
  return string.format("%."..(decimals or 0).."f", math.floor(n * m + 0.5) / m)
end

-- Map a row to a comparable value for the active column
local function keyOf(row, key)
  if not row then return nil end
  if key == "name"    then return row.name or ""
  elseif key == "rank"    then return row.rank or -1
  elseif key == "avg"     then return row.avg or -math.huge
  elseif key == "total"   then return row.total or -math.huge
  elseif key == "dps"     then return row.dps or -math.huge
  elseif key == "dpm"     then return row.dpm or -math.huge
  elseif key == "critPct" then return row.critPct or -math.huge
  elseif key == "time"    then return row.time or math.huge  -- lower is better
  elseif key == "cost"    then return row.cost or math.huge  -- lower is better
  else return row.name or ""  -- fallback
  end
end

-- Map header keys to actual row fields and default types
local function key_map(k)
  if k == "crit" then return "critPct" end  -- header says "crit", data uses "critPct"
  return k
end

local NUMERIC_KEYS = {
  rank=true, avg=true, total=true, dps=true, dpm=true, critPct=true, time=true
}

local function value_of(row, key)
  if type(row) ~= "table" then return nil end
  local f = key_map(key)
  local v = row[f]

  if NUMERIC_KEYS[f] then
    -- numeric columns: coerce to number, default to -inf so “missing” sorts last in ascending
    v = tonumber(v)
    if v == nil then return -math.huge end
    return v
  else
    -- string columns: coerce to lowercased string, default empty string
    if v == nil then return "" end
    return tostring(v):lower()
  end
end

local function sortRows(list)
  -- keep only tables (defensive)
  local filtered = {}
  for i = 1, #list do
    if type(list[i]) == "table" then
      filtered[#filtered+1] = list[i]
    end
  end

  local key = SortState.key or "name"
  local asc = (SortState.dir ~= "desc")

  local function less(a, b)
    -- Primary key
    local va = value_of(a, key)
    local vb = value_of(b, key)

    -- Same-type, already normalized by value_of:
    if va ~= vb then
      if asc then return va < vb else return va > vb end
    end

    -- Tie-breakers (all normalized, guaranteed boolean returns):
    -- 1) name (string)
    local na = value_of(a, "name")
    local nb = value_of(b, "name")
    if na ~= nb then return na < nb end

    -- 2) rank (number)
    local ra = value_of(a, "rank")
    local rb = value_of(b, "rank")
    if ra ~= rb then return ra < rb end

    -- 3) id (number/string as last resort, coerced safely)
    local ia = tonumber(a and a.id) or 0
    local ib = tonumber(b and b.id) or 0
    if ia ~= ib then return ia < ib end

    -- Completely equal for sorting purposes
    return false
  end

  table.sort(filtered, less)

  -- write back
  for i = 1, #list do list[i] = nil end
  for i = 1, #filtered do list[i] = filtered[i] end
end


local function rebuildIDs(knownOnly)
  local out, known = {}, collectKnownSpellIDs()
  for id in pairs(ADDON.Data.Spells or {}) do
    if (not knownOnly) or known[id] then
      out[#out+1] = id
    end
  end
  table.sort(out, function(a,b)
    local A, B = ADDON.Data.Spells[a], ADDON.Data.Spells[b]
    if A and B then
      if A.name == B.name then return (A.rank or 0) < (B.rank or 0) end
      return (A.name or "") < (B.name or "")
    end
    return a < b
  end)
  return out
end



buildRows = function()
  -- hide & clear old UI rows
  for _, r in ipairs(uiRows) do r:Hide() end
  wipe(uiRows)

  -- ensure we have an id list (rebuild to KNOWN-only if you prefer)
  if not ids or type(ids) ~= "table" or #ids == 0 then
    ids = rebuildIDs(true)  -- set to false to list ALL database spells
  end

  -- 1) collect DATA rows
  local dataRows = {}
  for _, id in ipairs(ids) do
    local d = computeDisplayRow(id)
    if d then dataRows[#dataRows+1] = d end
  end

  -- 2) sort the DATA (not UI frames)
  sortRows(dataRows)

  -- 3) render UI rows from sorted data
  local y = -2
  for _, data in ipairs(dataRows) do
    local row = CreateFrame("Button", nil, content)
    row:SetPoint("TOPLEFT", 0, y)
    row:SetSize(640, ROW_H)
    y = y - ROW_H

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.rank = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.avg  = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.tot  = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.dps  = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.dpm  = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.crit = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.time = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.cost = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

    local x = 0
    setCell(row.name, data.name,                 cols[1].w); row.name:SetPoint("LEFT", row, "LEFT", x, 0); x=x+cols[1].w+4
    setCell(row.rank, tostring(data.rank or 0),  cols[2].w); row.rank:SetPoint("LEFT", row, "LEFT", x, 0); x=x+cols[2].w+4
    setCell(row.avg,  formatNum(data.avg,0),     cols[3].w); row.avg:SetPoint("LEFT", row, "LEFT", x, 0); x=x+cols[3].w+4
    setCell(row.tot,  formatNum(data.total,0),   cols[4].w); row.tot:SetPoint("LEFT", row, "LEFT", x, 0); x=x+cols[4].w+4
    setCell(row.dps,  formatNum(data.dps,1),     cols[5].w); row.dps:SetPoint("LEFT", row, "LEFT", x, 0); x=x+cols[5].w+4
    setCell(row.dpm,  formatNum(data.dpm,2),     cols[6].w); row.dpm:SetPoint("LEFT", row, "LEFT", x, 0); x=x+cols[6].w+4
    setCell(row.crit, formatNum(data.critPct,1), cols[7].w); row.crit:SetPoint("LEFT", row, "LEFT", x, 0); x=x+cols[7].w+4
    setCell(row.time, formatNum(data.time,2).."s", cols[8].w); row.time:SetPoint("LEFT", row, "LEFT", x, 0); x=x+cols[8].w+4
    setCell(row.cost, tostring(data.cost or 0),  cols[9].w); row.cost:SetPoint("LEFT", row, "LEFT", x, 0)

    row:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(data.name.." (Rank "..(data.rank or 0)..")")
      GameTooltip:AddLine(string.format("|cff80d0ffAvg %.0f  DPS %.1f  DPM %.2f  Crit %.1f%%  Time %.2fs  Cost %d|r",
        data.avg or 0, data.dps or 0, data.dpm or 0, data.critPct or 0, data.time or (ADDON.GCD or 1.5), data.cost or 0))
      if (data.total or 0) > 0 then
        GameTooltip:AddLine(string.format("|cff80d0ffTotal %.0f (DoT/Chan)|r", data.total))
      end
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)

    uiRows[#uiRows+1] = row
  end

  content:SetHeight(math.max(400, #uiRows * ROW_H + 8))
end

-- Rebuild rows when values could change
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
ev:RegisterEvent("PLAYER_TALENT_UPDATE")
ev:RegisterEvent("PLAYER_LEVEL_UP")
ev:RegisterEvent("UNIT_AURA")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
ev:RegisterEvent("SPELLS_CHANGED")
ev:SetScript("OnEvent", function(_, e, unit)
  if e == "UNIT_AURA" and unit ~= "player" then return end
  if f:IsShown() then buildRows() end
  if e == "SPELLS_CHANGED" then
    known = collectKnownSpellIDs()
    wipe(ids)
    for id in pairs(ADDON.Data.Spells or {}) do
      if known[id] then ids[#ids+1] = id end
    end
    table.sort(ids, function(a,b)
      local A,B = ADDON.Data.Spells[a], ADDON.Data.Spells[b]
      if A and B then
        if A.name == B.name then return (A.rank or 0) < (B.rank or 0) end
        return (A.name or "") < (B.name or "")
      end
      return a < b
    end)
    if f:IsShown() then buildRows() end
    return
  end
end)

-- Toggle function
function ADDON:ToggleUI()
  if f:IsShown() then
    f:Hide()
  else
    -- if ids not built yet, rebuild now (only known spells)
    if not ids or #ids == 0 then
      ids = rebuildIDs(true)  -- pass false if you want *all* spells instead of known-only
    end
    buildRows()
    f:Show()
  end
end
