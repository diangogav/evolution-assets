local cm,m=GetID()
cm.name="昂光的咒缚"
function cm.initial_effect(c)
	Duel.AddCustomActivityCounter(m,ACTIVITY_CHAIN,cm.chainfilter)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP))
end
function cm.filter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and (not c:IsPosition(POS_FACEUP_ATTACK) or c:IsCanTurnSet())
end
function cm.excon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(m,1-tp,ACTIVITY_CHAIN)~=0 or Duel.GetTurnCount()==2
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)<=1
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ex=cm.excon(e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e,tp)
		and (not ex or (Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2))) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	if ex then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,2)
	end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		local pos=POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			pos=POS_FACEDOWN_DEFENSE
		elseif tc:IsFacedown() or not tc:IsCanTurnSet() then
			pos=POS_FACEUP_ATTACK
		end
		pos=Duel.SelectPosition(tp,tc,pos)
		if RD.ChangePosition(tc,e,tp,REASON_EFFECT,pos)~=0 and cm.excon(e,tp,eg,ep,ev,re,r,rp) then
			Duel.Draw(tp,2,REASON_EFFECT)
			Duel.Draw(1-tp,2,REASON_EFFECT)
		end
	end)
end