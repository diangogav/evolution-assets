local cm,m=GetID()
cm.name="梦中之虎甲"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
cm.trival=RD.ValueDoubleTributeAttrRace(ATTRIBUTE_LIGHT,RACE_INSECT)
function cm.exfilter(c)
	return c:IsFaceup() and RD.IsCanChangeRace(c,RACE_INSECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanAttachDoubleTribute(e:GetHandler(),cm.trival)
end
cm.cost=RD.CostChangeSelfPosition(POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachDoubleTribute(e,c,cm.trival,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,2),aux.Stringid(m,3),cm.exfilter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
			RD.ChangeRace(e,sg:GetFirst(),RACE_INSECT,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end)
	end
end