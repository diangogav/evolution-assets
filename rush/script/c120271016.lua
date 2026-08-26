local cm,m=GetID()
local list={120196006}
cm.name="重钢铁徽章之阿修罗明星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,nil,cm.cost,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetCategory(CATEGORY_ATKCHANGE)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevel(9) and c:IsRace(RACE_CYBORG)
end
--Multi-Choose Effect
cm.cost=RD.CostSendHandToDeckBottom(Card.IsAbleToDeckAsCost,1,1,false)
--Special Summon
function cm.spfilter(c,e,tp)
	return c:IsLevel(9) and c:IsRace(RACE_CYBORG) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP_DEFENSE)
end
--Atk Up
function cm.atkfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_CYBORG)
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.SelectAndDoAction(aux.Stringid(m,3),cm.atkfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			RD.AttachAtkDef(e,c,g:GetFirst():GetAttack(),0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end