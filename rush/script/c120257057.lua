local cm,m=GetID()
cm.name="机器检查员"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return (c:IsRace(RACE_MACHINE) or c:IsType(TYPE_TRAP)) and c:IsAbleToGrave()
end
function cm.exfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsLocation(LOCATION_GRAVE)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>3 end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetDecktopGroup(tp,4)
	local g2=Duel.GetDecktopGroup(1-tp,4)
	local g3=Group.CreateGroup()
	g3:Merge(g1)
	g3:Merge(g2)
	if g3:GetCount()<8 then return end
	Duel.ConfirmDecktop(tp,4)
	Duel.ConfirmDecktop(1-tp,4)
	local mg=g3:Filter(cm.filter,nil)
	local draw=false
	if mg:GetCount()>0 then
		local sg=RD.CanSelect(aux.Stringid(m,1),HINTMSG_TOGRAVE,tp,mg,nil,1,2)
		if sg then
			Duel.DisableShuffleCheck()
			if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
				draw=RD.IsOperatedGroupExists(cm.exfilter,1,nil)
				g1:Sub(sg)
				g2:Sub(sg)
			end
		end
	end
	Duel.SortDecktop(tp,tp,g1:GetCount())
	RD.SendDeckTopToBottom(tp,g1:GetCount())
	Duel.SortDecktop(1-tp,1-tp,g2:GetCount())
	RD.SendDeckTopToBottom(1-tp,g2:GetCount())
	if draw then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end