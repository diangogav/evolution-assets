local cm,m=GetID()
local list={120105001,120196021}
cm.name="道星魔导剑斗士"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,nil,cm.cost,aux.Stringid(m,2),cm.target1,cm.operation1,aux.Stringid(m,3),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_ATKCHANGE)
end
--Multi-Choose Effect
cm.cost=RD.CostSendDeckTopToGrave(1)
--Atk Down
function cm.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(1)
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.atkfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.atkfilter,tp,LOCATION_GRAVE,0,nil)
	local val=g:GetClassCount(Card.GetLevel)*400
	RD.SelectAndDoAction(aux.Stringid(m,4),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
		RD.AttachAtkDef(e,sg:GetFirst(),-val,-val,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end
--Pierce
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsAbleToEnterBP() and RD.IsCanAttachPierce(e:GetHandler()) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachPierce(e,c,aux.Stringid(m,5),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end