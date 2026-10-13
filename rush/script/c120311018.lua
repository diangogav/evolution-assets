local cm,m=GetID()
local list={120261058}
cm.name="宇宙姬的更衣"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()==900 and c:IsRace(RACE_GALAXY)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 and Duel.GetFlagEffect(tp,m)==0 then
			-- use flag to check draw
			if RD.CanDraw(aux.Stringid(m,1),tp,2)~=0 then
				Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end)
end