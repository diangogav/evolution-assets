local cm,m=GetID()
local list={120309058,120309059}
cm.name="天使之印 米卡"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.exfilter(c)
	return c:IsCode(list[2])
end
function cm.spfilter(c,e,tp)
	return c:IsLevel(4) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1]) and mg:GetClassCount(Card.GetRace)>=2
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,0,LOCATION_GRAVE,1,1,nil,e,POS_FACEUP,true)
	end
end