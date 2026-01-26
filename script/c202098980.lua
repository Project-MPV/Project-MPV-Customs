--Imaginary Force - Tribe Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Imaginary Force
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--Negate attack and LP
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={0x303}
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re then return false end
	local rc=re:GetHandler()
	return rc:IsSetCard(0x303)
	and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x303) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local bc1,bc2=Duel.GetBattleMonster(tp)
	if not (bc1 and bc1:IsFaceup() and bc1:IsSetCard(0x303)) then return false end
	if not (bc2 and bc2:IsFaceup()) then return false end
	return true
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local _,bc=Duel.GetBattleMonster(tp)
	local a=Duel.GetAttacker()
	local t=Duel.GetAttackTarget()
	local g=Group.FromCards(a,t)
	local dam=math.abs(a:GetAttack()-t:GetAttack())
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(dam)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dam)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateAttack() then return end
	local g=Duel.GetTargetCards(e)
	local _,bc=Duel.GetBattleMonster(tp)
	if #g<2 then return end
	local c1=g:GetFirst()
	local c2=g:GetNext()
	if not (bc:IsFaceup() and bc:IsControler(1-tp) and bc:IsRelateToBattle()) then return end
		if c1:IsFaceup() and c2:IsFaceup() then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.abs(c1:GetAttack()-c2:GetAttack())
		Duel.Recover(p,dam,REASON_EFFECT)
end
end
