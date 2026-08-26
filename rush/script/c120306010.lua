local cm,m=GetID()
local list={120196050}
cm.name="救惺之狂击 斯莱"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.filter(c)
	return c:IsCode(list[1]) and c:IsLocation(LOCATION_GRAVE)
end
function cm.matfilter(c)
	return c:IsOnField() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsRace(RACE_WYRM) or c:IsRace(RACE_MAGICALKNIGHT))
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if RD.SendDeckTopToGraveAndExists(tp,1,cm.filter,1,nil)
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.CanFusionSummon(aux.Stringid(m,1),cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeckBottom,e,tp,POS_FACEUP,true,true)
	end
end