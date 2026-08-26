local cm,m=GetID()
local list={120196050,120260020}
cm.name="深空宇宙冲击"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return (c:IsRace(RACE_CYBERSE) or c:IsCode(list[1],list[2])) and c:IsAbleToDeck()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,3,6,nil,function(g)
		if RD.SendToDeckTop(g,e,tp,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,nil,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end)
		end
	end)
end