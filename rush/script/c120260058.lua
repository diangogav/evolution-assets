local cm,m=GetID()
local list={120209001,120208016}
cm.name="穿越侍·大力线性海牛侍"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_GALAXY)
end
--Atk Up
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2,nil,nil,function(g)
	if g:IsExists(Card.IsCode,1,nil,list[2]) then
		return 20260058
	else
		return 0
	end
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachAtkDef(e,c,1000,0,reset)
		RD.AttachCannotDirectAttack(e,c,aux.Stringid(m,1),reset)
		if e:GetLabel()==20260058 then
			RD.AttachAtkDef(e,c,2600,0,reset)
		end
	end
end