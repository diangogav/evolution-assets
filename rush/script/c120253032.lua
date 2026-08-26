local cm,m=GetID()
cm.name="暗构体"
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
cm.trival=RD.ValueDoubleTributeAttrType(ATTRIBUTE_DARK,TYPE_NORMAL,true)