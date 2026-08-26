local cm,m=GetID()
cm.name="魔力动物威严"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
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
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c,e,tp)
	if c:IsControler(tp) then
		return c:IsFaceup() and c:IsLevelAbove(1)
			and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST)
	else
		return c:IsFaceup() and c:IsLevelAbove(1)
			and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and c:IsCanTurnSet()
	end
end
function cm.exfilter(c,tc)
	return c:GetLevel()<tc:GetLevel()
end
function cm.check(g,tp)
	if g:FilterCount(Card.IsControler,nil,tp)~=1 then return false end
	local tc=g:Filter(Card.IsControler,nil,tp):GetFirst()
	return g:FilterCount(cm.exfilter,tc,tc)==(g:GetCount()-1)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return g:CheckSubGroup(cm.check,2,3,tp) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	local check=RD.Check(cm.check,tp)
	RD.SelectGroupAndDoAction(aux.Stringid(m,1),filter,check,tp,LOCATION_MZONE,LOCATION_MZONE,2,3,nil,function(g)
		local sg=g:Filter(Card.IsControler,nil,1-tp)
		RD.ChangePosition(sg,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)
	end)
end