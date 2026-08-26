local cm,m=GetID()
cm.name="穿越侍·高天海牛侍 铠天原新星"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddPrimeSummonProcedure(c,aux.Stringid(m,0),1800)
	RD.AddSummonProcedureThree(c,aux.Stringid(m,1))
	RD.CreateAdvanceSummonFlag(c,20257008)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Set Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetLabelObject(e1)
	e2:SetCondition(cm.atkcon)
	e2:SetOperation(cm.atkop)
	c:RegisterEffect(e2)
	--Material Check
	RD.AdvanceMaterialCheck(c,e2,cm.getter)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Set Attack
function cm.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_VALUE_THREE)
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	local atk1,atk2=e:GetLabel()
	if atk1~=atk2 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,2))
		atk1=Duel.AnnounceNumber(tp,atk1,atk2)
	end
	e:GetLabelObject():SetLabel(atk1)
end
--Material Check
function cm.getter(c,ct,mat)
	if mat==3 then
		return c:GetOriginalLevel()*100
	else
		return 0
	end
end
--Atk Up
function cm.atkval(e,c)
	if c:GetFlagEffect(20257008)~=0 and c:IsSummonType(SUMMON_VALUE_THREE) then return e:GetLabel() else return 0 end
end