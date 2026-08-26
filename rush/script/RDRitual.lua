-- Rush Duel 仪式
RushDuel = RushDuel or {}
-- 当前的仪式效果
RushDuel.CurrentRitualEffect = nil
-- 额外的仪式素材过滤
RushDuel.RitualExtraMaterialFilter = nil
-- 额外的仪式检测
RushDuel.RitualExtraChecker = nil
-- 最小仪式素材数
RushDuel.MinRitualMaterialCount = nil
-- 最大仪式素材数
RushDuel.MaxRitualMaterialCount = nil

-- 原本等级相同
RITUAL_ORIGINAL_LEVEL_EQUAL = 1
-- 原本等级超过
RITUAL_ORIGINAL_LEVEL_GREATER = 2
-- 当前等级相同
RITUAL_CURRENT_LEVEL_EQUAL = 3
-- 当前等级超过
RITUAL_CURRENT_LEVEL_GREATER = 4
-- 原本攻击相同
RITUAL_ORIGINAL_ATTACK_EQUAL = 5
-- 原本攻击超过
RITUAL_ORIGINAL_ATTACK_GREATER = 6
-- 当前攻击相同
RITUAL_CURRENT_ATTACK_EQUAL = 7
-- 当前攻击超过
RITUAL_CURRENT_ATTACK_GREATER = 8

-- 添加仪式手续
function RushDuel.AddRitualProcedure(card)
    if card:IsStatus(STATUS_COPYING_EFFECT) then
        return
    end
    local e = Effect.CreateEffect(card)
    e:SetType(EFFECT_TYPE_SINGLE)
    e:SetCode(EFFECT_REMOVE_TYPE)
    e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_SET_AVAILABLE)
    e:SetRange(0xff)
    e:SetValue(TYPE_FUSION)
    card:RegisterEffect(e)
end

-- 创建效果: 仪式术/仪式 召唤
function RushDuel.CreateRitualEffect(card, type, matfilter, spfilter, exfilter, s_range, o_range, mat_check, mat_move, target_action, operation_action, limit_action, including_self, self_leave)
    local self_range = s_range or 0
    local opponent_range = o_range or 0
    local move = mat_move or RushDuel.RitualToGrave
    local include = including_self or false
    local leave = self_leave or false
    local e = Effect.CreateEffect(card)
    e:SetTarget(RushDuel.RitualTarget(card, type, matfilter, spfilter, exfilter, self_range, opponent_range, mat_check, include, leave, target_action))
    e:SetOperation(RushDuel.RitualOperation(card, type, matfilter, spfilter, exfilter, self_range, opponent_range, mat_check, move, include, leave, operation_action, limit_action))
    return e
end
-- 仪式召唤 - 类型素材过滤
function RushDuel.RitualTypeFilter(c, type)
    if type == RITUAL_ORIGINAL_LEVEL_EQUAL or type == RITUAL_ORIGINAL_LEVEL_GREATER then
        return c:IsLevelAbove(1)
    elseif type == RITUAL_CURRENT_LEVEL_EQUAL or type == RITUAL_CURRENT_LEVEL_GREATER then
        return c:IsLevelAbove(1)
    elseif type == RITUAL_ORIGINAL_ATTACK_EQUAL or type == RITUAL_ORIGINAL_ATTACK_GREATER then
        return c:IsAttackAbove(1)
    elseif type == RITUAL_CURRENT_ATTACK_EQUAL or type == RITUAL_CURRENT_ATTACK_GREATER then
        return c:IsAttackAbove(1)
    end
