local cm,m=GetID()
local list={120310034}
cm.name="粉彩寻宝·比比"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Level Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Level Up
function cm.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function cm.spfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(8)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachLevel(e,c,4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if c:IsLevelAbove(8) then
			RD.CanRitualSummonWithMaterial(aux.Stringid(m,1),RITUAL_ORIGINAL_LEVEL_GREATER,c,cm.spfilter,RD.RitualToGrave,e,tp,POS_FACEUP,true)
		end
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[1])
end