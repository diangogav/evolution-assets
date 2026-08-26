local cm,m=GetID()
cm.name="百神硬盘龙"
function cm.initial_effect(c)
	--Draw Count
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(cm.drawval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Draw Count
function cm.drawval(e)
	local ct=Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)
	return math.max(1,6-ct)
end