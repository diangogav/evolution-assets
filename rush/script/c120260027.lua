local cm,m=GetID()
cm.name="磁力要塞壶"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureThree(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and (c:IsFaceup() or c:IsControler(tp))
end
--Destroy
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsSummonTurn(c) and c:IsSummonType(SUMMON_VALUE_SELF)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			RD.CanDraw(aux.Stringid(m,1),tp,1,true)
		end
	end)
end