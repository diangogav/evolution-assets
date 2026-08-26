local cm,m=GetID()
local list={120235060}
cm.name="二咒葬之龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Recover
function cm.setfilter(c)
	return c:IsCode(list[1]) and c:IsSSetable()
end
cm.cost=RD.CostSendDeckTopToGrave(2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetRecover(tp,200)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Recover()~=0 then
		RD.CanSelectAndSet(aux.Stringid(m,1),aux.NecroValleyFilter(cm.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,true)
	end
end