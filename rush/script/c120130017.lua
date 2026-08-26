local cm,m=GetID()
cm.name="闪电击秃鹰"
function cm.initial_effect(c)
	--Atk & Def Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk & Def Down
function cm.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(cm.adfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function cm.adfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1,function(g)
	local tc=g:GetFirst()
	return tc:GetLevel(),tc:GetAttribute()
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local lv,attr=e:GetLabel()
	local down=lv*-300
	local g=Duel.GetMatchingGroup(cm.adfilter,tp,0,LOCATION_MZONE,nil,attr)
	g:ForEach(function(tc)
		RD.AttachAtkDef(e,tc,down,down,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end