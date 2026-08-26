-- Rush Duel 极大
RushDuel = RushDuel or {}

TYPE_MAXIMUM = 0x8000 -- 极大怪兽
SUMMON_TYPE_MAXIMUM = 0x4a000000 -- 极大召唤

-- 初始化极大怪兽规则
function RushDuel.InitMaximum()
    -- 不可改变表示形式
    local e1 = Effect.GlobalEffect()
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SET_POSITION)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(RushDuel.MaximumMonster)
    e1:SetValue(POS_FACEUP_ATTACK)
    Duel.RegisterEffect(e1, 0)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    e2:SetValue(0)
    Duel.RegisterEffect(e2, 0)
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    e3:SetTarget(RushDuel.MaximumMonsterAtk)
    Duel.RegisterEffect(e3, 0)
    local e4 = e2:Clone()
    e4:SetCode(EFFECT_CANNOT_TURN_SET)
    Duel.RegisterEffect(e4, 0)
end
function RushDuel.MaximumMonster(e, c)
    return c:IsHasEffect(EFFECT_MAXIMUM_MODE) and c:GetOverlayCount() > 0
end
function RushDuel.MaximumMonsterAtk(e, c)
    return c:IsPosition(POS_FACEUP_ATTACK) and RushDuel.MaximumMonster(e, c)
end

-- 添加极大召唤手续
function RushDuel.AddMaximumProcedure(card, max_atk, left_code, right_code)
    if card:IsStatus(STATUS_COPYING_EFFECT) then
        return
    end
    -- 记录状态
    if card.maximum_attack == nil then
        local mt = getmetatable(card)
        mt.maximum_attack = max_atk
    end
    -- 极大召唤 手续
    RushDuel.AddHandSpecialSummonProcedure(card, HINTMSG_MAXSUMMON, RushDuel.MaximumSummonCondition(left_code, right_code), RushDuel.MaximumSummonTarget(left_code, right_code),
        RushDuel.MaximumSummonOperation(left_code, right_code), RushDuel.MaximumSummonValue, POS_FACEUP_ATTACK)
    -- 极大攻击力
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(RushDuel.MaximumMode)
    e1:SetValue(max_atk)
    card:RegisterEffect(e1)
    -- 占用3个主要怪兽区域
    local e2 = Effect.CreateEffect(card)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_MAX_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1, 0)
    e2:SetCondition(RushDuel.MaximumMode)
    e2:SetValue(1)
    card:RegisterEffect(e2)
end
function RushDuel.MaximumSummonFilter(c, e, tp, left_code, right_code)
    return c:IsCode(left_code, right_code)
end
function RushDuel.MaximumSummonCheck(g)
    return g:GetClassCount(Card.GetCode) == #g
end
function RushDuel.MaximumSummonCondition(left_code, right_code)
    return function(e, c, og, min, max)
        if c == nil then
            return true
        end
        local tp = c:GetControler()
        local mg = Duel.GetMatchingGroup(RushDuel.MaximumSummonFilter, tp, LOCATION_HAND, 0, nil, e, tp, left_code, right_code)
        local fg = Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
        return Duel.GetMZoneCount(tp, fg) > 0 and mg:CheckSubGroup(RushDuel.MaximumSummonCheck, 2, 2)
    end
end
function RushDuel.MaximumSummonTarget(left_code, right_code)
    return function(e, tp, eg, ep, ev, re, r, rp, chk, c, og, min, max)
        local mg = Duel.GetMatchingGroup(RushDuel.MaximumSummonFilter, tp, LOCATION_HAND, 0, nil, e, tp, left_code, right_code)
        local cancelable = Duel.GetCurrentChain() == 0
        local sg = RushDuel.Select(HINTMSG_MAXMATERIAL, tp, mg, RushDuel.MaximumSummonCheck, cancelable, 2, 2)
        if sg then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            return true
        else
            return false
        end
    end
end
function RushDuel.MaximumSummonOperation(left_code, right_code)
    return function(e, tp, eg, ep, ev, re, r, rp, c, og, min, max)
        local fg = Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
        Duel.SendtoGrave(fg, REASON_RULE)
        local mg = e:GetLabelObject()
        local left = mg:GetFirst()
        local right = mg:GetNext()
        if left:IsCode(right_code) then
            left, right = right, left
        end
        Duel.MoveToField(left, tp, tp, LOCATION_MZONE, POS_FACEUP_ATTACK, false, 0x2)
        Duel.MoveToField(right, tp, tp, LOCATION_MZONE, POS_FACEUP_ATTACK, false, 0x8)
        c:SetMaterial(mg)
        Duel.Overlay(c, mg)
        mg:DeleteGroup()
        RushDuel.EnableMaximumMode(c, RESET_EVENT + 0xff0000)
    end
end
function RushDuel.MaximumSummonValue(e, c)
    return SUMMON_TYPE_MAXIMUM, 0x4
end

-- 手动添加极大模式
function RushDuel.EnableMaximumMode(card, reset)
    local e = Effect.CreateEffect(card)
    e:SetType(EFFECT_TYPE_SINGLE)
    e:SetCode(EFFECT_MAXIMUM_MODE)
    e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e:SetRange(LOCATION_MZONE)
    e:SetReset(reset)
    card:RegisterEffect(e, true)
end
-- 极大模式
function RushDuel.MaximumMode(e)
    local c = e:GetHandler()
    return c:IsHasEffect(EFFECT_MAXIMUM_MODE) and c:GetOverlayCount() > 0
end
