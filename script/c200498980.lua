--Imaginary Force - Sacred Knight, Amire
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.cost2)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Special Summon,,,,,
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost)
	e3:SetTarget(s.qstg)
	e3:SetOperation(s.qsop)
	c:RegisterEffect(e3)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e3)
end
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x303) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and c:GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
	and Duel.IsExistingMatchingCard(s.cfilter2,tp,0,LOCATION_MZONE,1,nil) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g1=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(1-tp,s.cfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	if c:IsRelateToEffect(e) and ft>0 then
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
end
end
function s.arfilter(c,ft)
	return c:IsSetCard(0x303) and c:IsAbleToDeckAsCost()
end
function s.ssfilter(c,ft,e,tp)
	return c:IsSetCard(0x303) and c:IsType(TYPE_MONSTER) and ((ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)) or c:IsAbleToHand())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.arfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.arfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,1,REASON_COST)
end
function s.qstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.ssfilter(chkc,e,tp,ft) end
	if chk==0 then return Duel.IsExistingTarget(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,ft,e,tp) end
	local g=Duel.GetMatchingGroup(s.ssfilter,tp,LOCATION_GRAVE,0,nil,ft,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local sg=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(sg)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
end
function s.qsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sc=Duel.GetFirstTarget()
	if sc and sc:IsRelateToEffect(e) then
		aux.ToHandOrElse(sc,tp,function(c)
			return sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and ft>0 end,
		function(c)
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
		2)
	end
end
