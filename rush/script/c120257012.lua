local cm,m=GetID()
local list={120257049}
cm.name="骰子的大天使"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk & Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
cm.toss_dice=true
--Atk & Def Up
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end
	local d=Duel.TossDice(tp,1)
	local val=d*100
	if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		val=d*200
	end
	g:ForEach(function(tc)
		RD.AttachAtkDef(e,tc,val,val,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end