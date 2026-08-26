local cm,m=GetID()
local list={120253014,120253012,120196050,120253051}
cm.name="曼陀林掠夺者·时髦"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	-- Fusion Expend
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	e1:SetValue(cm.value)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
-- Fusion Expend
function cm.filter(c,e)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToDeck() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function cm.target(e,te,tp,mg)
	if te:GetHandler():IsCode(list[3],list[4]) then
		local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil,te)
		g:Merge(mg:Filter(Card.IsAbleToDeck,nil))
		return g
	else
		return Group.CreateGroup()
	end
end
function cm.operation(e,te,tp,tc,mat,sumtype)
	if mat:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		RD.FusionToDeck(tp,mat)
	else
		RD.FusionToGrave(tp,mat)
	end
end
function cm.value(fc)
	return fc:IsLevelAbove(8)
end