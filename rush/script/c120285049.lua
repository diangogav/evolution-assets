local cm,m=GetID()
cm.name="传说系谱的剑士"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Fake Legend
	RD.EnableFakeLegend(c,LOCATION_GRAVE)
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
function cm.exfilter(c)
	return c:IsLevel(7) and RD.IsDefense(c,300)
end
function cm.spfilter(c,e,tp)
	return c:IsLevel(7) and RD.IsDefense(c,300) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,3,nil) then
			RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)
		end
	end
end