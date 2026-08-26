local cm,m=GetID()
local list={120155029,120247031}
cm.name="环幻乐鬼神 小号大管枪贯神息虎吸人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsCanAttachEffectIndes(c,tp,cm.indval) or RD.IsCanAttachPierce(c)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,3,function(g)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,1),reset)
		RD.AttachPierce(e,c,aux.Stringid(m,2),reset)
		local atk=e:GetLabel()*1000
		if RD.IsSpecialSummonMainPhase(c) and atk>0 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,3)) then
			RD.AttachAtkDef(e,c,atk,0,reset)
		end
	end
end