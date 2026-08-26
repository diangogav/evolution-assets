local cm,m=GetID()
local list={120246052}
cm.name="斩神 奇拔茨"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
function cm.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.ShuffleDeck(tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2 then return end
	local sg,g=RD.RevealDeckTopAndCanSelect(tp,2,aux.Stringid(m,1),HINTMSG_TOGRAVE,cm.filter,1,1)
	local des=false
	if sg:GetCount()>0 then
		if Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)~=0 then
			local tc=Duel.GetOperatedGroup():GetFirst()
			des=tc:IsCode(list[1]) and tc:IsLocation(LOCATION_GRAVE)
		end
	end
	Duel.ShuffleDeck(tp)
	if des then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil,function(dg)
			Duel.Destroy(dg,REASON_EFFECT)
		end)
	end
end