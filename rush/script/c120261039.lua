local cm,m=GetID()
cm.name="解压除冻骑兵改"
function cm.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.exfilter(c)
	return (c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_CYBERSE)) or c:IsType(TYPE_EQUIP)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetDamage(1-tp,200)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Damage()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			RD.AttachAtkDef(e,g:GetFirst(),-600,-600,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end