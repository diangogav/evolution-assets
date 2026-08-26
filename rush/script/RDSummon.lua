-- Rush Duel 召唤
RushDuel = RushDuel or {}

SUMMON_VALUE_ZERO = 0x20 -- 不用解放的妥协召唤
SUMMON_VALUE_ONE = 0x40 -- 解放1只的妥协召唤
SUMMON_VALUE_TWO = 0x80 -- 解放2只的妥协召唤
SUMMON_VALUE_THREE = 0x100 -- 解放3只的妥协召唤

-- 内部方法: 获取上级召唤的可解放怪兽
function RushDuel._private_get_tribute_group(filter, ...)
    if filter == nil then
        return nil
    else
        return Duel.GetMatchingGroup(filter, 0, LOCATION_MZONE, LOCATION_MZONE, nil, ...)
    end
end

-- 添加不用解放的妥协召唤手续
function RushDuel.AddSummonProcedureZero(card, desc, condition, operation)
    local e1 = Effect.CreateEffect(card)
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(RushDuel.SummonProcedureConditionZero(condition))
    if operation ~= nil then
        e1:SetOperation(operation)
    end
    e1:SetValue(SUMMON_VALUE_ZERO + SUMMON_VALUE_SELF)
    card:RegisterEffect(e1)
    return e1
end
function RushDuel.SummonProcedureConditionZero(condition)
    return function(e, c, minc)
        if c == nil then
            return true
        end
        local tp = c:GetControler()
        return minc == 0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   (not condition or condition(c, e, tp))
    end
end

-- 添加解放1只的妥协召唤手续
function RushDuel.AddSummonProcedureOne(card, desc, condition, filter, operation)
    local e1 = Effect.CreateEffect(card)
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(RushDuel.SummonProcedureConditionOne(filter, condition))
    e1:SetOperation(RushDuel.SummonProcedureOperationOne(filter, operation))
    e1:SetValue(SUMMON_TYPE_ADVANCE + SUMMON_VALUE_ONE + SUMMON_VALUE_SELF)
    card:RegisterEffect(e1)
    return e1
end
function RushDuel.SummonProcedureConditionOne(filter, condition)
    return function(e, c, minc)
        if c == nil then
            return true
        end
        local tp = c:GetControler()
        local mg = RushDuel._private_get_tribute_group(filter, e, tp)
        return c:IsLevelAbove(7) and minc <= 1 and Duel.CheckTribute(c, 1, 1, mg) and
                   (not condition or condition(c, e, tp))
    end
end
function RushDuel.SummonProcedureOperationOne(filter, operation)
    return function(e, tp, eg, ep, ev, re, r, rp, c)
        local mg = RushDuel._private_get_tribute_group(filter, e, tp)
        local sg = Duel.SelectTribute(tp, c, 1, 1, mg)
        c:SetMaterial(sg)
        Duel.Release(sg, REASON_SUMMON + REASON_MATERIAL)
        if operation then
            operation(e, tp, eg, ep, ev, re, r, rp, c, sg)
        end
    end
end

-- 添加解放2只的妥协召唤手续
function RushDuel.AddSummonProcedureTwo(card, desc, condition, filter, operation)
    local e1 = Effect.CreateEffect(card)
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(RushDuel.SummonProcedureConditionTwo(filter, condition))
    e1:SetOperation(RushDuel.SummonProcedureOperationTwo(filter, operation))
    e1:SetValue(SUMMON_TYPE_ADVANCE + SUMMON_VALUE_TWO + SUMMON_VALUE_SELF)
    card:RegisterEffect(e1)
    return e1
end
function RushDuel.SummonProcedureConditionTwo(filter, condition)
    return function(e, c, minc)
        if c == nil then
            return true
        end
        local tp = c:GetControler()
        local mg = RushDuel._private_get_tribute_group(filter, e, tp)
        return minc <= 2 and Duel.CheckTribute(c, 2, 2, mg) and (not condition or condition(c, e, tp))
    end
end
function RushDuel.SummonProcedureOperationTwo(filter, operation)
    return function(e, tp, eg, ep, ev, re, r, rp, c)
        local mg = RushDuel._private_get_tribute_group(filter, e, tp)
        local sg = Duel.SelectTribute(tp, c, 2, 2, mg)
        c:SetMaterial(sg)
        Duel.Release(sg, REASON_SUMMON + REASON_MATERIAL)
        if operation then
            operation(e, tp, eg, ep, ev, re, r, rp, c, sg)
        end
    end
