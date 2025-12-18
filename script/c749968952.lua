--Metal Crystal Dragon
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(s.sfilter1),1,1,aux.FilterSummonCode(749968950),1,1)
	c:EnableReviveLimit()
	--Eternal Ice Salvation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local ec=e1:Clone()
	ec:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(ec)
	--Ice Salvation 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tice)
	e2:SetOperation(s.opice)
	c:RegisterEffect(e2)
end
s.material={49968945}
s.listed_names={49968945}
s.synchro_nt_required=1
function s.sfilter1(c,val,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,scard,sumtype,tp) and c:IsType(TYPE_SYNCHRO,scard,sumtype,tp)
end
function s.vfilter(c)
	return c:IsFaceup() and c:IsAttack(0)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.vfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c)
	return g:GetSum(Card.GetBaseAttack)
end
function s.sum(c)
	return c:IsFaceup() and c:HasNonZeroAttack()
end
function s.tice(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sum,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.opice(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.sum,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(3100)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetRange(LOCATION_MZONE)
			e2:SetValue(s.efilter)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
end
end
function s.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end