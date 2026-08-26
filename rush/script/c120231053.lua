local cm,m=GetID()
local list={120170002}
cm.name="可能甜心-偶像：D"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.confilter1(c)
	return c:IsRace(RACE_PSYCHO) or c:IsRace(RACE_OMEGAPSYCHO)
end
function cm.confilter2(c)
	return c:IsType(TYPE_MONSTER) and not cm.confilter1(c)
end
function cm.costfilter(c,e,tp)
	return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function cm.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsRace(RACE_PSYCHO) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(cm.confilter2,tp,LOCATION_GRAVE,0,1,nil)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if RD.SelectAndSpecialSummon(cm.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,POS_FACEUP)~=0
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil)
		and c:IsFaceup()
		and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,700,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end