local cm,m=GetID()
local list={120110001,120196026}
cm.name="超击龙 星齿车戒龙F"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,cm.condition,cm.cost,aux.Stringid(m,1),nil,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_ATKCHANGE)
end
--Multi-Choose Effect
function cm.confilter1(c)
	return c:IsRace(RACE_DRAGON) or c:IsRace(RACE_HYDRAGON)
end
function cm.confilter2(c)
	return c:IsType(TYPE_MONSTER) and not cm.confilter1(c)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(cm.confilter2,tp,LOCATION_GRAVE,0,1,nil)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
--Atk Up
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,900,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.AttachExtraAttackMonster(e,c,1,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end
--Pierce
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsAbleToEnterBP() and RD.IsCanAttachExtraAttack(e:GetHandler(),1) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachExtraAttack(e,c,1,aux.Stringid(m,4),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.AttachPierce(e,c,aux.Stringid(m,5),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end