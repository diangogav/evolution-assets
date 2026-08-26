local cm,m=GetID()
cm.name="朋友！"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter1(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(cm.confilter2,tp,LOCATION_MZONE,0,1,c,c:GetRace())
end
function cm.confilter2(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
function cm.check(g)
	return g:GetClassCount(Card.GetAttribute)==1
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_MZONE,0,1,nil,tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 then
		RD.CanSelectGroupAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),Card.IsFaceup,cm.check,tp,LOCATION_MZONE,0,2,2,nil,function(g)
			Duel.BreakEffect()
			g:ForEach(function(tc)
				RD.AttachAtkDef(e,tc,400,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end)
	end
end