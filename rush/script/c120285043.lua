local cm,m=GetID()
local list={120109022,120231024}
cm.name="电子监视龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end

--Fusion Summon
function cm.matfilter(c)
	return c:IsOnField() and c:IsCode(list[2])
end
function cm.spfilter(c)
	return c:IsLevel(10) and c:IsRace(RACE_MACHINE)
end
function cm.exfilter(c)
	return c:IsCode(list[2]) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.matcheck(tp,sg,fc)
	return sg:GetCount()>=3
end
cm.cost=RD.CostChangeSelfPosition(POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE)
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	RD.AttachAtkDef(e,fc,600,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,true)
end