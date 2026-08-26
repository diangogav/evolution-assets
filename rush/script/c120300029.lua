local cm,m=GetID()
cm.name="电动刃虫"
function cm.initial_effect(c)
	--Draw
	local e1=RD.ContinuousBattleDestroyToGrave(c,nil,cm.drop)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Draw
function cm.drop(e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.Hint(HINT_CARD,0,m)
	Duel.Draw(1-tp,1,REASON_EFFECT)
end