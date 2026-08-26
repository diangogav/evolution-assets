-- Rush Duel 基础
RushDuel = RushDuel or {}

-- 特殊卡号
CARD_CODE_OTS = 120000010    -- OTS

-- 新种族
RACE_MAGICALKNIGHT = 0x4000000 -- 魔导骑士
RACE_HYDRAGON = 0x8000000 -- 多头龙
RACE_OMEGAPSYCHO = 0x10000000 -- 欧米茄念动力
RACE_CELESTIALWARRIOR = 0x20000000 -- 天界战士
RACE_GALAXY = 0x40000000 -- 银河
RACE_CYBORG = 0x80000000 -- 电子人

RACE_ALL = 0xffffffff

-- 特殊调整
EFFECT_LEGEND_CARD = 120000000 -- 传说卡标识 (改变卡名不影响)
EFFECT_CANNOT_SINGLE_TRIBUTE = 120170045 -- 监狱岛 大姐头巨岩 (与下面的效果结合变成不能上级召唤)
EFFECT_CANNOT_DOUBLE_TRIBUTE = 120120029 -- 魔将 雅灭鲁拉 (不能使用：双重解放)
EFFECT_PLAYER_CANNOT_ATTACK = 120155054 -- 幻刃封锁 (对方不能攻击时不能发动)
EFFECT_PLAYER_RACE_CANNOT_ATTACK = 120155055 -- 幻刃封锁 (不能选择不能攻击的种族)
EFFECT_PLAYER_CANNOT_ACTIVATE_TRAP = 120247013 -- 三角神迷火花 (整个回合不能发动陷阱)
EFFECT_PLAYER_CANNOT_ACTIVATE_TRAP_BATTLE = 120261022 -- 暗物质人偶·水母 (战斗阶段不能发动陷阱)
EFFECT_ATTACK_NOT_CHAIN_TRAP = 120140004 -- 不许始末战士 (攻击宣言时, 对方不能把陷阱卡发动)
EFFECT_DOUBLE_FUSION_MATERIAL = 120252004 -- 青眼幻像龙 (作为2只数量的融合术素材)
EFFECT_ONLY_FUSION_SUMMON = 120263031 -- 只能融合召唤 (奇迹融合)
EFFECT_MAXIMUM_MODE = 120272058 -- 通过效果变成极大模式 (时间机器)
EFFECT_CANNOT_TO_HAND_EFFECT = 120274001 -- 不会因效果回到手卡
EFFECT_CANNOT_TO_DECK_EFFECT = 120274002 -- 不会因效果回到卡组·额外卡组
EFFECT_CANNOT_CHANGE_POSITION_EFFECT = 120277011 -- 不会因效果改变表示形式
EFFECT_NO_COST_SEND_HAND_TO_GRAVE = 120294004 -- 不需要支付"把手卡送去墓地"的代价
EFFECT_CANNOT_BE_RITUAL_MATERIAL = 120294063 -- 不能作为仪式术召唤的素材
EFFECT_RITUAL_MATERIAL = 120300052 -- 额外的仪式素材
EFFECT_UNION_FUSION_MATERIAL = 120305005 -- XY-神龙炮 (作为2只不同卡名的融合术素材)
EFFECT_UNION_TARGET = 120306017 -- 同盟怪兽的装备要求

-- 标记
FLAG_SUMMON_TURN = 120000011 -- 召唤·特殊召唤的回合
FLAG_FLIP_TURN = 120000012 -- 反转的回合
FLAG_SUMMON_MAIN_PHASE = 120000013 -- 召唤·特殊召唤的主要阶段
FLAG_FLIP_MAIN_PHASE = 120000014 -- 反转的主要阶段
FLAG_ATTACK_ANNOUNCED = 120000021 -- 已经进行了攻击宣言, 不能向怪兽攻击的效果失效
FLAG_ATTACH_EFFECT = 120000022 -- 通过效果赋予的效果, 不能重复叠加
FLAG_CANNOT_ATTACK_NEXT_TURN = 120231059 -- 下个回合不能攻击
FLAG_CANNOT_ATTACK_UNTIL_NEXT_TURN = 120247006 -- 直到下个回合, 不能攻击
FLAG_HAS_DRAW_IN_MAIN_PHASE = 120261037 -- 已在主要阶段抽卡
FLAG_HAS_DRAW_IN_TURN = 120294034 -- 已在这个回合抽卡
FLAG_SKIP_MAIN_PHASE = 120306067 -- 跳过主要阶段, 部分陷阱卡不能发动
FLAG_MAX_ATTACK_TWICE_NEXT_TURN = 120285044 -- 下个回合, 对方最多攻击2次

