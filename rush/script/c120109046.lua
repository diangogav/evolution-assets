local cm,m=GetID()
local list={120222017,120244004}
cm.name="碧牙重轰爆速龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1,nil,nil,function(g)
	local tc=g:GetFirst()
	if tc:IsLevelAbove(7) and tc:IsRace(RACE_DRAGON) then
		return 1
	else
		return 0
	end
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachAtkDef(e,c,1500,0,reset)
		RD.AttachCannotDirectAttack(e,c,aux.Stringid(m,2),reset)
		if e:GetLabel()==1 then
			RD.AttachExtraAttackMonster(e,c,1,aux.Stringid(m,3),reset)
		end
	end
end