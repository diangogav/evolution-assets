local cm,m=GetID()
local list={120120008,120298039}
cm.name="蛹化的飞蛾幼虫"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
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
	return c:IsLevelBelow(5) and c:IsRace(RACE_INSECT)
end
--Change Code
function cm.spfilter(c)
	return c:IsLevelBelow(8) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_INSECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[2])
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[2],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanFusionSummon(aux.Stringid(m,2),nil,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,e,tp,POS_FACEUP,true,true)
	end
end