local cm,m=GetID()
local list={120196006,120196007}
cm.name="钢铁徽章之拉冬明星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,nil,cm.cost,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCategory(CATEGORY_ATKCHANGE)
end
--Multi-Choose Effect
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
--Atk & Def Down(Single)
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,3),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),-1500,-1500,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end
--Atk & Def Down(AOE)
function cm.downfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.downfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.downfilter,tp,0,LOCATION_MZONE,nil)
	g:ForEach(function(tc)
		RD.AttachAtkDef(e,tc,-2000,-2000,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end