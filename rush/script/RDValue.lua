-- Rush Duel 效果值
RushDuel = RushDuel or {}

-- 内部方法: 双重解放的对象怪兽信息
function RushDuel._private_double_tribute_info(code, attribute, type, level, race, attack, defense)
    local info = {}
    info.code = code
    info.attribute = attribute
    info.type = type
    info.level = level
    info.race = race
    info.attack = attack
    info.defense = defense
    return info
end
-- 内部方法: 判断双重解放的对象怪兽是否重合
function RushDuel._private_is_double_tribute_info_different(info1, info2)
    if info1.code ~= info2.code then
        return true
    elseif info1.attribute ~= info2.attribute then
        return true
    elseif info1.type ~= info2.type then
        return true
    elseif info1.level ~= info2.level then
        return true
    elseif info1.race ~= info2.race then
        return true
    elseif info1.attack ~= info2.attack then
        return true
    elseif info1.defense ~= info2.defense then
        return true
    end
    return false
end

-- 效果值: 双重解放
function RushDuel.ValueDoubleTributeMix(ignore, code, attribute, type, level, race, attack, defense)
    return function(e, c)
        if e == nil then
            return ignore, RushDuel._private_double_tribute_info(code, attribute, type, level, race, attack, defense)
        end
        return (code == nil or c:IsCode(code))
            and (attribute == nil or c:IsAttribute(attribute))
            and (type == nil or c:IsType(type))
            and (level == nil or c:IsLevel(level))
            and (race == nil or c:IsRace(race))
            and (attack == nil or c:IsAttack(attack))
            and (defense == nil or c:IsDefense(defense))
    end
end
-- 效果值: 双重解放 全范围
function RushDuel.ValueDoubleTributeAll(ignore)
    return function(e, c)
        if e == nil then
            return ignore, 1
        end
        return true
    end
end
-- 效果值: 双重解放 卡名
function RushDuel.ValueDoubleTributeCode(code, ignore)
    return RushDuel.ValueDoubleTributeMix(ignore, code, nil, nil, nil, nil, nil, nil)
end
-- 效果值: 双重解放 属性/种族
function RushDuel.ValueDoubleTributeAttrRace(attribute, race, ignore)
    return RushDuel.ValueDoubleTributeMix(ignore, nil, attribute, nil, nil, race, nil, nil)
end
-- 效果值: 双重解放 属性/类型
function RushDuel.ValueDoubleTributeAttrType(attribute, type, ignore)
    return RushDuel.ValueDoubleTributeMix(ignore, nil, attribute, type, nil, nil, nil, nil)
end
-- 效果值: 双重解放 等级/属性/种族
function RushDuel.ValueDoubleTributeLvAttrRace(level, attribute, race, ignore)
    return RushDuel.ValueDoubleTributeMix(ignore, nil, attribute, nil, level, race, nil, nil)
end
-- 效果值: 双重解放 攻击力/守备力
function RushDuel.ValueDoubleTributeAtkDef(attack, defense, ignore)
    return RushDuel.ValueDoubleTributeMix(ignore, nil, nil, nil, nil, nil, attack, defense)
end

-- 判断： 是否可以赋予双重解放
function RushDuel.CheckValueDoubleTribute(values, value)
    local _, info = value(nil)
    for _, val in ipairs(values) do
        if val == 1 then
            -- 全范围双重解放, 无法再赋予双重解放
            return false
        else
            -- 已有抗性全部叠加
            local ignore, attach_info = val(nil)
            if not ignore then
                if attach_info == 1 then
                    -- 全范围双重解放, 无法再赋予双重解放
                    return false
                elseif info == 1 then
                    -- 全范围双重解放, 无需判断
                elseif not RushDuel._private_is_double_tribute_info_different(info, attach_info) then
                    -- 已存在相同的双重解放效果
                    return false
                end
            end
        end
    end
    return true
end

-- 效果值: 效果破坏抗性 抵抗类型
function RushDuel.ValueEffectIndesType(self_type, opponent_type, ignore)
    local s_type = self_type or 0
    local o_type = opponent_type or 0
    return function(e, re, rp)
        if e == nil then
            return ignore or false, s_type, o_type
        end
        local op = e:GetOwnerPlayer()
        if rp == op then
            return s_type ~= 0 and re:IsActiveType(s_type)
        else
            return o_type ~= 0 and re:IsActiveType(o_type)
        end
    end
end

-- 判断： 是否可以赋予效果破坏抗性
function RushDuel.CheckValueEffectIndesType(player, effects, value)
    local attachs_s, attachs_o = 0, 0
    for _, effect in ipairs(effects) do
        local val = effect:GetValue()
        if val == 1 then
            -- 全破坏抗性, 无法再赋予其他抗性
            return false
        else
            -- 已有抗性全部叠加
            local ignore, s_type, o_type = val(nil)
            if not ignore then
                if effect:GetHandlerPlayer() ~= effect:GetOwnerPlayer() then
                    s_type, o_type = o_type, s_type
                end
                attachs_s = attachs_s | s_type
                attachs_o = attachs_o | o_type
            end
        end
    end
    -- 判断抗性是否有变化
    local _, s_type, o_type = value(nil)
    return (attachs_s | s_type) ~= attachs_s or (attachs_o | o_type) ~= attachs_o
end
