local cm,m=GetID()
local list={120106001}
cm.name="历战的暗黑骑士 盖亚"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
--Change Code
function cm.matfilter(c)
	return c:IsOnField() and c:IsAbleToDeck()
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[1],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.SetFusionSummonMaterialCount(e,2,2)
		RD.CanFusionSummon(aux.Stringid(m,2),cm.matfilter,nil,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck,e,tp,POS_FACEUP,true,true)
		RD.ResetFusionSummonMaterialCount(e)
	end
end