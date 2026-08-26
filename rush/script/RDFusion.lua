-- Rush Duel 融合
RushDuel = RushDuel or {}
-- 当前的融合效果
RushDuel.CurrentFusionEffect = nil
-- 额外的融合素材过滤
RushDuel.FusionExtraMaterialFilter = nil
-- 额外的融合检测
RushDuel.FusionExtraChecker = nil
-- 最小融合素材数
RushDuel.MinFusionMaterialCount = nil
-- 最大融合素材数
RushDuel.MaxFusionMaterialCount = nil

-- 添加融合手续: 指定卡名/条件, 固定数量
function RushDuel.AddFusionProcedure(card, sub, insf, ...)
    if card:IsStatus(STATUS_COPYING_EFFECT) then
        return
    end
    local vals = {...}
    -- 简易融合
    if type(insf) ~= "boolean" then
        table.insert(vals, 1, insf)
        insf = true
    end
    -- 融合素材替代
    if type(sub) ~= "boolean" then
        table.insert(vals, 1, sub)
        sub = true
    end
    -- 融合素材
    local codes, funcs = RushDuel.MakeFusionMaterial(card, table.unpack(vals))
    RushDuel.SetFusionMaterialData(card, codes, #funcs, #funcs)
    return RushDuel.CreateFusionProcedure(card, sub, insf, funcs, nil, 0, 0, nil)
end

-- 添加融合手续: 指定条件, 不固定数量
function RushDuel.AddFusionProcedureRep(card, sub, insf, func, min, max, ...)
    if card:IsStatus(STATUS_COPYING_EFFECT) then
        return
    end
    local vals = {...}
    -- 融合素材
    local codes, funcs = RushDuel.MakeFusionMaterial(card, table.unpack(vals))
    RushDuel.SetFusionMaterialData(card, codes, #funcs + min, #funcs + max)
    return RushDuel.CreateFusionProcedure(card, sub, insf, funcs, func, min, max, nil)
end

-- 添加融合手续: 指定条件, 不固定数量
function RushDuel.AddFusionProcedureSP(card, sub, insf, matfilter, matcheck, min, max)
    if card:IsStatus(STATUS_COPYING_EFFECT) then
        return
    end
    local insf = (insf ~= false)
    local sub = (sub ~= false)
    local funcs = {}
    return RushDuel.CreateFusionProcedure(card, sub, insf, funcs, matfilter, min, max, matcheck)
end

-- 生成融合素材
function RushDuel.MakeFusionMaterial(card, ...)
    local codes = {}
    local funcs = {}
    for _, val in ipairs {...} do
        local val_type = type(val)
        if val_type == "number" then
            RushDuel.AddCodeFusionMaterial(codes, funcs, val)
        elseif val_type == "function" then
            RushDuel.AddFuncFusionMaterial(codes, funcs, val)
        elseif val_type == "table" then
            RushDuel.AddMixFusionMaterial(codes, funcs, val)
        end
    end
    return codes, funcs
end
-- 融合素材 - 卡名
function RushDuel.AddCodeFusionMaterial(codes, funcs, code)
    table.insert(codes, code)
    table.insert(funcs, function(c, fc, sub, mg, sg)
        return c:IsFusionCode(code) or (sub and c:CheckFusionSubstitute(fc))
    end)
end
-- 融合素材 - 条件
function RushDuel.AddFuncFusionMaterial(codes, funcs, func)
    table.insert(funcs, function(c, fc, sub, mg, sg)
        return func(c, fc, sub, mg, sg) and not c:IsHasEffect(6205579)
    end)
end
-- 融合素材 - 混合
function RushDuel.AddMixFusionMaterial(codes, funcs, list)
    local mixs = {}
    for _, val in ipairs(list) do
        local val_type = type(val)
        if val_type == "number" then
            RushDuel.AddCodeFusionMaterial(codes, mixs, val)
        elseif val_type == "function" then
            RushDuel.AddFuncFusionMaterial(codes, mixs, val)
        end
    end
    table.insert(funcs, function(c, fc, sub, mg, sg)
        for _, func in ipairs(mixs) do
            if func(c, fc, sub, mg, sg) then
                return true
            end
        end
        return false
    end)
end

-- 设置融合素材数据
function RushDuel.SetFusionMaterialData(card, codes, min, max)
    local mt = getmetatable(card)
    -- 卡名记述的素材
    if codes ~= nil then
        RushDuel.AddCodeList(card, codes)
        local mat = {}
        for _, code in ipairs(codes) do
            mat[code] = true
        end
        mt.material = mat
    end
    -- 素材的数量
    if mt.material_count == nil then
        mt.material_count = {min, max}
    end
end

-- 手动添加融合素材列表
function RushDuel.SetFusionMaterial(card, codes, min, max)
    if card:IsStatus(STATUS_COPYING_EFFECT) then
        return
    end
    RushDuel.SetFusionMaterialData(card, codes, min, max)
end

-- 创建融合手续
function RushDuel.CreateFusionProcedure(card, sub, insf, funcs, rep, min, max, checker)
    local e = Effect.CreateEffect(card)
    e:SetType(EFFECT_TYPE_SINGLE)
    e:SetCode(EFFECT_FUSION_MATERIAL)
    e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e:SetCondition(RushDuel.FusionProcedureCondition(sub, insf, funcs, rep, min, max, checker))
    e:SetOperation(RushDuel.FusionProcedureOperation(sub, insf, funcs, rep, min, max, checker))
    card:RegisterEffect(e)
    return e
end
-- 融合手续 - 素材过滤
function RushDuel.FusionProcedureMaterialFilter(c, fc, sub, funcs, rep)
    if not c:IsCanBeFusionMaterial(fc, SUMMON_TYPE_FUSION) then
        return false
    end
    for _, func in ipairs(funcs) do
        if func(c, fc, sub) then
            return true
        end
    end
    if rep and rep(c, fc, sub) then
        return true
    end
    return false
end
-- 融合手续 - 条件
function RushDuel.FusionProcedureCondition(sub, insf, funcs, rep, min, max, checker)
    return function(e, g, gc, chkfnf)
        local c = e:GetHandler()
        local tp = c:GetControler()
        if g == nil then
            return insf and Auxiliary.MustMaterialCheck(nil, tp, EFFECT_MUST_BE_FMATERIAL)
        end
        local mg = g:Filter(RushDuel.FusionProcedureMaterialFilter, c, c, sub, funcs, rep)
        if gc then
            if not mg:IsContains(gc) then
                return false
            end
            Duel.SetSelectedCard(gc)
        end
        local minc, maxc = #funcs + min, #funcs + max
        if RushDuel.MinFusionMaterialCount ~= nil and maxc < RushDuel.MinFusionMaterialCount then
            return false
        end
        if RushDuel.MaxFusionMaterialCount ~= nil and minc > RushDuel.MaxFusionMaterialCount then
            return false
        end
        return mg:CheckSubGroup(RushDuel.FusionProcedureMaterialChecker, minc, maxc, tp, c, chkfnf, sub, funcs, rep, checker)
    end
end
-- 融合手续 - 操作
function RushDuel.FusionProcedureOperation(sub, insf, funcs, rep, min, max, checker)
    return function(e, tp, eg, ep, ev, re, r, rp, gc, chkfnf)
        local c = e:GetHandler()
        local tp = c:GetControler()
        local mg = eg:Filter(RushDuel.FusionProcedureMaterialFilter, c, c, sub, funcs, rep)
        if gc then
            Duel.SetSelectedCard(gc)
        end
        local minc, maxc = #funcs + min, #funcs + max
        if RushDuel.MinFusionMaterialCount ~= nil then
            minc = math.max(minc, RushDuel.MinFusionMaterialCount)
        end
        if RushDuel.MaxFusionMaterialCount ~= nil then
            maxc = math.min(maxc, RushDuel.MaxFusionMaterialCount)
        end
        maxc = math.min(maxc, #mg)
        local sg = RushDuel.Select(HINTMSG_FUSION_MATERIAL, tp, mg, RushDuel.FusionProcedureMaterialChecker, true, minc, maxc, tp, c, chkfnf, sub, funcs, rep, checker)
        if sg == nil then
            sg = Group.CreateGroup()
        end
        Duel.SetFusionMaterial(sg)
    end
end
-- 融合手续 - 素材选择
function RushDuel.FusionProcedureMaterialChecker(mg, tp, fc, chkfnf, sub, funcs, rep, checker)
    local chkf = chkfnf & 0xff
    if mg:IsExists(Auxiliary.TuneMagicianCheckX, 1, nil, mg, EFFECT_TUNE_MAGICIAN_F) then
        return false
    elseif not Auxiliary.MustMaterialCheck(mg, tp, EFFECT_MUST_BE_FMATERIAL) then
        return false
    elseif checker and not checker(mg, tp, fc, chkf) then
        return false
    elseif RushDuel.FusionExtraChecker and not RushDuel.FusionExtraChecker(mg, tp, fc, chkf) then
        return false
    elseif Auxiliary.FCheckAdditional and not Auxiliary.FCheckAdditional(mg, tp, fc, chkf) then
        return false
    elseif Auxiliary.FGoalCheckAdditional and not Auxiliary.FGoalCheckAdditional(mg, tp, fc, chkf) then
        return false
    else
        local sg = Group.CreateGroup()
        return mg:IsExists(RushDuel.FusionProcedureCheckStep, 1, nil, mg, sg, fc, sub, rep, table.unpack(funcs))
    end
end
-- 融合手续 - 素材组合
function RushDuel.FusionProcedureCheckStep(c, mg, sg, fc, sub, rep, func1, func2, ...)
    if func2 then
        local res = false
        sg:AddCard(c)
        if func1(c, fc, false, mg, sg) then
            res = mg:IsExists(RushDuel.FusionProcedureCheckStep, 1, sg, mg, sg, fc, sub, rep, func2, ...)
        elseif sub and func1(c, fc, true, mg, sg) then
            res = mg:IsExists(RushDuel.FusionProcedureCheckStep, 1, sg, mg, sg, fc, false, rep, func2, ...)
        end
        sg:RemoveCard(c)
        return res
    elseif func1 then
        return func1(c, fc, sub, mg, sg)
    elseif rep then
        local eg = mg:Clone()
        eg:Sub(sg)
        return eg:FilterCount(rep, nil, fc, false, mg, sg) == #eg
    end
    return false
end

-- 可以进行接触融合术
function RushDuel.EnableContactFusion(card, desc)
    local e = Effect.CreateEffect(card)
    e:SetDescription(desc)
    e:SetType(EFFECT_TYPE_FIELD)
    e:SetCode(EFFECT_SPSUMMON_PROC)
    e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e:SetRange(LOCATION_EXTRA)
    e:SetCondition(RushDuel.ContactFusionCondition)
    e:SetTarget(RushDuel.ContactFusionTarget)
    e:SetOperation(RushDuel.ContactFusionOperation)
    e:SetValue(SUMMON_TYPE_FUSION)
    card:RegisterEffect(e)
    return e
end
-- 接触融合术: 素材过滤
function RushDuel.ContactFusionMaterialFilter(c, fc)
    return c:IsFaceup() and c:IsCanBeFusionMaterial(fc) and c:IsAbleToDeckOrExtraAsCost()
end
-- 接触融合术: 条件
function RushDuel.ContactFusionCondition(e, c)
    if c == nil then
        return true
    end
    if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then
        return false
    end
    local tp = c:GetControler()
    RushDuel.FusionExtraChecker = RushDuel.FusionCheckLocation(e)
    local mg = Duel.GetMatchingGroup(RushDuel.ContactFusionMaterialFilter, tp, LOCATION_MZONE, 0, c, c)
    local res = c:CheckFusionMaterial(mg, nil, tp)
    RushDuel.FusionExtraChecker = nil
    return res
end
-- 接触融合术: 对象
function RushDuel.ContactFusionTarget(e, tp, eg, ep, ev, re, r, rp, chk, c)
    RushDuel.FusionExtraChecker = RushDuel.FusionCheckLocation(e)
    local mg = Duel.GetMatchingGroup(RushDuel.ContactFusionMaterialFilter, tp, LOCATION_MZONE, 0, c, c)
    local g = Duel.SelectFusionMaterial(tp, c, mg, nil, tp)
    RushDuel.FusionExtraChecker = nil
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    else
        return false
    end
end
-- 接触融合术: 处理
function RushDuel.ContactFusionOperation(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    c:SetMaterial(g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_MATERIAL + REASON_FUSION + REASON_COST)
    g:DeleteGroup()
end

-- 可以进行同盟融合术
function RushDuel.EnableUnionFusion(card, desc)
    local e = Effect.CreateEffect(card)
    e:SetDescription(desc)
    e:SetType(EFFECT_TYPE_FIELD)
    e:SetCode(EFFECT_SPSUMMON_PROC)
    e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e:SetRange(LOCATION_EXTRA)
    e:SetCondition(RushDuel.UnionFusionCondition)
    e:SetTarget(RushDuel.UnionFusionTarget)
    e:SetOperation(RushDuel.UnionFusionOperation)
    e:SetValue(SUMMON_TYPE_FUSION)
    card:RegisterEffect(e)
    return e
end
-- 同盟融合术: 素材过滤
function RushDuel.UnionFusionMaterialFilter(c, fc)
    return c:IsFaceup() and c:IsCanBeFusionMaterial(fc) and c:IsAbleToDeckOrExtraAsCost()
end
-- 同盟融合术: 条件
function RushDuel.UnionFusionCondition(e, c)
    if c == nil then
        return true
    end
    if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then
        return false
    end
    local tp = c:GetControler()
    RushDuel.FusionExtraChecker = RushDuel.FusionCheckLocation(e)
    local mg = Duel.GetMatchingGroup(RushDuel.UnionFusionMaterialFilter, tp, LOCATION_ONFIELD, 0, c, c)
    local res = c:CheckFusionMaterial(mg, nil, tp)
    RushDuel.FusionExtraChecker = nil
    return res
end
-- 同盟融合术: 对象
function RushDuel.UnionFusionTarget(e, tp, eg, ep, ev, re, r, rp, chk, c)
    RushDuel.FusionExtraChecker = RushDuel.FusionCheckLocation(e)
    local mg = Duel.GetMatchingGroup(RushDuel.UnionFusionMaterialFilter, tp, LOCATION_ONFIELD, 0, c, c)
    local g = Duel.SelectFusionMaterial(tp, c, mg, nil, tp)
    RushDuel.FusionExtraChecker = nil
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    else
        return false
    end
end
-- 同盟融合术: 处理
function RushDuel.UnionFusionOperation(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    c:SetMaterial(g)
    RushDuel.SendToDeckSort(g, SEQ_DECKBOTTOM, REASON_MATERIAL + REASON_FUSION + REASON_COST, tp)
    g:DeleteGroup()
end

-- 创建效果: 融合术/结合 召唤
function RushDuel.CreateFusionEffect(card, matfilter, spfilter, exfilter, s_range, o_range, mat_check, mat_move, target_action, operation_action, limit_action, sum_pos, including_self, self_leave)
    local self_range = s_range or 0
    local opponent_range = o_range or 0
    local move = mat_move or RushDuel.FusionToGrave
    local include = including_self or false
    local leave = self_leave or false
    local pos = sum_pos or POS_FACEUP
    local e = Effect.CreateEffect(card)
    e:SetTarget(RushDuel.FusionTarget(card, matfilter, spfilter, exfilter, self_range, opponent_range, mat_check, include, leave, pos, target_action))
    e:SetOperation(RushDuel.FusionOperation(card, matfilter, spfilter, exfilter, self_range, opponent_range, mat_check, move, include, leave, pos, operation_action, limit_action))
    return e
end
-- 融合召唤 - 设置融合效果的额外参数
function RushDuel.SetFusionEffectParameter(e)
    if e then
        RushDuel.CurrentFusionEffect = e
        if e:IsHasProperty(EFFECT_FLAG_SPSUM_PARAM) then
            local min, max = e:GetLabel()
            RushDuel.MinFusionMaterialCount = min
            RushDuel.MaxFusionMaterialCount = max
        else
            RushDuel.MinFusionMaterialCount = nil
            RushDuel.MaxFusionMaterialCount = nil
        end
    else
        RushDuel.CurrentFusionEffect = nil
        RushDuel.MinFusionMaterialCount = nil
        RushDuel.MaxFusionMaterialCount = nil
    end
end
-- 融合召唤 - 素材过滤
function RushDuel.FusionMaterialFilter(c, filter, e)
    return (not filter or filter(c)) and (not e or not c:IsImmuneToEffect(e))
end
-- 融合召唤 - 融合召唤的怪兽过滤
function RushDuel.FusionSpecialSummonFilter(c, e, tp, pos, m, f, gc, chkf, filter)
    RushDuel.SetFusionEffectParameter(e)
    local res = c:IsType(TYPE_FUSION) and (not filter or filter(c, e, tp, m, f, chkf)) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false, pos) and
                    c:CheckFusionMaterial(m, gc, chkf)
    RushDuel.SetFusionEffectParameter()
    return res
end
-- 融合召唤 - 确认素材过滤
function RushDuel.ConfirmCardFilter(c)
    return c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown())
end
-- 融合召唤 - 获取融合素材与融合怪兽
function RushDuel.GetFusionSummonData(e, tp, pos, matfilter, spfilter, exfilter, s_range, o_range, including_self, self_leave, except, effect)
    local chkf = tp
    if except and self_leave then
        except:AddCard(e:GetHandler())
    elseif self_leave then
        except = e:GetHandler()
    end
    local mg = Duel.GetFusionMaterial(tp):Filter(RushDuel.FusionMaterialFilter, except, matfilter, effect)
    if s_range ~= 0 or o_range ~= 0 then
        local ext = Duel.GetMatchingGroup(Auxiliary.NecroValleyFilter(exfilter), tp, s_range, o_range, except, effect)
        mg:Merge(ext)
    end
    local gc = nil
    if including_self then
        gc = e:GetHandler()
    end
    if RushDuel.FusionExtraMaterialFilter then
        mg = mg:Filter(RushDuel.FusionExtraMaterialFilter, nil, e, tp, mg)
    end
    local sg = Duel.GetMatchingGroup(RushDuel.FusionSpecialSummonFilter, tp, LOCATION_EXTRA, 0, nil, e, tp, pos, mg, nil, gc, chkf, spfilter)
    local list = {}
    local fusionable = false
    if #sg > 0 then
        table.insert(list, {nil, mg, sg})
        fusionable = true
    end
    local effects = {Duel.IsPlayerAffectedByEffect(tp, EFFECT_CHAIN_MATERIAL)}
    for _, effect in ipairs(effects) do
        local target = effect:GetTarget()
        local mg2 = target(effect, e, tp, mg)
        if RushDuel.FusionExtraMaterialFilter then
            mg2 = mg2:Filter(RushDuel.FusionExtraMaterialFilter, nil, e, tp, mg2)
        end
        if #mg2 > 0 then
            local mf = effect:GetValue()
            local sg2 = Duel.GetMatchingGroup(RushDuel.FusionSpecialSummonFilter, tp, LOCATION_EXTRA, 0, nil, e, tp, pos, mg2, mf, gc, chkf, spfilter)
            if #sg2 > 0 then
                table.insert(list, {effect, mg2, sg2})
                fusionable = true
            end
        end
    end
    return fusionable, list, chkf, gc
end
-- 融合召唤 - 进行融合召唤
function RushDuel.ExecuteFusionSummon(e, tp, pos, list, chkf, gc, mat_move, cancelable)
    local sg = Group.CreateGroup()
    for _, data in ipairs(list) do
        sg:Merge(data[3])
    end
    ::cancel::
    local fc = nil
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    if cancelable then
        fc = sg:SelectUnselect(nil, tp, false, true, 1, 1)
        if not fc then
            return nil
        end
    else
        fc = sg:Select(tp, 1, 1, nil):GetFirst()
    end
    local options = {}
    for _, data in ipairs(list) do
        local ce, sg = data[1], data[3]
        if sg:IsContains(fc) then
            if ce then
                table.insert(options, {true, ce:GetDescription(), data})
            else
                table.insert(options, {true, 1169, data})
            end
        end
    end
    local data = options[1][3]
    if #options > 1 then
        data = RushDuel.SelectOption(tp, table.unpack(options))
    end
    local ce, mg = data[1], data[2]
    RushDuel.SetFusionEffectParameter(e)
    local mat = Duel.SelectFusionMaterial(tp, fc, mg, gc, chkf)
    RushDuel.SetFusionEffectParameter()
    if #mat < 2 then
        goto cancel
    end
    local cg = mat:Filter(RushDuel.ConfirmCardFilter, nil)
    if #cg > 0 then
        Duel.ConfirmCards(1 - tp, cg)
    end
    fc:SetMaterial(mat)
    if ce then
        local fop = ce:GetOperation()
        fop(ce, e, tp, fc, mat)
    else
        mat_move(tp, mat, e)
    end
    Duel.BreakEffect()
    Duel.SpecialSummon(fc, SUMMON_TYPE_FUSION, tp, tp, false, false, pos)
    fc:CompleteProcedure()
    return fc, mat
end
-- 判断条件: 怪兽区域判断
function RushDuel.FusionCheckLocation(e, self_leave, extra)
    return function(sg, tp, fc, chkf)
        if extra and not extra(tp, sg, fc, chkf) then
            return false
        elseif chkf == PLAYER_NONE then
            return true
        elseif self_leave then
            local mg = Group.FromCards(e:GetHandler())
            mg:Merge(sg)
            return Duel.GetLocationCountFromEx(tp, tp, mg, fc) > 0
        else
            return Duel.GetLocationCountFromEx(tp, tp, sg, fc) > 0
        end
    end
end
-- 判断条件: 是否可以进行融合召唤
function RushDuel.IsCanFusionSummon(e, tp, pos, matfilter, spfilter, exfilter, s_range, o_range, mat_check, including_self, self_leave, except)
    RushDuel.FusionExtraChecker = RushDuel.FusionCheckLocation(e, self_leave, mat_check)
    local fusionable = RushDuel.GetFusionSummonData(e, tp, pos, matfilter, spfilter, exfilter, s_range, o_range, including_self, self_leave, except)
    RushDuel.FusionExtraChecker = nil
    return fusionable
end
-- 融合召唤 - 目标
function RushDuel.FusionTarget(card, matfilter, spfilter, exfilter, s_range, o_range, mat_check, including_self, self_leave, pos, action)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            RushDuel.FusionExtraMaterialFilter = card.fusion_mat_filter
            local res = RushDuel.IsCanFusionSummon(e, tp, pos, matfilter, spfilter, exfilter, s_range, o_range, mat_check, including_self, self_leave, nil)
            RushDuel.FusionExtraMaterialFilter = nil
            return res
        end
        if action ~= nil then
            action(e, tp, eg, ep, ev, re, r, rp)
        end
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
    end
end
-- 融合召唤 - 处理
function RushDuel.FusionOperation(card, matfilter, spfilter, exfilter, s_range, o_range, mat_check, mat_move, including_self, self_leave, pos, action, limit)
    return function(e, tp, eg, ep, ev, re, r, rp)
        RushDuel.FusionExtraMaterialFilter = card.fusion_mat_filter
        RushDuel.FusionExtraChecker = RushDuel.FusionCheckLocation(e, self_leave, mat_check)
        local fusionable, list, chkf, gc = RushDuel.GetFusionSummonData(e, tp, pos, matfilter, spfilter, exfilter, s_range, o_range, including_self, self_leave, nil, e)
        if fusionable then
            local fc, mat = RushDuel.ExecuteFusionSummon(e, tp, pos, list, chkf, gc, mat_move)
            if action ~= nil then
                action(e, tp, eg, ep, ev, re, r, rp, mat, fc)
            end
        end
        RushDuel.FusionExtraMaterialFilter = nil
        RushDuel.FusionExtraChecker = nil
        if limit ~= nil then
            limit(e, tp, eg, ep, ev, re, r, rp)
        end
    end
end

-- 强制进行融合召唤
function RushDuel.FusionSummon(matfilter, spfilter, exfilter, s_range, o_range, mat_check, mat_move, e, tp, pos, break_effect, including_self, self_leave)
    local include = including_self or false
    local leave = self_leave or false
    RushDuel.FusionExtraChecker = RushDuel.FusionCheckLocation(e, self_leave, mat_check)
    local fusionable, list, chkf, gc = RushDuel.GetFusionSummonData(e, tp, pos, matfilter, spfilter, exfilter, s_range, o_range, include, leave, nil, e)
    local fc = nil
    if fusionable then
        if break_effect then
            Duel.BreakEffect()
        end
        fc = RushDuel.ExecuteFusionSummon(e, tp, pos, list, chkf, gc, mat_move)
    end
    RushDuel.FusionExtraChecker = nil
    return fc
end

-- 可以进行融合召唤
function RushDuel.CanFusionSummon(desc, matfilter, spfilter, exfilter, s_range, o_range, mat_check, mat_move, e, tp, pos, break_effect, including_self, self_leave)
    local include = including_self or false
    local leave = self_leave or false
    RushDuel.FusionExtraChecker = RushDuel.FusionCheckLocation(e, self_leave, mat_check)
    local fusionable, list, chkf, gc = RushDuel.GetFusionSummonData(e, tp, pos, matfilter, spfilter, exfilter, s_range, o_range, include, leave, nil, e)
    local fc = nil
    ::cancel::
    if fusionable and Duel.SelectYesNo(tp, desc) then
        if break_effect then
            Duel.BreakEffect()
        end
        fc = RushDuel.ExecuteFusionSummon(e, tp, pos, list, chkf, gc, mat_move, true)
        if not fc then
            goto cancel
        end
    end
    RushDuel.FusionExtraChecker = nil
    return fc
end

-- 设置进行融合召唤的素材数量限制 (需要使用 Property 和 Label)
function RushDuel.SetFusionSummonMaterialCount(e, min, max)
    e:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
    e:SetLabel(min, max)
end

-- 重置进行融合召唤的素材数量限制 (需要使用 Property 和 Label)
function RushDuel.ResetFusionSummonMaterialCount(e)
    e:SetProperty(0)
    e:SetLabel(0)
end

-- 素材去向: 墓地
function RushDuel.FusionToGrave(tp, mat)
    Duel.SendtoGrave(mat, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
end
-- 素材去向: 卡组
function RushDuel.FusionToDeck(tp, mat)
    local g = mat:Filter(Card.IsFacedown, nil)
    if #g > 0 then
        Duel.ConfirmCards(1 - tp, g)
    end
    Duel.SendtoDeck(mat, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
end
-- 素材去向: 卡组下面
function RushDuel.FusionToDeckBottom(tp, mat)
    local g = mat:Filter(Card.IsFacedown, nil)
    if #g > 0 then
        Duel.ConfirmCards(1 - tp, g)
    end
    Auxiliary.PlaceCardsOnDeckBottom(tp, mat, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
end

-- 获取可以宣言的融合素材的卡名
function RushDuel.GetAnnouncableFusionMaterialCodes(card, target)
    local codes = {}
    local code = card:GetCode()
    for code, _ in pairs(target.material or {}) do
        if not card:IsCode(code) then
            table.insert(codes, code)
        end
    end
    return codes
end

-- 宣言融合素材的卡名
function RushDuel.AnnounceFusionMaterialCode(player, card, target)
    local codes = RushDuel.GetAnnouncableFusionMaterialCodes(card, target)
    if #codes > 0 then
        return RushDuel.AnnounceCodes(player, codes)
    else
        return nil
    end
end
