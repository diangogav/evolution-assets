local cm,m=GetID()
cm.name="骰子的大剑士"
function cm.initial_effect(c)
	--Multiple Attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
cm.toss_dice=true
--Multiple Attack
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and d>1 then
		RD.AttachExtraAttack(e,c,d-1,aux.Stringid(m,d),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
	if d<=3 then
		RD.CanDraw(aux.Stringid(m,1),tp,1)
	end
end