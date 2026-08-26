local cm,m=GetID()
cm.name="珠宝祭司的象牙"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return RD.IsSpecialSummonMainPhase(c,SUMMON_TYPE_RITUAL) and c:GetMaterialCount()>=2
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	RD.TargetDraw(tp,2)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.Draw()
end