end
-- 仪式召唤 - 数值合计参考
function RushDuel.GetRitualTypeValue(c, type)
    if type == RITUAL_ORIGINAL_LEVEL_EQUAL or type == RITUAL_ORIGINAL_LEVEL_GREATER then
        return c:GetOriginalLevel()
    elseif type == RITUAL_CURRENT_LEVEL_EQUAL or type == RITUAL_CURRENT_LEVEL_GREATER then
        return c:GetLevel()
    elseif type == RITUAL_ORIGINAL_ATTACK_EQUAL or type == RITUAL_ORIGINAL_ATTACK_GREATER then
        return c:GetBaseAttack()
    elseif type == RITUAL_CURRENT_ATTACK_EQUAL or type == RITUAL_CURRENT_ATTACK_GREATER then
        return c:GetAttack()
    end
end
-- 仪式召唤 - 素材数值参考
function RushDuel.GetRitualMaterialGetter(type)
    if type == RITUAL_ORIGINAL_LEVEL_EQUAL or type == RITUAL_ORIGINAL_LEVEL_GREATER or type == RITUAL_CURRENT_LEVEL_EQUAL or type == RITUAL_CURRENT_LEVEL_GREATER then
        return RushDuel.RitualCheckAdditionalLevel
    elseif type == RITUAL_ORIGINAL_ATTACK_EQUAL or type == RITUAL_ORIGINAL_ATTACK_GREATER or type == RITUAL_CURRENT_ATTACK_EQUAL or type == RITUAL_CURRENT_ATTACK_GREATER then
        return RushDuel.RitualCheckAdditionalAttack
    end
end
-- 仪式召唤 - 使用等级
function RushDuel.RitualCheckAdditionalLevel(c, rc)
	local raw_level = c:GetRitualLevel(rc)
	local lv1 = raw_level&0xffff
	local lv2 = raw_level>>16
	if lv2 > 0 then
		return math.min(lv1, lv2)
	else
		return lv1
	end
end
-- 仪式召唤 - 使用攻击力
function RushDuel.RitualCheckAdditionalAttack(c, rc)
	local x = c:GetAttack()
	if x > MAX_PARAMETER then
		return MAX_PARAMETER
	else
		return x
	end
end

-- 仪式召唤 - 可以作为仪式素材
function RushDuel.IsCanBeRitualMaterial(c, rc)
    if c:IsLocation(LOCATION_HAND + LOCATION_DECK + LOCATION_ONFIELD) and not c:IsCanBeRitualMaterial(rc) then
        return false
    end
    local effects = {c:IsHasEffect(EFFECT_CANNOT_BE_RITUAL_MATERIAL)}
    for i, e in ipairs(effects) do
        local value = e:GetValue()
        if value == 1 then
            return false
        elseif type(value) == "function" and value(e, c, SUMMON_TYPE_RITUAL) then
            return false
        end
    end
    return true
end

-- 仪式召唤 - 素材过滤
function RushDuel.RitualMaterialFilter(c, type, filter, e)
    return RushDuel.RitualTypeFilter(c, type) and (not filter or filter(c)) and (not e or not c:IsImmuneToEffect(e))
end
-- 仪式召唤 - 仪式召唤的怪兽过滤
function RushDuel.RitualSpecialSummonFilter(c, e, tp, type, mat, f, gc, chkf, filter)
    RushDuel.CurrentRitualEffect = e
    local mg = mat
    if RushDuel.RitualExtraMaterialFilter then
        mg = mg:Filter(RushDuel.RitualExtraMaterialFilter, nil, e, tp, c, mg)
    end
    local res = c:GetType() & 0x81 == 0x81 and (not filter or filter(c, e, tp, mg, f, chkf)) and (not f or f(c))
        and RushDuel.GetRitualTypeValue(c, type) > 0
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, false)
        and RushDuel.CheckRitualMaterial(tp, c, type, mg, gc)
    RushDuel.CurrentRitualEffect = nil
    return res
