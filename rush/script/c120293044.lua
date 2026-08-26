local cm,m=GetID()
cm.name="黑极精 秋英宇宙星"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter,cm.matfilter)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Atk & Def Down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(cm.condition)
	e2:SetTarget(cm.target)
	e2:SetValue(-1000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAttack(900)
end
--Atk & Def Down
function cm.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function cm.target(e,c)
	return c:IsFaceup()
end