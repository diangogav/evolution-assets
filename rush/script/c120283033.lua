local cm,m=GetID()
local list={120231037,120231032}
cm.name="超可爱执行者·花草女 开拓"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Atk & Def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(cm.downtg)
	e1:SetValue(-600)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Recover
	local e3=RD.ContinuousBattleDestroyToGrave(c,nil,cm.recop)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Atk & Def
function cm.downtg(e,c)
	return c:IsFaceup() and not c:IsLevel(6)
end
--Recover
function cm.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	Duel.Recover(tp,600,REASON_EFFECT)
end