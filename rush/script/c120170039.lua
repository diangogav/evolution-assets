local cm,m=GetID()
local list={120170002}
cm.name="即兴果酱音跃：P跳起！"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function cm.filter(c,e,tp)
	return c:IsLevel(7) and c:IsRace(RACE_PSYCHO) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,1,1,false,nil,nil,function(g)
	return g:GetFirst():GetPreviousCodeOnField()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0)
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(cm.filter,tp,LOCATION_HAND,0,1,1,nil,e,POS_FACEUP)~=0 and e:GetLabel()==list[1] then
		local tc=Duel.GetOperatedGroup():GetFirst()
		RD.AttachAtkDef(e,tc,1500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end