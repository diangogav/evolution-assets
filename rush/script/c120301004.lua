local cm,m=GetID()
cm.name="风灵使 薇茵"
function cm.initial_effect(c)
	--Control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Control
function cm.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and RD.IsDefense(c,1500)
end
function cm.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_MAXIMUM) and c:IsLevelBelow(8)
		and c:IsAttribute(ATTRIBUTE_WIND) and c:IsControlerCanBeChanged()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsFlipMainPhase(c)
		or Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,c)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_CONTROL,cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		Duel.GetControl(g,tp)
	end)
end