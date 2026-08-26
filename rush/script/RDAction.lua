-- Rush Duel 操作
RushDuel = RushDuel or {}

-- 特殊调整，里侧守备表示特殊召唤时需要给对方确认
RushDuel.FaceDownSpecialSummonConfirm = false

-- 内部方法: 选择匹配卡片, 执行操作
function RushDuel._private_action_select_match(hint, filter, tp, s_range, o_range, min, max, expect, hint_selection, confirm, action, ...)
    local g = Duel.GetMatchingGroup(filter, tp, s_range, o_range, expect, ...)
    if #g >= min then
        local sg = RushDuel.Select(hint, tp, g, nil, false, min, max)
        if sg and #sg > 0 then
            RushDuel.HintOrConfirm(sg, hint_selection, confirm, 1 - tp)
            return action(sg, ...)
        end
    end
    return 0
end
-- 内部方法: 可以选择匹配卡片, 执行操作
function RushDuel._private_action_can_select_match(desc, hint, filter, tp, s_range, o_range, min, max, expect, hint_selection, confirm, action, ...)
    local g = Duel.GetMatchingGroup(filter, tp, s_range, o_range, expect, ...)
    if #g >= min then
        local sg = RushDuel.CanSelect(desc, hint, tp, g, nil, min, max)
        if sg and #sg > 0 then
            RushDuel.HintOrConfirm(sg, hint_selection, confirm, 1 - tp)
            return action(sg, ...)
        end
    end
    return 0
end
-- 内部方法: 选择子卡片组, 执行操作
function RushDuel._private_action_select_group(hint, filter, check, tp, s_range, o_range, min, max, expect, hint_selection, confirm, action, ...)
    local g = Duel.GetMatchingGroup(filter, tp, s_range, o_range, expect, ...)
    if g:CheckSubGroup(check, min, max, ...) then
        local sg = RushDuel.Select(hint, tp, g, check, false, min, max, ...)
        if sg and #sg > 0 then
            RushDuel.HintOrConfirm(sg, hint_selection, confirm, 1 - tp)
            return action(sg, ...)
        end
    end
    return 0
end
-- 内部方法: 可以选择子卡片组, 执行操作
function RushDuel._private_action_can_select_group(desc, hint, filter, check, tp, s_range, o_range, min, max, expect, hint_selection, confirm, action, ...)
    local g = Duel.GetMatchingGroup(filter, tp, s_range, o_range, expect, ...)
    if g:CheckSubGroup(check, min, max, ...) then
        local sg = RushDuel.CanSelect(desc, hint, tp, g, check, min, max)
        if sg and #sg > 0 then
            RushDuel.HintOrConfirm(sg, hint_selection, confirm, 1 - tp)
            return action(sg, ...)
        end
    end
    return 0
end
-- 内部方法: 是否包含公开区域
function RushDuel._private_is_include_public(s_range, o_range)
    return (s_range | o_range) & (LOCATION_ONFIELD | LOCATION_GRAVE | LOCATION_REMOVED) ~= 0
end
-- 内部方法: 是否需要给对方确认
function RushDuel._private_is_confirm_card(c)
    return c:GetSummonLocation() ~= LOCATION_HAND
end
-- 内部方法: 特殊召唤
function RushDuel._special_summon(target, effect, player, position, break_effect, target_player)
    if break_effect then
        Duel.BreakEffect()
    end
    local ct = Duel.SpecialSummon(target, 0, player, target_player or player, false, false, position)
    if (position & POS_FACEDOWN) ~= 0 then
        local og = Duel.GetOperatedGroup():Filter(Card.IsFacedown, nil)
        if RushDuel.FaceDownSpecialSummonConfirm then
            if #og > 0 then
                Duel.ConfirmCards(1 - player, og)
            end
        else
            local confirm = og:Filter(RushDuel._private_is_confirm_card, nil)
            if confirm:GetCount() > 0 then
                Duel.ConfirmCards(1 - player, confirm)
            end
        end
        if #og > 1 then
            Duel.ShuffleSetCard(og)
        end
    end
    RushDuel.FaceDownSpecialSummonConfirm = false
    return ct
