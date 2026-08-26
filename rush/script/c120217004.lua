local cm,m=GetID()
local list={120183017,120196026}
cm.name="刚击龙 星齿车戒钢龙F"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,nil,cm.cost,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_ATKCHANGE)
end
--Multi-Choose Effect
cm.cost=RD.CostSendDeckTopToGrave(1)
--Atk Up
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end
	g:ForEach(function(tc)
		RD.AttachAtkDef(e,tc,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachExtraAttackMonster(e,c,1,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end
	g:ForEach(function(tc)
		RD.AttachBattleIndes(e,tc,1,aux.Stringid(m,4),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,5),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachExtraAttack(e,c,1,aux.Stringid(m,6),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end