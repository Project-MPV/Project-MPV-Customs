--Imaginary Force - Dracoreign
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.sfilter,s.ffilter)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (sum_type&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION end)
	c:RegisterEffect(e0)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.t)
	e1:SetOperation(s.o)
	c:RegisterEffect(e1)
	--Turn into Quick Effect
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.qecon)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon2)
	e3:SetOperation(s.disop2)
	c:RegisterEffect(e3)
end
s.listed_series={0x303}
function s.sfilter(c,fc,sumtype,tp)
	return (c:IsRace(RACE_FAIRY,fc,sumtype,tp) or c:IsRace(RACE_WYRM,fc,sumtype,tp)) and c:GetLevel()>=6
end
function s.ffilter(c,fc,sumtype,tp)
	return (c:IsRace(RACE_FAIRY,fc,sumtype,tp) or c:IsRace(RACE_DRAGON,fc,sumtype,tp)) and c:GetLevel()<=5
end
function s.rtfilter(c,ft,tp)
	return c:IsFaceup() and c:IsSetCard(0x303) and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x303) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.t(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,e:GetHandler()) and
	Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.o(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,e:GetHandler())
	if #g>0 then
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,1,REASON_EFFECT)~=0 then
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #sg>0 then	
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)		
end
end
end
end
function s.qecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,200898980),e:GetHandlerPlayer(),LOCATION_SZONE,0,1,e:GetHandler()) 
end
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local oc=tc:GetBattleTarget()
	if not oc then return false end
	if oc:IsControler(tp) then tc,oc=oc,tc end
	e:SetLabelObject(oc)
	return tc:IsSetCard(0x303) and tc:IsLevelAbove(8) and tc:IsControler(tp) and oc:IsControler(1-tp)
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e2)
end