local cm,m=GetID()
local list={120249022}
cm.name="秘密基地守护神 打偏小姐"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Tribute
	RD.CreateAdvanceCheck(c,cm.tricheck,1,20257023)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Tribute
function cm.tricheck(c)
	return c:IsCode(list[1])
end
--Atk Up
function cm.costfilter(c)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE)
		and c:IsAbleToDeckOrExtraAsCost()
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,3,3)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,3000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		if RD.IsSummonTurn(c) and c:GetFlagEffect(20257023)~=0 then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,3,nil,function(g)
				Duel.Destroy(g,REASON_EFFECT)
			end)
		end
	end
end