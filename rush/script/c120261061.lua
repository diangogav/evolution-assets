local cm,m=GetID()
cm.name="香料忍布黑胡椒"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CUSTOM+m)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	--Event
	if not cm.global_check then
		cm.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(cm.event)
		Duel.RegisterEffect(ge1,0)
	end
end
--Activate
function cm.confilter1(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_CYBERSE)
end
function cm.confilter2(c,tp)
	return c:IsPreviousControler(tp)
end
function cm.filter(c)
	return c:IsAbleToDeck()
end
function cm.check(g)
	return g:IsExists(Card.IsLevelBelow,2,nil,4)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(cm.confilter1,tp,LOCATION_GRAVE,0,nil)
	return mg:GetClassCount(Card.GetCode)>2 and eg:IsExists(cm.confilter2,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return g:CheckSubGroup(cm.check,5,5,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,1-tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),cm.check,tp,0,LOCATION_GRAVE,5,5,nil,function(g)
		RD.SendToDeckTop(g,e,tp,REASON_EFFECT)
	end)
end
--Event
function cm.event(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_DECK)
	if g:GetCount()>0 then
		Duel.RaiseEvent(g,EVENT_CUSTOM+m,re,r,rp,ep,ev)
	end
end