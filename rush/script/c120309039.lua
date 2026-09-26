local cm,m=GetID()
cm.name="云海龙 谢尔"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToGraveAsCost()
end
function cm.filter(c,e,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil,e,c)
end
function cm.exfilter(c,e,tc)
	return c:IsType(TYPE_UNION) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
		and RD.CheckUnionEquip(e,tc,c)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local filter1=RD.Filter(cm.filter,e,tp)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_EQUIP,filter1,tp,LOCATION_MZONE,0,1,1,nil,function(g)
			local tc=g:GetFirst()
			local filter2=RD.Filter(cm.exfilter,e,tc)
			RD.SelectAndDoAction(HINTMSG_EQUIP,aux.NecroValleyFilter(filter2),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
				Duel.BreakEffect()
				RD.UnionEquip(tp,tc,sg:GetFirst())
			end)
		end)
	end
end