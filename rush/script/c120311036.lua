local cm,m=GetID()
local list={120263008,120263005,120263009}
cm.name="元素英雄 暴风侠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2],list[3])
	--Only Fusion Summon
	RD.OnlyFusionSummon(c)
	--Buff
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Buff
function cm.costfilter(c,e,tp)
	return c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,c)
end
function cm.filter(c)
	return c:IsFaceup() and RD.IsCanAttachBattleIndes(c,1)
end
cm.cost=RD.CostSendOnFieldToGrave(cm.costfilter,1,1,true)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachBattleIndes(e,g:GetFirst(),1,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	end)
end