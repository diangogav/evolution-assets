local cm,m=GetID()
local list={120213010,120310004,120310005}
cm.name="接合科技无双英雄"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2],list[3])
	--Union Fusion
	RD.EnableUnionFusion(c,aux.Stringid(m,0))
	--Coin
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
cm.toss_coin=true
--Coin
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler(),SUMMON_TYPE_FUSION)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local r1,r2,r3=Duel.TossCoin(tp,3)
	local atk=(r1+r2+r3+1)*200
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local ct=3-r1-r2-r3
		if ct>0 then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,ct,nil,function(g)
				Duel.BreakEffect()
				Duel.Destroy(g,REASON_EFFECT)
			end)
		end
	end
end