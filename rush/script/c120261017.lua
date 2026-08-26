local cm,m=GetID()
cm.name="小麦布料得墨忒耳"
function cm.initial_effect(c)
	--Special Summon Counter
	Duel.AddCustomActivityCounter(m,ACTIVITY_SPSUMMON,cm.ctfilter)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Counter
function cm.ctfilter(c)
	return not c:IsSummonLocation(LOCATION_GRAVE)
end
--Special Summon
function cm.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(m,tp,ACTIVITY_SPSUMMON)==0
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<2 then return end
	Duel.ConfirmDecktop(1-tp,2)
	local g=Duel.GetDecktopGroup(1-tp,2):Filter(Card.IsLevelAbove,nil,1)
	local lv=g:GetSum(Card.GetLevel)
	if lv>0 then
		local filter=aux.NecroValleyFilter(RD.Filter(cm.spfilter,e,tp,lv))
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),filter,tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)
	end
	Duel.SortDecktop(1-tp,1-tp,2)
end