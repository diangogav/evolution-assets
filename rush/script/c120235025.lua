local cm,m=GetID()
cm.name="苍救骑士 邓库斯"
function cm.initial_effect(c)
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
--Atk Up
function cm.costfilter(c)
	return c:IsRace(RACE_CELESTIALWARRIOR)
end
function cm.costcheck(g)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
cm.cost=RD.CostShowGroupExtra(cm.costfilter,cm.costcheck,1,5,Group.GetCount)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		local atk=e:GetLabel()*200
		RD.AttachAtkDef(e,c,atk,0,reset)
		RD.AttachCannotDirectAttack(e,c,aux.Stringid(m,1),reset)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,2),RACE_ALL-RACE_CELESTIALWARRIOR-RACE_WARRIOR-RACE_FAIRY,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end