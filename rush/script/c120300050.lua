local cm,m=GetID()
cm.name="心灵之友"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_CURRENT_LEVEL_EQUAL,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToDeck,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
function cm.ritual_mat_filter(c,e,tp,rc,mg)
	return not c:IsCode(rc:GetCode())
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsRace(RACE_GALAXY) and c:IsAbleToDeck()
end
function cm.spfilter(c,e,tp,mat)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_GALAXY)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	RD.CanDiscardDeck(aux.Stringid(m,1),tp,1,mat:GetCount(),true,1-tp)
end