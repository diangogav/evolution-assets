local cm,m=GetID()
local list={120312002}
cm.name="枯木的金尼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Union
	local e1=RD.RegisterUnionEffect(c,cm.filter,nil,cm.cost,cm.operation)
	e1:SetCategory(e1:GetCategory()|CATEGORY_RECOVER)
	--Atk Down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(cm.downtg)
	e2:SetValue(cm.downval)
	c:RegisterEffect(e2)
end
--Union
function cm.filter(c)
	local g=c:GetEquipGroup()
	return not g:IsExists(Card.IsCode,1,nil,list[1])
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.Recover(tp,500,REASON_EFFECT)
end
--Atk Down
function cm.downtg(e,c)
	return c:IsFaceup()
		and (c==e:GetHandler():GetEquipTarget() or not c:IsControler(e:GetHandlerPlayer()))
end
function cm.downval(e,c)
	return e:GetHandler():GetEquipTarget():GetOriginalLevel()*-100
end