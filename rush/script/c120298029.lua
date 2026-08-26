local cm,m=GetID()
local list={120298018,120298019}
cm.name="想要点除魔的圣水！"
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
	return c:IsFaceup() and c:IsOnField() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_SPELLCASTER)
end
function cm.spfilter(c)
	return c:IsCode(list[1],list[2])
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsRace(RACE_FIEND+RACE_WARRIOR)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end)
end