local cm,m=GetID()
local list={120209001,120105001}
cm.name="穿越侍道·线性海牛侍"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_GALAXY) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY)
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)~=0 then
		local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
		local ag=Duel.GetMatchingGroup(cm.exfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		local atk=ag:GetClassCount(Card.GetAttribute)*300
		if g:GetCount()>0 and atk~=0 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
			g:ForEach(function(tc)
				RD.AttachAtkDef(e,tc,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end
end