local cm,m=GetID()
local list={120213023}
cm.name="二子蛋球机器人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[1])
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	RD.TargetDraw(1-tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 then
		local g=Duel.GetOperatedGroup()
		Duel.ConfirmCards(1-tp,g)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		if tc:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsRelateToEffect(e) then
			RD.AttachAtkDef(e,c,tc:GetAttack(),0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
		Duel.ShuffleHand(1-tp)
	end
end