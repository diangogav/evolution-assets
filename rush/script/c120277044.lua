local cm,m=GetID()
local list={120222025,120227012}
cm.name="虚空噬骸兵·禁忌镇魂鹰巨人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsAttackAbove(1600)
		and c:IsLocation(LOCATION_GRAVE)
end
cm.cost=RD.CostSendDeckTopToGrave(3,function(g)
	return g:FilterCount(cm.exfilter,nil)
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,900,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local ct=e:GetLabel()
		if ct>0 then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,ct,nil,function(g)
				Duel.Destroy(g,REASON_EFFECT)
			end)
		end
	end
end