end
-- 内部方法: 盖放魔法陷阱
function RushDuel._set_spell_trap(target, effect, player, break_effect)
    if break_effect then
        Duel.BreakEffect()
    end
    local confirm = true
    -- 全部都是从手卡盖放的场合, 不需要给对方确认
    if target:FilterCount(Card.IsLocation, nil, LOCATION_HAND) == #target then
        confirm = false
    end
    return Duel.SSet(player, target, player, confirm)
end

-- 操作: 选择匹配卡片
function RushDuel.SelectAndDoAction(hint, filter, tp, s_range, o_range, min, max, expect, action)
    local hint_selection = RushDuel._private_is_include_public(s_range, o_range)
    return RushDuel._private_action_select_match(hint, filter, tp, s_range, o_range, min, max, expect, hint_selection, false, action)
end
-- 可选操作: 选择匹配卡片
function RushDuel.CanSelectAndDoAction(desc, hint, filter, tp, s_range, o_range, min, max, expect, action)
    local hint_selection = RushDuel._private_is_include_public(s_range, o_range)
    return RushDuel._private_action_can_select_match(desc, hint, filter, tp, s_range, o_range, min, max, expect, hint_selection, false, action)
end
-- 操作: 选择子卡片组
function RushDuel.SelectGroupAndDoAction(hint, filter, check, tp, s_range, o_range, min, max, expect, action)
    local hint_selection = RushDuel._private_is_include_public(s_range, o_range)
    return RushDuel._private_action_select_group(hint, filter, check, tp, s_range, o_range, min, max, expect, hint_selection, false, action)
end
-- 可选操作: 选择子卡片组
function RushDuel.CanSelectGroupAndDoAction(desc, hint, filter, check, tp, s_range, o_range, min, max, expect, action)
    local hint_selection = RushDuel._private_is_include_public(s_range, o_range)
    return RushDuel._private_action_can_select_group(desc, hint, filter, check, tp, s_range, o_range, min, max, expect, hint_selection, false, action)
end

-- 操作: 选择怪兽特殊召唤
function RushDuel.SelectAndSpecialSummon(filter, tp, s_range, o_range, min, max, expect, e, pos, break_effect, target_player)
    local ct = RushDuel.GetMZoneCount(target_player or tp, max)
    if ct >= min then
        return RushDuel._private_action_select_match(HINTMSG_SPSUMMON, filter, tp, s_range, o_range, min, ct, expect, false, false, RushDuel._special_summon, e, tp, pos, break_effect, target_player)
    end
    return 0
end
-- 可选操作: 选择怪兽特殊召唤
function RushDuel.CanSelectAndSpecialSummon(desc, filter, tp, s_range, o_range, min, max, expect, e, pos, break_effect, target_player)
    local ct = RushDuel.GetMZoneCount(target_player or tp, max)
    if ct >= min then
        return RushDuel._private_action_can_select_match(desc, HINTMSG_SPSUMMON, filter, tp, s_range, o_range, min, ct, expect, false, false, RushDuel._special_summon, e, tp, pos, break_effect,
            target_player)
    end
    return 0
end
-- 操作: 选择怪兽特殊召唤 (子卡片组)
function RushDuel.SelectGroupAndSpecialSummon(filter, check, tp, s_range, o_range, min, max, expect, e, pos, break_effect, target_player)
    local ct = RushDuel.GetMZoneCount(target_player or tp, max)
    if ct >= min then
        return RushDuel._private_action_select_group(HINTMSG_SPSUMMON, filter, check, tp, s_range, o_range, min, ct, expect, false, false, RushDuel._special_summon, e, tp, pos, break_effect,
            target_player)
    end
    return 0
end
-- 可选操作: 选择怪兽特殊召唤 (子卡片组)
function RushDuel.CanSelectGroupAndSpecialSummon(desc, filter, check, tp, s_range, o_range, min, max, expect, e, pos, break_effect, target_player)
    local ct = RushDuel.GetMZoneCount(target_player or tp, max)
    if ct >= min then
        return RushDuel._private_action_can_select_group(desc, HINTMSG_SPSUMMON, filter, check, tp, s_range, o_range, min, ct, expect, false, false, RushDuel._special_summon, e, tp, pos, break_effect,
            target_player)
    end
    return 0