end

-- 添加解放3只的妥协召唤手续
function RushDuel.AddSummonProcedureThree(card, desc, condition, filter, operation)
    local e1 = Effect.CreateEffect(card)
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(RushDuel.SummonProcedureConditionThree(filter, condition))
    e1:SetOperation(RushDuel.SummonProcedureOperationThree(filter, operation))
    e1:SetValue(SUMMON_TYPE_ADVANCE + SUMMON_VALUE_THREE + SUMMON_VALUE_SELF)
    card:RegisterEffect(e1)
    local mt = getmetatable(card)
    if mt.is_can_triple_tribute == nil then
        mt.is_can_triple_tribute = true
    end
    return e1
end
function RushDuel.SummonProcedureConditionThree(filter, condition)
    return function(e, c, minc)
        if c == nil then
            return true
        end
        local tp = c:GetControler()
        local mg = RushDuel._private_get_tribute_group(filter, e, tp)
        return minc <= 3 and Duel.CheckTribute(c, 3, 3, mg) and (not condition or condition(c, e, tp))
    end
end
function RushDuel.SummonProcedureOperationThree(filter, operation)
    return function(e, tp, eg, ep, ev, re, r, rp, c)
        local mg = RushDuel._private_get_tribute_group(filter, e, tp)
        local sg = Duel.SelectTribute(tp, c, 3, 3, mg)
        c:SetMaterial(sg)
        Duel.Release(sg, REASON_SUMMON + REASON_MATERIAL)
        if operation then
            operation(e, tp, eg, ep, ev, re, r, rp, c, sg)
        end
    end
end

-- 改变攻击力的召唤效果
function RushDuel.SummonAttackChangeOperation(attack)
    return function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_BASE_ATTACK)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(attack)
        e1:SetReset(RESET_EVENT + 0xff0000)
        c:RegisterEffect(e1)
    end
end

-- 添加不用解放的妥协召唤手续 (改变原本攻击力)
function RushDuel.AddHealthySummonProcedure(card, desc, attack)
    return RushDuel.AddSummonProcedureZero(card, desc, nil, RushDuel.SummonAttackChangeOperation(attack))
end

-- 添加解放1只的妥协召唤手续 (改变原本攻击力)
function RushDuel.AddPrimeSummonProcedure(card, desc, attack, filter)
    return RushDuel.AddSummonProcedureOne(card, desc, nil, filter, RushDuel.SummonAttackChangeOperation(attack))
end

