-- Rush Duel 同盟
RushDuel = RushDuel or {}

-- 注册效果: 同盟怪兽的同盟效果
function RushDuel.RegisterUnionEffect(card, target, condition, cost, operation, limit)
    local filter = function(c, e, re)
        return c:IsFaceup() and target(c, e, re)
    end
    -- Union
    local e1 = Effect.CreateEffect(card)
    e1:SetDescription(1060)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    if condition then
        e1:SetCondition(condition)
    end
    if cost then
        e1:SetCost(cost)
    end
    e1:SetTarget(RushDuel.UnionTarget(filter))
    e1:SetOperation(RushDuel.UnionOperation(filter, operation, limit))
    card:RegisterEffect(e1)
    -- Equip Limit
    local e2 = Effect.CreateEffect(card)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(RushDuel.UnionFilter(filter))
    card:RegisterEffect(e2)
    local e3 = Effect.CreateEffect(card)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UNION_TARGET)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetValue(filter)
    card:RegisterEffect(e3)
    return e1
end
function RushDuel.UnionTarget(target)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(target, tp, LOCATION_MZONE, 0, 1, e:GetHandler(), e)
        end
        Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
    end
end
function RushDuel.UnionOperation(target, operation, limit)
    return function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
        local g = Duel.SelectMatchingCard(tp, target, tp, LOCATION_MZONE, 0, 1, 1, c, e)
        local tc = g:GetFirst()
        if tc and c:IsRelateToEffect(e) then
            Duel.HintSelection(g)
            RushDuel.UnionEquip(tp, tc, c)
            if operation then
                operation(e, tp, eg, ep, ev, re, r, rp, tc)
            end
        end
        if limit then
            limit(e, tp, eg, ep, ev, re, r, rp)
        end
    end
end
function RushDuel.UnionFilter(target)
    return function(e, c)
        return e:GetHandler():GetEquipTarget() == c
    end
end

-- 检查是否可以同盟装备
function RushDuel.CheckUnionEquip(e, c, ec)
    local effects = {ec:IsHasEffect(EFFECT_UNION_TARGET)}
    for i, effect in ipairs(effects) do
        local value = effect:GetValue()
        if value(c, effect, e) then
            return true
        end
    end
    return false
end

-- 进行同盟装备
function RushDuel.UnionEquip(tp, c, ec)
    if c and ec and Duel.Equip(tp, ec, c) then
        local e1 = Effect.CreateEffect(ec)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UNION_STATUS)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e1)
        return true
    end
    return false
end