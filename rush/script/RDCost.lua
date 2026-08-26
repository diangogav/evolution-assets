-- Rush Duel 代价
RushDuel = RushDuel or {}
-- 当前的融合效果
RushDuel.CostCancelable = false

-- 内部方法: 获取选择范围
function RushDuel._private_get_select_range(min, max, ...)
    if type(min) == "function" then
        min = min(...)
    end
    if type(max) == "function" then
        max = max(...)
    end
    return min, max
end

-- 内部方法: 选择匹配卡片, 执行操作
function RushDuel._private_cost_select_match(hint, filter, s_range, o_range, min, max, except_self, action)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        local expect = nil
        if except_self then
            expect = e:GetHandler()
        end
        local min, max = RushDuel._private_get_select_range(min, max, e, tp, eg, ep, ev, re, r, rp, chk)
        local g = Duel.GetMatchingGroup(filter, tp, s_range, o_range, expect, e, tp, eg, ep, ev, re, r, rp)
        if chk == 0 then
            return #g >= min
        end
        local cancelable = RushDuel.CostCancelable
        local sg = RushDuel.Select(hint, tp, g, nil, cancelable, min, max)
        if sg and #sg > 0 then
            action(sg, e, tp, eg, ep, ev, re, r, rp)
            return true
        else
            return false
        end
    end
end
-- 内部方法: 选择子卡片组, 执行操作
function RushDuel._private_cost_select_group(hint, filter, check, s_range, o_range, min, max, except_self, action)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        local expect = nil
        if except_self then
            expect = e:GetHandler()
        end
        local min, max = RushDuel._private_get_select_range(min, max, e, tp, eg, ep, ev, re, r, rp, chk)
        local g = Duel.GetMatchingGroup(filter, tp, s_range, o_range, expect, e, tp, eg, ep, ev, re, r, rp)
        if chk == 0 then
            return g:CheckSubGroup(check, min, max, e, tp, eg, ep, ev, re, r, rp)
        end
        local cancelable = RushDuel.CostCancelable
        local sg = RushDuel.Select(hint, tp, g, check, cancelable, min, max, e, tp, eg, ep, ev, re, r, rp)
        if sg and #sg > 0 then
            action(sg, e, tp, eg, ep, ev, re, r, rp)
            return true
        else
            return false
        end
    end