end
-- 操作: 选择怪兽加入手卡或者特殊召唤 (限定 1 只怪兽)
function RushDuel.SelectAndToHandOrSpecialSummon(hint, filter, tp, s_range, o_range, expect, e, pos, break_effect, target_player)
    return RushDuel._private_action_select_match(hint, filter, tp, s_range, o_range, 1, 1, expect, false, false, function(g)
        local tc = g:GetFirst()
        local ft = RushDuel.GetMZoneCount(target_player or tp, 1)
        if tc:IsAbleToHand() and (not RD.IsCanBeSpecialSummoned(tc, e, tp, pos) or ft <= 0 or Duel.SelectOption(tp, 1190, 1152) == 0) then
            if break_effect then
                Duel.BreakEffect()
            end
            return RushDuel.SendToHandAndExists(tc, e, tp, REASON_EFFECT)
        else
            return RushDuel._special_summon(tc, e, tp, pos, break_effect, target_player)~=0
        end
    end, e, tp)
end
-- 可选操作: 选择怪兽加入手卡或者特殊召唤 (限定 1 只怪兽)
function RushDuel.CanSelectAndToHandOrSpecialSummon(desc, hint, filter, tp, s_range, o_range, expect, e, pos, break_effect, target_player)
    return RushDuel._private_action_can_select_match(desc, hint, filter, tp, s_range, o_range, 1, 1, expect, false, false, function(g)
        local tc = g:GetFirst()
        local ft = RushDuel.GetMZoneCount(target_player or tp, 1)
        if tc:IsAbleToHand() and (not RD.IsCanBeSpecialSummoned(tc, e, tp, pos) or ft <= 0 or Duel.SelectOption(tp, 1190, 1152) == 0) then
            if break_effect then
                Duel.BreakEffect()
            end
            return RushDuel.SendToHandAndExists(tc, e, tp, REASON_EFFECT)
        else
            return RushDuel._special_summon(tc, e, tp, pos, break_effect, target_player)~=0
        end
    end, e, tp)
end
-- 操作: 选择魔法, 陷阱卡盖放
function RushDuel.SelectAndSet(filter, tp, s_range, o_range, min, max, expect, e, break_effect)
    local ct = RushDuel.GetSZoneCount(tp, max)
    if ct >= min then
        return RushDuel._private_action_select_match(HINTMSG_SET, filter, tp, s_range, o_range, min, ct, expect, false, false, RushDuel._set_spell_trap, e, tp, break_effect)
    end
    return 0
end
-- 可选操作: 选择魔法, 陷阱卡盖放
function RushDuel.CanSelectAndSet(desc, filter, tp, s_range, o_range, min, max, expect, e, break_effect)
    local ct = RushDuel.GetSZoneCount(tp, max)
    if ct >= min then
        return RushDuel._private_action_can_select_match(desc, HINTMSG_SET, filter, tp, s_range, o_range, min, ct, expect, false, false, RushDuel._set_spell_trap, e, tp, break_effect)
    end
    return 0
end
-- 操作: 选择魔法, 陷阱卡盖放 (子卡片组)
function RushDuel.SelectGroupAndSet(filter, check, tp, s_range, o_range, min, max, expect, e, break_effect)
    local ct = RushDuel.GetSZoneCount(tp, max)
    if ct >= min then
        return RushDuel._private_action_select_group(HINTMSG_SET, filter, check, tp, s_range, o_range, min, ct, expect, false, false, RushDuel._set_spell_trap, e, tp, break_effect)
    end
    return 0
end
-- 可选操作: 选择魔法, 陷阱卡盖放 (子卡片组)
function RushDuel.CanSelectGroupAndSet(desc, filter, check, tp, s_range, o_range, min, max, expect, e, break_effect)
    local ct = RushDuel.GetSZoneCount(tp, max)
    if ct >= min then
        return RushDuel._private_action_can_select_group(desc, HINTMSG_SET, filter, check, tp, s_range, o_range, min, ct, expect, false, false, RushDuel._set_spell_trap, e, tp, break_effect)
    end
    return 0
end

