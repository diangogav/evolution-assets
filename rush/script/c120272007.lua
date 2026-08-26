local cm,m=GetID()
cm.name="骰子小钥心·小合"
function cm.initial_effect(c)
	--Dice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
cm.toss_dice=true
--Dice
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.matfilter(c)
	return c:IsOnField() and c:IsRace(RACE_FAIRY)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d==1 then
		RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,LOCATION_ONFIELD,0,1,1,nil,function(g)
			Duel.Destroy(g,REASON_EFFECT)
		end)
	elseif d>=2 and d<=6 then
		local fc=RD.FusionSummon(cm.matfilter,nil,nil,0,0,nil,RD.FusionToGrave,e,tp,POS_FACEUP)
		if fc and fc:IsFaceup() and d==5 or d==6 then
			RD.AttachEffectIndes(e,fc,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end