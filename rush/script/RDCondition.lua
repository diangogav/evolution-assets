-- Rush Duel 条件
RushDuel = RushDuel or {}

-- 条件: 卡片是通常魔法卡
function RushDuel.IsNormalSpell(card)
    return card:GetType()==TYPE_SPELL or card:GetType()==TYPE_SPELL+TYPE_LEGEND
end
-- 条件: 卡片是否处于"极大模式"
function RushDuel.IsMaximumMode(card)
    return card:IsLocation(LOCATION_MZONE) and card:IsSummonType(SUMMON_TYPE_MAXIMUM) and card:GetOverlayCount() > 0
end
-- 条件: 离场前是否处于"极大模式"
function RushDuel.IsPreviousMaximumMode(card)
    return card:IsType(TYPE_MAXIMUM) and card:IsSummonType(SUMMON_TYPE_MAXIMUM) and card:GetPreviousOverlayCountOnField()>0
end
-- 条件: 玩家的主要阶段
function RushDuel.IsMainPhase()
    local player = Duel.GetTurnPlayer()
    if Duel.GetFlagEffect(player, FLAG_SKIP_MAIN_PHASE) ~= 0 then
        return false
    end
    local ph = Duel.GetCurrentPhase()
    return ph == PHASE_MAIN1 or ph == PHASE_MAIN2
end
-- 条件: 这张卡召唤的回合
function RushDuel.IsSummonTurn(card)
    return card:IsReason(REASON_SUMMON) and card:IsStatus(STATUS_SUMMON_TURN) and card:GetFlagEffect(FLAG_SUMMON_TURN) ~= 0
end
-- 条件: 这张卡攻击表示上级召唤的回合
function RushDuel.IsAdvanceSummonTurn(card)
    return RushDuel.IsSummonTurn(card) and card:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 条件: 这张卡特殊召唤的回合
function RushDuel.IsSpecialSummonTurn(card)
    return card:IsReason(REASON_SPSUMMON) and card:IsStatus(STATUS_SPSUMMON_TURN) and card:GetFlagEffect(FLAG_SUMMON_TURN) ~= 0
end
-- 条件: 这张卡特殊召唤的自己主要阶段
function RushDuel.IsSpecialSummonMainPhase(card, type)
    return card:IsReason(REASON_SPSUMMON) and card:IsStatus(STATUS_SPSUMMON_TURN) and card:GetFlagEffect(FLAG_SUMMON_MAIN_PHASE) ~= 0
        and (not type or card:IsSummonType(type))
end
-- 条件: 这张卡召唤·特殊召唤的自己主要阶段
function RushDuel.IsSummonOrSpecialSummonMainPhase(card)
    return card:IsReason(REASON_SUMMON + REASON_SPSUMMON) and card:IsStatus(STATUS_SUMMON_TURN + STATUS_SPSUMMON_TURN)
        and card:GetFlagEffect(FLAG_SUMMON_MAIN_PHASE) ~= 0
end
-- 条件: 这张卡反转的自己主要阶段
function RushDuel.IsFlipMainPhase(card)
    return card:GetFlagEffect(FLAG_FLIP_MAIN_PHASE) ~= 0
end
-- 条件: 处于攻击中
function RushDuel.IsAttacking(effect)
    local player = Duel.GetTurnPlayer()
    return Duel.GetFlagEffect(player, FLAG_ATTACK_ANNOUNCED) ~= 0
end
-- 条件: 玩家的LP在 lp 以上
function RushDuel.IsLPAbove(player, lp)
    return Duel.GetLP(player) >= lp
end
-- 条件: 玩家的LP在 lp 以下
function RushDuel.IsLPBelow(player, lp)
    return Duel.GetLP(player) <= lp
end
-- 条件: 玩家的LP比对方少 lp 以上
function RushDuel.IsLPBelowOpponent(player, lp)
    return Duel.GetLP(player) <= Duel.GetLP(1 - player) - (lp or 0)
