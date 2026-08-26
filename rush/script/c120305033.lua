local cm,m=GetID()
local list={120305033}
cm.name="我我我啦啦队少女"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
function cm.filter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
end
function cm.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,2,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.filter,tp,LOCATION_MZONE,0,2,2,nil,function(g)
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0
			and RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP,true)~=0 then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),aux.Stringid(m,3),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
				Duel.BreakEffect()
				RD.AttachAtkDef(e,g:GetFirst(),-1000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,4),m,tp,list[1])
end