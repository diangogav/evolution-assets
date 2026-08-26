local cm,m=GetID()
local list={120231022,120231024}
cm.name="电子战术龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
function cm.check(g,atk)
	return g:GetSum(Card.GetAttack)<=atk
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,atk)
	if chk==0 then return g:CheckSubGroup(cm.check,1,2,atk) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=c:GetAttack()
		RD.SelectGroupAndDoAction(HINTMSG_DESTROY,RD.Filter(cm.filter,atk),RD.Check(cm.check,atk),tp,0,LOCATION_MZONE,1,2,nil,function(g)
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end