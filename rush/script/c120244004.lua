local cm,m=GetID()
local list={120222017,120225001}
cm.name="增速飞龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.confilter(c)
	return c:IsFaceup() and c:IsCode(list[1],list[2])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.ConditionSummonOrSpecialSummonMainPhase(e)
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetDamage(1-tp,600)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.Damage()
end