--カタパルト·タートル
--Catapult Turtle (Pre-Errata)
function c511000228.initial_effect(c)
	--Tribute 1 monster to inflict damage equal to half of its ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(511000228,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c511000228.cost)
	e1:SetTarget(c511000228.target)
	e1:SetOperation(c511000228.operation)
	c:RegisterEffect(e1)
end
function c511000228.filter(c)
	return c:GetAttack()>0
end
function c511000228.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c511000228.filter,1,nil) end
	local sg=Duel.SelectReleaseGroup(tp,c511000228.filter,1,1,nil)
	e:SetLabel(math.floor(sg:GetFirst():GetAttack()/2))
	Duel.Release(sg,REASON_COST)
end
function c511000228.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
function c511000228.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end