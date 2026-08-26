-- Rush Duel 限制玩家操作
RushDuel = RushDuel or {}

-- 创建限制: 只能用特定类型的怪兽攻击
function RushDuel.CreateAttackLimitEffect(e, target, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(s_range, o_range)
    if target ~= nil then
        e1:SetTarget(target)
    end
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建限制: 不能攻击
function RushDuel.CreateCannotAttackEffect(e, desc, player, s_range, o_range, reset)
    local s_target, o_traget = 0, 0
    if s_range == 1 then
        s_target = LOCATION_MZONE
    end
    if o_range == 1 then
        o_traget = LOCATION_MZONE
    end
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(s_target, o_traget)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(desc)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_PLAYER_CANNOT_ATTACK)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e2:SetTargetRange(s_range, o_range)
    e2:SetReset(reset)
    Duel.RegisterEffect(e2, player)
    return e1, e2
end
-- 创建限制: 不能用某些种族攻击
function RushDuel.CreateRaceCannotAttackEffect(e, desc, race, player, s_range, o_range, reset)
    local s_target, o_traget = 0, 0
    if s_range == 1 then
        s_target = LOCATION_MZONE
    end
    if o_range == 1 then
        o_traget = LOCATION_MZONE
    end
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(s_target, o_traget)
    e1:SetTarget(function(e, c)
        return c:IsRace(race)
    end)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(desc)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_PLAYER_RACE_CANNOT_ATTACK)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e2:SetTargetRange(s_range, o_range)
    e2:SetValue(race)
    e2:SetReset(reset)
    Duel.RegisterEffect(e2, player)
    return e1, e2
