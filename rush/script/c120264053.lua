local cm,m=GetID()
local list={120196050}
cm.name="幻坏融门 废铁之门"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
	-- Fusion Expend
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHAIN_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,1)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.operation)
	e2:SetValue(aux.TRUE)
	c:RegisterEffect(e2)
end
--Activate
function cm.costfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_WYRM)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,1,1,false)
-- Fusion Expend
function cm.filter(c,e)
	return c:IsRace(RACE_WYRM) and c:IsAbleToDeck() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function cm.target(e,te,tp)
	if te:GetHandler():IsCode(list[1]) then
		return Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil,te)
	else
		return Group.CreateGroup()
	end
end
function cm.operation(e,te,tp,tc,mat,sumtype)
	RD.FusionToDeck(tp,mat)
end