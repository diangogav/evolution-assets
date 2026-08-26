local cm,m=GetID()
cm.name="王家魔族·极端金属歌手"
function cm.initial_effect(c)
	--Tribute
	RD.CreateAdvanceCheck(c,cm.tricheck,1,20309006)
	--Release
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Tribute
function cm.tricheck(c)
	return c:IsLevelAbove(5)
end
--Release
function cm.filter(c,tp)
	return RD.IsCanAttachOpponentTribute(c,tp,20244046)
		and RD.IsCanAttachOpponentTribute(c,tp,20309007)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsSummonTurn(c) and c:GetFlagEffect(20309006)~=0
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
		local e1,e2=RD.AttachOpponentTribute(e,sg:GetFirst(),20309007,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,RESET_PHASE+PHASE_END)
		e1:SetValue(POS_FACEUP_ATTACK)
		e2:SetTarget(cm.sumtg)
	end)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,3),RACE_ALL-RACE_FIEND,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.sumtg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end