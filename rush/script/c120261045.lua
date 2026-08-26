local cm,m=GetID()
local list={120115001}
cm.name="七星道终极咒魔女"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsType(TYPE_FUSION) and (c:IsRace(RACE_SPELLCASTER) or c:IsRace(RACE_MAGICALKNIGHT))
end
--To Deck
function cm.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
function cm.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,0,LOCATION_GRAVE,1,1,nil,function(g)
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT,cm.exfilter,1,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
				Duel.BreakEffect()
				if RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT) and Duel.GetFlagEffect(tp,m)==0 then
					RD.CreateActivateCountLimitEffect(e,aux.Stringid(m,2),cm.aclimit,1,tp,RESET_PHASE+PHASE_END)
					Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
				end
			end)
		end
	end)
end
function cm.aclimit(e,re,tp,chk)
	return RD.IsNormalSpell(re:GetHandler()) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and re:IsActiveType(TYPE_SPELL)
end