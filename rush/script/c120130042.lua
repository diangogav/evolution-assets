local cm,m=GetID()
cm.name="神风剑"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c,tp)
	if c:IsControler(tp) then
		return c:IsFaceup() and c:IsType(TYPE_NORMAL)
	else
		return c:IsFaceup() and c:IsLevelBelow(8)
	end
end
function cm.check(g,tp)
	return g:FilterCount(Card.IsControler,nil,tp)==2
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then return g:CheckSubGroup(cm.check,3,3,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,3,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	local check=RD.Check(cm.check,tp)
	RD.SelectGroupAndDoAction(HINTMSG_DESTROY,filter,check,tp,LOCATION_MZONE,LOCATION_MZONE,3,3,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end