-- 过滤可以改变表示形式的卡
function RushDuel.FilterChangePositionTarget(card, effect, player, reason, hints)
    local effects = {card:IsHasEffect(EFFECT_CANNOT_CHANGE_POSITION_EFFECT)}
    for i, e in ipairs(effects) do
        local value = e:GetValue()
        if value == 1 then
            hints:AddCard(e:GetHandler())
            return false
        elseif type(value) == "function" and value(e, effect, reason, player) then
            hints:AddCard(e:GetHandler())
            return false
        end
    end
    return true
end
-- 操作: 改变表示形式
function RushDuel.ChangePosition(target, effect, player, reason, pos)
    local hints = Group.CreateGroup()
    local group = RushDuel.ToGroup(target):Filter(RushDuel.FilterChangePositionTarget, nil, effect, player, reason, hints)
    local tc = hints:GetFirst()
    if tc then
        Duel.Hint(HINT_CARD, 0, tc:GetOriginalCode())
    end
    if group:GetCount() > 0 then
        if pos == nil then
            return Duel.ChangePosition(group, POS_FACEUP_DEFENSE, POS_FACEUP_DEFENSE, POS_FACEUP_ATTACK, POS_FACEUP_ATTACK)
        else
            return Duel.ChangePosition(group, pos)
        end
    else
        return 0
    end
end

-- 过滤可以加入手卡的卡
function RushDuel.FilterToHandTarget(card, effect, player, reason, hints)
    if effect:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) then
        return true
    end
    local effects = {card:IsHasEffect(EFFECT_CANNOT_TO_HAND_EFFECT)}
    for i, e in ipairs(effects) do
        local value = e:GetValue()
        if value == 1 then
            hints:AddCard(e:GetHandler())
            return false
        elseif type(value) == "function" and value(e, effect, reason, player) then
            hints:AddCard(e:GetHandler())
            return false
        end
    end
    return true
end
-- 过滤需要给对方确认的卡
function RushDuel.FilterToHandConfirm(card, player)
    return card:IsControler(player) and card:IsPreviousLocation(LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED)
end
-- 操作: 加入/返回手卡, 并给对方确认加入自己手卡的卡
function RushDuel.SendToHandAndExists(target, effect, player, reason, filter, count, expect)
    local hints = Group.CreateGroup()
    local group = RushDuel.ToGroup(target):Filter(RushDuel.FilterToHandTarget, nil, effect, player, reason, hints)
    local g = RushDuel.ToMaximunGroup(group)
    local tc = hints:GetFirst()
    if tc then
        Duel.Hint(HINT_CARD, 0, tc:GetOriginalCode())
    end
    if #g == 0 then
        return false
    end
    if Duel.SendtoHand(g, nil, REASON_EFFECT) == 0 then
        return false
    end
    local cg = g:Filter(RushDuel.FilterToHandConfirm, nil, player)
    if #cg > 0 then
        Duel.ConfirmCards(1 - player, cg)
    end
    return RushDuel.IsOperatedGroupExists(filter, count, expect)
end

-- 操作: 送去墓地
function RushDuel.SendToGraveAndExists(target, filter, count, expect)
    local g = RushDuel.ToMaximunGroup(target)
    return Duel.SendtoGrave(g, REASON_EFFECT) ~= 0 and RushDuel.IsOperatedGroupExists(filter, count, expect)
end
-- 操作: 从卡组上面把卡送去墓地
function RushDuel.SendDeckTopToGraveAndExists(player, card_count, filter, count, expect)
    return Duel.DiscardDeck(player, card_count, REASON_EFFECT) ~= 0 and RushDuel.IsOperatedGroupExists(filter, count, expect)
end
-- 操作: 从卡组下面把卡送去墓地
function RushDuel.SendDeckBottomToGraveAndExists(player, card_count, filter, count, expect)
    local dg = RushDuel.GetDeckBottomGroup(player, card_count)
    if #dg == 0 then
        return false
    end
    Duel.DisableShuffleCheck()
    return Duel.SendtoGrave(dg, REASON_EFFECT) ~= 0 and RushDuel.IsOperatedGroupExists(filter, count, expect)
