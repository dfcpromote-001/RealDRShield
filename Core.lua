local ADDON_NAME = ...

local defaults = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 120,
    locked = false,
    scale = 1,
    alpha = 1,
    showHealAbsorb = true,
}

local auraRules = {
    -- categories: global, physical, magic, aoe. shieldType: all, physical, magic.
    -- Extend this table with spell IDs as needed.
    [48707] = { name = "Anti-Magic Shell", shieldType = "magic" },
    [48792] = { name = "Icebound Fortitude", dr = 0.30, categories = { "global" } },
    [22812] = { name = "Barkskin", dr = 0.20, categories = { "global" } },
    [61336] = { name = "Survival Instincts", dr = 0.50, categories = { "global" } },
    [102342] = { name = "Ironbark", dr = 0.20, categories = { "global" } },
    [198589] = { name = "Blur", dr = 0.20, categories = { "global" } },
    [196555] = { name = "Netherwalk", dr = 1.00, categories = { "global" } },
    [186265] = { name = "Aspect of the Turtle", dr = 1.00, categories = { "global" } },
    [414658] = { name = "Survival of the Fittest", dr = 0.40, categories = { "global" } },
    [45438] = { name = "Ice Block", dr = 1.00, categories = { "global" } },
    [55342] = { name = "Mirror Image", dr = 0.20, categories = { "global" } },
    [122783] = { name = "Diffuse Magic", dr = 0.60, categories = { "magic" } },
    [122278] = { name = "Dampen Harm", dr = 0.20, categories = { "global" } },
    [115203] = { name = "Fortifying Brew", dr = 0.20, categories = { "global" } },
    [642] = { name = "Divine Shield", dr = 1.00, categories = { "global" } },
    [498] = { name = "Divine Protection", dr = 0.20, categories = { "global" } },
    [31850] = { name = "Ardent Defender", dr = 0.20, categories = { "global" } },
    [86659] = { name = "Guardian of Ancient Kings", dr = 0.50, categories = { "global" } },
    [47585] = { name = "Dispersion", dr = 0.75, categories = { "global" } },
    [33206] = { name = "Pain Suppression", dr = 0.40, categories = { "global" } },
    [31224] = { name = "Cloak of Shadows", dr = 1.00, categories = { "magic" } },
    [108271] = { name = "Astral Shift", dr = 0.40, categories = { "global" } },
    [104773] = { name = "Unending Resolve", dr = 0.25, categories = { "global" } },
    [118038] = { name = "Die by the Sword", dr = 0.30, categories = { "physical" } },
    [871] = { name = "Shield Wall", dr = 0.40, categories = { "global" } },
    [23920] = { name = "Spell Reflection", dr = 0.20, categories = { "magic" } },
    [207319] = { name = "Corpse Shield", dr = 0.90, categories = { "global" } },
    [116849] = { name = "Life Cocoon", shieldType = "all" },
    [17] = { name = "Power Word: Shield", shieldType = "all" },
    [11426] = { name = "Ice Barrier", shieldType = "all" },
    [235450] = { name = "Prismatic Barrier", shieldType = "magic" },
    [235313] = { name = "Blazing Barrier", shieldType = "all" },
    [414660] = { name = "Mass Barrier", shieldType = "all" },
    [108416] = { name = "Dark Pact", shieldType = "all" },
    [190456] = { name = "Ignore Pain", shieldType = "physical" },
}

local db
local updateErrorShown = false
local updateDisplay
local frame = CreateFrame("Frame", ADDON_NAME .. "Frame", UIParent, "BackdropTemplate")
frame:SetSize(280, 152)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})
frame:SetBackdropColor(0.05, 0.06, 0.07, 0.84)
frame:SetBackdropBorderColor(0.25, 0.55, 0.95, 0.9)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOPLEFT", 10, -8)
title:SetText("Real DR Shield")

local physicalText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
physicalText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
physicalText:SetJustifyH("LEFT")

local magicText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
magicText:SetPoint("TOPLEFT", physicalText, "BOTTOMLEFT", 0, -5)
magicText:SetJustifyH("LEFT")

local specialText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
specialText:SetPoint("TOPLEFT", magicText, "BOTTOMLEFT", 0, -5)
specialText:SetJustifyH("LEFT")

local absorbText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
absorbText:SetPoint("TOPLEFT", specialText, "BOTTOMLEFT", 0, -8)
absorbText:SetJustifyH("LEFT")

