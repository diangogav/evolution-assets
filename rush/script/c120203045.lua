local cm,m=GetID()
cm.name="裂缝掉落"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			RD.AttachAtkDef(e,g:GetFirst(),-1000,-1000,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end