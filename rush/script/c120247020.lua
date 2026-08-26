local cm,m=GetID()
local list={120247025,120247031,120151036,120196050}
cm.name="环幻乐姬 旋律动作斧手"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Down
function cm.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeckTopOrBottom(cm.costfilter,1,1,aux.Stringid(m,1),aux.Stringid(m,2),nil,nil,function(g)
	return g:GetFirst():GetCode()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,3),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),-2000,-2000,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		local code=e:GetLabel()
		if (code==list[3] or code==list[4]) then
			RD.CanDraw(aux.Stringid(m,4),tp,1)
		end
	end)
end