local absorbSplitText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
absorbSplitText:SetPoint("TOPLEFT", absorbText, "BOTTOMLEFT", 0, -5)
absorbSplitText:SetJustifyH("LEFT")

local auraText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
auraText:SetPoint("TOPLEFT", absorbSplitText, "BOTTOMLEFT", 0, -7)
auraText:SetJustifyH("LEFT")
auraText:SetWidth(258)

local function copyDefaults(target, source)
    for key, value in pairs(source) do
        if target[key] == nil then
            target[key] = value
        end
    end
end

local function sanitizeSettings()
    if type(db.point) ~= "string" then
        db.point = defaults.point
    end
    if type(db.relativePoint) ~= "string" then
        db.relativePoint = defaults.relativePoint
    end
    if type(db.x) ~= "number" then
        db.x = defaults.x
    end
    if type(db.y) ~= "number" then
        db.y = defaults.y
    end
    if type(db.scale) ~= "number" or db.scale <= 0 then
        db.scale = defaults.scale
    end
    if type(db.alpha) ~= "number" then
        db.alpha = defaults.alpha
    end
    if type(db.locked) ~= "boolean" then
        db.locked = defaults.locked
    end
    if type(db.showHealAbsorb) ~= "boolean" then
        db.showHealAbsorb = defaults.showHealAbsorb
    end

    db.scale = math.max(0.5, math.min(db.scale, 2))
    db.alpha = math.max(0.2, math.min(db.alpha, 1))
end

local function shortNumber(value)
    value = math.floor((value or 0) + 0.5)
    if value >= 100000000 then
        return string.format("%.1f亿", value / 100000000)
    end
    if value >= 10000 then
        return string.format("%.1f万", value / 10000)
    end
    if BreakUpLargeNumbers then
        return BreakUpLargeNumbers(value)
    end
    return tostring(value)
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local ok, first, second, third, fourth = pcall(fn, ...)
    if ok then
        return first, second, third, fourth
    end
    return nil
end

local function getPlayerLevel()
    local level = safeCall(UnitEffectiveLevel, "player") or safeCall(UnitLevel, "player")
    if not level or level < 1 then
        level = safeCall(UnitLevel, "player")
    end
    return level or 1
end

local function getArmorReduction()
    local _, effectiveArmor = safeCall(UnitArmor, "player")
    effectiveArmor = math.max(effectiveArmor or 0, 0)

    if PaperDollFrame_GetArmorReduction then
        local reduction = safeCall(PaperDollFrame_GetArmorReduction, effectiveArmor, getPlayerLevel())
        return math.max(0, math.min((reduction or 0) / 100, 0.85)), effectiveArmor
    end

    -- Conservative fallback used only if Blizzard's paper doll helper is unavailable.
    local level = getPlayerLevel()
    local constant = 467.5 * level - 22167.5
    if constant < 1 then
        constant = 1
    end
    local reduction = effectiveArmor / (effectiveArmor + constant)
    return math.max(0, math.min(reduction, 0.85)), effectiveArmor
end

local function percentToRate(value)
    return math.max(0, math.min((value or 0) / 100, 1))
end

local function getVersatilityReduction()
    if CR_VERSATILITY_DAMAGE_TAKEN and GetCombatRatingBonus then
        return percentToRate(safeCall(GetCombatRatingBonus, CR_VERSATILITY_DAMAGE_TAKEN))
    end
    if CR_VERSATILITY_DAMAGE_DONE and GetCombatRatingBonus then
        return percentToRate((safeCall(GetCombatRatingBonus, CR_VERSATILITY_DAMAGE_DONE) or 0) / 2)
    end
    return 0
end

local function getAvoidanceReduction()
    if GetAvoidance then
        return percentToRate(safeCall(GetAvoidance))
    end
    if CR_AVOIDANCE and GetCombatRatingBonus then
        return percentToRate(safeCall(GetCombatRatingBonus, CR_AVOIDANCE))
    end
    return 0
end

local function combineDR(current, added)
    added = math.max(0, math.min(added or 0, 1))
    return 1 - ((1 - current) * (1 - added))
end

local function getAuraAmount(aura)
    if aura and aura.points then
        for _, point in ipairs(aura.points) do
            if type(point) == "number" and point > 0 then
                return point
            end
        end
    end
    return nil
end

