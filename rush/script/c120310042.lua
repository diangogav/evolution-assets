local cm,m=GetID()
local list={120102007,120310057}
cm.name="坚守的千年石人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelBelow(5) and c:IsAttribute(ATTRIBUTE_EARTH)
end
--To Hand
function cm.thfilter(c)
	return c:IsCode(list[2]) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler(),SUMMON_TYPE_FUSION)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,1,2,nil,function(sg)
				Duel.BreakEffect()
				if RD.SendToDeckAndExists(sg,e,tp,REASON_EFFECT)
					and c:IsFaceup() and c:IsRelateToEffect(e) then
					RD.AttachLevel(e,c,2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				end
			end)
		end
	end)
end