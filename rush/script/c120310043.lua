local cm,m=GetID()
local list={120310032}
cm.name="圣洁人 露米娜"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Atk & Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.adtg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetCondition(cm.indcon)
	e3:SetTarget(cm.indtg)
	e3:SetValue(cm.indval)
	c:RegisterEffect(e3)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevel(4) and c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_WIND) and RD.IsDefense(c,500)
end
--Atk & Def Up
function cm.adtg(e,c)
	return c:IsFaceup()
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER,TYPE_MONSTER,true)
function cm.indcon(e)
	local g=Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetRace)>=3
end
function cm.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end