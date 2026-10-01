local cm,m=GetID()
local list={120309056}
cm.name="游乐园挂饰 夜场"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Union
	local e1=RD.RegisterUnionEffect(c,aux.TRUE,nil,nil,cm.operation)
	e1:SetCategory(e1:GetCategory()|CATEGORY_DESTROY)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(aux.IsUnionState)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
--Union
function cm.desfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	if tc:IsCode(list[1]) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end