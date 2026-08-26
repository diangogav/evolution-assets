local cm,m=GetID()
cm.name="鼠小僧盗贼·梅尔"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=15
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
		local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0
		return (b1 or b2) and (not b1 or Duel.IsPlayerCanDraw(tp,1)) and (not b2 or Duel.IsPlayerCanDraw(1-tp,1))
	end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end