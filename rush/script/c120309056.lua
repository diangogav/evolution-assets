local cm,m=GetID()
cm.name="游乐设施小挂件·午午"
function cm.initial_effect(c)
	--Union
	RD.RegisterUnionEffect(c,aux.TRUE,nil,cm.cost)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e1)
end
--Union
cm.cost=RD.CostSendDeckBottomToGrave(2)