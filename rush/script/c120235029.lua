local cm,m=GetID()
cm.name="传说的战士 吉尔福德"
function cm.initial_effect(c)
	--Cannot Special Summon
	RD.CannotSpecialSummon(c)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Equip
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function cm.eqfilter(c,g)
	return c:IsType(TYPE_EQUIP) and g:IsExists(cm.eqcheck,1,nil,c)
end
function cm.eqcheck(c,ec)
	return ec:CheckEquipTarget(c)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(cm.eqfilter,tp,LOCATION_GRAVE,0,1,nil,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
	local filter=RD.Filter(cm.eqfilter,g)
	RD.SelectAndDoAction(aux.Stringid(m,1),aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,ft,nil,function(sg)
		for i=1,sg:GetCount() do
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,2))
			local ec=sg:Select(tp,1,1,nil):GetFirst()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,3))
			local tc=g:FilterSelect(tp,cm.eqcheck,1,1,nil,ec):GetFirst()
			Duel.Equip(tp,ec,tc,true,true)
			sg:RemoveCard(ec)
		end
		Duel.EquipComplete()
	end)
end