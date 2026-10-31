local cm,m=GetID()
local list={120310066}
cm.name="蕾娜的蘑菇汤"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
end
function cm.spfilter(c)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		RD.AttachAtkDef(e,tc,-700,0,RESET_EVENT+RESETS_STANDARD)
		if tc:IsControler(tp) and tc:IsCode(list[1]) then
			RD.CanRitualSummonWithMaterial(aux.Stringid(m,2),RITUAL_ORIGINAL_LEVEL_GREATER,tc,cm.spfilter,RD.RitualToGrave,e,tp,POS_FACEUP,true)
		end
	end)
end