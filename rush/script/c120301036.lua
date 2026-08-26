local cm,m=GetID()
local list={120235020,120301049}
cm.name="苍救之闪戟士 德古雷西翁"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2,e3=RD.CreateMultiChooseEffect3(c,nil,cm.cost,
		aux.Stringid(m,1),cm.target1,cm.operation1,
		aux.Stringid(m,2),nil,cm.operation2,
		aux.Stringid(m,3),cm.target3,cm.operation3)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_WARRIOR)
end
--Multi-Choose Effect
cm.cost=RD.CostSendDeckTopToGrave(1)
--Direct Attack
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsAbleToEnterBP() and RD.IsCanAttachDirectAttack(e:GetHandler()) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachDirectAttack(e,c,aux.Stringid(m,4),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end
--Atk Up
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,1500,1500,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end
--Attack Twice
function cm.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsAbleToEnterBP() and RD.IsCanAttachExtraAttack(e:GetHandler(),1) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachExtraAttack(e,c,1,aux.Stringid(m,5),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end