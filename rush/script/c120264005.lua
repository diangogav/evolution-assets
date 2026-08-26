local cm,m=GetID()
local list={120264006,120264005}
cm.name="暗物质秘雾法师"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Procedure
	RD.AddHandSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spcon)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spconfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
--Change Code
function cm.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and RD.IsCanChangeCode(c,list[2])
end
cm.cost=RD.CostPayLP(500)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,2),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.ChangeCode(e,g:GetFirst(),list[2],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end