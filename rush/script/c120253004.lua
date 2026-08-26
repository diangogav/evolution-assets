local cm,m=GetID()
cm.name="暗冥穿越侍·危机海牛侍"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureThree(c,aux.Stringid(m,2),nil,cm.sumfilter(ATTRIBUTE_LIGHT))
	RD.AddSummonProcedureThree(c,aux.Stringid(m,3),nil,cm.sumfilter(ATTRIBUTE_DARK))
	RD.AddSummonProcedureThree(c,aux.Stringid(m,4),nil,cm.sumfilter(ATTRIBUTE_FIRE))
	RD.AddSummonProcedureThree(c,aux.Stringid(m,5),nil,cm.sumfilter(ATTRIBUTE_WATER))
	RD.AddSummonProcedureThree(c,aux.Stringid(m,6),nil,cm.sumfilter(ATTRIBUTE_EARTH))
	RD.AddSummonProcedureThree(c,aux.Stringid(m,7),nil,cm.sumfilter(ATTRIBUTE_WIND))
	RD.AddSummonProcedureThree(c,aux.Stringid(m,8),nil,cm.sumfilter(ATTRIBUTE_DIVINE))
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(attr)
	return function(c,e,tp)
		return c:IsAttribute(attr) and (c:IsFaceup() or c:IsControler(tp))
	end
end
--Destroy
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsSummonTurn(c) and c:IsSummonType(SUMMON_VALUE_SELF)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsLevelAbove(1)
			and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,1)) then
			Duel.BreakEffect()
			local atk=tc:GetOriginalLevel()*200
			RD.AttachAtkDef(e,c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end