local cm,m=GetID()
cm.name="虚空噬骸兵·百臂鹰巨人"
function cm.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevel(8)
end
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
cm.cost=RD.CostChangeSelfPosition(POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetDamage(1-tp,500)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Damage()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
		local filter=RD.Filter(cm.posfilter,e,tp)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_POSCHANGE,filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
			RD.ChangePosition(g,e,tp,REASON_EFFECT)
		end)
	end
end