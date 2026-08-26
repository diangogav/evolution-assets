local cm,m=GetID()
local list={120196006,120196008}
cm.name="钢铁徽章之弗栗多明星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,nil,nil,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_POSITION)
	e2:SetCategory(CATEGORY_DESTROY)
end
--Position
function cm.posfilter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and (not c:IsPosition(POS_FACEUP_ATTACK) or c:IsCanTurnSet())
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		local pos=POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			pos=POS_FACEDOWN_DEFENSE
		elseif tc:IsFacedown() or not tc:IsCanTurnSet() then
			pos=POS_FACEUP_ATTACK
		end
		pos=Duel.SelectPosition(tp,tc,pos)
		RD.ChangePosition(tc,e,tp,REASON_EFFECT,pos)
	end)
end
--Destroy
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBORG)
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(cm.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,ct,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end