local cm,m=GetID()
cm.name="幻刃奥义-突陷攻事"
function cm.initial_effect(c)
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
function cm.upfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7) and c:IsRace(RACE_WYRM)
end
function cm.downfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(3000)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.upfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local ug=Duel.GetMatchingGroup(cm.upfilter,tp,LOCATION_MZONE,0,nil)
	if ug:GetCount()==0 then return end
	ug:ForEach(function(tc)
		RD.AttachAtkDef(e,tc,600,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
	local dg=Duel.GetMatchingGroup(cm.downfilter,tp,0,LOCATION_MZONE,nil)
	if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
		Duel.BreakEffect()
		dg:ForEach(function(tc)
			RD.AttachAtkDef(e,tc,-1200,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end