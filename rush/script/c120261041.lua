local cm,m=GetID()
cm.name="倍骷髅"
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
cm.trival=RD.ValueDoubleTributeMix(true,nil,ATTRIBUTE_DARK,TYPE_EFFECT,nil,RACE_FIEND,0,0)