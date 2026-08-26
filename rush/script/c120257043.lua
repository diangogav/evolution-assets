local cm,m=GetID()
local list={120228024,120253012}
cm.name="华蝶风彩之预言乐句酷炫盗贼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_ATKCHANGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function cm.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(cm.tdfilter),tp,0,LOCATION_GRAVE,nil)
			if mg:GetCount()>0 and Duel.IsPlayerCanDraw(tp,1)
				and Duel.SelectYesNo(tp,aux.Stringid(m,1)) and RD.SendToDeckAndExists(mg,e,tp,REASON_EFFECT) then
				local c=e:GetHandler()
				if c:IsFaceup() and c:IsRelateToEffect(e) then
					RD.AttachAtkDef(e,c,1200,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end)
end