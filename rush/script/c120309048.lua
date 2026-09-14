local cm,m=GetID()
local list={120309048,120309049}
cm.name="到临神殿之黑魔女"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Once
	RD.SetFaceupSpSummonOnce(list[1],aux.Stringid(m,0))
	--Special Summon Procedure
	RD.AddHandSpecialSummonProcedure(c,aux.Stringid(m,1),cm.spcon,cm.sptg,cm.spop)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,2))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Procedure
function cm.spconfilter(c,tp)
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(cm.spconfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(cm.spconfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=mg:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else
		return false
	end
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	Duel.SendtoGrave(tc,REASON_SPSUMMON)
end
--Set
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function cm.setfilter(c)
	return c:IsCode(list[2]) and c:IsSSetable()
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cm.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndSet(aux.NecroValleyFilter(cm.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
end