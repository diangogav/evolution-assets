local cm,m=GetID()
cm.name="最大岩浆之地幔阿育吠陀医师"
function cm.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.costfilter(c,e,tp)
	return c:IsRace(RACE_PYRO) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(cm.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetLevel())
end
function cm.desfilter(c,lv)
	return c:IsLevel(lv) and c:IsPosition(POS_FACEUP_DEFENSE)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1,function(g)
	return g:GetFirst():GetLevel()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lv=e:GetLabel()
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lv)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lv)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end