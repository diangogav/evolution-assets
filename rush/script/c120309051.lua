local cm,m=GetID()
local list={CARD_CODE_FuSiGiNaKoBiTo,120309053}
cm.name="小人的伙伴们"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.filter(c)
	return c:IsLevel(1) or c:IsCode(list[2])
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	Duel.ConfirmDecktop(tp,5)
	local atk=Duel.GetDecktopGroup(tp,5):FilterCount(cm.filter,nil)*700
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	end
	Duel.SortDecktop(tp,tp,5)
	RD.SendDeckTopToBottom(tp,5)
end