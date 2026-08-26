local cm,m=GetID()
local list={CARD_CODE_OTS}
cm.name="外宇宙爆震融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp,rp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and ((rp==1-tp and c:IsReason(REASON_EFFECT)) or c==Duel.GetAttackTarget())
end
function cm.filter(c)
	return c:IsCode(list[1]) and c:IsAbleToHand()
end
function cm.matfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,tp,rp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,2,3,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			RD.CanFusionSummon(aux.Stringid(m,1),cm.matfilter,cm.spfilter,nil,0,0,nil,RD.FusionToDeck,e,tp,POS_FACEUP_ATTACK,true)
		end
	end)
end