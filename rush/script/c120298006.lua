local cm,m=GetID()
local list={120264031}
cm.name="叛骨之镇法"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Level Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE)
end
--Level Up
function cm.exfilter(c,e,tp)
	return c:IsLevel(5) and c:IsCode(list[1])
		and RD.IsAbleToHandOrSpecialSummon(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachLevel(e,c,1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndToHandOrSpecialSummon(aux.Stringid(m,1),aux.Stringid(m,2),aux.NecroValleyFilter(cm.exfilter),tp,LOCATION_GRAVE,0,nil,e,POS_FACEUP,true)
	end
end