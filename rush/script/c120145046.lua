local cm,m=GetID()
cm.name="火面烧心背脂之术"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(cm.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=Duel.GetMatchingGroupCount(cm.atkfilter,tp,LOCATION_MZONE,0,nil)*-400
	if atk==0 then return end
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end