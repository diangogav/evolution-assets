local cm,m=GetID()
cm.name="元素循环"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	if c:IsLocation(LOCATION_EXTRA) then
		return c:IsType(TYPE_FUSION) and c:IsLevel(6,7) and c:IsRace(RACE_WARRIOR)
	else
		return c:IsRace(RACE_WARRIOR) and c:IsAbleToGraveAsCost()
	end
end
function cm.check(g)
	if g:GetClassCount(Card.GetLocation)==1 then return false end
	local mc,fc=g:GetFirst(),g:GetNext()
	if mc:IsLocation(LOCATION_EXTRA) then mc,fc=fc,mc end
	return aux.IsMaterialListCode(fc,mc:GetCode())
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.costfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,nil)
	if chk==0 then return g:CheckSubGroup(cm.check,2,2) end
	local sg=RD.Select(aux.Stringid(m,1),tp,g,cm.check,false,2,2)
	local mc,fc=sg:GetFirst(),sg:GetNext()
	if mc:IsLocation(LOCATION_EXTRA) then mc,fc=fc,mc end
	Duel.ConfirmCards(1-tp,fc)
	Duel.SendtoGrave(mc,REASON_COST)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	RD.TargetDraw(tp,3)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 then
		RD.SelectAndDoAction(HINTMSG_TOGRAVE,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil,function(g)
			Duel.BreakEffect()
			Duel.SendtoGrave(g,REASON_EFFECT)
		end)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotActivateEffect(e,aux.Stringid(m,2),cm.aclimit,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not tc:IsRace(RACE_WARRIOR)
end