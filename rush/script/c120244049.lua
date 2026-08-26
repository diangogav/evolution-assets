local cm,m=GetID()
local list={120225001}
cm.name="龙击速融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,nil,nil,nil,nil,nil,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsRace(RACE_DRAGON)
end
function cm.exfilter(c)
	return c:IsCode(list[1]) and c:IsLocation(LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if mat:IsExists(cm.exfilter,1,nil) and RD.CanDiscardDeck(aux.Stringid(m,1),tp,7)~=0 then
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
			and Duel.IsPlayerCanDiscardDeck(1-tp,7)
			and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
			Duel.DiscardDeck(1-tp,7,REASON_EFFECT)
		end
	end
end