local cm,m=GetID()
local list={120222017,120225001}
cm.name="蛋球结合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
	--Event
	if not cm.global_effect then
		cm.global_effect=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_ADD_FUSION_CODE)
		ge1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		ge1:SetTarget(cm.codetg)
		ge1:SetValue(list[1])
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetValue(list[2])
		Duel.RegisterEffect(ge2,0)
	end
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField()
end
function cm.spfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	RD.AttachAtkDef(e,fc,200,0,RESET_EVENT+RESETS_STANDARD,true)
end
-- Extra
function cm.codetg(e,c)
	-- 临时解决办法: 使用"蛋球结合"时，赋予额外的融合卡号
	return RD.IsFusionEffectCode(120285053)
		and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end