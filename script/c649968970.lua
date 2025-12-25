--Exfrost Cyanocitta
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xfc13),1,1,Synchro.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	--Token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--SP "Crystal Dragon"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc13,0xfd12}
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,649968954,0xfc13,TYPES_TOKEN,100,100,2,RACE_AQUA,ATTRIBUTE_WATER)end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and s.tg(e,tp,eg,ep,ev,re,r,rp,0) then
	local token=Duel.CreateToken(tp,649968954)
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	local eff=Effect.CreateEffect(c)
	eff:SetType(EFFECT_TYPE_SINGLE)
	eff:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	eff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	eff:SetValue(s.matlimit)
	eff:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(eff)
	end
	Duel.SpecialSummonComplete()
end
function s.matlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
function s.thfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfd12) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.dfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) and
	Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.dfilter,1,1,REASON_COST|REASON_DISCARD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
	-- cannot summon extra deck monsters except WATER synchro
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
	-- lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
end
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WATER))
end
function s.lizfilter(e,c)
	return not (c:IsOriginalType(TYPE_SYNCHRO) and c:IsOriginalAttribute(ATTRIBUTE_WATER))
end
