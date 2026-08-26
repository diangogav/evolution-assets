local cm,m=GetID()
cm.name="涌军机 海炎"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandConfirmSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return not c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_MACHINE)
		and not c:IsPublic()
end
--Special Summon
function cm.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function cm.spfilter(c,e,tp)
	return c:IsLevel(9) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_MACHINE)
		and c:IsType(TYPE_EFFECT) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostSendMZoneToDeckBottom(cm.costfilter,1,1)
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0)
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)
end