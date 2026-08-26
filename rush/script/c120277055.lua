local cm,m=GetID()
local list={120145000}
cm.name="恶魔的供物"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c,tp)
	if not RD.IsCanAttachOpponentTribute(c,tp,20244046) then return false end
	return c:IsFaceup() and c:IsLevelBelow(8) and RD.IsCanAttachOpponentTribute(c,tp,20277055)
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
		local e1,e2=RD.AttachOpponentTribute(e,sg:GetFirst(),20277055,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,RESET_PHASE+PHASE_END)
		e1:SetValue(POS_FACEUP_ATTACK)
		e2:SetTarget(cm.sumtg)
	end)
end
function cm.sumtg(e,c)
	return RD.IsLegendCode(c,list[1])
end