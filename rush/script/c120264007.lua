local cm,m=GetID()
cm.name="混合驱动推进宝珠龙"
function cm.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.confilter(c)
	return c:IsRace(RACE_MACHINE)
end
function cm.costfilter(c)
	return c:IsLevel(7,8) and c:IsRace(RACE_DRAGON) and not c:IsPublic()
end
function cm.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and Duel.GetMZoneCount(tp)>0 and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1,function(g)
	return g:GetFirst():GetLevel()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local lv=e:GetLabel()
	local sg,g=RD.RevealDeckTopAndCanSelect(tp,3,aux.Stringid(m,1),HINTMSG_SPSUMMON,cm.spfilter,1,1,e,tp,lv)
	if sg:GetCount()>0 then
		Duel.DisableShuffleCheck()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	local ct=g:GetCount()
	if ct>0 then
		Duel.SortDecktop(tp,tp,ct)
		RD.SendDeckTopToBottom(tp,ct)
	end
end