--Eternal Frost Dragon
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(s.sfilter1),1,1,Synchro.NonTunerEx(s.sfilter),1,1)
	c:EnableReviveLimit()
	--Eternal Ice Prison
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_SZONE)
	e0:SetTargetRange(0,LOCATION_MZONE)
	e0:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e0:SetValue(s.atlimit)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.reccost)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
function s.sfilter(c,val,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,scard,sumtype,tp) and c:IsType(TYPE_SYNCHRO,scard,sumtype,tp)
end
function s.sfilter1(c,val,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,scard,sumtype,tp) 
end
function s.ffilter(c)
	return c:IsFaceup() and (c:IsFieldSpell() or c:IsContinuousTrap()) and c:IsAbleToRemoveAsCost()
end
function s.efilter(c)
	return c~=e:GetHandler()
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e2:SetValue(781133000)
		c:RegisterEffect(e2)
end
end

function s.atkfilter(c,e)
	return c:IsFaceup() and c:HasNonZeroAttack()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	local latk=g:GetSum(Card.GetBaseAttack)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local ag=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,e:GetHandler())
		for rc in aux.Next(ag) do
		local ef=Effect.CreateEffect(e:GetHandler())
		ef:SetType(EFFECT_TYPE_SINGLE)
		ef:SetDescription(aux.Stringid(id,2))
		ef:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		ef:SetCode(EFFECT_UPDATE_ATTACK)
		ef:SetValue(-latk)
		ef:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(ef)
		if rc then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,true,POS_FACEUP)

end
end
end
end