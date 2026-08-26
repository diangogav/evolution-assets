local cm,m=GetID()
cm.name="超可爱执行者联合！"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
cm.trival=RD.ValueDoubleTributeAll()
function cm.filter(c)
	return c:IsFaceup() and RD.IsCanAttachDoubleTribute(c,cm.trival)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevel(6) and RD.IsDefense(c,500)
end
function cm.check(g)
	return g:GetClassCount(Card.GetRace)==g:GetCount()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(cm.check,2,2) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(aux.Stringid(m,1),cm.filter,cm.check,tp,LOCATION_MZONE,0,2,2,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachDoubleTribute(e,tc,cm.trival,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
			Duel.Damage(1-tp,800,REASON_EFFECT)
		end
	end)
end