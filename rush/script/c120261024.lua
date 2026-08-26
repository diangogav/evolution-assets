local cm,m=GetID()
cm.name="暗物质线团"
function cm.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.costfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
		and RD.IsDefense(c,1300) and not c:IsPublic()
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1,nil,function(g)
	return g:GetFirst()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and e:IsCostChecked() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if Duel.GetMZoneCount(tp)>0 and RD.IsCanBeSpecialSummoned(tc,e,tp,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0
			and c:IsFaceup() and c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			RD.AttachAtkDef(e,c,700,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
	end
end