end
-- 创建限制: 不能直接攻击
function RushDuel.CreateCannotDirectAttackEffect(e, target, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(s_range, o_range)
    if target ~= nil then
        e1:SetTarget(target)
    end
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建限制: 不能选择攻击目标
function RushDuel.CreateCannotSelectBattleTargetEffect(e, condition, target, value, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(s_range, o_range)
    e1:SetCondition(function(e)
        return not RushDuel.IsAttacking(e) and (not condition or condition(e))
    end)
    if target ~= nil then
        e1:SetTarget(target)
    end
    if value ~= nil then
        e1:SetValue(value)
    end
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建限制: 不能召唤怪兽
function RushDuel.CreateCannotSummonEffect(e, desc, target, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    if target ~= nil then
        e1:SetTarget(target)
    end
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建限制: 不能盖放怪兽
function RushDuel.CreateCannotSetMonsterEffect(e, desc, target, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_MSET)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    if target ~= nil then
        e1:SetTarget(target)
    end
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(s_range, o_range)
    e2:SetTarget(function(e, c, sump, sumtype, sumpos, targetp)
        return sumpos & POS_FACEDOWN > 0 and (not target or target(e, c))
    end)
    e2:SetReset(reset)
    Duel.RegisterEffect(e2, player)
    return e1, e2
end
-- 创建限制: 不能特殊召唤怪兽
function RushDuel.CreateCannotSpecialSummonEffect(e, desc, target, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    if target ~= nil then
        e1:SetTarget(target)
    end
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建限制: 不能表侧特殊召唤怪兽
function RushDuel.CreateCannotFaceupSpecialSummonEffect(e, desc, target, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    e1:SetTarget(function(e, c, sump, sumtype, sumpos, targetp)
        return sumpos & POS_FACEUP > 0 and (not target or target(e, c))
    end)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建限制: 只能用1只怪兽进行攻击
function RushDuel.CreateOnlySoleAttackEffect(e, code, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetFlagEffect(tp, code) == 0 then
            e:GetLabelObject():SetLabel(eg:GetFirst():GetFieldID())
            Duel.RegisterFlagEffect(tp, code, reset, 0, 1)
        end
    end)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetTargetRange(s_range, o_range)
    e2:SetCondition(function(e)
        return Duel.GetFlagEffect(e:GetHandlerPlayer(), code) ~= 0
    end)
    e2:SetTarget(function(e, c)
        return c:GetFieldID() ~= e:GetLabel()
    end)
    e2:SetReset(reset)
    Duel.RegisterEffect(e2, player)
    e1:SetLabelObject(e2)
end
-- 创建限制: 只能用1只怪兽进行直接攻击
function RushDuel.CreateOnlySoleDirectAttackEffect(e, code, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetAttackTarget() == nil and Duel.GetFlagEffect(tp, code) == 0 then
            e:GetLabelObject():SetLabel(eg:GetFirst():GetFieldID())
            Duel.RegisterFlagEffect(tp, code, reset, 0, 1)
        end
    end)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ATTACK_DISABLED)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if Duel.GetAttackTarget() == nil and Duel.GetFlagEffect(tp, code) ~= 0 then
            Duel.ResetFlagEffect(tp, code)
        end
    end)
    e2:SetReset(reset)
    Duel.RegisterEffect(e2, player)
    local e3 = Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetTargetRange(s_range, o_range)
    e3:SetCondition(function(e)
        return Duel.GetFlagEffect(e:GetHandlerPlayer(), code) ~= 0
    end)
    e3:SetTarget(function(e, c)
        return c:GetFieldID() ~= e:GetLabel()
    end)
    e3:SetReset(reset)
    Duel.RegisterEffect(e3, player)
    e1:SetLabelObject(e3)
end
-- 创建限制: 只能用这张卡进行攻击
function RushDuel.CreateOnlyThisAttackEffect(e, code, player, s_range, o_range, reset)
    RushDuel.CreateOnlyThatAttackEffect(e, e:GetHandler(), code, player, s_range, o_range, reset)
end
-- 创建限制: 只能用那只进行攻击
function RushDuel.CreateOnlyThatAttackEffect(e, card, code, player, s_range, o_range, reset)
    local flag = card:GetFieldID()
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetLabelObject(card)
    e1:SetTargetRange(s_range, o_range)
    e1:SetTarget(function(e, c)
        return not (c == e:GetLabelObject() and c:GetFlagEffect(code) ~= 0 and c:GetFlagEffect(flag) ~= 0)
    end)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    card:RegisterFlagEffect(code, RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET + reset, 0, 1)
    card:RegisterFlagEffect(flag, RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET + reset, 0, 1)
end
-- 创建限制: 只能攻击宣言X次
function RushDuel.CreateLimitAttackCountEffect(e, desc, count, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    e1:SetLabel(0, count)
    e1:SetCondition(function(e)
        local ct1, ct2 = e:GetLabel()
        return ct1 >= ct2
    end)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetLabelObject(e1)
    e2:SetOperation(function(e)
        local te = e:GetLabelObject()
        local ct1, ct2 = te:GetLabel()
        te:SetLabel(ct1 + 1, ct2)
    end)
    e2:SetReset(reset)
    Duel.RegisterEffect(e2, player)
    return e1, e2
end
-- 创建限制: 不能发动卡的效果
function RushDuel.CreateCannotActivateMix(e, desc, player, s_range, o_range, reset, value)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    e1:SetValue(value)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建限制: 不能把效果发动
function RushDuel.CreateCannotActivateEffect(e, desc, value, player, s_range, o_range, reset)
    return RushDuel.CreateCannotActivateMix(e, desc, player, s_range, o_range, reset, value)
end
-- 创建限制: 整个回合, 不能发动陷阱卡
function RushDuel.CreateCannotActivateTrapTurn(e, desc, player, s_range, o_range)
    local e1 = RushDuel.CreateCannotActivateMix(e, desc, player, s_range, o_range, RESET_PHASE + PHASE_END,
        function(e, re, tp)
            return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
        end)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_PLAYER_CANNOT_ACTIVATE_TRAP)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(s_range, o_range)
    e2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e2, player)
    return e1, e2
end
-- 创建限制: 战斗阶段, 不能发动陷阱卡
function RushDuel.CreateCannotActivateTrapBattle(e, desc, player, s_range, o_range)
    local e1 = RushDuel.CreateCannotActivateMix(e, desc, player, s_range, o_range, RESET_PHASE + PHASE_END,
        function(e, re, tp)
            local ph = Duel.GetCurrentPhase()
            return ph >= PHASE_BATTLE_START and ph <= PHASE_BATTLE and re:IsHasType(EFFECT_TYPE_ACTIVATE) and
                       re:IsActiveType(TYPE_TRAP)
        end)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_PLAYER_CANNOT_ACTIVATE_TRAP_BATTLE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(s_range, o_range)
    e2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e2, player)
    return e1, e2
end
-- 创建限制: 这个回合，自己不能把「卡名」的效果发动
function RushDuel.CreateCannotActivateSameCodeEffect(e, desc, flag, player, code)
	if Duel.GetFlagEffect(player, flag) ~= 0 then
        return nil
    end
    local e1 = RushDuel.CreateCannotActivateMix(e, desc, player, 1, 0, RESET_PHASE + PHASE_END,
        function(e, re, tp)
	        return re:GetHandler():IsCode(code)
        end)
	Duel.RegisterFlagEffect(player, flag, RESET_PHASE + PHASE_END, 0, 1)
    return e1
end
-- 创建限制: 特定卡的效果最多发动X次 (只能针对1名玩家)
function RushDuel.CreateActivateCountLimitEffect(e, desc, value, count, player, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1, 0)
    e1:SetLabel(0)
    e1:SetCondition(function(e)
        return e:GetLabel() >= count
    end)
    e1:SetValue(value)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetLabelObject(e1)
    e2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if ep == tp and value(e, re, tp, true) then
            local te = e:GetLabelObject()
            te:SetLabel(te:GetLabel() + 1)
        end
    end)
    Duel.RegisterEffect(e2, player)
    local e3 = e2:Clone()
    e3:SetCode(EVENT_CHAIN_NEGATED)
    e3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if ep == tp and value(e, re, tp, false) then
            local te = e:GetLabelObject()
            local ct = te:GetLabel() - 1
            if ct < 0 then
                ct = 0
            end
            te:SetLabel(ct)
        end
    end)
    return e1
end
-- 创建限制: 不会受到战斗伤害
function RushDuel.CreateNoBattleDamageEffect(e, desc, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    e1:SetValue(1)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建限制: 不会受到效果伤害
function RushDuel.CreateNoEffectDamageEffect(e, desc, value, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    e1:SetValue(value)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(e2, player)
    return e1, e2
end
