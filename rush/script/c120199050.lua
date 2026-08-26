local cm,m=GetID()
cm.name="火面炙烤喷灯之术"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_PYRO)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
function cm.atkfilter(c)
	return c:IsType(TYPE_NORMAL)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(cm.atkfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=Duel.GetMatchingGroupCount(cm.atkfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)*100
	if atk==0 then return end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
	g:ForEach(function(tc)
		RD.AttachAtkDef(e,tc,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end