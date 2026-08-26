local cm,m=GetID()
local list={120196050}
cm.name="银河舰融合宇宙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
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
	e2:SetValue(cm.value)
	c:RegisterEffect(e2)
end
-- Fusion Expend
function cm.filter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end
function cm.target(e,te,tp,mg)
	if te:GetHandler():IsCode(list[1]) then
		local g=Duel.GetFusionMaterial(tp,LOCATION_HAND):Filter(cm.filter,nil)
		g:Merge(mg)
		return g
	else
		return Group.CreateGroup()
	end
end
function cm.operation(e,te,tp,tc,mat,sumtype)
	RD.FusionToGrave(tp,mat)
end
function cm.value(fc)
	return fc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and fc:IsRace(RACE_GALAXY)
end