local cm,m=GetID()
local list={120105010}
cm.name="落单使魔术师"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
--Draw
function cm.costfilter(c)
	return c:IsAttack(0) and c:IsAbleToGraveAsCost()
end
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.filter(c,tp)
	return c:IsFaceup() and c:IsAttack(0) and RD.IsCanAttachEffectIndes(c,tp,cm.indval)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		local filter=RD.Filter(cm.filter,tp)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),filter,tp,LOCATION_MZONE,0,1,1,nil,function(sg)
			RD.AttachEffectIndes(e,sg:GetFirst(),cm.indval,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end