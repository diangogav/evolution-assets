-- Rush Duel 编号
RushDuel = RushDuel or {}

TYPE_LEGEND = 0x8 -- 传说卡

-- LEGEND_MONSTER = 120000000
-- LEGEND_SPELL = 120000001
-- LEGEND_TRAP = 120000002

-- 初始化传说卡
function RushDuel.InitLegend()
    -- local g = Duel.GetMatchingGroup(RushDuel.IsLegendCard, 0, 0xff, 0xff, nil, true)
    -- g:ForEach(RushDuel.InitLegendCard)
end
function RushDuel.InitLegendCard(c)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEGEND_CARD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetRange(0xff)
    e1:SetValue(c:GetOriginalCodeRule())
    c:RegisterEffect(e1, true)
end

-- 条件: 是否为传说卡
function RushDuel.IsLegendCard(card)
    return card:IsType(TYPE_LEGEND) or card:IsHasEffect(EFFECT_LEGEND_CARD) ~= nil
end

-- 条件: 是否为传说卡的卡名
function RushDuel.IsLegendCode(card, ...)
    return card:IsCode(table.unpack({...}))
end

-- 条件: 是否为同名卡
function RushDuel.IsSameCode(card1, card2)
    return card1:IsCode(card2:GetCode())
end

-- 条件: 是否为原本卡名相同的卡
function RushDuel.IsSameOriginalCode(card1, card2)
    return card1:IsOriginalCodeRule(card2:GetOriginalCodeRule())
end

-- 永续改变卡名
function RushDuel.EnableChangeCode(c, code, location, condition)
    Auxiliary.AddCodeList(c, code)
    local loc = c:GetOriginalType() & TYPE_MONSTER ~= 0 and LOCATION_MZONE or LOCATION_SZONE
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(location or loc)
    if condition ~= nil then
        e1:SetCondition(condition)
    end
    e1:SetValue(code)
    c:RegisterEffect(e1)
    return e1
end

-- 当作传说卡 (赝品)
function RushDuel.EnableFakeLegend(card, location)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEGEND_CARD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(location)
    e1:SetValue(0)
    card:RegisterEffect(e1, true)
    return e1
end
