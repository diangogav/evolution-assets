local cm,m=GetID()
local list={120213023}
cm.name="蛋球机器人国王巨人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedureSP(c,true,true,cm.matfilter,cm.check,2,3)
	RD.SetFusionMaterial(c,{list[1]},3,3)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
function cm.matfilter(c,fc,sub)
	return c:IsFusionCode(list[1]) or (sub and c:CheckFusionSubstitute(fc))
end
function cm.exfilter(c)
	return RD.IsCanBeDoubleFusionMaterial(c,120285039)
end
function cm.check(g,tp,fc,chkf)
	return g:GetCount()==3 or g:IsExists(cm.exfilter,1,nil)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.costfilter(c)
	return c:IsCode(list[1]) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeckTop(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),nil,tp,LOCATION_MZONE,0,1,3,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end)
		local c=e:GetHandler()
		if RD.IsSpecialSummonMainPhase(c,SUMMON_TYPE_FUSION) then
			RD.CanRecover(aux.Stringid(m,3),tp,2000,true)
		end
	end)
end