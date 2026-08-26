local cm,m=GetID()
local list={120207007}
cm.name="鹰身女郎 羽毛扫"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter1,cm.matfilter2)
	RD.SetFusionMaterial(c,{list[1]},2,2)
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter1(c,fc,sub)
	return c:IsLevel(4) and (c:IsFusionCode(list[1]) or (sub and c:CheckFusionSubstitute(fc)))
end
function cm.matfilter2(c)
	return c:IsFusionType(TYPE_NORMAL) and c:IsFusionAttribute(ATTRIBUTE_WIND)
		and c:IsRace(RACE_WINDBEAST)
end
--Change Code
function cm.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[1],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if RD.IsSpecialSummonMainPhase(c) then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
				Duel.Destroy(g,REASON_EFFECT)
			end)
		end
	end
end