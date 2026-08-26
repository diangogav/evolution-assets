-- Rush Duel 赋予Buff
RushDuel = RushDuel or {}

-- 赋予: 攻守升降
function RushDuel.AttachAtkDef(e, card, atk, def, reset, forced)
    if atk ~= nil and atk ~= 0 then
        RushDuel.CreateSingleEffect(e, nil, card, EFFECT_UPDATE_ATTACK, atk, reset, forced)
    end
    if def ~= nil and def ~= 0 and RushDuel.IsCanChangeDef(card) then
        RushDuel.CreateSingleEffect(e, nil, card, EFFECT_UPDATE_DEFENSE, def, reset, forced)
    end
end
-- 赋予: 等级升降
function RushDuel.AttachLevel(e, card, level, reset, forced)
    return RushDuel.CreateSingleEffect(e, nil, card, EFFECT_UPDATE_LEVEL, level, reset, forced)
end
-- 赋予: 直接攻击
function RushDuel.AttachDirectAttack(e, card, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_DIRECT_ATTACK, nil, reset, forced)
end
-- 赋予: 贯通
function RushDuel.AttachPierce(e, card, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_PIERCE, nil, reset, forced)
end
-- 赋予: 多次攻击
function RushDuel.AttachExtraAttack(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_EXTRA_ATTACK, value, reset, forced)
end
-- 赋予: 多次攻击 (怪兽限定)
function RushDuel.AttachExtraAttackMonster(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_EXTRA_ATTACK_MONSTER, value, reset, forced)
end
-- 赋予: 全体攻击
function RushDuel.AttachAttackAll(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_ATTACK_ALL, value, reset, forced)
end
-- 赋予: 战破重定向
function RushDuel.AttachBattleRedirect(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_BATTLE_DESTROY_REDIRECT, value, reset, forced)
end
-- 赋予: 双重解放
function RushDuel.AttachDoubleTribute(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_DOUBLE_TRIBUTE, value, reset, forced)
end
-- 赋予: 三重解放
function RushDuel.AttachTripleTribute(e, card, value, desc1, desc2, reset, forced)
    local e1 = RushDuel.CreateSingleEffect(e, desc1, card, EFFECT_TRIPLE_TRIBUTE, value, reset, forced)
    local e2 = RushDuel.CreateTripleTribute(e:GetHandler(), card, desc2, value, forced)
    e2:SetReset(reset)
    return e1, e2
end
-- 赋予: 使用对方的怪兽解放
function RushDuel.AttachOpponentTribute(e, card, flag, desc, reset, reset_player)
    card:RegisterFlagEffect(flag, reset, EFFECT_FLAG_CLIENT_HINT, 1, 0, desc)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetTargetRange(0, LOCATION_MZONE)
    e1:SetLabelObject(card)
    e1:SetTarget(function(e, c)
        return c == e:GetLabelObject() and card:GetFlagEffect(flag) ~= 0
    end)
    e1:SetValue(POS_FACEUP_ATTACK + POS_FACEDOWN_DEFENSE)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e2:SetTarget(Auxiliary.TargetBoolFunction(Card.IsType, TYPE_MONSTER))
    e2:SetTargetRange(LOCATION_HAND, 0)
    e2:SetLabelObject(e1)
    e2:SetReset(reset_player or reset)
    Duel.RegisterEffect(e2, e:GetHandlerPlayer())
    return e1, e2
end
-- 赋予: 效果战斗抗性
function RushDuel.AttachBattleIndes(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_INDESTRUCTABLE_BATTLE, value, reset, forced)
end
-- 赋予: 效果破坏抗性
function RushDuel.AttachEffectIndes(e, card, value, desc, reset, forced)
    local attach = RushDuel.CreateSingleEffect(e, desc, card, EFFECT_INDESTRUCTABLE_EFFECT, value, reset, forced)
    attach:SetOwnerPlayer(e:GetHandlerPlayer())
    return attach
end
-- 赋予: 战斗, 效果破坏抗性 (有次数限制)
function RushDuel.AttachIndesCount(e, card, count, value, desc, reset, forced)
    local e1 = RushDuel.CreateSingleEffect(e, desc, card, EFFECT_INDESTRUCTABLE_COUNT, value, reset, forced)
    e1:SetCountLimit(count)
    return e1
end
-- 赋予: 战斗不会让自己受到伤害
function RushDuel.AttachAvoidBattleDamage(e, card, desc, reset, forced)
    local e1 =  RushDuel.CreateSingleEffect(e, desc, card, EFFECT_AVOID_BATTLE_DAMAGE, 1, reset, forced)
    return e1
end
-- 赋予: 战斗不会让双方受到伤害
function RushDuel.AttachNoBattleDamage(e, card, desc, reset, forced)
    local e1 =  RushDuel.CreateSingleEffect(e, desc, card, EFFECT_AVOID_BATTLE_DAMAGE, 1, reset, forced)
    local e2 =  RushDuel.CreateSingleEffect(e, desc, card, EFFECT_NO_BATTLE_DAMAGE, 1, reset, forced)
    return e1, e2
end
-- 赋予: 攻击宣言时特效
function RushDuel.AttachAttackAnnounce(e, card, operation, desc, reset, forced)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetOperation(operation)
    if desc ~= nil then
        e1:SetDescription(desc)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    end
    e1:SetReset(reset)
    card:RegisterEffect(e1, forced)
    return e1
