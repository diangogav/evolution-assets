local cm,m=GetID()
local list={120150014,120150015}
cm.name="仄米粒子机"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.confilter(c,code)
	return c:IsCode(code)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil,list[1])
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil,list[2])
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGrave() and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsControler(tp) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and Duel.Draw(tp,2,REASON_EFFECT)~=0 then
		RD.SelectAndDoAction(HINTMSG_TODECK,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil,function(g)
			Duel.BreakEffect()
			RD.SendToDeckBottom(g,e,tp,REASON_EFFECT)
		end)
	end
end