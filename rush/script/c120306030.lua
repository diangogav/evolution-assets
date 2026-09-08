local cm,m=GetID()
cm.name="强力机器·机关步行机"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Union
	local e1=RD.RegisterUnionEffect(c,cm.filter,nil,nil,cm.operation)
	e1:SetCategory(e1:GetCategory()|CATEGORY_DESTROY)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(aux.IsUnionState)
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR)
end
--Union
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR)
end
function cm.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end)
end