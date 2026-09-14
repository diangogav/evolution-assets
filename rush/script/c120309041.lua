local cm,m=GetID()
cm.name="云海龙 缪拉"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Union
	local e1=RD.RegisterUnionEffect(c,cm.filter,nil,cm.cost,cm.operation)
	e1:SetCategory(e1:GetCategory()|CATEGORY_SPECIAL_SUMMON)
	--Cannot To Hand & Deck & Extra
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e2:SetCondition(aux.IsUnionState)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e3)
end
--Union
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
end
function cm.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),cm.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,POS_FACEUP,true)
end