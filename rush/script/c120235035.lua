local cm,m=GetID()
local list={120235003}
cm.name="THE☆星齿车戒龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[1])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,cm.condition,cm.cost,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
end
--Multi-Choose Effect
function cm.confilter1(c,tp)
	return c:IsType(TYPE_NORMAL) and Duel.IsExistingMatchingCard(cm.confilter2,tp,LOCATION_GRAVE,0,1,c,c)
end
function cm.confilter2(c,tc)
	return c:IsType(TYPE_NORMAL) and RD.IsSameCode(c,tc)
end
function cm.check(g)
	return g:GetCount()==2 and RD.IsSameCode(g:GetFirst(),g:GetNext())
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_GRAVE,0,1,nil,tp)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
--Attack Twice
function cm.filter1(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and RD.IsCanAttachExtraAttack(c,1)
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter1,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.IsAbleToEnterBP() and g:CheckSubGroup(cm.check,2,2) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(aux.Stringid(m,3),cm.filter1,cm.check,tp,LOCATION_MZONE,0,2,2,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachExtraAttack(e,tc,1,aux.Stringid(m,4),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end)
end
--Special Summon
function cm.filter2(c,e,tp)
	return c:IsType(TYPE_NORMAL) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetMZoneCount(tp)>1
		and g:CheckSubGroup(cm.check,2,2,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndSpecialSummon(aux.NecroValleyFilter(cm.filter2),cm.check,tp,LOCATION_GRAVE,0,2,2,nil,e,POS_FACEUP)
end