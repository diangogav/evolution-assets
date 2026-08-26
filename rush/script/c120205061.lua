local cm,m=GetID()
cm.name="警告鳞光"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
function cm.confilter2(c,tp)
	return c:GetSummonPlayer()==tp and c:IsFaceup() and c:IsLevelAbove(7)
end
function cm.tdfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,m)==0
		and Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_MZONE,0,1,nil)
		and eg:IsExists(cm.confilter2,1,nil,1-tp)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,m)==0 then
		RD.CreateHintEffect(e,aux.Stringid(m,1),tp,0,1,RESET_PHASE+PHASE_END)
		RD.CreateAttackLimitEffect(e,cm.atktg,tp,0,LOCATION_MZONE,RESET_PHASE+PHASE_END)
		Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
	end
	RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,LOCATION_GRAVE,0,1,5,nil,function(g)
		RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
	end)
end
function cm.atktg(e,c)
	return c:IsAttackAbove(3000)
end