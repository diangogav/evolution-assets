local cm,m=GetID()
cm.name="元素英雄 棱镜侠"
function cm.initial_effect(c)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.costfilter(c,e)
	return c:IsType(TYPE_FUSION) and RD.IsCanAnnounceFusionMaterialCode(e:GetHandler(),c)
end
cm.cost=RD.CostShowExtra(cm.costfilter,1,1,nil,Group.GetFirst)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	local ac=RD.AnnounceFusionMaterialCode(tp,e:GetHandler(),tc)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		RD.ChangeCode(e,c,ac,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end