end
-- 条件: 玩家在这次主要阶段没有抽卡
function RushDuel.IsPlayerNoDrawInThisMain(player)
    return Duel.GetFlagEffect(player, FLAG_HAS_DRAW_IN_MAIN_PHASE) == 0
end
-- 条件: 玩家在这个回合有抽卡
function RushDuel.IsPlayerDrawInThisTurn(player)
    return Duel.GetFlagEffect(player, FLAG_HAS_DRAW_IN_TURN) ~= 0
end
-- 条件: 玩家在这个回合没有发动过特定卡名的效果
function RushDuel.IsPlayerNoActivateInThisTurn(player, code)
    local codes = RushDuel.ActivateCodes[player + 1] or {}
    return not codes[code]
end
-- 条件: 是宣言的种类
function RushDuel.IsAnnounceType(card)
    local announce = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
    return (announce == 0 and card:IsType(TYPE_MONSTER)) or (announce == 1 and card:IsType(TYPE_SPELL)) or (announce == 2 and card:IsType(TYPE_TRAP))
end
-- 条件: 守备力为 def
function RushDuel.IsDefense(card, def)
    return card:IsDefense(def) and not RushDuel.IsMaximumMode(card)
end
-- 条件: 守备力在 def 以上
function RushDuel.IsDefenseAbove(card, def)
    return card:IsDefenseAbove(def) and not RushDuel.IsMaximumMode(card)
end
-- 条件: 守备力在 def 以下
function RushDuel.IsDefenseBelow(card, def)
    return card:IsDefenseBelow(def) and not RushDuel.IsMaximumMode(card)
end
-- 条件: 原本守备力为 def
function RushDuel.IsBaseDefense(card, def)
    return card:GetBaseDefense() == def and not RushDuel.IsMaximumMode(card)
end
-- 条件: 可否改变守备力
function RushDuel.IsCanChangeDef(card)
    return card:IsDefenseAbove(0) and not RushDuel.IsMaximumMode(card)
end
-- 条件: 可否改变表示形式
function RushDuel.IsCanChangePosition(card, effect, player, reason)
    if not card:IsCanChangePosition() or RushDuel.IsMaximumMode(card) then
        return false
    end
    return true
end
-- 条件: 可以改变卡名
function RushDuel.IsCanChangeCode(card, code)
    return not card:IsCode(code)
end
-- 条件: 可以作为Cost回到手卡或者额外卡组
function RushDuel.IsAbleToHandOrExtraAsCost(card)
    return card:IsAbleToHandAsCost() or card:IsAbleToExtraAsCost()
end
-- 条件: 可否特殊召唤
function RushDuel.IsCanBeSpecialSummoned(card, effect, player, position)
    return card:IsCanBeSpecialSummoned(effect, 0, player, false, false, position)
end
-- 条件: 可否加入手卡或特殊召唤
function RushDuel.IsAbleToHandOrSpecialSummon(card, effect, player, position)
    return card:IsAbleToHand() or (Duel.GetLocationCount(player, LOCATION_MZONE) > 0 and RushDuel.IsCanBeSpecialSummoned(card, effect, player, position))
end
-- 条件: 是否拥有永续效果
function RushDuel.IsHasContinuousEffect(card)
    local has_effect = card.continuous_effect
    if RushDuel.IsMaximumMode(card) then
        card:GetOverlayGroup():ForEach(function(tc)
            has_effect = has_effect or tc.continuous_effect
        end)
    end
    return has_effect
end
-- 条件: 当前的融合效果的卡片编号
function RushDuel.IsFusionEffectCode(code)
    if RD.CurrentFusionEffect then
        return RD.CurrentFusionEffect:GetHandler():IsCode(code)
    end
    return false
end
-- 条件: 是否可以作为2只数量的融合术素材
function RushDuel.IsCanBeDoubleFusionMaterial(card, code)
    local effects = {card:IsHasEffect(EFFECT_DOUBLE_FUSION_MATERIAL)}
    for i, effect in ipairs(effects) do
        local value = effect:GetValue()
        if value == code then
            return true
        end
    end
    return false
