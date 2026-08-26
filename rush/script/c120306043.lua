local cm,m=GetID()
local list={120306043}
cm.name="秘密特搜人鱼 八重"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	RD.AddRitualProcedure(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return RD.IsSpecialSummonMainPhase(e:GetHandler(),SUMMON_TYPE_RITUAL)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_FACEDOWN,cm.filter,tp,0,LOCATION_SZONE,1,1,nil,function(g)
			Duel.ConfirmCards(tp,g)
			if g:GetFirst():IsType(TYPE_TRAP) then
				Duel.Destroy(g,REASON_EFFECT)
			end
		end)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[1])
end