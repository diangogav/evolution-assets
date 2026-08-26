local cm,m=GetID()
local list={120222020}
cm.name="化学火山现行化火精神灵"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
	--Material Check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetLabelObject(e1)
	e2:SetValue(cm.check)
	c:RegisterEffect(e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsType(TYPE_MAXIMUM) and c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER)
end
--Material Check
function cm.check(e,c)
	local g=c:GetMaterial()
	if g:IsExists(RD.IsMaximumMode,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
--Atk Down
function cm.costfilter(c)
	return c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeckTopOrBottom(cm.costfilter,3,3,aux.Stringid(m,1),aux.Stringid(m,2))
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	g:ForEach(function(tc)
		RD.AttachAtkDef(e,tc,-3000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) 
		and RD.IsSpecialSummonMainPhase(c) and e:GetLabel()==1 then
		RD.AttachExtraAttack(e,c,2,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end