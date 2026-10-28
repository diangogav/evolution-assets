local cm,m=GetID()
cm.name="圣洁人的圣战"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.costfilter(c)
	return (cm.costfilter1(c) or cm.costfilter2(c)) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.costfilter1(c)
	return c:IsRace(RACE_CYBERSE)
end
function cm.costfilter2(c)
	return not c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_MONSTER)
end
function cm.check(g)
	return g:IsExists(cm.costfilter1,1,nil) and g:IsExists(cm.costfilter2,1,nil)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.check,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),Card.IsFaceup,tp,LOCATION_MZONE,0,1,2,nil,function(g)
		local ex=false
		g:ForEach(function(tc)
			RD.AttachAtkDef(e,tc,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			if tc:IsType(TYPE_FUSION) and tc:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_CYBERSE) then
				ex=true
			end
		end)
		if ex then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil,function(dg)
				Duel.Destroy(dg,REASON_EFFECT)
			end)
		end
	end)
end