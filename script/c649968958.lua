--Exfrost Frost Wave
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--halve or destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc13}
s.listed_names={749968950}
function s.scfilter(c)
	return c:IsFaceup() and (c:IsCode(749968950) or c:IsSetCard(0xfc13)) and (c:GetAttack()>0 or c:IsDestructable())
end
function s.atfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.scfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.scfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
	local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	if opt==0 then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(tc:GetAttack()/2)
	tc:RegisterEffect(e1)
	if Duel.GetTurnPlayer()~=tp then
	--Cannot Attack
	local ac=Duel.SelectMatchingCard(tp,s.atfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if ac then
		Duel.HintSelection(ac)
		local at=Effect.CreateEffect(e:GetHandler())
		at:SetDescription(3206)
		at:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		at:SetType(EFFECT_TYPE_SINGLE)
		at:SetCode(EFFECT_CANNOT_ATTACK)
		at:SetValue(1)
		at:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ac:RegisterEffect(at)
	end
	end
	else
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
	Duel.Draw(tp,1,REASON_EFFECT)
	local sc=Duel.SelectMatchingCard(tp,s.atfilter,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if sc then
		Duel.HintSelection(sc)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(sc:GetAttack()/2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e2)
end
end
end
end
end