end
-- 条件: 是否可以作为2只不同卡名的融合术素材
function RushDuel.IsCanBeUnionFusionMaterial(card, code)
    local effects = {card:IsHasEffect(EFFECT_UNION_FUSION_MATERIAL)}
    for i, effect in ipairs(effects) do
        local code1, code2 = effect:GetLabel()
        if code1 == code or code2 == code then
            return true
        end
    end
    return false
end
-- 条件: 是否可以作为2只不同卡名的融合术素材
function RushDuel.IsCanBeUnionFusionMaterial2(card, code1, code2)
    local effects = {card:IsHasEffect(EFFECT_UNION_FUSION_MATERIAL)}
    for i, effect in ipairs(effects) do
        local c1, c2 = effect:GetLabel()
        if (c1 == code1 and c2 == code2) or (c1 == code2 and c2 == code1) then
            return true
        end
    end
    return false
end
-- 条件: 可以宣言融合素材的卡名
function RushDuel.IsCanAnnounceFusionMaterialCode(card, target)
    local codes = RushDuel.GetAnnouncableFusionMaterialCodes(card, target)
    return #codes > 0
end

-- 条件: 位置变化前的控制者
function RushDuel.IsPreviousControler(card, player)
    return card:GetPreviousControler() == player
end
-- 条件: 位置变化前的类型
function RushDuel.IsPreviousCode(card, code)
    return card:GetPreviousCodeOnField() == code
end
-- 条件: 位置变化前的类型
function RushDuel.IsPreviousType(card, type)
    return (card:GetPreviousTypeOnField() & type) ~= 0
end
-- 条件: 位置变化前的属性
function RushDuel.IsPreviousAttribute(card, attr)
    return (card:GetPreviousAttributeOnField() & attr) ~= 0
end
-- 条件: 位置变化前的种族
function RushDuel.IsPreviousRace(card, race)
    return (card:GetPreviousRaceOnField() & race) ~= 0
end
-- 条件: 位置变化前的等级
function RushDuel.IsPreviousLevel(card, level)
    return card:GetPreviousLevelOnField() == level
end
-- 条件: 位置变化前的等级大于
function RushDuel.IsPreviousLevelAbove(card, level)
    return card:GetPreviousLevelOnField() >= level
end
-- 条件: 位置变化前的等级小于
function RushDuel.IsPreviousLevelBelow(card, level)
    return card:GetPreviousLevelOnField() > 0 and card:GetPreviousLevelOnField() <= level
end
-- 条件: 位置变化前的攻击力
function RushDuel.IsPreviousAttack(card, atk)
    return card:GetPreviousAttackOnField() == atk
end
-- 条件: 位置变化前的攻击力大于
function RushDuel.IsPreviousAttackAbove(card, atk)
    return card:GetPreviousAttackOnField() >= atk
end

-- 条件: 可以攻击
function RushDuel.IsCanAttack(card)
    return not card:IsHasEffect(EFFECT_CANNOT_ATTACK)
end
-- 条件: 被赋予了效果
function RushDuel.IsHasAttachEffect(card, code)
    return #RushDuel.GetAttachEffects(card, code) ~= 0
end
-- 条件: 可否赋予效果 - 直接攻击
function RushDuel.IsCanAttachDirectAttack(card)
    return RushDuel.IsCanAttack(card) and not card:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) and not RushDuel.IsHasAttachEffect(card, EFFECT_DIRECT_ATTACK)
end
-- 条件: 可否赋予效果 - 贯通
function RushDuel.IsCanAttachPierce(card)
    return RushDuel.IsCanAttack(card) and not RushDuel.IsHasAttachEffect(card, EFFECT_PIERCE)
