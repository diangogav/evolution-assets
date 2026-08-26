local cm,m=GetID()
local list={120247040,120247043}
cm.name="幻坏爆龙 危险爆破龙王"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.filter(c,tp)
	if c:IsControler(tp) then
		return c:IsFaceup()
	else
		return true
	end
end
function cm.exfilter(c,tp)
	return RD.IsPreviousControler(c,tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
function cm.check(g,tp)
	return g:FilterCount(Card.IsControler,nil,tp)==1
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_ONFIELD,LOCATION_MZONE,nil,tp)
	if chk==0 then return g:CheckSubGroup(cm.check,2,3,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	local check=RD.Check(cm.check,tp)
	RD.SelectGroupAndDoAction(HINTMSG_DESTROY,filter,check,tp,LOCATION_ONFIELD,LOCATION_MZONE,2,3,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			local og=Duel.GetOperatedGroup()
			local ct=og:FilterCount(cm.exfilter,nil,1-tp)
			if ct>0 then
				Duel.BreakEffect()
				Duel.Damage(1-tp,ct*500,REASON_EFFECT)
			end
		end
	end)
end