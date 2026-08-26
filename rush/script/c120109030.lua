local cm,m=GetID()
local list={120196050,120238025}
cm.name="融合再生翼龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Summon Counter
	Duel.AddCustomActivityCounter(m,ACTIVITY_SPSUMMON,cm.count)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Summon Counter
function cm.count(c)
	return not c:IsSummonType(SUMMON_TYPE_FUSION)
end
--Draw
function cm.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_HYDRAGON) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.thfilter(c)
	return (c:IsCode(list[1]) or RD.IsLegendCode(c,list[2])) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(m,tp,ACTIVITY_SPSUMMON)~=0
end
cm.cost=RD.CostSendSelfToGrave()
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0
		and RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP,true)~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		end)
	end
end