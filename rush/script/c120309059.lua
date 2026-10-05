local cm,m=GetID()
local list={120309058}
cm.name="恶魔之印 卢法"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(2500)
		and (RD.IsCanAttachEffectIndes(c,tp,cm.indval)
		or RD.IsCanAttachCannotToHandEffect(c,1)
		or RD.IsCanAttachCannotToDeckEffect(c,1))
end
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.thfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAbleToHand()
end
function cm.check(g)
	return g:GetClassCount(Card.GetRace)==g:GetCount()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(cm.check,2,2) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(aux.Stringid(m,1),cm.filter,cm.check,tp,LOCATION_MZONE,0,2,2,nil,function(g)
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		g:ForEach(function(tc)
			RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),reset)
			RD.AttachCannotToHandEffect(e,tc,1,aux.Stringid(m,3),reset)
			RD.AttachCannotToDeckEffect(e,tc,1,aux.Stringid(m,4),reset)
		end)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,5),HINTMSG_RTOHAND,cm.thfilter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
			end)
		end
	end)
end