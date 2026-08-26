local cm,m=GetID()
cm.name="高潮终场"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsRace(RACE_PSYCHO)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp=Duel.GetMatchingGroupCount(cm.costfilter,tp,LOCATION_GRAVE,0,nil)*100
	if chk==0 then return lp>0 and Duel.CheckLPCost(tp,lp) end
	Duel.PayLPCost(tp,lp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=Duel.GetMatchingGroupCount(cm.costfilter,tp,LOCATION_GRAVE,0,nil)*100
	if atk==0 then return end
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end