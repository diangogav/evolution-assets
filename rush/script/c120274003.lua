local cm,m=GetID()
local list={120125001}
cm.name="真红眼极炎龙［R］"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Cannot To Hand & Deck & Extra
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_XMATERIAL)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_XMATERIAL)
	c:RegisterEffect(e4)
	--Fusion Code
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_ADD_FUSION_CODE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(cm.fucon)
	e5:SetValue(list[1])
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetType(EFFECT_TYPE_XMATERIAL)
	c:RegisterEffect(e6)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3,e4,e5,e6)
end
--Cannot To Hand & Deck & Extra
function cm.condition(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function cm.target(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
--Fusion Code
function cm.fucon(e)
	return e:GetHandler():IsFaceup()
end