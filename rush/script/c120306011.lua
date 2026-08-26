local cm,m=GetID()
local list={120306047,120306037}
cm.name="救惺之轰拳 非斯特"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
function cm.filter(c)
	return c:IsCode(list[1]) and c:IsAbleToGrave()
end
function cm.spfilter(c)
	return c:IsCode(list[2])
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	local sg,g=RD.RevealDeckTopAndCanSelect(tp,4,aux.Stringid(m,1),HINTMSG_TOGRAVE,cm.filter,1,1)
	local res=0
	if sg:GetCount()>0 then
		Duel.DisableShuffleCheck()
		res=Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	local ct=g:GetCount()
	if ct>0 then
		Duel.SortDecktop(tp,tp,ct)
		RD.SendDeckTopToBottom(tp,ct)
	end
	local c=e:GetHandler()
	if res~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.CanFusionSummon(aux.Stringid(m,2),nil,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,e,tp,POS_FACEUP,true,true)
	end
end