end
-- 赋予: 攻击宣言时, 对方不能把陷阱卡发动
function RushDuel.AttachAttackNotChainTrap(e, code, card, desc, reset, forced)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    if desc ~= nil then
        e1:SetDescription(desc)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    end
    e1:SetLabel(code)
    e1:SetOperation(RushDuel.AttackNotChainTrapOperation)
    e1:SetReset(reset)
    card:RegisterEffect(e1, forced)
    local e2 = RushDuel.CreateSingleEffect(e, desc, card, EFFECT_ATTACK_NOT_CHAIN_TRAP, nil, reset, forced)
    return e1, e2
end
-- 赋予: 回合结束时特效
function RushDuel.AttachEndPhase(e, card, player, code, operation, desc, once)
    if once then
        card:RegisterFlagEffect(0, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, code, desc)
    else
        card:RegisterFlagEffect(0, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, code, desc)
    end
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabelObject(card)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local tc = e:GetLabelObject()
        local fids = {tc:GetFlagEffectLabel(0)}
        for i = 1, #fids do
            if fids[i] == code then
                return true
            end
        end
        e:Reset()
        return false
    end)
    e1:SetOperation(operation)
    if once then
        e1:SetReset(RESET_PHASE + PHASE_END)
    end
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 赋予: 不能攻击
function RushDuel.AttachCannotAttack(e, card, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_CANNOT_ATTACK, nil, reset, forced)
end
-- 赋予: 不能直接攻击
function RushDuel.AttachCannotDirectAttack(e, card, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_CANNOT_DIRECT_ATTACK, nil, reset, forced)
end
-- 赋予: 不能选择攻击目标
function RushDuel.AttachCannotSelectBattleTarget(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_CANNOT_SELECT_BATTLE_TARGET, value, reset, forced)
end
-- 赋予: 不能用于上级召唤而解放
function RushDuel.AttachCannotTribute(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_UNRELEASABLE_SUM, value, reset, forced)
end
-- 赋予: 不能作为融合术召唤的素材
function RushDuel.AttachCannotBeFusionMaterial(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_CANNOT_BE_FUSION_MATERIAL, value, reset, forced)
end
-- 赋予: 不能作为仪式术召唤的素材
function RushDuel.AttachCannotBeRitualMaterial(e, card, value, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_CANNOT_BE_RITUAL_MATERIAL, value, reset, forced)
end
-- 赋予: 不能发动效果
function RushDuel.AttachCannotTrigger(e, card, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_CANNOT_TRIGGER, nil, reset, forced)
end
-- 赋予: 永续效果无效化
function RushDuel.AttachDisableContinuous(e, card, desc, reset, forced)
    return RushDuel.CreateSingleEffect(e, desc, card, EFFECT_DISABLE, nil, reset, forced)
end
-- 赋予: 变更原本攻守
function RushDuel.SetBaseAtkDef(e, card, atk, def, reset, forced)
    if atk ~= nil then
        RushDuel.CreateSingleEffect(e, nil, card, EFFECT_SET_BASE_ATTACK, atk, reset, forced)
    end
    if def ~= nil and RushDuel.IsCanChangeDef(card) then
        RushDuel.CreateSingleEffect(e, nil, card, EFFECT_SET_BASE_DEFENSE, def, reset, forced)
    end
end
-- 赋予: 交换原本攻守
function RushDuel.SwapBaseAtkDef(e, card, reset, forced)
    if RushDuel.IsCanChangeDef(card) then
        RushDuel.CreateSingleEffect(e, nil, card, EFFECT_SWAP_BASE_AD, nil, reset, forced)
    end
end
-- 赋予: 交换当前攻守
function RushDuel.SwapAtkDef(e, card, reset, forced)
    if RushDuel.IsCanChangeDef(card) then
        local atk = card:GetAttack()
        local def = card:GetDefense()
        RushDuel.CreateSingleEffect(e, nil, card, EFFECT_SET_ATTACK_FINAL, def, reset, forced)
        RushDuel.CreateSingleEffect(e, nil, card, EFFECT_SET_DEFENSE_FINAL, atk, reset, forced)
    end
end
-- 赋予: 改变属性
function RushDuel.ChangeAttribute(e, card, attribute, reset, forced)
    return RushDuel.CreateSingleEffect(e, nil, card, EFFECT_CHANGE_ATTRIBUTE, attribute, reset, forced)
end
-- 赋予: 改变种族
function RushDuel.ChangeRace(e, card, race, reset, forced)
    return RushDuel.CreateSingleEffect(e, nil, card, EFFECT_CHANGE_RACE, race, reset, forced)
end
-- 赋予: 改变卡名
function RushDuel.ChangeCode(e, card, code, reset, forced)
    return RushDuel.CreateSingleEffect(e, nil, card, EFFECT_CHANGE_CODE, code, reset, forced)
end
-- 赋予: 复制卡名
function RushDuel.CopyCode(e, card, target, reset, forced)
    local code = target:GetCode()
    return RushDuel.CreateSingleEffect(e, nil, card, EFFECT_CHANGE_CODE, code, reset, forced)
end
