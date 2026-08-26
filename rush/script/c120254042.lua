local cm,m=GetID()
cm.name="传导士 炼金化学人·水雷"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,false,cm.matfilter1,cm.matfilter2)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter1(c)
	return c:IsRace(RACE_AQUA)
end
function cm.matfilter2(c)
	return c:IsRace(RACE_THUNDER)
end
--Atk Up
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.check(g,e,tp)
	return g:IsExists(cm.costfilter,1,nil)
end
cm.cost=RD.CostSendHandSubToGrave(Card.IsAbleToGraveAsCost,cm.check,1,3,function(g)
	local sg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
	return g:GetSum(Card.GetLevel),sg:GetClassCount(Card.GetRace)
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local lv,ct=e:GetLabel()
		RD.AttachAtkDef(e,c,lv*100,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		if ct==3 then
			RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
	end
end