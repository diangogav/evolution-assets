local cm,m=GetID()
local list={120257058,120213010}
cm.name="接合科技再接合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c)
	return aux.IsMaterialListCode(c,list[2]) and c:IsLevelBelow(9)
		and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,2) then
		RD.CanFusionSummon(aux.Stringid(m,1),nil,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,e,tp,POS_FACEUP,true)
	end
end