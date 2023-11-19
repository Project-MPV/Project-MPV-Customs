local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--fusion from the pendulum zone
	local params = {aux.FilterBoolFunction(Card.IsSetCard,0x7970)}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
	--End the BP, then place it in the PZ
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.c)
	e2:SetTarget(s.t)
	e2:SetOperation(s.o)
	c:RegisterEffect(e2)

end
s.listed_series={0x7970,0x8}
function s.c(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)==0 and at:GetControler()~=tp and Duel.GetAttackTarget()==nil
end
function s.t(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
function s.o(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
end
