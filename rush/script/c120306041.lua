local cm,m=GetID()
local list={120306041}
cm.name="健康斗士·伊丽莎拉蜜拉"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Recover
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler(),SUMMON_TYPE_RITUAL)
end
cm.cost=RD.CostSendMZoneToGrave(Card.IsAbleToGraveAsCost,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetRecover(tp,700)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Recover()~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,nil,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[1])
end