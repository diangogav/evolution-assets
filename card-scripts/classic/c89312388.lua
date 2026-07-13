--E・HERO プリズマー
function c89312388.initial_effect(c)
	--cos
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89312388,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c89312388.coscost)
	e1:SetTarget(c89312388.costarget)
	e1:SetOperation(c89312388.cosoperation)
	c:RegisterEffect(e1)
end
function c89312388.filter2(c,fc)
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToGrave()
end
function c89312388.filter1(c,tp)
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c89312388.filter2,tp,LOCATION_DECK,0,1,nil,c)
end
function c89312388.coscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c89312388.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c89312388.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
end
function c89312388.costarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c89312388.cosoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c89312388.filter2,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) then
			local c=e:GetHandler()
			if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(gc:GetCode())
			c:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(89312388,1))
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e2:SetCountLimit(1)
			e2:SetRange(LOCATION_MZONE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetLabelObject(e1)
			e2:SetOperation(c89312388.rstop)
			c:RegisterEffect(e2)
		end
	end
end
function c89312388.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=e:GetLabelObject()
	e1:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
