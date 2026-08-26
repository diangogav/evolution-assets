local cm,m=GetID()
cm.name="梦中的引诱"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c,ignore)
	return c:IsFaceup() and not c:IsType(TYPE_MAXIMUM) and c:IsLevelBelow(8) and c:IsControlerCanBeChanged(ignore)
end
function cm.costcheck(g,e,tp)
	return g:GetClassCount(Card.GetLocation)==g:GetCount()
		and Duel.GetMZoneCount(tp,g,tp,LOCATION_REASON_CONTROL)>0
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendGroupToDeckSort(Card.IsAbleToDeckOrExtraAsCost,cm.costcheck,LOCATION_MZONE+LOCATION_HAND,2,2,true,SEQ_DECKBOTTOM,true,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (e:IsCostChecked() or Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)>0)
		and Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,true) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,false)
	RD.SelectAndDoAction(HINTMSG_CONTROL,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		if Duel.GetControl(tc,tp)~=0 then
			RD.AttachCannotAttack(e,tc,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD)
			RD.AttachCannotTrigger(e,tc,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD)
		end
	end)
end