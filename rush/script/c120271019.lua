local cm,m=GetID()
local list={120196006,120271026}
cm.name="钢铁徽章之格尼乌斯明星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,cm.condition,nil,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DAMAGE)
end
--Multi-Choose Effect
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
--Draw
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	RD.Draw()
end
--To Deck
function cm.tdfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToDeck()
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tdfilter,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1400)
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,0,LOCATION_GRAVE,1,6,nil,function(g)
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,1400,REASON_EFFECT)
		end
	end)
end