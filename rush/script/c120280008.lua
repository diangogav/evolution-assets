local cm,m=GetID()
cm.name="诱动光明的狮鹫兽卫"
function cm.initial_effect(c)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Set
function cm.costfilter(c,e,tp)
	return c:IsType(TYPE_RITUAL) and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
		and RD.IsDefenseAbove(c,2500) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cm.setfilter,tp,LOCATION_GRAVE,0,1,nil,c)
end
function cm.setfilter(c,tc)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and aux.IsCodeListed(c,tc:GetCode())
		and c:IsSSetable()
end
cm.cost=RD.CostShowExtra(cm.costfilter,1,1,nil,Group.GetFirst)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.setfilter,e:GetLabelObject())
	RD.SelectAndSet(aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,1,nil,e)
end