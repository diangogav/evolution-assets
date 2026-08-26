local cm,m=GetID()
cm.name="精英秘密搜查官 神秘小姐"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.costfilter(c)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsAbleToDeckAsCost()
	else
		return c:IsFaceup() and c:IsRace(RACE_REPTILE) and c:IsAbleToDeckOrExtraAsCost()
	end
end
function cm.costcheck(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)==1
end
function cm.spfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsRace(RACE_REPTILE) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostSendGroupToDeckSort(cm.costfilter,cm.costcheck,LOCATION_HAND+LOCATION_MZONE,3,3,true,SEQ_DECKSHUFFLE,true,false)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,300,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,2,nil,e,POS_FACEUP,true)
	end
end