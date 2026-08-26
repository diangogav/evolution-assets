local cm,m=GetID()
local list={120205025,120205006,120205025}
cm.name="火浇摩天鱼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.thfilter(c)
	return c:IsCode(list[3]) and c:IsAbleToHand()
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsLevel(8)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,800,REASON_EFFECT)
			local c=e:GetHandler()
			local sg=Duel.GetMatchingGroup(cm.atkfilter,tp,0,LOCATION_MZONE,nil)
			if sg:GetCount()>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
				RD.AttachAtkDef(e,c,800,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sg:ForEach(function(tc)
					RD.AttachAtkDef(e,tc,-800,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				end)
			end
		end
	end)
end