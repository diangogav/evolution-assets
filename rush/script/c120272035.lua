local cm,m=GetID()
local list={120209001,120109024}
cm.name="穿越侍·强袭线性海牛侍"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Level Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
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
	return c:IsFusionType(TYPE_EFFECT) and not c:IsLevel(7) and c:IsRace(RACE_GALAXY)
end
--Level Down
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsCode(list[2])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLevelAbove(4)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2,nil,nil,function(g)
	if g:IsExists(cm.exfilter,1,nil) then
		return 20272035
	else
		return 0
	end
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachLevel(e,c,-3,reset)
		if e:GetLabel()==20272035 then
			local e1=RD.AttachPierce(e,c,aux.Stringid(m,1),reset)
			e1:SetValue(DOUBLE_DAMAGE)
		end
	end
end