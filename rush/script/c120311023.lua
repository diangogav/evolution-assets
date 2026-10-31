local cm,m=GetID()
local list={120263005,120263006,120311026,120307014}
cm.name="邪心英雄 闪电巨魔"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Special Summon Condition
	RD.OnlySpecialSummonByEffect(c,cm.splimit)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Condition
function cm.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(list[3],list[4]) or se:GetValue()==SUMMON_VALUE_DARK_FUSION
end
--Destroy
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end