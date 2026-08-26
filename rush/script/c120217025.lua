local cm,m=GetID()
local list={120120028,120217042}
cm.name="彩光超 欧米伽公主"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,nil,nil,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
end
--Position
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(RD.IsCanChangePosition,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(RD.IsCanChangePosition,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(RD.IsCanChangePosition,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 and RD.ChangePosition(g,e,tp,REASON_EFFECT)~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,3),aux.Stringid(m,4),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			Duel.BreakEffect()
			local atk=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*-800
			RD.AttachAtkDef(e,g:GetFirst(),atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end
--To Deck
function cm.tdfilter(c)
	return c:IsAbleToDeck()
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tdfilter,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_GRAVE,nil)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,0,LOCATION_GRAVE,1,7,nil,function(g)
		RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
	end)
end