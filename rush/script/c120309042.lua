local cm,m=GetID()
cm.name="风之足迹"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function cm.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostSendOnFieldToGrave(cm.costfilter,1,1,true)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	RD.TargetDraw(tp,2)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 then
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),cm.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,POS_FACEUP,true)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,2),RACE_ALL-RACE_SEASERPENT,tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT))
end