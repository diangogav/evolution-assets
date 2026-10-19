local cm,m=GetID()
local list={120225024,120310003}
cm.name="大师升级燃龙兽"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter1,cm.matfilter2,cm.matfilter2)
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition1)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- Cannot Activate
	local e2=RD.ContinuousAttackNotChainTrap(c)
	e2:SetCondition(cm.condition1)
	--Atk Up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.condition2)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	--Pierce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	e4:SetCondition(cm.condition2)
	c:RegisterEffect(e4)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3,e4)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter1(c)
	return c:IsFusionType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON)
end
function cm.matfilter2(c)
	return c:IsRace(RACE_DRAGON) and RD.IsDefense(c,900)
end
--Atk Up 1
function cm.filter1(c)
	return c:IsCode(list[1])
end
function cm.condition1(e)
	return Duel.IsExistingMatchingCard(cm.filter1,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
--Atk Up 2
function cm.filter2(c)
	return c:IsCode(list[2])
end
function cm.condition2(e)
	return Duel.IsExistingMatchingCard(cm.filter2,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil)
end