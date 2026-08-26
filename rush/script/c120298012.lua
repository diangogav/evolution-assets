local cm,m=GetID()
local list={120298002,120264030}
cm.name="起死骸生的暴风"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsRace(RACE_ZOMBIE)
end
function cm.spfilter(c)
	return c:IsCode(list[1])
end
function cm.exfilter(c)
	return c:IsOriginalCodeRule(list[2]) and c:IsLocation(LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	if mat:IsExists(cm.exfilter,1,nil) then
		RD.CanDraw(aux.Stringid(m,1),tp,1)
	end
end