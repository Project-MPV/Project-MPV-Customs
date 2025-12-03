--Imaginary Force Zyifarigon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,200298980,s.ffilter)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,sum_eff,sum_p,sum_type) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (sum_type&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION end)
	c:RegisterEffect(e0)
	--Material Check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	--Fairy: Fairy Draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.fcon)
	e2:SetOperation(s.fop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--Dragon: Debuff
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.dcon)
	e3:SetOperation(s.dop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
end
s.listed_series={0x303}
s.listed_names={200298980}
function s.ffilter(c,fc,sumtype,tp)
	return (c:IsRace(RACE_FAIRY,fc,sumtype,tp) or c:IsRace(RACE_DRAGON,fc,sumtype,tp))
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tpe=0
	for tc in g:Iter() do
			tpe=(tpe|tc:GetOriginalRace())
	end
	e:SetLabel(tpe)
end
function s.fcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
		and (e:GetLabelObject():GetLabel()&RACE_FAIRY)~=0
end
function s.fop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.t)
	e1:SetOperation(s.o)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
end
function s.rtfilter(c,ft,tp)
	return c:IsFaceup() and c:IsSetCard(0x303) and c:IsAbleToDeck()
end
function s.t(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,e:GetHandler())
	and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.o(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,e:GetHandler())
	if #g>0 then
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,1,REASON_EFFECT)~=0 then
	Duel.Draw(tp,1,REASON_EFFECT)
	e:GetHandler():UpdateAttack(400,RESET_EVENT|RESETS_STANDARD)	
end
end
end

function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
		and (e:GetLabelObject():GetLabel()&RACE_DRAGON)~=0
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.t1)
	e1:SetOperation(s.o1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
function s.rtfilter1(c,ft,tp)
	return c:IsFaceup() and c:IsSetCard(0x303) and c:IsAbleToDeck()
end
function s.t1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(s.rtfilter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,e:GetHandler()) and
	Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK+LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.o1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.rtfilter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,e:GetHandler())
	if #g>0 then
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,1,REASON_EFFECT)~=0 then
	--
	local fg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	if #fg>0 then
	Duel.HintSelection(fg)
	fg:GetFirst():UpdateAttack(-1000,RESET_EVENT|RESETS_STANDARD)	
end
end
end
end
