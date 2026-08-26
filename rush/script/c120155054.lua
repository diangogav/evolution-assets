local cm,m=GetID()
cm.name="幻刃封锁"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsLevelAbove(7)
end
function cm.costfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM) and c:IsAbleToGraveAsCost()
end
function cm.filter(c,tp)
	return c:IsFaceup() and RD.IsPlayerCanUseRaceAttack(1-tp,c:GetRace())
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local race=g:GetFirst():GetRace()
		RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,2),race,tp,0,1,RESET_PHASE+PHASE_END)
	end)
end