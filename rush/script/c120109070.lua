local cm,m=GetID()
local list={120109070}
cm.name="敌人操纵器"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1,e2=RD.CreateMultiChooseEffectSpell(c,cm.condition,nil,aux.Stringid(m,1),cm.target1,cm.activate1,aux.Stringid(m,2),cm.target2,cm.activate2)
	e1:SetCategory(CATEGORY_POSITION)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_CONTROL)
end
--Activate
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.tgfilter(c,tp)
	return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
function cm.ntrfilter(c)
	return not RD.IsMaximumMode(c) and c:IsFaceup() and c:IsControlerCanBeChanged()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate1(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.ChangePosition(g,e,tp,REASON_EFFECT)
	end)
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(cm.ntrfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function cm.activate2(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.tgfilter,tp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		if RD.SendToGraveAndExists(g) then
			RD.SelectAndDoAction(HINTMSG_CONTROL,cm.ntrfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
				local tc=g:GetFirst()
				Duel.BreakEffect()
				if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
					RD.AttachCannotAttack(e,tc,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				end
			end)
		end
	end)
end