end
-- 内部方法: 送去墓地动作
function RushDuel._private_action_send_grave(reason, hint_selection, confirm, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return function(g, e, tp, eg, ep, ev, re, r, rp)
        RushDuel.HintOrConfirm(g, hint_selection, confirm, 1 - tp)
        RushDuel.SetLabelAndObject(e, g, set_label_before, set_object_before)
        if Duel.SendtoGrave(g, reason) ~= 0 and (set_label_after ~= nil or set_object_after ~= nil) then
            local og = Duel.GetOperatedGroup()
            RushDuel.SetLabelAndObject(e, og, set_label_after, set_object_after)
        end
    end
end
-- 内部方法: 返回卡组动作
function RushDuel._private_action_send_deck_sort(sequence, reason, hint_selection, confirm, set_label_before,
    set_object_before, set_label_after, set_object_after)
    return function(g, e, tp, eg, ep, ev, re, r, rp)
        RushDuel.HintOrConfirm(g, hint_selection, confirm, 1 - tp)
        RushDuel.SetLabelAndObject(e, g, set_label_before, set_object_before)
        local og, ct = RushDuel.SendToDeckSort(g, sequence, reason, tp)
        RushDuel.SetLabelAndObject(e, og, set_label_after, set_object_after)
    end
end
-- 内部方法: 返回卡组上面或下面动作
function RushDuel._private_action_send_deck_top_or_bottom(top_desc, bottom_desc, reason, hint_selection, confirm,
    set_label_before, set_object_before, set_label_after, set_object_after)
    return function(g, e, tp, eg, ep, ev, re, r, rp)
        RushDuel.HintOrConfirm(g, hint_selection, confirm, 1 - tp)
        RushDuel.SetLabelAndObject(e, g, set_label_before, set_object_before)
        local sequence = Duel.SelectOption(tp, top_desc, bottom_desc)
        local og, ct = RushDuel.SendToDeckSort(g, sequence, reason, tp)
        RushDuel.SetLabelAndObject(e, og, set_label_after, set_object_after)
    end
end
-- 内部方法: 返回手卡动作
function RushDuel._private_action_send_hand(reason, hint_selection, confirm, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return function(g, e, tp, eg, ep, ev, re, r, rp)
        if hint_selection then
            Duel.HintSelection(g)
        end
        RushDuel.SetLabelAndObject(e, g, set_label_before, set_object_before)
        if Duel.SendtoHand(g, nil, reason) ~= 0 then
            local og = Duel.GetOperatedGroup()
            if confirm then
                Duel.ConfirmCards(1 - tp, og)
            end
            RushDuel.SetLabelAndObject(e, og, set_label_after, set_object_after)
        end
    end
end
-- 内部方法: 改变表示形式动作
function RushDuel._private_action_change_position(position, set_label_before, set_object_before, set_label_after,
    set_object_after)
    return function(g, e, tp, eg, ep, ev, re, r, rp)
        RushDuel.SetLabelAndObject(e, g, set_label_before, set_object_before)
        if RushDuel.ChangePosition(g, e, tp, REASON_COST, position) ~= 0 then
            local og = Duel.GetOperatedGroup()
            RushDuel.SetLabelAndObject(e, og, set_label_after, set_object_after)
        end
    end
end

-- 代价: 免除代价
function RushDuel.NoCostCheck(cost, flag_effect)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        local effects = {Duel.IsPlayerAffectedByEffect(tp, flag_effect)}
        for _, effect in ipairs(effects) do
            local val = effect:GetValue()
            if val == 1 then
                return true
            elseif val(effect, e, tp, eg, ep, ev, re, r, rp) then
                return true
            end
        end
        return cost(e, tp, eg, ep, ev, re, r, rp, chk)
    end
end

-- 代价: 只有条件
function RushDuel.CostOnlyCondition(condition)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        return condition(e, tp, eg, ep, ev, re, r, rp, chk)
    end
end
-- 代价: 选择匹配卡片, 送去墓地
function RushDuel.CostSendMatchToGrave(filter, field, min, max, except_self, hint_selection, confirm, set_label_before,
    set_object_before, set_label_after, set_object_after)
    local action = RushDuel._private_action_send_grave(REASON_COST, hint_selection, confirm, set_label_before,
        set_object_before, set_label_after, set_object_after)
    return RushDuel._private_cost_select_match(HINTMSG_TOGRAVE, filter, field, 0, min, max, except_self, action)
end
-- 代价: 选择子卡片组, 送去墓地
function RushDuel.CostSendGroupToGrave(filter, check, field, min, max, except_self, hint_selection, confirm,
    set_label_before, set_object_before, set_label_after, set_object_after)
    local action = RushDuel._private_action_send_grave(REASON_COST, hint_selection, confirm, set_label_before,
        set_object_before, set_label_after, set_object_after)
    return RushDuel._private_cost_select_group(HINTMSG_TOGRAVE, filter, check, field, 0, min, max, except_self, action)
end
-- 代价: 选择匹配卡片, 返回卡组 (排序)
function RushDuel.CostSendMatchToDeckSort(filter, field, min, max, except_self, sequence, hint_selection, confirm,
    set_label_before, set_object_before, set_label_after, set_object_after)
    local action = RushDuel._private_action_send_deck_sort(sequence, REASON_COST, hint_selection, confirm,
        set_label_before, set_object_before, set_label_after, set_object_after)
    return RushDuel._private_cost_select_match(HINTMSG_TODECK, filter, field, 0, min, max, except_self, action)
end
-- 代价: 选择子卡片组, 返回卡组 (排序)
function RushDuel.CostSendGroupToDeckSort(filter, check, field, min, max, except_self, sequence, hint_selection,
    confirm, set_label_before, set_object_before, set_label_after, set_object_after)
    local action = RushDuel._private_action_send_deck_sort(sequence, REASON_COST, hint_selection, confirm,
        set_label_before, set_object_before, set_label_after, set_object_after)
    return RushDuel._private_cost_select_group(HINTMSG_TODECK, filter, check, field, 0, min, max, except_self, action)
end
-- 代价: 选择匹配卡片, 返回卡组上面或下面
function RushDuel.CostSendMatchToDeckTopOrBottom(filter, field, min, max, except_self, top_desc, bottom_desc,
    hint_selection, confirm, set_label_before, set_object_before, set_label_after, set_object_after)
    local action = RushDuel._private_action_send_deck_top_or_bottom(top_desc, bottom_desc, REASON_COST, hint_selection,
        confirm, set_label_before, set_object_before, set_label_after, set_object_after)
    return RushDuel._private_cost_select_match(HINTMSG_TODECK, filter, field, 0, min, max, except_self, action)
end
-- 代价: 选择子卡片组, 返回卡组上面或下面
function RushDuel.CostSendGroupToDeckTopOrBottom(filter, check, field, min, max, except_self, top_desc, bottom_desc,
    hint_selection, confirm, set_label_before, set_object_before, set_label_after, set_object_after)
    local action = RushDuel._private_action_send_deck_top_or_bottom(top_desc, bottom_desc, REASON_COST, hint_selection,
        confirm, set_label_before, set_object_before, set_label_after, set_object_after)
    return RushDuel._private_cost_select_group(HINTMSG_TODECK, filter, check, field, 0, min, max, except_self, action)
end
-- 代价: 选择匹配卡片, 返回手卡
function RushDuel.CostSendMatchToHand(filter, field, min, max, except_self, hint_selection, confirm, set_label_before,
    set_object_before, set_label_after, set_object_after)
    local action = RushDuel._private_action_send_hand(REASON_COST, hint_selection, confirm, set_label_before,
        set_object_before, set_label_after, set_object_after)
    return RushDuel._private_cost_select_match(HINTMSG_TOGRAVE, filter, field, 0, min, max, except_self, action)
end

-- 代价: 支付LP
function RushDuel.CostPayLP(lp)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.CheckLPCost(tp, lp)
        end
        Duel.PayLPCost(tp, lp)
        return true
    end
end
-- 代价: 把手卡给对方观看
function RushDuel.CostShowHand(filter, min, max, set_label, set_object)
    return RushDuel._private_cost_select_match(HINTMSG_CONFIRM, filter, LOCATION_HAND, 0, min, max, true,
        function(g, e, tp, eg, ep, ev, re, r, rp)
            RushDuel.SetLabelAndObject(e, g, set_label, set_object)
            Duel.ConfirmCards(1 - tp, g)
            Duel.ShuffleHand(tp)
        end)
end
-- 代价: 把手卡给对方观看 (子卡片组)
function RushDuel.CostShowGroupHand(filter, check, min, max, set_label, set_object)
    return RushDuel._private_cost_select_group(HINTMSG_CONFIRM, filter, check, LOCATION_HAND, 0, min, max, true,
        function(g, e, tp, eg, ep, ev, re, r, rp)
            RushDuel.SetLabelAndObject(e, g, set_label, set_object)
            Duel.ConfirmCards(1 - tp, g)
            Duel.ShuffleHand(tp)
        end)
end
-- 代价: 把额外卡组给对方观看
function RushDuel.CostShowExtra(filter, min, max, set_label, set_object)
    return RushDuel._private_cost_select_match(HINTMSG_CONFIRM, filter, LOCATION_EXTRA, 0, min, max, false,
        function(g, e, tp, eg, ep, ev, re, r, rp)
            RushDuel.SetLabelAndObject(e, g, set_label, set_object)
            Duel.ConfirmCards(1 - tp, g)
        end)
end
-- 代价: 把额外卡组给对方观看 (子卡片组)
function RushDuel.CostShowGroupExtra(filter, check, min, max, set_label, set_object)
    return RushDuel._private_cost_select_group(HINTMSG_CONFIRM, filter, check, LOCATION_EXTRA, 0, min, max, false,
        function(g, e, tp, eg, ep, ev, re, r, rp)
            RushDuel.SetLabelAndObject(e, g, set_label, set_object)
            Duel.ConfirmCards(1 - tp, g)
        end)
end
-- 代价: 从卡组上面把卡送去墓地
function RushDuel.CostSendDeckTopToGrave(count, set_label, set_object)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsPlayerCanDiscardDeckAsCost(tp, count)
        end
        if Duel.DiscardDeck(tp, count, REASON_COST) ~= 0 and (set_label ~= nil or set_object ~= nil) then
            local og = Duel.GetOperatedGroup()
            RushDuel.SetLabelAndObject(e, og, set_label, set_object)
        end
        return true
    end
end
-- 代价: 从卡组上面把任意数量的卡送去墓地
function RushDuel.CostSendDeckTopAnyToGrave(desc, min, max, set_label, set_object)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsPlayerCanDiscardDeckAsCost(tp, min)
        end
        local ops = {}
        for i = min, max do
            if Duel.IsPlayerCanDiscardDeckAsCost(tp, i) then
                table.insert(ops, i)
            end
        end
        Duel.Hint(HINT_SELECTMSG, tp, desc)
        local count = Duel.AnnounceNumber(tp, table.unpack(ops))
        if Duel.DiscardDeck(tp, count, REASON_COST) ~= 0 and (set_label ~= nil or set_object ~= nil) then
            local og = Duel.GetOperatedGroup()
            RushDuel.SetLabelAndObject(e, og, set_label, set_object)
        end
        return true
    end
end
-- 代价: 从卡组下面把卡送去墓地
function RushDuel.CostSendDeckBottomToGrave(count, set_label, set_object)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return Duel.IsPlayerCanDiscardDeckAsCost(tp, count)
        end
        local dg = RushDuel.GetDeckBottomGroup(tp, count)
        Duel.DisableShuffleCheck()
        if Duel.SendtoGrave(dg, REASON_COST) ~= 0 and (set_label ~= nil or set_object ~= nil) then
            local og = Duel.GetOperatedGroup()
            RushDuel.SetLabelAndObject(e, og, set_label, set_object)
        end
        return true
    end
end
-- 代价: 把自己场上表侧表示的这张卡送去墓地
function RushDuel.CostSendSelfToGrave()
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return e:GetHandler():IsAbleToGraveAsCost()
        end
        Duel.SendtoGrave(RushDuel.ToMaximunGroup(e:GetHandler()), REASON_COST)
        return true
    end
end
-- 代价: 把手卡送去墓地
function RushDuel.CostSendHandToGrave(filter, min, max, set_label_before, set_object_before, set_label_after,
    set_object_after)
    local cost = RushDuel.CostSendMatchToGrave(filter, LOCATION_HAND, min, max, true, false, false, set_label_before,
        set_object_before, set_label_after, set_object_after)
    return RushDuel.NoCostCheck(cost, EFFECT_NO_COST_SEND_HAND_TO_GRAVE)
end
-- 代价: 把手卡送去墓地 (子卡片组)
function RushDuel.CostSendHandSubToGrave(filter, check, min, max, set_label_before, set_object_before, set_label_after,
    set_object_after)
    local cost = RushDuel.CostSendGroupToGrave(filter, check, LOCATION_HAND, min, max, true, false, false,
        set_label_before, set_object_before, set_label_after, set_object_after)
    return RushDuel.NoCostCheck(cost, EFFECT_NO_COST_SEND_HAND_TO_GRAVE)
end
-- 代价: 把怪兽送去墓地
function RushDuel.CostSendMZoneToGrave(filter, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToGrave(filter, LOCATION_MZONE, min, max, except_self, false, false, set_label_before,
        set_object_before, set_label_after, set_object_after)
end
-- 代价: 把怪兽送去墓地 (子卡片组)
function RushDuel.CostSendMZoneSubToGrave(filter, check, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendGroupToGrave(filter, check, LOCATION_MZONE, min, max, except_self, false, false,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 把场上的卡送去墓地
function RushDuel.CostSendOnFieldToGrave(filter, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToGrave(filter, LOCATION_ONFIELD, min, max, except_self, false, false,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 把场上的卡送去墓地 (子卡片组)
function RushDuel.CostSendOnFieldSubToGrave(filter, check, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendGroupToGrave(filter, check, LOCATION_ONFIELD, min, max, except_self, false, false,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 把手卡·场上的卡送去墓地
function RushDuel.CostSendHandOrFieldToGrave(filter, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToGrave(filter, LOCATION_HAND + LOCATION_ONFIELD, min, max, except_self, false, false,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 把手卡·场上的卡送去墓地 (子卡片组)
function RushDuel.CostSendHandOrFieldSubToGrave(filter, check, min, max, except_self, set_label_before,
    set_object_before, set_label_after, set_object_after)
    return RushDuel.CostSendGroupToGrave(filter, check, LOCATION_HAND + LOCATION_ONFIELD, min, max, except_self, false,
        false, set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让自己场上表侧表示的这张卡回到卡组
function RushDuel.CostSendSelfToDeck()
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return e:GetHandler():IsAbleToDeckAsCost()
        end
        RushDuel.SendToDeckSort(e:GetHandler(), SEQ_DECKSHUFFLE, REASON_COST, tp)
        return true
    end
end
-- 代价: 让自己场上表侧表示的这张卡回到卡组上面
function RushDuel.CostSendSelfToDeckTop()
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return e:GetHandler():IsAbleToDeckAsCost()
        end
        RushDuel.SendToDeckSort(e:GetHandler(), SEQ_DECKTOP, REASON_COST, tp)
        return true
    end
end
-- 代价: 让自己场上表侧表示的这张卡回到卡组下面
function RushDuel.CostSendSelfToDeckBottom()
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return e:GetHandler():IsAbleToDeckAsCost()
        end
        RushDuel.SendToDeckSort(e:GetHandler(), SEQ_DECKBOTTOM, REASON_COST, tp)
        return true
    end
end
-- 代价: 让自己场上表侧表示的这张卡回到额外卡组
function RushDuel.CostSendSelfToExtra()
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return e:GetHandler():IsAbleToExtraAsCost()
        end
        Duel.SendtoDeck(RushDuel.ToMaximunGroup(e:GetHandler()), nil, SEQ_DECKSHUFFLE, REASON_COST)
        return true
    end
end
-- 代价: 让怪兽返回卡组
function RushDuel.CostSendMZoneToDeck(filter, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_MZONE, min, max, except_self, SEQ_DECKSHUFFLE, true, false,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让怪兽返回卡组下面
function RushDuel.CostSendMZoneToDeckBottom(filter, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_MZONE, min, max, except_self, SEQ_DECKBOTTOM, true, false,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让怪兽返回卡组上面或下面
function RushDuel.CostSendMZoneToDeckTopOrBottom(filter, min, max, top_desc, bottom_desc, except_self, set_label_before,
    set_object_before, set_label_after, set_object_after)
    return RushDuel.CostSendMatchToDeckTopOrBottom(filter, LOCATION_MZONE, min, max, except_self, top_desc, bottom_desc,
        true, false, set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让场上的卡返回卡组
function RushDuel.CostSendOnFieldToDeck(filter, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_ONFIELD, min, max, except_self, SEQ_DECKSHUFFLE, true,
        false, set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让场上的卡返回卡组下面
function RushDuel.CostSendOnFieldToDeckBottom(filter, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_ONFIELD, min, max, except_self, SEQ_DECKBOTTOM, true,
        false, set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 把手卡返回卡组
function RushDuel.CostSendHandToDeck(filter, min, max, confirm, set_label_before, set_object_before, set_label_after,
    set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_HAND, min, max, true, SEQ_DECKSHUFFLE, false, confirm,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 把手卡返回卡组上面
function RushDuel.CostSendHandToDeckTop(filter, min, max, confirm, set_label_before, set_object_before, set_label_after,
    set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_HAND, min, max, true, SEQ_DECKTOP, false, confirm,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 把手卡返回卡组下面
function RushDuel.CostSendHandToDeckBottom(filter, min, max, confirm, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_HAND, min, max, true, SEQ_DECKBOTTOM, false, confirm,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 把手卡返回卡组上面或下面
function RushDuel.CostSendHandToDeckTopOrBottom(filter, min, max, top_desc, bottom_desc, confirm, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToDeckTopOrBottom(filter, LOCATION_HAND, min, max, true, top_desc, bottom_desc,
        false, confirm, set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让墓地的卡返回卡组
function RushDuel.CostSendGraveToDeck(filter, min, max, set_label_before, set_object_before, set_label_after,
    set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_GRAVE, min, max, false, SEQ_DECKSHUFFLE, false, true,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让墓地的卡返回卡组 (子卡片组)
function RushDuel.CostSendGraveSubToDeck(filter, check, min, max, set_label_before, set_object_before, set_label_after,
    set_object_after)
    return RushDuel.CostSendGroupToDeckSort(filter, check, LOCATION_GRAVE, min, max, false, SEQ_DECKSHUFFLE, false,
        true, set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让墓地的卡返回卡组上面
function RushDuel.CostSendGraveToDeckTop(filter, min, max, set_label_before, set_object_before, set_label_after,
    set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_GRAVE, min, max, false, SEQ_DECKTOP, false, true,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让墓地的卡返回卡组上面 (子卡片组)
function RushDuel.CostSendGraveSubToDeckTop(filter, check, min, max, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendGroupToDeckSort(filter, check, LOCATION_GRAVE, min, max, false, SEQ_DECKTOP, false, true,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让墓地的卡返回卡组下面
function RushDuel.CostSendGraveToDeckBottom(filter, min, max, set_label_before, set_object_before, set_label_after,
    set_object_after)
    return RushDuel.CostSendMatchToDeckSort(filter, LOCATION_GRAVE, min, max, false, SEQ_DECKBOTTOM, false, true,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让墓地的卡返回卡组下面 (子卡片组)
function RushDuel.CostSendGraveSubToDeckBottom(filter, check, min, max, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendGroupToDeckSort(filter, check, LOCATION_GRAVE, min, max, false, SEQ_DECKBOTTOM, false, true,
        set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让墓地的卡返回卡组上面或下面
function RushDuel.CostSendGraveToDeckTopOrBottom(filter, min, max, top_desc, bottom_desc, set_label_before,
    set_object_before, set_label_after, set_object_after)
    return RushDuel.CostSendMatchToDeckTopOrBottom(filter, LOCATION_GRAVE, min, max, false, top_desc, bottom_desc,
        false, true, set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让墓地的卡返回卡组上面或下面 (子卡片组)
function RushDuel.CostSendGraveSubToDeckTopOrBottom(filter, check, min, max, top_desc, bottom_desc, set_label_before,
    set_object_before, set_label_after, set_object_after)
    return RushDuel.CostSendGroupToDeckTopOrBottom(filter, check, LOCATION_GRAVE, min, max, false, top_desc,
        bottom_desc, false, true, set_label_before, set_object_before, set_label_after, set_object_after)
end
-- 代价: 让怪兽返回手卡
function RushDuel.CostSendMZoneToHand(filter, min, max, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    return RushDuel.CostSendMatchToHand(filter, LOCATION_MZONE, min, max, except_self, false, true, set_label_before,
        set_object_before, set_label_after, set_object_after)
end
-- 代价: 改变怪兽的表示形式
function RushDuel.CostChangePosition(filter, min, max, position, except_self, set_label_before, set_object_before,
    set_label_after, set_object_after)
    local action = RushDuel._private_action_change_position(position, set_label_before, set_object_before,
        set_label_after, set_object_after)
    return RushDuel._private_cost_select_match(HINTMSG_POSCHANGE, filter, LOCATION_MZONE, 0, min, max, except_self,
        action)
end
-- 代价: 让自己场上表侧表示的这张卡返回手卡
function RushDuel.CostSendSelfToHand()
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return e:GetHandler():IsAbleToHandAsCost()
        end
        Duel.SendtoHand(RushDuel.ToMaximunGroup(e:GetHandler()), nil, REASON_COST)
        return true
    end
end
-- 代价: 改变自身的表示形式
function RushDuel.CostChangeSelfPosition(pos1, pos2)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        local c = e:GetHandler()
        if chk == 0 then
            return (not pos1 or c:IsPosition(pos1)) and RushDuel.IsCanChangePosition(c, e, tp, REASON_COST)
        end
        if pos2 then
            RushDuel.ChangePosition(c, e, tp, REASON_COST, pos2)
        else
            RushDuel.ChangePosition(c, e, tp, REASON_COST)
        end
        return true
    end
end

-- 代价: 合并2个代价
function RushDuel.CostMerge(cost1, cost2)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then
            return cost1(e, tp, eg, ep, ev, re, r, rp, chk) and cost2(e, tp, eg, ep, ev, re, r, rp, chk)
        end
        cost1(e, tp, eg, ep, ev, re, r, rp, chk)
        cost2(e, tp, eg, ep, ev, re, r, rp, chk)
    end
end
-- 代价: 从2个代价中选择1个(分开选)
function RushDuel.CostChoose(hit1, cost1, hit2, cost2, set_label)
    return function(e, tp, eg, ep, ev, re, r, rp, chk)
        local s1 = cost1(e, tp, eg, ep, ev, re, r, rp, 0)
        local s2 = cost2(e, tp, eg, ep, ev, re, r, rp, 0)
        if chk == 0 then
            return s1 or s2
        end
        local res = 0
        if s1 and s2 then
            RushDuel.CostCancelable = true
            ::cancel::
            res = RushDuel.SelectOption(tp, {s1, hit1}, {s2, hit2})
            if res == 1 then
                if not cost1(e, tp, eg, ep, ev, re, r, rp, 1) then
                    goto cancel
                end
            elseif res == 2 then
                if not cost2(e, tp, eg, ep, ev, re, r, rp, 1) then
                    goto cancel
                end
            end
            RushDuel.CostCancelable = false
        elseif s1 then
            cost1(e, tp, eg, ep, ev, re, r, rp, 1)
            res = 1
        elseif s2 then
            cost2(e, tp, eg, ep, ev, re, r, rp, 1)
            res = 2
        end
        if res ~= 0 and set_label then
            e:SetLabel(res)
        end
    end
end
