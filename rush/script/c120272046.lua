local cm,m=GetID()
local list={120196006,120272001}
cm.name="钢铁徽章之阿梅勒斯明星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,nil,cm.cost,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_DESTROY)
	e2:SetCategory(CATEGORY_CONTROL)
end
--Multi-Choose Effect
cm.cost=RD.CostChangeSelfPosition()
--Destroy
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()==0 then return end
	Duel.ConfirmCards(tp,g)
	local sg=g:Filter(Card.IsType,nil,TYPE_SPELL)
	if sg:GetCount()>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
--Control
function cm.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_MAXIMUM) and c:IsRace(RACE_FAIRY)
		and c:IsControlerCanBeChanged()
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_CONTROL,cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		Duel.GetControl(g:GetFirst(),tp)
	end)
end