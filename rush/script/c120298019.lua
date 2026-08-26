local cm,m=GetID()
local list={120298019}
cm.name="火星心激情灰烬姐姐"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	RD.AddRitualProcedure(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
cm.cost=RD.CostSendHandOrFieldToGrave(Card.IsAbleToGraveAsCost,1,1,true)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,800,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanDraw(aux.Stringid(m,1),tp,1)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[1])
end