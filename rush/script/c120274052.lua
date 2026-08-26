local cm,m=GetID()
cm.name="现梦中之丝绸蚕"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,false,cm.matfilter,cm.matfilter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevel(7,8,9) and c:IsRace(RACE_INSECT) and c:IsFusionType(TYPE_EFFECT)
end
--Atk Up
function cm.costfilter(c)
	return not c:IsLevel(9) and c:IsRace(RACE_INSECT) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler(),SUMMON_TYPE_FUSION)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,3,3)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,cm.exfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
			RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end