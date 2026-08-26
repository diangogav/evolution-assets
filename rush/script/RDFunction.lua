-- Rush Duel 辅助函数
RushDuel = RushDuel or {}

-- 为效果设置标签
function RushDuel.SetLabelAndObject(effect, target, set_label, set_object)
    if effect ~= nil and target ~= nil then
        if set_label ~= nil then
            effect:SetLabel(set_label(target))
        end
        if set_object ~= nil then
            effect:SetLabelObject(set_object(target))
        end
    end
end

-- 带有额外参数的过滤器
function RushDuel.Filter(filter, ...)
    local args = {...}
    return function(c)
        return filter(c, table.unpack(args))
    end
end
-- 带有额外参数的检测器
function RushDuel.Check(check, ...)
    local args = {...}
    return function(g)
        return check(g, table.unpack(args))
    end
end

-- 选择卡片组 (功能整合)
function RushDuel.Select(hint, player, group, check, cancelable, min, max, ...)
    Duel.Hint(HINT_SELECTMSG, player, hint)
    if check == nil then
        if cancelable then
            return group:CancelableSelect(player, min, max, nil)
        else
            return group:Select(player, min, max, nil)
        end
    else
        return group:SelectSubGroup(player, check, cancelable, min, max, ...)
    end
end
-- 可以选择卡片组 (功能整合)
function RushDuel.CanSelect(desc, hint, player, group, check, min, max, ...)
    ::cancel::
    if Duel.SelectYesNo(player, desc) then
        local sg = RushDuel.Select(hint, player, group, check, true, min, max, ...)
        if sg == nil then
            goto cancel
        else
            return sg
        end
    else
        return nil
    end
end
-- 选择选项 (自动选择)
function RushDuel.SelectOption(player, ...)
    local options = {...}
    local ops = {}
    local opvals = {}
    for i = 1, #options do
        if options[i][1] then
            table.insert(ops, options[i][2])
            table.insert(opvals, options[i][3] or i)
        end
    end
    if #ops == 0 then return nil end
    if #ops == 1 then
        Duel.Hint(HINT_OPSELECTED, 1 - player, ops[1])
        return opvals[1]
    end
    local select = Duel.SelectOption(player, table.unpack(ops))
    return opvals[select + 1]
end

-- 对卡片组里的全部卡片作位或运算
function RushDuel.GroupBor(g, func, ...)
    local result = 0
    local args = {...}
    g:ForEach(function(tc)
        result = result | func(tc, table.unpack(args))
    end)
    return result
end

-- 显示选择动画, 或者展示卡片组
function RushDuel.HintOrConfirm(group, hint_selection, confirm, target_player)
    if hint_selection then
        Duel.HintSelection(group)
    elseif confirm then
        Duel.ConfirmCards(target_player, group)
    end
end

-- 将 卡片组/卡片/效果 转化为卡片组
function RushDuel.ToGroup(target)
    local type = Auxiliary.GetValueType(target)
    local g = Group.CreateGroup()
    if type == "Group" then
        g:Merge(target)
    elseif type == "Card" then
        g:AddCard(target)
    elseif type == "Effect" then
        g:AddCard(target:GetHandler())
    end
    return g
end

-- 将 卡片组/卡片/效果 转化为卡片组, 对于极大怪兽, 其素材也包含其中
function RushDuel.ToMaximunGroup(target)
    local g = RushDuel.ToGroup(target)
    local overlay = Group.CreateGroup()
    g:ForEach(function(tc)
        if RushDuel.IsMaximumMode(tc) then
            overlay:Merge(tc:GetOverlayGroup())
        end
    end)
    g:Merge(overlay)
    return g
end

-- 获取可用的主要怪兽区域数量
function RushDuel.GetMZoneCount(player, max)
    local ct = Duel.GetLocationCount(player, LOCATION_MZONE)
    if Duel.IsPlayerAffectedByEffect(player, 59822133) then
        ct = math.min(ct, 1)
    end
    return math.min(ct, max)
end
-- 获取可用的魔法与陷阱区域数量
function RushDuel.GetSZoneCount(player, max)
    local ct = Duel.GetLocationCount(player, LOCATION_SZONE)
    return math.min(ct, max)
end

-- 将玩家卡组最上面的N张卡移到卡组最下面
function RushDuel.SendDeckTopToBottom(player, count)
    for i = 1, count do
        Duel.MoveSequence(Duel.GetDecktopGroup(player, 1):GetFirst(), 1)
    end