-- 上级召唤时的解放怪兽检测
function RushDuel.CreateAdvanceCheck(card, filter, count, flag)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MATERIAL_CHECK)
    e1:SetValue(function(e, c)
        local mg = c:GetMaterial()
        local ct = math.min(count, #mg)
        local label = 0
        if c:IsLevelBelow(6) and count == 2 then
            -- 当前等级小于解放要求
        elseif ct > 0 and mg:IsExists(filter, ct, nil, e) then
            label = flag
        end
        e:SetLabel(label)
    end)
    card:RegisterEffect(e1)
    local e2 = Effect.CreateEffect(card)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetLabelObject(e1)
    e2:SetCondition(RushDuel.AdvanceCheckCondition)
    e2:SetOperation(RushDuel.AdvanceCheckOperation)
    card:RegisterEffect(e2)
    return e1, e2
end
function RushDuel.AdvanceCheckCondition(e, tp, eg, ep, ev, re, r, rp)
    return e:GetLabelObject():GetLabel() ~= 0 and e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function RushDuel.AdvanceCheckOperation(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():RegisterFlagEffect(e:GetLabelObject():GetLabel(), RESET_EVENT + RESETS_STANDARD, 0, 1)
end

-- 获取召唤的解放数量
function RushDuel.GetTributeCount(card)
    if card:IsSummonType(SUMMON_VALUE_ZERO) then
        return 0
    elseif card:IsSummonType(SUMMON_VALUE_ONE) then
        return 1
    elseif card:IsSummonType(SUMMON_VALUE_TWO) then
        return 2
    elseif card:IsSummonType(SUMMON_VALUE_THREE) then
        return 3
    elseif card:IsLevelBelow(4) then
        return 0
    elseif card:IsLevelBelow(6) then
        return 1
    else
        return 2
    end
end

-- 分割上级召唤的解放怪兽
function RushDuel.SplitTribute(card, group)
    local g = group or card:GetMaterial()
    local normal, double = Group.CreateGroup(), Group.CreateGroup()
    g:ForEach(function(tc)
        if RushDuel.IsCanDoubleTribute(tc, card) then
            double:AddCard(tc)
        else
            normal:AddCard(tc)
        end
    end)
    return normal, double
end

-- 计算上级召唤时解放怪兽的合计值
function RushDuel.AdvanceMaterialCheck(card, effect, getter)
    local e = Effect.CreateEffect(card)
    e:SetType(EFFECT_TYPE_SINGLE)
    e:SetCode(EFFECT_MATERIAL_CHECK)
    e:SetLabelObject(effect)
    e:SetValue(RushDuel.AdvanceMaterialCheckValue(getter))
    card:RegisterEffect(e)
    return e
end
function RushDuel.AdvanceMaterialCheckValue(getter)
    return function(e, c)
        local g = c:GetMaterial()
        local mat = RushDuel.GetTributeCount(c)
        local count = #g
        local value1, value2 = 0, 0
        if count == 1 then
            value1 = getter(g:GetFirst(), count, mat) * mat
            value2 = value1
        elseif count == 2 then
            local tc1, tc2 = g:GetFirst(), g:GetNext()
            if mat == 2 then
                value1 = getter(tc1, count, mat) + getter(tc2, count, mat)
                value2 = value1
            elseif mat == 3 then
                local ng, dg = RushDuel.SplitTribute(c)
                if #dg == 1 then
                    value1 = getter(ng:GetFirst(), count, mat) + getter(dg:GetFirst(), count, mat) * 2
                    value2 = value1
                else
                    value1 = getter(tc1, count, mat) * 2 + getter(tc2, count, mat)
                    value2 = getter(tc1, count, mat) + getter(tc2, count, mat) * 2
                end
            end
        elseif count == 3 then
            value1 = g:GetSum(getter, count, mat)
            value2 = value1
        end
        e:GetLabelObject():SetLabel(value1, value2)
    end
end

-- 记录攻击表示上级召唤的状态
function RushDuel.CreateAdvanceSummonFlag(card, flag)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetLabel(flag)
    e1:SetCondition(RushDuel.AdvanceSummonFlagCondition)
    e1:SetOperation(RushDuel.AdvanceSummonFlagOperation)
    card:RegisterEffect(e1)
    return e1
end
function RushDuel.AdvanceSummonFlagCondition(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function RushDuel.AdvanceSummonFlagOperation(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():RegisterFlagEffect(e:GetLabel(), RESET_EVENT + RESETS_STANDARD, 0, 1)
end

-- 记录融合术召唤的状态
function RushDuel.CreateFusionSummonFlag(card, flag)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetLabel(flag)
    e1:SetCondition(RushDuel.FusionSummonFlagCondition)
    e1:SetOperation(RushDuel.FusionSummonFlagOperation)
    card:RegisterEffect(e1)
    return e1
end
function RushDuel.FusionSummonFlagCondition(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function RushDuel.FusionSummonFlagOperation(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():RegisterFlagEffect(e:GetLabel(), RESET_EVENT + RESETS_STANDARD, 0, 1)
end

-- 三重解放 (临时处理方法)
function RushDuel.CreateTripleTribute(source, card, desc, value, forced)
    local e1 = Effect.CreateEffect(source)
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_HAND, 0)
    e1:SetCondition(RushDuel.TripleTributeCondition)
    e1:SetTarget(RushDuel.TripleTributeTarget(value))
    e1:SetOperation(RushDuel.TripleTributeOperation)
    e1:SetValue(SUMMON_TYPE_ADVANCE + SUMMON_VALUE_THREE + SUMMON_VALUE_SELF)
    card:RegisterEffect(e1, forced)
    return e1
end
function RushDuel.TripleTributeCondition(e, c, minc)
    if c == nil then
        return true
    end
    local tc = e:GetHandler()
    local tp = c:GetControler()
    local mg = Duel.GetTributeGroup(c)
    return minc <= 3 and mg:IsContains(tc) and Duel.GetMZoneCount(tp, tc) > 0
end
function RushDuel.TripleTributeTarget(value)
    return function(e, c)
        return value(e, c) and c.is_can_triple_tribute
    end
end
function RushDuel.TripleTributeOperation(e, tp, eg, ep, ev, re, r, rp, c)
    local mg = Group.FromCards(e:GetHandler())
    c:SetMaterial(mg)
    Duel.Release(mg, REASON_SUMMON + REASON_MATERIAL)
end

-- 上级召唤所需的解放数量可以减少
function RushDuel.DecreaseSummonTribute(card, condition, value)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DECREASE_TRIBUTE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SINGLE_RANGE)
    if condition then
        e1:SetCondition(condition)
    end
    e1:SetRange(LOCATION_HAND)
    e1:SetValue(RushDuel.DecreaseSummonValue(value or 0x1))
    card:RegisterEffect(e1)
    return e1
end
function RushDuel.DecreaseSummonValue(value)
    return function(e, c)
        return value, 1
    end
end

-- 添加手卡特殊召唤手续
function RushDuel.AddHandSpecialSummonProcedure(card, desc, condition, target, operation, value, position)
    local e1 = Effect.CreateEffect(card)
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    if position == nil then
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    else
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SPSUM_PARAM)
        e1:SetTargetRange(position, 0)
    end
    e1:SetRange(LOCATION_HAND)
    if condition ~= nil then
        e1:SetCondition(condition)
    end
    if target ~= nil then
        e1:SetTarget(target)
    end
    if operation ~= nil then
        e1:SetOperation(operation)
    end
    if value ~= nil then
        e1:SetValue(value)
    end
    card:RegisterEffect(e1)
    return e1
end

-- 添加手卡特殊召唤手续: 把手卡1张卡给对方观看
function RushDuel.AddHandConfirmSpecialSummonProcedure(card, desc, filter, value, position)
    local con = RushDuel.HandConfirmSpecialSummonCondition(filter)
    local tg = RushDuel.HandConfirmSpecialSummonTarget(filter)
    local op = RushDuel.HandConfirmSpecialSummonOperation
    local e1 = RD.AddHandSpecialSummonProcedure(card, desc, con, tg, op, value, position)
    return e1
end
function RushDuel.HandConfirmSpecialSummonCondition(filter)
    return function(e, c)
        if c == nil then
            return true
        end
        local tp = c:GetControler()
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(filter, tp, LOCATION_HAND, 0, 1, nil, e, tp, c)
    end
end
function RushDuel.HandConfirmSpecialSummonTarget(filter)
    return function(e, tp, eg, ep, ev, re, r, rp, chk, c)
        local mg = Duel.GetMatchingGroup(filter, tp, LOCATION_HAND, 0, nil, e, tp, c)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
        local tc = mg:SelectUnselect(nil, tp, false, true, 1, 1)
        if tc then
            e:SetLabelObject(tc)
            return true
        else
            return false
        end
    end
end
function RushDuel.HandConfirmSpecialSummonOperation(e, tp, eg, ep, ev, re, r, rp, c)
    local tc = e:GetLabelObject()
    Duel.ConfirmCards(1 - tp, tc)
    Duel.ShuffleHand(tp)
end

-- 添加手卡特殊召唤手续: 把手卡送去墓地
function RushDuel.AddHandToGraveSpecialSummonProcedure(card, desc, filter, count, value, position)
    local con = RushDuel.HandToGraveSpecialSummonCondition(filter, count)
    local tg = RushDuel.HandToGraveSpecialSummonTarget(filter, count)
    local op = RushDuel.HandToGraveSpecialSummonOperation
    local e1 = RD.AddHandSpecialSummonProcedure(card, desc, con, tg, op, value, position)
    return e1
end
function RushDuel.HandToGraveSpecialSummonCondition(filter, count)
    return function(e, c)
        if c == nil then
            return true
        end
        local tp = c:GetControler()
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(filter, tp, LOCATION_HAND, 0, count, c, e, tp)
    end
end
function RushDuel.HandToGraveSpecialSummonTarget(filter, count)
    return function(e, tp, eg, ep, ev, re, r, rp, chk, c)
        local mg = Duel.GetMatchingGroup(filter, tp, LOCATION_HAND, 0, c, e, tp)
        local sg = RushDuel.Select(HINTMSG_TOGRAVE, tp, mg, nil, true, count, count)
        if sg and sg:GetCount() == count then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            return true
        else
            return false
        end
    end
end
function RushDuel.HandToGraveSpecialSummonOperation(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
	Duel.SendtoGrave(g, REASON_SPSUMMON)
	g:DeleteGroup()
end
