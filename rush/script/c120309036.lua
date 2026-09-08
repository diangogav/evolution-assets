local cm,m=GetID()
cm.name="云海抱龙 旋律龙"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spcon,nil,nil,nil,POS_FACEUP_DEFENSE)
	--Multiple Attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
--Multiple Attack
function cm.confilter(c)
	return c:IsFaceup() and RD.IsUnionMonsterCard(c)
end
function cm.filter(c,ct)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
		and RD.IsCanAttachExtraAttack(c,ct)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_ONFIELD,0,2,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(cm.confilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,ct-1) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(cm.confilter,tp,LOCATION_ONFIELD,0,nil)
	local filter=RD.Filter(cm.filter,ct-1)
	RD.SelectAndDoAction(aux.Stringid(m,2),filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachExtraAttackMonster(e,g:GetFirst(),ct-1,aux.Stringid(m,ct+1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end