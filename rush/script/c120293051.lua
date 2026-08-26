local cm,m=GetID()
cm.name="惑精 大戟地球"
function cm.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSummonTurn(e:GetHandler()) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,c) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e),function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			RD.CanDraw(aux.Stringid(m,1),tp,1,true)
		end
	end)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotActivateEffect(e,aux.Stringid(m,2),cm.aclimit,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return tc:IsType(TYPE_MONSTER) and not tc:IsRace(RACE_GALAXY)
end