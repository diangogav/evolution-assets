local cm,m=GetID()
cm.name="绿眼星猫"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
cm.trival=RD.ValueDoubleTributeAtkDef(nil,200)
function cm.costfilter(c)
	return c:IsRace(RACE_BEAST+RACE_WARRIOR) and RD.IsDefense(c,200) and c:IsAbleToGraveAsCost()
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1,nil,nil,function(g)
	return g:GetFirst():GetType()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if RD.Draw()~=0 and (e:GetLabel()&(TYPE_NORMAL))~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachDoubleTribute(e,c,cm.trival,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end