local cm,m=GetID()
cm.name="灵使的归宿"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk & Def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cm.uptg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--Decrease Tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCondition(cm.ntcon)
	e3:SetTarget(cm.nttg)
	c:RegisterEffect(e3)
end
--Atk & Def
function cm.uptg(e,c)
	return c:IsFaceup() and RD.IsBaseDefense(c,1500) and c:IsLevel(3,4,5) and c:IsRace(RACE_SPELLCASTER)
end
--Decrease Tribute
function cm.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function cm.nttg(e,c)
	return c:IsLevel(5) and c:IsRace(RACE_SPELLCASTER) and RD.IsBaseDefense(c,1500)
end