end
-- 条件: 可否赋予效果 - 多次攻击
function RushDuel.IsCanAttachExtraAttack(card, value)
    if not RushDuel.IsCanAttack(card) then
        return false
    end
    local values = RushDuel.GetEffectValues(card, EFFECT_EXTRA_ATTACK)
    for _, val in ipairs(values) do
        if val >= value then
            return false
        end
    end
    return true
end
-- 条件: 可否赋予效果 - 多次攻击 (怪兽限定)
function RushDuel.IsCanAttachExtraAttackMonster(card, value)
    if not RushDuel.IsCanAttack(card) then
        return false
    end
    local values = RushDuel.GetEffectValues(card, EFFECT_EXTRA_ATTACK_MONSTER)
    for _, val in ipairs(values) do
        if val >= value then
            return false
        end
    end
    return true
end
-- 条件: 可否赋予效果 - 全体攻击
function RushDuel.IsCanAttachAttackAll(card, value)
    return RushDuel.IsCanAttack(card) and not RushDuel.IsHasAttachEffect(card, EFFECT_ATTACK_ALL)
end
-- 条件: 可否赋予效果 - 双重解放
function RushDuel.IsCanAttachDoubleTribute(card, value)
    if Duel.IsPlayerAffectedByEffect(card:GetControler(), EFFECT_CANNOT_DOUBLE_TRIBUTE) then
        return false
    end
    if card:IsHasEffect(EFFECT_UNRELEASABLE_SUM) then
        return false
    end
    local values = RushDuel.GetEffectValues(card, EFFECT_DOUBLE_TRIBUTE)
    return RushDuel.CheckValueDoubleTribute(values, value)
end
-- 条件: 可否赋予效果 - 三重解放
function RushDuel.IsCanAttachTripleTribute(card, value)
    if Duel.IsPlayerAffectedByEffect(card:GetControler(), EFFECT_CANNOT_DOUBLE_TRIBUTE) then
        return false
    end
    if card:IsHasEffect(EFFECT_UNRELEASABLE_SUM) then
        return false
    end
    local values = RushDuel.GetEffectValues(card, EFFECT_TRIPLE_TRIBUTE)
    return RushDuel.CheckValueDoubleTribute(values, value)
end
-- 条件: 可否赋予效果 - 使用对方的怪兽解放
function RushDuel.IsCanAttachOpponentTribute(card, player, flag)
    if Duel.IsPlayerAffectedByEffect(player, EFFECT_CANNOT_SINGLE_TRIBUTE) and Duel.IsPlayerAffectedByEffect(player, EFFECT_CANNOT_DOUBLE_TRIBUTE) then
        return false
    end
    return not card:IsHasEffect(EFFECT_UNRELEASABLE_SUM) and card:GetFlagEffect(flag) == 0
end
-- 条件: 可否赋予效果 - 战斗破坏抗性
function RushDuel.IsCanAttachBattleIndes(card, value)
    local values = RushDuel.GetEffectValues(card, EFFECT_INDESTRUCTABLE_BATTLE)
    for _, val in ipairs(values) do
        if val == 1 then
            return false
        end
    end
    return true
end
-- 条件: 可否赋予效果 - 效果破坏抗性
function RushDuel.IsCanAttachEffectIndes(card, player, value)
    local effects = RushDuel.GetAttachEffects(card, EFFECT_INDESTRUCTABLE_EFFECT)
    return RushDuel.CheckValueEffectIndesType(player, effects, value)
end
-- 条件: 可否赋予效果 - 攻击宣言时, 对方不能把陷阱卡发动
function RushDuel.IsCanAttachAttackNotChainTrap(card)
    local player = 1 - card:GetControler()
    return RushDuel.IsPlayerCanActivateTrapBattle(player) and RushDuel.IsCanAttack(card) and not RushDuel.IsHasAttachEffect(card, EFFECT_ATTACK_NOT_CHAIN_TRAP)
