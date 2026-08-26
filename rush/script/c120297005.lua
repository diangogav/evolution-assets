local cm,m=GetID()
local list={120297005}
cm.name="封拳之僵尸"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Level Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Level Down
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(3)
end
function cm.spfilter(c,e,tp)
	return c:IsCode(list[1]) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachLevel(e,g:GetFirst(),-2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local c=e:GetHandler()
		if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
			RD.CanSelectAndSpecialSummon(aux.Stringid(m,2),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP_DEFENSE)
		end
	end)
end