-- 提示信息
HINTMSG_MAXSUMMON = Auxiliary.Stringid(120000000, 0) -- 极大召唤
HINTMSG_MAXMATERIAL = Auxiliary.Stringid(120000000, 1) -- 请选择要极大召唤的怪兽(3只)
HINTMSG_FUSION_MATERIAL = Auxiliary.Stringid(120000000, 2) --请选择要作为融合术召唤的素材的卡
HINTMSG_RITUAL_MATERIAL = Auxiliary.Stringid(120000000, 3) -- 请选择要作为仪式术召唤的素材的卡
HINTMSG_OPERATE_COUNT = Auxiliary.Stringid(120000000, 4) -- 请选择要操作的数量
HINTMSG_ANNOUNCE_MONSTER = Auxiliary.Stringid(120000001, 0) -- 宣言常规怪兽
HINTMSG_ANNOUNCE_LEGEND = Auxiliary.Stringid(120000001, 1) -- 宣言传说怪兽
HINTMSG_SUMMON_TURN = Auxiliary.Stringid(120000002, 0) -- 在这个回合召唤
HINTMSG_SPSUMMON_TURN = Auxiliary.Stringid(120000002, 1) -- 在这个回合特殊召唤
-- HINTMSG_FILP_TURN = Auxiliary.Stringid(120000002, 3) -- 在这个回合反转
HINTMSG_FILP_TURN = 1071 -- 在这个回合反转
HINTMSG_EFFECT_USED = Auxiliary.Stringid(120000002, 2) -- 已使用过效果

-- 异画卡: 复制Lua代码
function RushDuel.AlternateCard(code)
    Duel.LoadScript("c" .. code .. ".lua")
end

-- 创建效果: 这张卡不能特殊召唤
function RushDuel.CannotSpecialSummon(card, range)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    if range then
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(range)
    else
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    end
    card:RegisterEffect(e1)
    return e1
end
-- 创建效果: 这张卡不用融合术召唤不能特殊召唤
function RushDuel.OnlyFusionSummon(card)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(Auxiliary.fuslimit)
    card:RegisterEffect(e1)
    local e2 = Effect.CreateEffect(card)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ONLY_FUSION_SUMMON)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    card:RegisterEffect(e2)
    return e1, e2
end
-- 创建效果: 玩家对象的全局效果
function RushDuel.CreatePlayerTargetGlobalEffect(code, value)
    local e1 = Effect.GlobalEffect()
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(code)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1, 1)
    if value ~= nil then
        e1:SetValue(value)
    end
    Duel.RegisterEffect(e1, 0)
    return e1
end
-- 创建效果: 影响全场的全局效果
function RushDuel.CreateFieldGlobalEffect(is_continuous, code, operation, limit)
    local e1 = Effect.GlobalEffect()
    if is_continuous then
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    else
        e1:SetType(EFFECT_TYPE_FIELD)
    end
    if limit then
        e1:SetCountLimit(limit)
    end
    e1:SetCode(code)
    e1:SetOperation(operation)
    Duel.RegisterEffect(e1, 0)
    return e1
