local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,649968957,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO))
	--ATK Change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetCountLimit(1,{id,0})
	e1:SetOperation(s.neop)
	c:RegisterEffect(e1)
	--Des rep
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.value)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.miracle_synchro_fusion=true
function s.cfilter(c)
	return c:IsFaceup() and c:IsNegatableMonster() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.neop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	if #tg>0 and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_CARD,0,id)
		for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end		
	end
	Duel.Readjust()
end
		
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsOnField,nil,tp)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0 and #g>0
	end
	e:SetLabel(#g)
	if Duel.SelectEffectYesNo(tp,c) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	return true
	else return false end
end
function s.value(e,c)
	return c:IsLocation(LOCATION_ONFIELD) 
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.RaiseEvent(e:GetHandler(),id,e,0,0,tp,0)
end
