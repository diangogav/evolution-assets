local cm,m=GetID()
local list={120257016,120272007}
cm.name="骰子炸药美腿女郎·翻倍小掷"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Dice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
cm.toss_dice=true
--Dice
function cm.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsAttribute(ATTRIBUTE_LIGHT) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler())
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local d1,d2=Duel.TossDice(tp,2)
	local lv=d1+d2
	local filter=aux.NecroValleyFilter(RD.Filter(cm.spfilter,e,tp,lv))
	if RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,POS_FACEUP)~=0 then
		local c=e:GetHandler()
		local tc=Duel.GetOperatedGroup():GetFirst()
		local atk=tc:GetBaseAttack()
		if atk>0 and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,2)) then
			Duel.BreakEffect()
			RD.AttachAtkDef(e,c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end