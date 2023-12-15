--Exfrost Crystal Avatar
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={0xfc13}
function s.thfilter1(c)
	return c:IsSetCard(0xfc13) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsSetCard(0xfc13) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	local mct=2
	if (Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) or Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)) then mct=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,mct,e:GetHandler())
	e:SetLabel(Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD))
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lbl=e:GetLabel()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=1
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	if (Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) or Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil))
	and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
	if lbl==2 or lbl==1 then d=1 end
		if lbl==1 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		end
	elseif lbl==2 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
end
end
end
end

