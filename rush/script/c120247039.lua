local cm,m=GetID()
local list={120247046,120247043,120196050}
cm.name="幻坏爆僚 警告起重工龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.thfilter(c)
	return ((c:IsLevelAbove(8) and c:IsRace(RACE_WYRM)) or c:IsCode(list[3])) and c:IsAbleToHand()
end
function cm.check(g)
	if g:GetCount()<2 then return true end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (tc1:IsRace(RACE_WYRM) and tc2:IsCode(list[3]))
		or (tc2:IsRace(RACE_WYRM) and tc1:IsCode(list[3]))
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),cm.check,tp,LOCATION_GRAVE,0,1,2,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,LOCATION_ONFIELD,0,1,1,nil,function(sg)
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end)
		end
	end)
end