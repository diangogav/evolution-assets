local cm,m=GetID()
local list={120310016}
cm.name="疯狂犯罪者·华丽女士"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Cannot Special Summon
	RD.CannotSpecialSummon(c)
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	c:RegisterEffect(e1)
	--Atk & Def Down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(cm.downtg)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cm.condition)
	e4:SetValue(cm.indval)
	c:RegisterEffect(e4)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3,e4)
end
--Atk & Def Down
function cm.downtg(e,c)
	return c:IsFaceup()
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
function cm.condition(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,list[1])
end