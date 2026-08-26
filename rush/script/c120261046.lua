local cm,m=GetID()
local list={120261014,120261013}
cm.name="电子界香料忍·肉桂女王"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,3,3)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 then
		Duel.ConfirmDecktop(tp,2)
		Duel.ConfirmDecktop(1-tp,2)
		Duel.BreakEffect()
		local g1=Duel.GetDecktopGroup(tp,2)
		local g2=Duel.GetDecktopGroup(1-tp,2)
		g1:Merge(g2)
		local g=g1:Filter(Card.IsLevelAbove,nil,1)
		local lv=g:GetSum(Card.GetLevel)
		if lv>0 then
			Duel.Damage(1-tp,lv*100,REASON_EFFECT)
		end
		Duel.ShuffleDeck(tp)
		Duel.ShuffleDeck(1-tp)
	end
end