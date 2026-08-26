local cm,m=GetID()
local list={120244012,120244011}
cm.name="名蔷薇匿名魔术师"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler(),SUMMON_TYPE_FUSION)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),aux.Stringid(m,3),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				Duel.BreakEffect()
				RD.AttachAtkDef(e,sg:GetFirst(),-tc:GetBaseAttack(),0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
end