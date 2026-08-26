local cm,m=GetID()
local list={120203034}
cm.name="大逆转之女神"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.confilter(c)
	return c:IsCode(list[1])
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE)
end
function cm.desfilter(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
	RD.TargetDraw(tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if RD.Draw()~=0 and RD.SendDeckTopToGraveAndExists(p,1,cm.exfilter,1,nil) then
		local tc=Duel.GetOperatedGroup():GetFirst()
		local filter=RD.Filter(cm.desfilter,tc:GetRace())
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,filter,tp,0,LOCATION_MZONE,2,2,nil,function(g)
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end