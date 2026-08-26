local cm,m=GetID()
local list={120217088,120222057}
cm.name="东方雕像"
function cm.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.filter(c)
	return c:IsType(TYPE_SPELL)
end
function cm.thfilter(c)
	return c:IsCode(list[1],list[2]) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=Duel.GetMatchingGroupCount(cm.filter,tp,0,LOCATION_GRAVE,nil)*100
	if chk==0 then return dam>0 end
	RD.TargetDamage(1-tp,dam)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetMatchingGroupCount(cm.filter,tp,0,LOCATION_GRAVE,nil)*100
	if RD.Damage(nil,dam)>=1000 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,2,nil,function(g)
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end