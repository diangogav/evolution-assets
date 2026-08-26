local cm,m=GetID()
cm.name="柳安冒险队出发！！"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		return c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
			and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,c,e,tp)
	else
		return c:IsFaceup() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
			and c:IsAbleToDeckOrExtraAsCost()
	end
end
function cm.filter(c,e,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil,e,c)
end
function cm.exfilter(c,e,tc)
	return c:IsType(TYPE_UNION) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PLANT)
		and RD.CheckUnionEquip(e,tc,c)
end
cm.cost=RD.CostSendMatchToDeckSort(cm.costfilter,LOCATION_ONFIELD,1,1,true,SEQ_DECKBOTTOM,true,true)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	local filter1=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_EQUIP,filter1,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		local filter2=RD.Filter(cm.exfilter,e,tc)
		local max=1
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>1 then max=2 end
		RD.SelectAndDoAction(HINTMSG_EQUIP,aux.NecroValleyFilter(filter2),tp,LOCATION_GRAVE,0,1,max,nil,function(sg)
			local ec1,ec2=sg:GetFirst(),sg:GetNext()
			RD.UnionEquip(tp,tc,ec1)
			RD.UnionEquip(tp,tc,ec2)
		end)
	end)
end