end
-- 操作: 随机选对方的手卡送去墓地
function RushDuel.SendOpponentHandToGrave(tp, hint, min, max)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
    local ct = #g
    if ct < min then
        return 0
    end
    local ops = {}
    for i = min, math.min(max, ct) do
        table.insert(ops, i)
    end
    local ac = 0
    if #ops == 1 then
        ac = table.remove(ops)
    elseif #ops > 1 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_OPERATE_COUNT)
        ac = Duel.AnnounceNumber(tp, table.unpack(ops))
    end
    if ac > 0 then
        local sg = g:RandomSelect(tp, ac)
        return Duel.SendtoGrave(sg, REASON_EFFECT)
    end
    return 0
end
-- 可选操作: 随机选对方的手卡送去墓地
function RushDuel.CanSendOpponentHandToGrave(desc, tp, hint, min, max, break_effect)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
    local ct = #g
    if ct > 0 and Duel.SelectYesNo(tp, desc) then
        if break_effect then
            Duel.BreakEffect()
        end
        return RushDuel.SendOpponentHandToGrave(tp, hint, min, max)
    end
    return 0
end

-- 过滤可以加入卡组的卡
function RushDuel.FilterToDeckTarget(card, effect, player, reason, hints)
    if effect:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) then
        return true
    end
    local effects = {card:IsHasEffect(EFFECT_CANNOT_TO_DECK_EFFECT)}
    for i, e in ipairs(effects) do
        local value = e:GetValue()
        if value == 1 then
            hints:AddCard(e:GetHandler())
            return false
        elseif type(value) == "function" and value(e, effect, reason, player) then
            hints:AddCard(e:GetHandler())
            return false
        end
    end
    return true
end
-- 操作: 返回卡组
function RushDuel.SendToDeckAndExists(target, effect, player, reason, filter, count, expect)
    local hints = Group.CreateGroup()
    local group = RushDuel.ToGroup(target):Filter(RushDuel.FilterToDeckTarget, nil, effect, player, reason, hints)
    local g = RushDuel.ToMaximunGroup(group)
    local tc = hints:GetFirst()
    if tc then
        Duel.Hint(HINT_CARD, 0, tc:GetOriginalCode())
    end
    if #g == 0 then
        return false
    end
    return Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) ~= 0 and RushDuel.IsOperatedGroupExists(filter, count, expect)
end
-- 操作: 返回卡组上面 (排序)
function RushDuel.SendToDeckTop(target, effect, player, reason)
    local hints = Group.CreateGroup()
    local group = RushDuel.ToGroup(target):Filter(RushDuel.FilterToDeckTarget, nil, effect, player, reason, hints)
    local g = RushDuel.ToMaximunGroup(group)
    local tc = hints:GetFirst()
    if tc then
        Duel.Hint(HINT_CARD, 0, tc:GetOriginalCode())
    end
    if #g == 0 then
        return 0
    end
    local og, ct = RushDuel.SendToDeckSort(g, SEQ_DECKTOP, REASON_EFFECT, player)
    return ct
end
-- 操作: 返回卡组下面 (排序)
function RushDuel.SendToDeckBottom(target, effect, player, reason)
    local hints = Group.CreateGroup()
    local group = RushDuel.ToGroup(target):Filter(RushDuel.FilterToDeckTarget, nil, effect, player, reason, hints)
    local g = RushDuel.ToMaximunGroup(group)
    local tc = hints:GetFirst()
    if tc then
        Duel.Hint(HINT_CARD, 0, tc:GetOriginalCode())
    end
    if #g == 0 then
        return 0
    end
    local og, ct = RushDuel.SendToDeckSort(g, SEQ_DECKBOTTOM, REASON_EFFECT, player)
    return ct
end
-- 操作: 返回卡组上面或下面 (排序)
function RushDuel.SendToDeckTopOrBottom(target, effect, player, reason, top_desc, bottom_desc)
    local sequence = Duel.SelectOption(player, top_desc, bottom_desc)
    if sequence == 0 then
	    RD.NeedShuffleHand[player + 1] = true
        return RushDuel.SendToDeckTop(target, effect, player, reason)
    else
        return RushDuel.SendToDeckBottom(target, effect, player, reason)
    end
end

