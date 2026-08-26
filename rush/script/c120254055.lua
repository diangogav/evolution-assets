local cm,m=GetID()
local list={120239048}
cm.name="深渊海兽违逆光环"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cm.prctg)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--No Damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(cm.damcon)
	e3:SetValue(cm.damval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e4)
	--Indes
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetCondition(cm.indcon)
	e5:SetValue(cm.indval)
	c:RegisterEffect(e5)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
--Pierce
function cm.prctg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end
--No Damage
function cm.ctfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.damcon(e)
	return e:GetHandler():GetEquipTarget()~=nil
		and Duel.IsExistingMatchingCard(cm.ctfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function cm.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp~=e:GetHandlerPlayer() then return 0
	else return val end
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.indcon(e)
	return e:GetHandler():GetEquipTarget()~=nil
		and Duel.IsExistingMatchingCard(cm.ctfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,2,nil)
end