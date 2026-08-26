local cm,m=GetID()
local list={120290049}
cm.name="饥饿的特别优惠券"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND+LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c,e,tp)
	return c:IsFaceup() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and c:IsCanTurnSet()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_SET,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)~=0 then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.exfilter,tp,LOCATION_MZONE,0,1,1,nil,function(sg)
				local tc=sg:GetFirst()
				RD.AttachLevel(e,tc,3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				RD.AttachPierce(e,tc,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
end