end
-- 将玩家卡组最下面的N张卡移到卡组最上面
function RushDuel.SendDeckBottomToTop(player, count)
    local g = Duel.GetFieldGroup(player, LOCATION_DECK, 0)
    for i = 1, count do
        Duel.MoveSequence(g:GetMinGroup(Card.GetSequence):GetFirst(), 0)
    end
end
-- 获取卡组底的N张卡
function RushDuel.GetDeckBottomGroup(player, count)
    local dg = Duel.GetFieldGroup(player, LOCATION_DECK, 0)
    local ct = #dg
    if (count < ct) then
        local top = Duel.GetDecktopGroup(player, ct - count)
        dg:Sub(top)
    end
    return dg
end

-- 返回卡组并排序
function RushDuel.SendToDeckSort(target, sequence, reason, sort_player)
    local g = RushDuel.ToMaximunGroup(target)
    local ct = 0
    if sequence == SEQ_DECKTOP then
        ct = Auxiliary.PlaceCardsOnDeckTop(sort_player, g, reason)
    elseif sequence == SEQ_DECKBOTTOM then
        ct = Auxiliary.PlaceCardsOnDeckBottom(sort_player, g, reason)
    else
        ct = Duel.SendtoDeck(target, nil, sequence, reason)
    end
    local og = Duel.GetOperatedGroup()
    return og, ct
end

-- 获取被上级召唤解放时的基础攻击力
function RushDuel.GetBaseAttackOnTribute(c)
    local atk
    if RushDuel.IsMaximumMode(c) then
        atk = c.maximum_attack
    else
        atk = c:GetTextAttack()
    end
    return math.max(0, atk)
end

-- 获取被破坏时的基础攻击力
function RushDuel.GetBaseAttackOnDestroy(c)
    local atk
    if RushDuel.IsPreviousMaximumMode(c) and c:IsReason(REASON_DESTROY) then
        atk = c.maximum_attack
    else
        atk = c:GetTextAttack()
    end
    return math.max(0, atk)
end

-- 让玩家从多个卡名中宣言一个
function RushDuel.AnnounceCodes(player, codes)
    if #codes == 0 then
        return nil
    end
    local afilter = {codes[1], OPCODE_ISCODE}
    if #codes > 1 then
        for i = 2, #codes do
            table.insert(afilter, codes[i])
            table.insert(afilter, OPCODE_ISCODE)
            table.insert(afilter, OPCODE_OR)
        end
    end
    Duel.Hint(HINT_SELECTMSG, player, HINTMSG_CODE)
    return Duel.AnnounceCard(player, table.unpack(afilter))
end

-- 检查融合素材 (多组素材使用)
function RushDuel.CheckFusionMaterials(group, fc, sub, funcs)
    if #group < #funcs then
        return false
    end
    local sg = Group.CreateGroup()
    return group:IsExists(RushDuel.CheckFusionMaterialsStep, 1, nil, group, sg, fc, sub, table.unpack(funcs))
end
function RushDuel.CheckFusionMaterialsStep(c, mg, sg, fc, sub, fun1, fun2, ...)
    if fun2 then
        sg:AddCard(c)
        local res = false
        if fun1(c, fc, false, mg, sg) then
            res = mg:IsExists(RushDuel.CheckFusionMaterialsStep, 1, sg, mg, sg, fc, sub, fun2, ...)
        elseif sub and fun1(c,fc,true,mg,sg) then
            res = mg:IsExists(RushDuel.CheckFusionMaterialsStep, 1, sg, mg, sg, fc, false, fun2, ...)
        end
        sg:RemoveCard(c)
        return res
    else
        return fun1(c, fc, sub, mg, sg)
    end
end

-- 添加以回合为基础的标记计数器
function RushDuel.AddTurnFlagCounter(player, code)
    local counter = Duel.GetFlagEffectLabel(player, code)
    if not counter then
        Duel.RegisterFlagEffect(player, code, RESET_PHASE + PHASE_END, 0, 1, 1)
    else
        Duel.SetFlagEffectLabel(player, code, counter + 1)
    end
end

-- 获取以回合为基础的标记计数器
function RushDuel.GetTurnFlagCounter(player, code)
    local counter = Duel.GetFlagEffectLabel(player, code)
    if not counter then
        return 0
    else
        return counter
    end
end