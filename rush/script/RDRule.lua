-- Rush Duel 规则
RushDuel = RushDuel or {}

-- 需要洗切手卡
RushDuel.NeedShuffleHand = {false, false}
-- 已发动过的卡名
RushDuel.ActivateCodes = {{}, {}}

-- 初始化
function RushDuel.Init()
    RushDuel.InitRule()
    RushDuel.InitFlag()
    RushDuel.OverrideFunction()
    -- 决斗开始
    RushDuel.CreateFieldGlobalEffect(true, EVENT_PHASE_START + PHASE_DRAW, function(e)
        -- 传说卡
        RushDuel.InitLegend()
        -- 先攻抽卡
        if not Auxiliary.Load2PickRule then
            Duel.Draw(0, 1, REASON_RULE)
        end
        e:Reset()
    end)
end
-- 初始化规则
function RushDuel.InitRule()
    -- 禁用最左与最右列
    RushDuel.CreateFieldGlobalEffect(false, EFFECT_DISABLE_FIELD, function()
        return 0x11711171
    end)
    -- 抽卡阶段, 抽卡至5张, 超过5张时改为抽1张
    RushDuel.CreatePlayerTargetGlobalEffect(EFFECT_DRAW_COUNT, function()
        return math.max(1, 5 - Duel.GetFieldGroupCount(Duel.GetTurnPlayer(), LOCATION_HAND, 0))
    end)
    -- 抽卡阶段抽卡后, 洗切手卡
    local e1 = Effect.GlobalEffect()
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_DRAW)
    e1:SetCondition(function()
        return Duel.GetCurrentPhase() == PHASE_DRAW
    end)
    e1:SetOperation(function()
        local tp = Duel.GetTurnPlayer()
        if RushDuel.NeedShuffleHand[tp + 1] then
            Duel.ShuffleHand(tp)
        end
        RushDuel.NeedShuffleHand[1] = false
        RushDuel.NeedShuffleHand[2] = false
    end)
    Duel.RegisterEffect(e1, 0)
    -- 跳过准备阶段
    RushDuel.CreatePlayerTargetGlobalEffect(EFFECT_SKIP_SP)
    -- 召唤次数无限制
    RushDuel.CreatePlayerTargetGlobalEffect(EFFECT_SET_SUMMON_COUNT_LIMIT, 100)
    -- 场上的怪兽的效果强制1回合1次
    local function get_effect_owner_code(e)
        if e:GetType() & EFFECT_TYPE_XMATERIAL == EFFECT_TYPE_XMATERIAL then
            -- 极大怪兽的L/R部分的效果分开计算
            return e:GetLabel()
        else
            return e:GetOwner():GetOriginalCode()
        end
    end
    RushDuel.CreatePlayerTargetGlobalEffect(EFFECT_CANNOT_ACTIVATE, function(e, re, tp)
        return re:GetHandler():GetFlagEffect(get_effect_owner_code(re)) ~= 0
    end)
    RushDuel.CreateFieldGlobalEffect(true, EVENT_CHAIN_SOLVING, function(e, tp, eg, ep, ev, re, r, rp)
        local te = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_EFFECT)
        local tc=te:GetHandler()
        local code = get_effect_owner_code(te)
        tc:RegisterFlagEffect(code, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0, HINTMSG_EFFECT_USED)
        RushDuel.ActivateCodes[ep + 1][tc:GetCode()] = true
    end)
    -- 同一时点只能发动一张陷阱卡
    local function is_trap(e)
        return e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:IsActiveType(TYPE_TRAP)
    end
    local function tarp_limit(e, rp, tp)
        return not is_trap(e)
    end
    RushDuel.CreateFieldGlobalEffect(true, EVENT_CHAINING, function(e, tp, eg, ep, ev, re, r, rp)
        if is_trap(re) then
            Duel.SetChainLimit(tarp_limit)
        end
    end)
    -- 没有主要阶段2
    RushDuel.CreatePlayerTargetGlobalEffect(EFFECT_SKIP_M2)
    --RushDuel.CreatePlayerTargetGlobalEffect(EFFECT_CANNOT_M2)
    -- 手卡无限制
    RushDuel.CreatePlayerTargetGlobalEffect(EFFECT_HAND_LIMIT, 100)
    -- 结束阶段重置计数
    RushDuel.CreateFieldGlobalEffect(true, EVENT_PHASE_START + PHASE_DRAW, function(e, tp, eg, ep, ev, re, r, rp)
        RushDuel.ActivateCodes = {{}, {}}
    end, 1)
    -- 极大怪兽
    RushDuel.InitMaximum()
end
-- 初始化标记
function RushDuel.InitFlag()
    local reg_summon = function(e, tp, eg, ep, ev, re, r, rp)
        eg:ForEach(function(tc)
            tc:RegisterFlagEffect(FLAG_SUMMON_TURN, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0, HINTMSG_SUMMON_TURN)
            if RushDuel.IsMainPhase() then
                tc:RegisterFlagEffect(FLAG_SUMMON_MAIN_PHASE, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_MAIN1 + PHASE_MAIN2, 0, 1)
            end
        end)
    end
    local reg_spsummon = function(e, tp, eg, ep, ev, re, r, rp)
        eg:ForEach(function(tc)
            tc:RegisterFlagEffect(FLAG_SUMMON_TURN, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0, HINTMSG_SPSUMMON_TURN)
            if RushDuel.IsMainPhase() then
                tc:RegisterFlagEffect(FLAG_SUMMON_MAIN_PHASE, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_MAIN1 + PHASE_MAIN2, 0, 1)
            end
        end)
    end
    local reg_flip = function(e, tp, eg, ep, ev, re, r, rp)
        eg:ForEach(function(tc)
            tc:RegisterFlagEffect(FLAG_FLIP_TURN, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0, HINTMSG_FILP_TURN)
            if RushDuel.IsMainPhase() then
                tc:RegisterFlagEffect(FLAG_FLIP_MAIN_PHASE, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_MAIN1 + PHASE_MAIN2, 0, 1)
            end
        end)
    end
    local reg_attack = function(e, tp, eg, ep, ev, re, r, rp)
        Duel.RegisterFlagEffect(rp, FLAG_ATTACK_ANNOUNCED, RESET_PHASE + PHASE_DAMAGE, 0, 1)
    end
    local reg_draw = function(e, tp, eg, ep, ev, re, r, rp)
        local ph = Duel.GetCurrentPhase()
        if ph == PHASE_MAIN1 or ph == PHASE_MAIN2 then
            Duel.RegisterFlagEffect(ep, FLAG_HAS_DRAW_IN_MAIN_PHASE, RESET_PHASE + PHASE_MAIN1 + PHASE_MAIN2, 0, 1)
        end
        Duel.RegisterFlagEffect(ep, FLAG_HAS_DRAW_IN_TURN, RESET_PHASE + PHASE_END, 0, 1)
    end
    RushDuel.CreateFieldGlobalEffect(true, EVENT_SUMMON_SUCCESS, reg_summon)
    RushDuel.CreateFieldGlobalEffect(true, EVENT_SPSUMMON_SUCCESS, reg_spsummon)
    RushDuel.CreateFieldGlobalEffect(true, EVENT_FLIP, reg_flip)
    RushDuel.CreateFieldGlobalEffect(true, EVENT_ATTACK_ANNOUNCE, reg_attack)
    RushDuel.CreateFieldGlobalEffect(true, EVENT_DRAW, reg_draw)
end
-- 重载函数
function RushDuel.OverrideFunction()
    -- "那之后" 不打断时点
    Duel.BreakEffect = function()
    end
end
