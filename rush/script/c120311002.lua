local cm,m=GetID()
local list={120311026,120307014}
cm.name="邪心英雄 暗黑地魔"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter1,cm.matfilter2)
	--Special Summon Condition
	RD.OnlySpecialSummonByEffect(c,cm.splimit)
	--Base Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.operation)
	c:RegisterEffect(e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter1(c)
	return c:IsRace(RACE_FIEND)
end
function cm.matfilter2(c)
	return c:IsRace(RACE_ROCK)
end
--Special Summon Condition
function cm.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(list[1],list[2])
end
--Base Atk
function cm.atkval(e,c)
	local atk=0
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	while tc do
		atk=atk+tc:GetBaseAttack()
		tc=g:GetNext()
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
--Position
function cm.posfilter(c,e,tp)
	return c:IsDefensePos() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(HINTMSG_DEFENSE,filter,tp,0,LOCATION_MZONE,1,3,nil,function(g)
		RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEUP_ATTACK)
	end)
end