-- 操作: 翻开卡组并选择卡
function RushDuel.RevealDeckTopAndSelect(player, count, hint, filter, min, max, ...)
    Duel.ConfirmDecktop(player, count)
    local g = Duel.GetDecktopGroup(player, count)
    local mg = g:Filter(filter, nil, ...)
    if #mg >= min then
        local sg = RushDuel.Select(hint, player, mg, nil, false, min, max)
        if sg and #sg > 0 then
            g:Sub(sg)
            return sg, g
        end
    else
        return Group.CreateGroup(), g
    end
end
-- 操作: 翻开卡组并可以选择卡
function RushDuel.RevealDeckTopAndCanSelect(player, count, desc, hint, filter, min, max, ...)
    Duel.ConfirmDecktop(player, count)
    local g = Duel.GetDecktopGroup(player, count)
    local mg = g:Filter(filter, nil, ...)
    if #mg >= min then
        local sg = RushDuel.CanSelect(desc, hint, player, mg, nil, min, max)
        if sg and #sg > 0 then
            g:Sub(sg)
            return sg, g
        end
    end
    return Group.CreateGroup(), g
end
-- 操作: 翻开卡组并可以选择卡 (子卡片组)
function RushDuel.RevealDeckTopAndCanSelectGroup(player, count, desc, hint, filter, check, min, max, ...)
    Duel.ConfirmDecktop(player, count)
    local g = Duel.GetDecktopGroup(player, count)
    local mg = g:Filter(filter, nil, ...)
    if mg:CheckSubGroup(check, min, max, ...) then
        local sg = RushDuel.CanSelect(desc, hint, player, mg, check, min, max, ...)
        if sg and #sg > 0 then
            g:Sub(sg)
            return sg, g
        end
    end
    return Group.CreateGroup(), g
end
-- 操作: 翻开卡组并可以选择卡(包含额外的卡片组)
function RushDuel.RevealDeckTopAndCanSelectEx(player, count, exg, desc, hint, filter, min, max, ...)
    Duel.ConfirmDecktop(player, count)
    local g = Duel.GetDecktopGroup(player, count)
    local mg = g:Filter(filter, nil, ...)
    mg:Merge(exg)
    if #mg >= min then
        local sg = RushDuel.CanSelect(desc, hint, player, mg, nil, min, max)
        if sg and #sg > 0 then
            g:Sub(sg)
            return sg, g
        end
    end
    return Group.CreateGroup(), g
end
-- 操作: 从卡组上面把卡送去墓地, 并选择被送去墓地的卡片
function RushDuel.SendDeckTopToGraveAndSelect(player, count, hint, filter, min, max, ...)
    if Duel.DiscardDeck(player, count, REASON_EFFECT) ~= 0 then
        local g = Duel.GetOperatedGroup()
        local mg = g:Filter(filter, nil, ...)
        if #mg >= min then
            local sg = RushDuel.Select(hint, player, mg, nil, false, min, max)
            if sg and #sg > 0 then
                g:Sub(sg)
                return sg, g
            end
        end
        return Group.CreateGroup(), g
    end
    return Group.CreateGroup(), Group.CreateGroup()
end
-- 操作: 从卡组上面把卡送去墓地, 并可以选择被送去墓地的卡片
function RushDuel.SendDeckTopToGraveAndCanSelect(player, count, desc, hint, filter, min, max, ...)
    if Duel.DiscardDeck(player, count, REASON_EFFECT) ~= 0 then
        local g = Duel.GetOperatedGroup()
        local mg = g:Filter(filter, nil, ...)
        if #mg >= min then
            local sg = RushDuel.CanSelect(desc, hint, player, mg, nil, min, max)
            if sg and #sg > 0 then
                g:Sub(sg)
                return sg, g
            end
        end
        return Group.CreateGroup(), g
    end
    return Group.CreateGroup(), Group.CreateGroup()
end
-- 操作: 从卡组上面把卡送去墓地, 并可以选择被送去墓地的卡片 (子卡片组)
function RushDuel.SendDeckTopToGraveAndCanSelectGroup(player, count, desc, hint, filter, check, min, max, ...)
    if Duel.DiscardDeck(player, count, REASON_EFFECT) ~= 0 then
        local g = Duel.GetOperatedGroup()
        local mg = g:Filter(filter, nil, ...)
        if #mg >= min then
            local sg = RushDuel.CanSelect(desc, hint, player, mg, check, min, max, ...)
            if sg and #sg > 0 then
                g:Sub(sg)
                return sg, g
            end
        end
        return Group.CreateGroup(), g
    end
    return Group.CreateGroup(), Group.CreateGroup()
