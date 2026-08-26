local cm,m=GetID()
cm.name="哥布林突击部队"
function cm.initial_effect(c)
	--Position
	local e1=RD.ContinuousBattleDestroyToGrave(c,cm.condition,cm.operation)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Position
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		Duel.Hint(HINT_CARD,0,m)
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end