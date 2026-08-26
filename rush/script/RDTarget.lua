-- Rush Duel 对象
RushDuel = RushDuel or {}

-- 对玩家效果: 抽卡 - 对象
function RushDuel.TargetDraw(player, count)
    Duel.SetTargetPlayer(player)
    Duel.SetTargetParam(count)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, player, count)
end
-- 对玩家效果: 恢复 - 对象
function RushDuel.TargetRecover(player, recover)
    Duel.SetTargetPlayer(player)
    Duel.SetTargetParam(recover)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, player, recover)
end
-- 对玩家效果: 伤害 - 对象
function RushDuel.TargetDamage(player, damage)
    Duel.SetTargetPlayer(player)
    Duel.SetTargetParam(damage)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, player, damage)
end
-- 对玩家效果: 盲堆 - 对象
function RushDuel.TargetDiscardDeck(player, count)
    Duel.SetTargetPlayer(player)
    Duel.SetTargetParam(count)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, player, count)
end
-- 对玩家效果: 宣言卡片的种类（怪兽·魔法·陷阱）
function RushDuel.TargetAnnounceType(player)
    Duel.SetTargetParam(Duel.AnnounceType(player))
end

-- 对玩家效果: 抽卡 - 结算
function RushDuel.Draw(player, count)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    return Duel.Draw(player or p, count or d, REASON_EFFECT)
end
-- 对玩家效果: 恢复 - 结算
function RushDuel.Recover(player, recover)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    return Duel.Recover(player or p, recover or d, REASON_EFFECT)
end
-- 对玩家效果: 伤害 - 结算
function RushDuel.Damage(player, damage)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    return Duel.Damage(player or p, damage or d, REASON_EFFECT)
end
-- 对玩家效果: 盲堆 - 结算
function RushDuel.DiscardDeck(player, count)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    return Duel.DiscardDeck(player or p, count or d, REASON_EFFECT)
end