local function scanAuras()
    local result = {
        global = 0,
        physical = 0,
        magic = 0,
        aoe = 0,
        allShield = 0,
        physicalShield = 0,
        magicShield = 0,
        classifiedShield = 0,
        unmeasuredShieldNames = {},
        activeNames = {},
    }

    for spellID, rule in pairs(auraRules) do
        local aura = C_UnitAuras and safeCall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
        if aura then
            local name = rule.name or aura.name or tostring(spellID)
            result.activeNames[#result.activeNames + 1] = name

            if rule.dr and rule.categories then
                for _, category in ipairs(rule.categories) do
                    result[category] = combineDR(result[category] or 0, rule.dr)
                end
            end

            if rule.shieldType then
                local amount = getAuraAmount(aura)
                if amount then
                    local key = rule.shieldType .. "Shield"
                    result[key] = (result[key] or 0) + amount
                    result.classifiedShield = result.classifiedShield + amount
                else
                    result.unmeasuredShieldNames[#result.unmeasuredShieldNames + 1] = name
                end
            end
        end
    end

    table.sort(result.activeNames)
    table.sort(result.unmeasuredShieldNames)
    return result
end

local function getAbsorbs()
    local absorb = safeCall(UnitGetTotalAbsorbs, "player") or 0
    local healAbsorb = safeCall(UnitGetTotalHealAbsorbs, "player") or 0
    return absorb or 0, healAbsorb or 0
end

local function savePosition()
    if not db then
        return
    end

    local point, _, relativePoint, x, y = frame:GetPoint(1)
    db.point = point or defaults.point
    db.relativePoint = relativePoint or defaults.relativePoint
    db.x = x or defaults.x
    db.y = y or defaults.y
end

local function applySettings()
    frame:ClearAllPoints()
    local ok = pcall(frame.SetPoint, frame, db.point, UIParent, db.relativePoint, db.x, db.y)
    if not ok then
        db.point = defaults.point
        db.relativePoint = defaults.relativePoint
        db.x = defaults.x
        db.y = defaults.y
        frame:ClearAllPoints()
        frame:SetPoint(db.point, UIParent, db.relativePoint, db.x, db.y)
    end
    frame:SetScale(db.scale)
    frame:SetAlpha(db.alpha)
    frame:EnableMouse(not db.locked)
end

local function safeUpdateDisplay()
    if not db then
        return
    end

    local ok, err = pcall(updateDisplay)
    if ok then
        updateErrorShown = false
        return
    end

    physicalText:SetText("物理减伤: --")
    magicText:SetText("魔法减伤: --")
    specialText:SetText("范围减伤: --  全局减伤: --")
    absorbText:SetText("总护盾: --")
    absorbSplitText:SetText("物理盾: --  魔法盾: --  通用盾: --  未分类: --")
    auraText:SetText("数据刷新失败，请 /reload 后重试")

    if not updateErrorShown then
        updateErrorShown = true
        print("Real DR Shield: display update failed: " .. tostring(err))
    end
end

function updateDisplay()
    local armorDR = getArmorReduction()
    local versatilityDR = getVersatilityReduction()
    local avoidanceDR = getAvoidanceReduction()
    local auras = scanAuras()
    local absorb, healAbsorb = getAbsorbs()
    local unclassifiedShield = math.max(absorb - auras.classifiedShield, 0)
    local globalDR = combineDR(versatilityDR, auras.global)
    local effectivePhysicalDR = combineDR(combineDR(armorDR, globalDR), auras.physical)
    local effectiveMagicDR = combineDR(globalDR, auras.magic)
    local effectiveAoeDR = combineDR(combineDR(avoidanceDR, globalDR), auras.aoe)

    physicalText:SetFormattedText("物理减伤: %.1f%%  护甲: %.1f%%", effectivePhysicalDR * 100, armorDR * 100)
    magicText:SetFormattedText("魔法减伤: %.1f%%", effectiveMagicDR * 100)
    specialText:SetFormattedText("范围减伤: %.1f%%  全局减伤: %.1f%%", effectiveAoeDR * 100, globalDR * 100)

    if db.showHealAbsorb and healAbsorb > 0 then
        absorbText:SetFormattedText("总护盾: %s  治疗吸收: %s", shortNumber(absorb), shortNumber(healAbsorb))
    else
        absorbText:SetFormattedText("总护盾: %s", shortNumber(absorb))
    end
    absorbSplitText:SetFormattedText(
        "物理盾: %s  魔法盾: %s  通用盾: %s  未分类: %s",
        shortNumber(auras.physicalShield),
        shortNumber(auras.magicShield),
        shortNumber(auras.allShield),
        shortNumber(unclassifiedShield)
    )

    if #auras.activeNames > 0 then
        auraText:SetText(table.concat(auras.activeNames, ", "))
    else
        auraText:SetText("无已识别防御/护盾 Buff")
    end
end

frame:SetScript("OnDragStart", function(self)
    if not db.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    savePosition()
end)

frame:SetScript("OnEvent", function(_, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == ADDON_NAME then
        RealDRShieldDB = RealDRShieldDB or {}
        db = RealDRShieldDB
        copyDefaults(db, defaults)
        sanitizeSettings()
        applySettings()
        safeUpdateDisplay()
    elseif db then
        safeUpdateDisplay()
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player")
frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
frame:RegisterUnitEvent("UNIT_AURA", "player")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("COMBAT_RATING_UPDATE")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    if not db then
        return
    end
    elapsed = elapsed + delta
    if elapsed >= 0.2 then
        elapsed = 0
        safeUpdateDisplay()
    end
end)

local function printPlayerAuras()
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then
        print("Real DR Shield: aura scan API is unavailable.")
        return
    end

    print("Real DR Shield: active helpful player auras:")
    for index = 1, 80 do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HELPFUL")
        if not aura then
            break
        end
        local spellID = aura.spellId or aura.spellID or 0
        print(string.format("%d - %s", spellID, aura.name or "unknown"))
    end
end

local function printDebugValues()
    local armorDR, armor = getArmorReduction()
    print("Real DR Shield debug:")
    print(string.format("armor=%s armorDR=%.1f%%", shortNumber(armor), armorDR * 100))
    print(string.format("versatilityDR=%.1f%%", getVersatilityReduction() * 100))
    print(string.format("avoidanceDR=%.1f%%", getAvoidanceReduction() * 100))

    local absorb, healAbsorb = getAbsorbs()
    print(string.format("absorb=%s healAbsorb=%s", shortNumber(absorb), shortNumber(healAbsorb)))
    print("UnitArmor API: " .. (type(UnitArmor) == "function" and "ok" or "missing"))
    print("GetCombatRatingBonus API: " .. (type(GetCombatRatingBonus) == "function" and "ok" or "missing"))
    print("C_UnitAuras.GetPlayerAuraBySpellID API: " .. (C_UnitAuras and type(C_UnitAuras.GetPlayerAuraBySpellID) == "function" and "ok" or "missing"))
end

SLASH_REALDRSHIELD1 = "/rds"
SLASH_REALDRSHIELD2 = "/减伤"
SlashCmdList.REALDRSHIELD = function(message)
    message = string.lower(message or "")

    if not db then
        RealDRShieldDB = RealDRShieldDB or {}
        db = RealDRShieldDB
        copyDefaults(db, defaults)
        sanitizeSettings()
        applySettings()
    end

    if message == "lock" then
        db.locked = true
        applySettings()
        print("Real DR Shield: locked.")
    elseif message == "unlock" then
        db.locked = false
        applySettings()
        print("Real DR Shield: unlocked. Drag with left mouse button.")
    elseif message == "reset" then
        for key in pairs(db) do
            db[key] = nil
        end
        copyDefaults(db, defaults)
        sanitizeSettings()
        applySettings()
        safeUpdateDisplay()
        print("Real DR Shield: reset.")
    elseif message == "hide" then
        frame:Hide()
    elseif message == "show" then
        frame:Show()
        safeUpdateDisplay()
    elseif message == "healabsorb" then
        db.showHealAbsorb = not db.showHealAbsorb
        safeUpdateDisplay()
        print("Real DR Shield: heal absorb display " .. (db.showHealAbsorb and "on." or "off."))
    elseif message == "reload" or message == "refresh" then
        sanitizeSettings()
        applySettings()
        safeUpdateDisplay()
        print("Real DR Shield: refreshed.")
    elseif message == "scan" then
        printPlayerAuras()
    elseif message == "debug" then
        printDebugValues()
    else
        print("Real DR Shield commands:")
        print("/rds lock - lock the frame")
        print("/rds unlock - unlock and drag the frame")
        print("/rds reset - reset position and settings")
        print("/rds hide - hide the frame")
        print("/rds show - show the frame")
        print("/rds healabsorb - toggle heal absorb display")
        print("/rds reload - refresh settings and display")
        print("/rds scan - print active player aura spell IDs")
        print("/rds debug - print raw API values")
    end
end
