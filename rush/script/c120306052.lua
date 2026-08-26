local cm,m=GetID()
local list={120306019}
cm.name="健康贤明抢答按钮战斗！"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_CURRENT_LEVEL_GREATER,cm.matfilter,cm.spfilter)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(1,1)
	c:RegisterEffect(e1)
end
function cm.ritual_mat_filter(c)
	return not c:IsOnField() or c:IsCode(list[1])
end
--Activate
function cm.matfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_PYRO) and RD.IsDefense(c,1300)
end
function cm.spfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_PYRO)
end