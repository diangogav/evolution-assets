--未来融合－フューチャー・フュージョン (Edison Format)
function c511002997.initial_effect(c)
	--Activate (send immediately)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c511002997.target)
	e1:SetOperation(c511002997.activate)
	c:RegisterEffect(e1)
	--Special Summon on 2nd Standby
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c511002997.proccon)
	e2:SetOperation(c511002997.procop)
	c:RegisterEffect(e2)
	--Destroy fusion if FF leaves field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c511002997.desop)
	c:RegisterEffect(e3)
	--Destroy FF if fusion leaves field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c511002997.descon2)
	e4:SetOperation(c511002997.desop2)
	c:RegisterEffect(e4)
end

function c511002997.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
function c511002997.filter2(c)
	return c:IsType(TYPE_FUSION)
end
function c511002997.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c511002997.filter2,tp,LOCATION_EXTRA,0,1,nil)
	end
	e:GetHandler():SetTurnCounter(0)
end

-- Activate and send materials immediately
function c511002997.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=Duel.GetMatchingGroup(c511002997.filter1,tp,LOCATION_DECK,0,nil,e)
	local sg=Duel.GetMatchingGroup(c511002997.filter2,tp,LOCATION_EXTRA,0,nil)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tg=sg:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	local code=tc:GetCode()
	local mat=Duel.SelectFusionMaterial(tp,tc,mg)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	e:SetLabel(code)
end

function c511002997.proccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c511002997.procop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()+1
	c:SetTurnCounter(ct)
	if ct==2 then
		local code=e:GetLabel()
		local tc=Duel.SelectMatchingCard(tp,function(c) return c:IsCode(code) end,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		if not tc then return end
		if Duel.GetLocationCountFromEx(tp)<=0 then
			Duel.SendtoGrave(tc,REASON_EFFECT)
			tc:CompleteProcedure()
		else
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
			c:SetCardTarget(tc)
		end
	end
end
function c511002997.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c511002997.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
function c511002997.desop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