end
-- 条件: 可否赋予效果 - 永续效果无效化
function RushDuel.IsCanAttachDisableContinuous(card)
    return RushDuel.IsHasContinuousEffect(card) and not card:IsHasEffect(EFFECT_DISABLE)
end
-- 条件: 可否赋予效果 - 不能发动效果
function RushDuel.IsCanAttachCannotTrigger(card)
    return not card:IsHasEffect(EFFECT_CANNOT_TRIGGER)
end

-- 条件: 可以被改变种族
function RushDuel.IsCanChangeRace(card, race)
    local effects = {card:IsHasEffect(EFFECT_CHANGE_RACE)}
    local curret = card:GetOriginalRace()
    local active = nil
    for i, effect in ipairs(effects) do
        local value = effect:GetValue()
        if value ~= curret or effect:GetLabel() == FLAG_ATTACH_EFFECT then
            curret = value
            active = effect
        end
    end
    -- 被改变了种族
    if active then
        if active:GetLabel() ~= FLAG_ATTACH_EFFECT then
            -- 不是赋予类效果，可以随便更改
            return true
        else
            return not card:IsRace(curret)
        end
    else
        return not card:IsRace(race)
    end
end

-- 条件: 是否可以使用双重解放
function RushDuel.IsCanDoubleTribute(card, target)
    local effects = {card:IsHasEffect(EFFECT_DOUBLE_TRIBUTE)}
    for i, effect in ipairs(effects) do
        local value = effect:GetValue()
        if value == 1 then
            return true
        elseif value(effect, target) then
            return true
        end
    end
    return false
end

-- 条件: 可以改变攻击对象
function RushDuel.IsCanChangeAttackTarget(card)
    local g = card:GetAttackableTarget()
    return #g > 1
end

-- 条件: 玩家是否能够使用特定种族进行攻击
function RushDuel.IsPlayerCanUseRaceAttack(player, race)
    if Duel.IsPlayerAffectedByEffect(player, EFFECT_PLAYER_CANNOT_ATTACK) then
        return false
    end
    local effects = {Duel.IsPlayerAffectedByEffect(player, EFFECT_PLAYER_RACE_CANNOT_ATTACK)}
    for i, effect in ipairs(effects) do
        if (race & effect:GetValue()) == race then
            return false
        end
    end
    return true
end
-- 条件: 玩家是否能够发动陷阱卡
function RushDuel.IsPlayerCanActivateTrap(player)
    return not Duel.IsPlayerAffectedByEffect(player, EFFECT_PLAYER_CANNOT_ACTIVATE_TRAP)
end
-- 条件: 玩家是否能够在战斗阶段发动陷阱卡
function RushDuel.IsPlayerCanActivateTrapBattle(player)
    return RushDuel.IsPlayerCanActivateTrap(player) and not Duel.IsPlayerAffectedByEffect(player, EFFECT_PLAYER_CANNOT_ACTIVATE_TRAP_BATTLE)
end

-- 额外条件: 最后的操作是否包含某种卡
function RushDuel.IsOperatedGroupExists(filter, count, expect)
    return filter == nil or Duel.GetOperatedGroup():IsExists(filter, count, expect)
end

-- 条件: 卡片组全部满足条件与数量
function RushDuel.GroupAllCount(group, filter, count, ...)
    return group:GetCount() == count and group:FilterCount(filter, nil, ...) == count
end

-- 通用条件: 这张卡召唤的回合
function RushDuel.ConditionSummonTurn(e)
	return RushDuel.IsSummonTurn(e:GetHandler())
end
-- 通用条件: 这张卡召唤·特殊召唤的自己主要阶段
function RushDuel.ConditionSummonOrSpecialSummonMainPhase(e)
	return RushDuel.IsSummonOrSpecialSummonMainPhase(e:GetHandler())
end
-- 通用条件: 这张卡反转的自己主要阶段
function RushDuel.ConditionFlipMainPhase(e)
	return RushDuel.IsFlipMainPhase(e:GetHandler())
end