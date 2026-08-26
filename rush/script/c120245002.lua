local cm,m=GetID()
local list={120209001}
cm.name="穿越侍·变星之线性海牛侍"
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
	return c:IsLevel(7) and c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_GALAXY)
end
--Atk Up
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.costfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsLevel(7) and c:IsType(TYPE_EFFECT)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2,nil,nil,function(g)
	if g:IsExists(cm.exfilter,2,nil) then
		return 20245002
	else
		return 0
	end
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachAtkDef(e,c,1400,0,reset)
		if e:GetLabel()==20245002 then
			RD.AttachBattleIndes(e,c,1,aux.Stringid(m,1),reset)
			RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,2),reset)
			RD.AttachExtraAttack(e,c,1,aux.Stringid(m,3),reset)
		end
	end
end