--黄泉ガエル
function c511002980.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(511002980,0))
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c511002980.condition)
	e1:SetTarget(c511002980.target)
	e1:SetOperation(c511002980.operation)
	c:RegisterEffect(e1)
end
function c511002980.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) or (c:IsCode(511002980) and c:IsFaceup())
end
function c511002980.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c511002980.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c511002980.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c511002980.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c511002980.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(c511002980.filter2,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