end
-- 可选操作: 把怪兽或魔陷盖放
function RushDuel.CanSetCard(player, desc, card, effect, break_effect)
    local b1 = card:IsType(TYPE_MONSTER) and Duel.GetLocationCount(player, LOCATION_MZONE) > 0 and card:IsCanBeSpecialSummoned(effect, 0, player, false, false, POS_FACEDOWN_DEFENSE)
    local b2 = card:IsType(TYPE_SPELL + TYPE_TRAP) and card:IsSSetable() and (card:IsType(TYPE_FIELD) or Duel.GetLocationCount(player, LOCATION_SZONE) > 0)
    if (b1 or b2) and Duel.SelectEffectYesNo(player, card, desc) then
        if break_effect then
            Duel.BreakEffect()
        end
        if b1 then
            Duel.SpecialSummon(card, 0, player, player, false, false, POS_FACEDOWN_DEFENSE)
            Duel.ConfirmCards(1 - player, card)
            return true
        else
            Duel.SSet(player, card)
            return true
        end
    end
    return false
end
-- 操作: 改变攻击对象
function RushDuel.ChangeAttackTarget(card, player, target)
    local g = card:GetAttackableTarget()
    Duel.Hint(HINT_SELECTMSG, player, HINTMSG_ATTACKTARGET)
    local sg = g:Select(player, 1, 1, nil)
    local tc = sg:GetFirst()
    return tc and (tc == target or Duel.ChangeAttackTarget(tc))
end
-- 操作: 结束当前阶段
function RushDuel.SkipCurrentPhase()
    local player = Duel.GetTurnPlayer()
    local phase = Duel.GetCurrentPhase()
    Duel.SkipPhase(player, phase, RESET_PHASE + PHASE_END, 1)
    if phase == PHASE_MAIN1 or phase == PHASE_MAIN2 then
        Duel.RegisterFlagEffect(player, FLAG_SKIP_MAIN_PHASE, RESET_PHASE + PHASE_END, 0, 1)
    end
end

-- 可选操作: 抽卡
function RushDuel.CanDraw(desc, player, count, break_effect)
    if Duel.IsPlayerCanDraw(player, count) and Duel.SelectYesNo(player, desc) then
        if break_effect then
            Duel.BreakEffect()
        end
        return Duel.Draw(player, count, REASON_EFFECT)
    end
    return 0
end
-- 可选操作: 盲堆
function RushDuel.CanDiscardDeck(desc, player, min, max, break_effect, target_player)
    target_player = target_player or player
    if Duel.IsPlayerCanDiscardDeck(target_player, min) and Duel.SelectYesNo(player, desc) then
        if break_effect then
            Duel.BreakEffect()
        end
        max = max or min
        local ct = Duel.GetFieldGroupCount(target_player, LOCATION_DECK, 0)
        local ops = {}
        for i = min, math.min(max, ct) do
            if Duel.IsPlayerCanDiscardDeck(target_player, i) then
                table.insert(ops, i)
            end
        end
        local count = 0
        if #ops == 1 then
            count = table.remove(ops)
        elseif #ops > 1 then
            Duel.Hint(HINT_SELECTMSG, player, HINTMSG_OPERATE_COUNT)
            count = Duel.AnnounceNumber(player, table.unpack(ops))
        end
        return Duel.DiscardDeck(target_player, count, REASON_EFFECT)
    end
    return 0
end
-- 可选操作: 回复
function RushDuel.CanRecover(desc, player, recover, break_effect)
    if recover > 0 and Duel.SelectYesNo(player, desc) then
        if break_effect then
            Duel.BreakEffect()
        end
        return Duel.Recover(player, recover, REASON_EFFECT)
    end
    return 0
end
-- 可选操作: 伤害
function RushDuel.CanDamage(desc, player, damage, break_effect)
    if damage > 0 and Duel.SelectYesNo(player, desc) then
        if break_effect then
            Duel.BreakEffect()
        end
        return Duel.Damage(1 - player, damage, REASON_EFFECT)
    end
    return 0
end
