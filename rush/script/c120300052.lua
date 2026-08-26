local cm,m=GetID()
local list={120300050}
cm.name="悠久之乡-妖光圣殿-"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
	-- Ritual Expend
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_RITUAL_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,1)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.operation)
	e2:SetValue(aux.TRUE)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,5,nil)
end
-- Fusion Expend
function cm.filter(c,e)
	return c:IsRace(RACE_GALAXY) and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
function cm.target(e,te,tp,mg)
	if te:GetHandler():IsCode(list[1]) then
		local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil,te)
		g:Merge(mg)
		return g
	else
		return Group.CreateGroup()
	end
end
function cm.operation(e,te,tp,tc,mat,sumtype)
	RD.RitualToDeck(tp,mat)
end