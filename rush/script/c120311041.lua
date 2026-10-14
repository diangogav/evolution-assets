local cm,m=GetID()
local list={120311041}
cm.name="高天喷燃超硬面"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
function cm.confilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cm.confilter2(c)
	return c:IsType(TYPE_MONSTER) and not cm.confilter1(c)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end
function cm.spfilter(c,e,tp)
	return not c:IsType(TYPE_FUSION) and c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsAttack(2500) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(cm.confilter2,tp,LOCATION_GRAVE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,2,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.filter,tp,LOCATION_MZONE,0,2,2,nil,function(g)
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
			RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP,true)
		end
	end)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[1])
end