local cm,m=GetID()
local list={120208006}
cm.name="肉与贪欲见面会"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_BEAST) and RD.IsCanAttachExtraAttackMonster(c,2)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.downfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachExtraAttackMonster(e,g:GetFirst(),2,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local sg=Duel.GetMatchingGroup(cm.downfilter,tp,0,LOCATION_MZONE,nil)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil)
			and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,3)) then
			sg:ForEach(function(tc)
				RD.AttachAtkDef(e,tc,-500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
end