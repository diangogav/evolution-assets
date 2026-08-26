local cm,m=GetID()
local list={120189003,120130024,120140029,120189012,120140034}
cm.name="五友乐队"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
--Atk Up
function cm.filter(c)
	return c:IsCode(list[1],list[2],list[3],list[4],list[5])
end
cm.cost=RD.CostSendDeckTopAnyToGrave(aux.Stringid(m,1),1,5)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil)
		if g:GetClassCount(Card.GetCode)==5 then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
				Duel.Destroy(g,REASON_EFFECT)
			end)
		end
	end
end