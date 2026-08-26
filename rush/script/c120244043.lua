local cm,m=GetID()
local list={120105001,120244013}
cm.name="魔导骑士-七魔导战车"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Multi-Choose Effect
	local e1,e2=RD.CreateMultiChooseEffect(c,nil,cm.cost,aux.Stringid(m,1),cm.target1,cm.operation1,aux.Stringid(m,2),cm.target2,cm.operation2)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCategory(CATEGORY_DESTROY)
end
--Multi-Choose Effect
function cm.filter(c)
	return c:GetSequence()<5
end
cm.cost=RD.CostSendDeckTopToGrave(1)
--Atk Up
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)*500
		RD.AttachAtkDef(e,c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end
--Indes Effect
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return RD.IsCanAttachEffectIndes(e:GetHandler(),tp,cm.indval) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local ct=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_SZONE,0,nil)
		if ct>0 then
			RD.CanSelectAndDoAction(aux.Stringid(m,4),HINTMSG_DESTROY,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,ct,nil,function(g)
				Duel.Destroy(g,REASON_EFFECT)
			end)
		end
	end
end