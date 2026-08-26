local cm,m=GetID()
local list={120105001,120110001}
cm.name="连击龙骑士-七魔术骑士"
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
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.AttachExtraAttackMonster(e,c,1,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return RD.IsCanAttachEffectIndes(e:GetHandler(),tp,cm.indval) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,4),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	end
end