local cm,m=GetID()
local list={120304069,120304045,120304056}
cm.name="恶魔镜的召来"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsRace(RACE_FIEND)
end
function cm.spfilter(c)
	return c:IsCode(list[1],list[2])
end
function cm.exfilter(c)
	return c:IsCode(list[3])
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end