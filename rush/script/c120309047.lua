local cm,m=GetID()
cm.name="巢食神殿之炎龙"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spcon,cm.sptg,cm.spop)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Procedure
function cm.spconfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
		and Duel.GetMZoneCount(tp,c)>0
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(cm.spconfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(cm.spconfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=mg:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else
		return false
	end
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	Duel.SendtoGrave(tc,REASON_SPSUMMON)
end
--Atk Up
function cm.spfilter(c,e,tp)
	return c:GetSequence()<5 and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,2),cm.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,POS_FACEUP_DEFENSE,true)
	end
end