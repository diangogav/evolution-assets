local cm,m=GetID()
local list={120213023}
cm.name="全中蛋球投球"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c,tp)
	if c:IsControler(tp) then
		return c:IsFaceup() and c:IsCode(list[1])
	else
		return c:IsFaceup() and c:IsAttackAbove(100)
	end
end
function cm.check(g)
	return g:GetClassCount(Card.GetControler)==2
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then return g:CheckSubGroup(cm.check,2,2,tp) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectGroupAndDoAction(aux.Stringid(m,1),filter,cm.check,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil,function(g)
		local tc1=g:Filter(Card.IsControler,nil,tp):GetFirst()
		local tc2=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
		RD.AttachAtkDef(e,tc1,tc2:GetAttack(),0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.AttachPierce(e,tc1,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end