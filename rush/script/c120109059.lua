local cm,m=GetID()
cm.name="特洛伊木马"
function cm.initial_effect(c)
	--Double Tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(cm.trival)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Double Tribute
function cm.trival(e,c)
	if e==nil then return true,1 end
	return c:IsLevel(7,8) and c:IsAttribute(ATTRIBUTE_EARTH)
end