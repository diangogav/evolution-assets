local cm,m=GetID()
local list={120222017}
cm.name="龙爆速融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,nil,nil,nil,nil,nil,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsRace(RACE_DRAGON)
end
function cm.exfilter(c)
	return c:IsCode(list[1]) and c:IsLocation(LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if mat:IsExists(cm.exfilter,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			RD.AttachAtkDef(e,g:GetFirst(),-1500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end