local cm,m=GetID()
cm.name="深渊龙神 深渊波塞德拉［R］"
function cm.initial_effect(c)
	--Cannot Set Monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.setcon1)
	e1:SetTarget(cm.setlimit)
	e1:SetTargetRange(0,1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e3:SetTarget(cm.splimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	c:RegisterEffect(e4)
	--Cannot Set Spell & Trap
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SSET)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetCondition(cm.setcon2)
	e5:SetTarget(cm.setlimit)
	c:RegisterEffect(e5)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3,e4,e5)
end
--Cannot Set Monster
function cm.confilter1(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.setcon1(e)
	return not Duel.IsExistingMatchingCard(cm.confilter1,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function cm.setlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_HAND)
end
function cm.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_HAND) and sumpos&POS_FACEDOWN>0
end
--Cannot Set Spell & Trap
function cm.confilter2(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.setcon2(e)
	return cm.setcon1(e) and RD.MaximumMode(e)
		and Duel.IsExistingMatchingCard(cm.confilter2,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,1,nil)
end
