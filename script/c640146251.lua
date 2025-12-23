--Phantasm Chaos Caller
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgact)
	e2:SetOperation(s.opact)
	c:RegisterEffect(e2)
end
s.listed_series={0x145}
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,c,e,tp,c,c:GetOriginalRank())
end
function s.filter2(c,e,tp,mc,rk)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rk+c:GetOriginalRank(),Group.FromCards(c,mc))
end
function s.spfilter(c,e,tp,rk,sg)
	local crk=c:GetOriginalRank()
	return crk==rk and c:IsSetCard(0x145) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,tc,e,tp,tc,tc:GetOriginalRank())
	g1:Merge(g2)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc1:GetOriginalRank()+tc2:GetOriginalRank())
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ssg=sg:Select(tp,1,1,nil)
	local sc=ssg:GetFirst()
	if sc then
		sc:SetMaterial(g)
		Duel.Overlay(sc,g)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
end
	Duel.SpecialSummonComplete()
end
--ACT
function s.xfilter(c,e,tp)
	return c:GetOverlayGroup():IsExists(Card.IsAbleToRemove,1,nil)
		and c:IsSetCard(0x145) and c:IsType(TYPE_XYZ)
end
function s.tgact(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.xfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetChainLimit(aux.FALSE)
end
function s.opact(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local ovg=tc:GetOverlayGroup()
	local of=Duel.Remove(ovg,POS_FACEUP,REASON_EFFECT)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,of,nil,e,tp)
	if #g>0 then
	Duel.HintSelection(g)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
end

