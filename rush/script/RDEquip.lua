-- Rush Duel 装备
RushDuel = RushDuel or {}

-- 注册效果: 装备魔法的装备效果
function RushDuel.RegisterEquipEffect(card, condition, cost, target, property)
    -- Activate
    local e1 = Effect.CreateEffect(card)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    if property ~= nil then
        e1:SetProperty(property)
    end
    if condition ~= nil then
        e1:SetCondition(condition)
    end
    if cost ~= nil then
        e1:SetCost(cost)
    end
    e1:SetTarget(RushDuel.EquipTarget(target))
    e1:SetOperation(RushDuel.EquipOperation(target))
    card:RegisterEffect(e1)
    -- Equip Limit
    local e2 = Effect.CreateEffect(card)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(RushDuel.EquipFilter(target))
    card:RegisterEffect(e2)
    return e1
end
function RushDuel.EquipTarget(target)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsExistingMatchingCard(target, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil, e, tp, true)
        end
        Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
    end
end
function RushDuel.EquipOperation(target)
    return function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
        local g = Duel.SelectMatchingCard(tp, target, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil, e, tp, true)
        local tc = g:GetFirst()
        if tc and c:IsRelateToEffect(e) then
            Duel.HintSelection(g)
            Duel.Equip(tp, c, tc)
        end
    end
end
function RushDuel.EquipFilter(target)
    return function(e, c)
        return e:GetHandler():GetEquipTarget() == c or target(c, e, e:GetHandlerPlayer(), false)
    end
end
