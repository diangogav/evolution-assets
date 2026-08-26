local cm,m=GetID()
cm.name="摆尾攻击"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c,tp)
	if c:IsControler(tp) then
		return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_DINOSAUR)
	else
		return (c:IsFacedown() or c:IsLevelAbove(1)) and c:IsAbleToHand()
	end
end
function cm.exfilter(c,tc)
	return c:IsFacedown() or c:GetLevel()<tc:GetLevel()
end
function cm.check(g,tp)
	if g:FilterCount(Card.IsControler,nil,tp)~=1 then return false end
	local tc=g:Filter(Card.IsControler,nil,tp):GetFirst()
	return g:FilterCount(cm.exfilter,tc,tc)==(g:GetCount()-1)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then return g:CheckSubGroup(cm.check,2,3,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_MZONE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	local check=RD.Check(cm.check,tp)
	RD.SelectGroupAndDoAction(aux.Stringid(m,1),filter,check,tp,LOCATION_MZONE,LOCATION_MZONE,2,3,nil,function(g)
		local sg=g:Filter(Card.IsControler,nil,1-tp)
		RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
	end)
end