local cm,m=GetID()
cm.name="骰子炸药少女·小双骰"
function cm.initial_effect(c)
	--Dice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_TODECK+CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
cm.toss_dice=true
--Dice
cm.cost=RD.CostSendDeckTopToGrave(2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local d1,d2=Duel.TossDice(tp,2)
	local res=d1+d2
	if res==7 or res==11 then
		RD.SelectAndDoAction(HINTMSG_TODECK,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
			RD.SendToDeckBottom(g,e,tp,REASON_EFFECT)
		end)
	elseif res==2 or res==3 or res==12 then
		RD.SelectAndDoAction(HINTMSG_POSCHANGE,RD.IsCanChangePosition,tp,LOCATION_MZONE,0,1,1,nil,function(g)
			RD.ChangePosition(g,e,tp,REASON_EFFECT)
		end)
	else
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			RD.AttachAtkDef(e,c,res*200,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
	end
end