end
-- 仪式召唤 - 获取可用的仪式素材
function RushDuel.GetRitualMaterial(tp, rc, type, mat)
    local mg = mat:Filter(RushDuel.IsCanBeRitualMaterial, rc, rc)
    if rc.mat_filter then
        mg = mg:Filter(rc.mat_filter, rc, tp)
    end
    local max = math.min(#mg, RushDuel.GetRitualTypeValue(rc, type))
    return mg, max
end
-- 仪式召唤 - 检测仪式素材
function RushDuel.CheckRitualMaterial(tp, rc, type, mat, gc)
    local mg, max = RushDuel.GetRitualMaterial(tp, rc, type, mat)
    Auxiliary.GCheckAdditional = RushDuel.RitualCheckAdditional(rc, type)
    local minc = RushDuel.MinRitualMaterialCount or 1
    local maxc = RushDuel.MaxRitualMaterialCount or max
    local res = mg:CheckSubGroup(RushDuel.RitualChecker, minc, maxc, rc, tp, type, gc)
    Auxiliary.GCheckAdditional = nil
    return res
end
-- 仪式召唤 - 选择仪式素材
function RushDuel.SelectRitualMaterial(tp, rc, type, mat, gc)
    local mg, max = RushDuel.GetRitualMaterial(tp, rc, type, mat)
    Auxiliary.GCheckAdditional = RushDuel.RitualCheckAdditional(rc, type)
    local minc = RushDuel.MinRitualMaterialCount or 1
    local maxc = RushDuel.MaxRitualMaterialCount or max
    local sg = RushDuel.Select(HINTMSG_RITUAL_MATERIAL, tp, mg, RushDuel.RitualChecker, true, minc, maxc, rc, tp, type, gc)
    Auxiliary.GCheckAdditional = nil
    return sg
end
-- 仪式召唤 - 素材不能超过必要的数量
function RushDuel.RitualCheckAdditional(rc, type)
    local value = RushDuel.GetRitualTypeValue(rc, type)
    local getter = RushDuel.GetRitualMaterialGetter(type)
    if type == RITUAL_ORIGINAL_LEVEL_EQUAL or type == RITUAL_CURRENT_LEVEL_EQUAL or type == RITUAL_ORIGINAL_ATTACK_EQUAL or type == RITUAL_CURRENT_ATTACK_EQUAL then
        return function(g)
            return (not Auxiliary.RGCheckAdditional or Auxiliary.RGCheckAdditional(g)) and g:GetSum(getter, rc) <= value
        end
    elseif type == RITUAL_ORIGINAL_LEVEL_GREATER or type == RITUAL_CURRENT_LEVEL_GREATER or type == RITUAL_ORIGINAL_ATTACK_GREATER or type == RITUAL_CURRENT_ATTACK_GREATER then
        return function(g, ec)
            if ec then
                return (not Auxiliary.RGCheckAdditional or Auxiliary.RGCheckAdditional(g, ec)) and g:GetSum(getter, rc) - getter(ec, rc) <= value
            else
                return not Auxiliary.RGCheckAdditional or Auxiliary.RGCheckAdditional(g)
            end
        end
    end
end
-- 仪式召唤 - 仪式素材检测
function RushDuel.RitualChecker(mg, rc, tp, type, gc)
    if gc and not mg:IsContains(gc) then
        return false
    elseif rc.mat_group_check and not rc.mat_group_check(mg, tp) then
        return false
    elseif RushDuel.RitualExtraChecker and not RushDuel.RitualExtraChecker(mg, tp, rc) then
        return false
    elseif Auxiliary.RCheckAdditional and not Auxiliary.RCheckAdditional(tp, mg, rc) then
        return false
    else
        local value = RushDuel.GetRitualTypeValue(rc, type)
        if type == RITUAL_ORIGINAL_LEVEL_EQUAL or type == RITUAL_CURRENT_LEVEL_EQUAL then
            return mg:CheckWithSumEqual(Card.GetRitualLevel, value, #mg, #mg, rc)
        elseif type == RITUAL_ORIGINAL_LEVEL_GREATER or type == RITUAL_CURRENT_LEVEL_GREATER then
            Duel.SetSelectedCard(mg)
            return mg:CheckWithSumGreater(Card.GetRitualLevel, value, rc)
        elseif type == RITUAL_ORIGINAL_ATTACK_EQUAL or type == RITUAL_CURRENT_ATTACK_EQUAL then
            return mg:CheckWithSumEqual(Card.GetAttack, value, #mg, #mg, rc)
        elseif type == RITUAL_ORIGINAL_ATTACK_GREATER or type == RITUAL_CURRENT_ATTACK_GREATER then
            Duel.SetSelectedCard(mg)
            return mg:CheckWithSumGreater(Card.GetAttack, value, rc)
        end
    end
    return false
end
-- 仪式召唤 - 确认素材过滤
function RushDuel.ConfirmCardFilter(c)
    return c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown())
end
-- 仪式召唤 - 获取仪式素材与仪式怪兽
function RushDuel.GetRitualSummonData(e, tp, type, matfilter, spfilter, exfilter, s_range, o_range, including_self, self_leave, except, effect)
    local chkf = tp
    if except and self_leave then
        except:AddCard(e:GetHandler())
    elseif self_leave then
        except = e:GetHandler()
    end
    local mg = Duel.GetRitualMaterial(tp):Filter(RushDuel.RitualMaterialFilter, except, type, matfilter, effect)
    if s_range ~= 0 or o_range ~= 0 then
        local ext = Duel.GetMatchingGroup(Auxiliary.NecroValleyFilter(exfilter), tp, s_range, o_range, except, effect)
        mg:Merge(ext:Filter(RushDuel.RitualMaterialFilter, nil, type, nil, effect))
    end
    local gc = nil
    if including_self then
        gc = e:GetHandler()
    end
    local sg = Duel.GetMatchingGroup(RushDuel.RitualSpecialSummonFilter, tp, LOCATION_EXTRA, 0, nil, e, tp, type, mg, nil, gc, chkf, spfilter)
    local list = {}
    local ritualable = false
    if #sg > 0 then
        table.insert(list, {nil, mg, sg})
        ritualable = true
    end
    local effects = {Duel.IsPlayerAffectedByEffect(tp, EFFECT_RITUAL_MATERIAL)}
    for _, effect in ipairs(effects) do
        local target = effect:GetTarget()
        local mg2 = target(effect, e, tp, mg)
        if #mg2 > 0 then
            local mf = effect:GetValue()
            local sg2 = Duel.GetMatchingGroup(RushDuel.RitualSpecialSummonFilter, tp, LOCATION_EXTRA, 0, nil, e, tp, type, mg2, mf, gc, chkf, spfilter)
            if #sg2 > 0 then
                table.insert(list, {effect, mg2, sg2})
                ritualable = true
            end
        end
    end
    return ritualable, list, chkf, gc
end
-- 仪式召唤 - 进行仪式召唤
function RushDuel.ExecuteRitualSummon(e, tp, type, list, chkf, gc, mat_move, cancelable)
    local sg = Group.CreateGroup()
    for _, data in ipairs(list) do
        sg:Merge(data[3])
    end
    ::cancel::
    local rc = nil
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    if cancelable then
        rc = sg:SelectUnselect(nil, tp, false, true, 1, 1)
        if not rc then
            return nil
        end
    else
        rc = sg:Select(tp, 1, 1, nil):GetFirst()
    end
    local options = {}
    for _, data in ipairs(list) do
        local ce, sg = data[1], data[3]
        if sg:IsContains(rc) then
            if ce then
                table.insert(options, {true, ce:GetDescription(), data})
            else
                table.insert(options, {true, 1168, data})
            end
        end
    end
    local data = options[1][3]
    if #options > 1 then
        data = RushDuel.SelectOption(tp, table.unpack(options))
    end
    local ce, mg = data[1], data[2]
    if RushDuel.RitualExtraMaterialFilter then
        mg = mg:Filter(RushDuel.RitualExtraMaterialFilter, nil, e, tp, rc, mg)
    end
    RushDuel.CurrentRitualEffect = e
    local mat = RushDuel.SelectRitualMaterial(tp, rc, type, mg, gc)
    RushDuel.CurrentRitualEffect = nil
    if not mat then
        goto cancel
    end
    local cg = mat:Filter(RushDuel.ConfirmCardFilter, nil)
    if #cg > 0 then
        Duel.ConfirmCards(1 - tp, cg)
    end
    rc:SetMaterial(mat)
    if ce then
        local fop = ce:GetOperation()
        fop(ce, e, tp, rc, mat)
    else
        mat_move(tp, mat, e)
    end
    Duel.BreakEffect()
    Duel.SpecialSummon(rc, SUMMON_TYPE_RITUAL, tp, tp, false, false, POS_FACEUP)
    rc:CompleteProcedure()
    return rc, mat
end
-- 判断条件: 怪兽区域判断
function RushDuel.RitualCheckLocation(e, self_leave, extra)
    return function(sg, tp, rc)
        local mg = nil
        if extra and not extra(tp, sg, rc) then
            return false
        elseif self_leave then
            mg = Group.FromCards(e:GetHandler())
            mg:Merge(sg)
        else
            mg = sg
        end
        if rc:IsLocation(LOCATION_EXTRA) then
            return Duel.GetLocationCountFromEx(tp, tp, mg, rc) > 0
        else
            return Duel.GetMZoneCount(tp, mg) > 0
        end
    end
end
-- 判断条件: 是否可以进行仪式召唤
function RushDuel.IsCanRitualSummon(e, tp, type, matfilter, spfilter, exfilter, s_range, o_range, mat_check, including_self, self_leave, except)
    RushDuel.RitualExtraChecker = RushDuel.RitualCheckLocation(e, self_leave, mat_check)
    local ritualable = RushDuel.GetRitualSummonData(e, tp, type, matfilter, spfilter, exfilter, s_range, o_range, including_self, self_leave, except)
    RushDuel.RitualExtraChecker = nil
    return ritualable
end
-- 仪式召唤 - 目标
function RushDuel.RitualTarget(card, type, matfilter, spfilter, exfilter, s_range, o_range, mat_check, including_self, self_leave, action)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            if e:IsHasProperty(EFFECT_FLAG_SPSUM_PARAM) then
                local min, max = e:GetLabel()
                RushDuel.MinRitualMaterialCount = min
                RushDuel.MaxRitualMaterialCount = max
            end
            RushDuel.RitualExtraMaterialFilter = card.ritual_mat_filter
            local res = RushDuel.IsCanRitualSummon(e, tp, type, matfilter, spfilter, exfilter, s_range, o_range, mat_check, including_self, self_leave, nil)
            RushDuel.RitualExtraMaterialFilter = nil
            RushDuel.MinRitualMaterialCount = nil
            RushDuel.MaxRitualMaterialCount = nil
            return res
        end
        if action ~= nil then
            action(e, tp, eg, ep, ev, re, r, rp)
        end
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    end
end
-- 仪式召唤 - 处理
function RushDuel.RitualOperation(card, type, matfilter, spfilter, exfilter, s_range, o_range, mat_check, mat_move, including_self, self_leave, action, limit)
    return function(e, tp, eg, ep, ev, re, r, rp)
        if e:IsHasProperty(EFFECT_FLAG_SPSUM_PARAM) then
            local min, max = e:GetLabel()
            RushDuel.MinRitualMaterialCount = min
            RushDuel.MaxRitualMaterialCount = max
        end
        RushDuel.RitualExtraMaterialFilter = card.ritual_mat_filter
        RushDuel.RitualExtraChecker = RushDuel.RitualCheckLocation(e, self_leave, mat_check)
        local ritualable, list, chkf, gc = RushDuel.GetRitualSummonData(e, tp, type, matfilter, spfilter, exfilter, s_range, o_range, including_self, self_leave, nil, e)
        if ritualable then
            local fc, mat = RushDuel.ExecuteRitualSummon(e, tp, type, list, chkf, gc, mat_move)
            if action ~= nil then
                action(e, tp, eg, ep, ev, re, r, rp, mat, fc)
            end
        end
        RushDuel.RitualExtraMaterialFilter = nil
        RushDuel.RitualExtraChecker = nil
        RushDuel.MinRitualMaterialCount = nil
        RushDuel.MaxRitualMaterialCount = nil
        if limit ~= nil then
            limit(e, tp, eg, ep, ev, re, r, rp)
        end
    end
end

-- 强制进行仪式召唤
function RushDuel.RitualSummon(type, matfilter, spfilter, exfilter, s_range, o_range, mat_check, mat_move, e, tp, break_effect, including_self, self_leave)
    local include = including_self or false
    local leave = self_leave or false
    RushDuel.RitualExtraMaterialFilter = card.ritual_mat_filter
    RushDuel.RitualExtraChecker = RushDuel.RitualCheckLocation(e, self_leave, mat_check)
    local ritualable, list, chkf, gc = RushDuel.GetRitualSummonData(e, tp, type, matfilter, spfilter, exfilter, s_range, o_range, include, leave, nil, e)
    local rc = nil
    if ritualable then
        if break_effect then
            Duel.BreakEffect()
        end
        rc = RushDuel.ExecuteRitualSummon(e, tp, type, list, chkf, gc, mat_move)
    end
    RushDuel.RitualExtraMaterialFilter = nil
    RushDuel.RitualExtraChecker = nil
    RushDuel.MinRitualMaterialCount = nil
    RushDuel.MaxRitualMaterialCount = nil
    return rc
end

-- 可以进行仪式召唤
function RushDuel.CanRitualSummon(desc, type, matfilter, spfilter, exfilter, s_range, o_range, mat_check, mat_move, e, tp, break_effect, including_self, self_leave)
    local include = including_self or false
    local leave = self_leave or false
    RushDuel.RitualExtraMaterialFilter = card.ritual_mat_filter
    RushDuel.RitualExtraChecker = RushDuel.RitualCheckLocation(e, self_leave, mat_check)
    local ritualable, list, chkf, gc = RushDuel.GetRitualSummonData(e, tp, type, matfilter, spfilter, exfilter, s_range, o_range, include, leave, nil, e)
    local rc = nil
    ::cancel::
    if ritualable and Duel.SelectYesNo(tp, desc) then
        if break_effect then
            Duel.BreakEffect()
        end
        rc = RushDuel.ExecuteRitualSummon(e, tp, type, list, chkf, gc, mat_move, true)
        if not rc then
            goto cancel
        end
    end
    RushDuel.RitualExtraMaterialFilter = nil
    RushDuel.RitualExtraChecker = nil
    RushDuel.MinRitualMaterialCount = nil
    RushDuel.MaxRitualMaterialCount = nil
    return rc
end

-- 素材去向: 墓地
function RushDuel.RitualToGrave(tp, mat)
    Duel.SendtoGrave(mat, REASON_EFFECT + REASON_MATERIAL + REASON_RITUAL)
end
-- 素材去向: 卡组
function RushDuel.RitualToDeck(tp, mat)
    local g = mat:Filter(Card.IsFacedown, nil)
    if #g > 0 then
        Duel.ConfirmCards(1 - tp, g)
    end
    Duel.SendtoDeck(mat, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_MATERIAL + REASON_RITUAL)
end
-- 素材去向: 卡组下面
function RushDuel.RitualToDeckBottom(tp, mat)
    local g = mat:Filter(Card.IsFacedown, nil)
    if #g > 0 then
        Duel.ConfirmCards(1 - tp, g)
    end
    Auxiliary.PlaceCardsOnDeckBottom(tp, mat, REASON_EFFECT + REASON_MATERIAL + REASON_RITUAL)
end
