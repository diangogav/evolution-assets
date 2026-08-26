local cm,m=GetID()
local list={120301019}
cm.name="灵术的指南书"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttack(c,500,1900) and RD.IsDefense(c,1500)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	Duel.ConfirmDecktop(tp,5)
	local ct=Duel.GetDecktopGroup(tp,5):FilterCount(cm.filter,nil)
	if ct>1 then
		local max=math.floor(ct/2)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,max,nil,function(g)
			if Duel.Destroy(g,REASON_EFFECT)==2 then
				RD.CreateHintEffect(e,aux.Stringid(m,2),tp,1,0,RESET_PHASE+PHASE_END)
				RD.CreateOnlySoleDirectAttackEffect(e,20301019,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
			end
		end)
	end
	Duel.SortDecktop(tp,tp,5)
	RD.SendDeckTopToBottom(tp,5)
end