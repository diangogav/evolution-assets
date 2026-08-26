local cm,m=GetID()
cm.name="简易礼物"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsLevel(7) and c:IsRace(RACE_WARRIOR) and c:IsAttack(2500)
		and Duel.IsExistingMatchingCard(cm.chkfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function cm.chkfilter(c,e,tp,fc)
	return aux.IsMaterialListCode(fc,c:GetFusionCode())
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.spfilter(c,e,tp,code)
	return c:IsCode(code) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostShowExtra(cm.costfilter,1,1,nil,Group.GetFirst)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 end
	local fc=e:GetLabelObject()
	local mg=Duel.GetMatchingGroup(cm.chkfilter,tp,LOCATION_GRAVE,0,nil,e,tp,fc)
	local codes={}
	for code, _ in pairs(fc.material or {}) do
		if mg:IsExists(Card.IsCode,1,nil,code) then
			table.insert(codes,code)
		end
	end
	local ac=RD.AnnounceCodes(tp,codes)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local filter=RD.Filter(cm.spfilter,e,tp,code)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)~=0 then
		RD.CanDraw(aux.Stringid(m,1),tp,1,true)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,2),RACE_ALL-RACE_WARRIOR,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end