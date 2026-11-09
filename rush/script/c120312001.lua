local cm,m=GetID()
cm.name="涂足的调色少女"
function cm.initial_effect(c)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
function cm.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cm.exfilter(c,attr,race)
	return c:IsFaceup() and (not c:IsAttribute(attr) or not c:IsRace(race))
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	RD.SendDeckBottomToTop(tp,3)
	local sg=RD.RevealDeckTopAndCanSelect(tp,3,aux.Stringid(m,1),HINTMSG_TOGRAVE,cm.filter,1,1)
	local tc=nil
	if sg:GetCount()>0 then
		Duel.DisableShuffleCheck()
		if RD.SendToGraveAndExists(sg,e,tp,REASON_EFFECT) then
			tc=Duel.GetOperatedGroup():GetFirst()
		end
	end
	Duel.ShuffleDeck(tp)
	if tc then
		local attr=tc:GetAttribute()
		local race=tc:GetRace()
		local filter=RD.Filter(cm.exfilter,attr,race)
		RD.CanSelectAndDoAction(aux.Stringid(m,2),aux.Stringid(m,3),filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN
			RD.ChangeAttribute(e,g:GetFirst(),attr,reset)
			RD.ChangeRace(e,g:GetFirst(),race,reset)
		end)
	end
end