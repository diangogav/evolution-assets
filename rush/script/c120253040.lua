local cm,m=GetID()
local list={120247040,120253010}
cm.name="幻坏熔龙 暗冥爆破龙王"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(1-tp,3) then
		local ct=Duel.GetOperatedGroup():FilterCount(cm.exfilter,nil)
		if ct==0 then return end
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,ct,nil,function(g)
			local des=Duel.Destroy(g,REASON_EFFECT)
			if des~=0 then
				Duel.BreakEffect()
				Duel.Damage(1-tp,des*500,REASON_EFFECT)
			end
		end)
	end
end