end
-- 创建效果: 在LP槽显示提示信息
function RushDuel.CreateHintEffect(e, desc, player, s_range, o_range, reset)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(desc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(s_range, o_range)
    e1:SetReset(reset)
    Duel.RegisterEffect(e1, player)
    return e1
end
-- 创建效果: Buff类效果
function RushDuel.CreateSingleEffect(e, desc, card, code, value, reset, forced)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(code)
    if desc ~= nil then
        e1:SetDescription(desc)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    end
    e1:SetLabel(FLAG_ATTACH_EFFECT)
    if value ~= nil then
        e1:SetValue(value)
    end
    if reset ~= nil then
        e1:SetReset(reset)
    end
    card:RegisterEffect(e1, forced)
    return e1
end
-- 创建效果: 选择效果
function RushDuel.CreateMultiChooseEffect(card, condition, cost, hint1, target1, operation1, hint2, target2, operation2)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    if condition ~= nil then
        e1:SetCondition(condition)
    end
    if cost ~= nil then
        e1:SetCost(cost)
    end
    local e2 = e1:Clone()
    e1:SetDescription(hint1)
    e2:SetDescription(hint2)
    e1:SetTarget(RushDuel.MultiChooseEffectTarget(target1))
    e2:SetTarget(RushDuel.MultiChooseEffectTarget(target2))
    e1:SetOperation(operation1)
    e2:SetOperation(operation2)
    card:RegisterEffect(e1)
    card:RegisterEffect(e2)
    return e1, e2
end
-- 创建效果: 选择效果
function RushDuel.CreateMultiChooseEffect3(card, condition, cost, hint1, target1, operation1, hint2, target2, operation2, hint3, target3, operation3)
    local e1 = Effect.CreateEffect(card)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    if condition ~= nil then
        e1:SetCondition(condition)
    end
    if cost ~= nil then
        e1:SetCost(cost)
    end
    local e2 = e1:Clone()
    local e3 = e1:Clone()
    e1:SetDescription(hint1)
    e2:SetDescription(hint2)
    e3:SetDescription(hint3)
    e1:SetTarget(RushDuel.MultiChooseEffectTarget(target1))
    e2:SetTarget(RushDuel.MultiChooseEffectTarget(target2))
    e3:SetTarget(RushDuel.MultiChooseEffectTarget(target3))
    e1:SetOperation(operation1)
    e2:SetOperation(operation2)
    e3:SetOperation(operation3)
    card:RegisterEffect(e1)
    card:RegisterEffect(e2)
    card:RegisterEffect(e3)
    return e1, e2, e3
end
function RushDuel.MultiChooseEffectTarget(target)
    if target ~= nil then
        return target
    else
        return function(e, tp, eg, ep, ev, re, r, rp, chk)
            if chk == 0 then
                return true
            end
            Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
        end
    end
end

-- 添加记述卡牌列表
function RushDuel.AddCodeList(card, ...)
    for _, list in ipairs {...} do
        local type = Auxiliary.GetValueType(list)
        if type == "number" then
            Auxiliary.AddCodeList(card, list)
        elseif type == "table" then
            Auxiliary.AddCodeList(card, table.unpack(list))
        end
    end
end

-- 获取附加的效果
function RushDuel.GetAttachEffects(card, code)
    local effects = {card:IsHasEffect(code)}
    local attachs = {}
    for i, effect in ipairs(effects) do
        if effect:GetLabel() == FLAG_ATTACH_EFFECT then
            table.insert(attachs, effect)
        end
    end
    return attachs
end

-- 获取效果值列表
function RushDuel.GetEffectValues(card, code)
    local effects = RushDuel.GetAttachEffects(card, code)
    local values = {}
    for i, effect in ipairs(effects) do
        values[i] = effect:GetValue()
    end
    return values
end

-- 抹平表
function RushDuel.FlatTable(...)
    local result = {}
    for _, item in ipairs({...}) do
        if type(item) == "table" then
            local datas = RushDuel.FlatTable(table.unpack(item))
            for _, data in ipairs(datas) do
                table.insert(result, data)
            end
        else
            table.insert(result, item)
        end
    end
    return result
end
-- 递归检查表
function RushDuel.FlatCheck(check, ...)
    for _, item in ipairs({...}) do
        if type(item) == "table" then
            if RushDuel.FlatCheck(check, table.unpack(item)) then
                return true
            end
        elseif check(item) then
            return true
        end
    end
    return false
end

-- 重载 ForEach
if not Group.ForEach then
    Group.ForEach = function(g, func, ...)
        local tc = g:GetFirst()
        while tc do
            func(tc, ...)
            tc = g:GetNext()
        end
    end
end
