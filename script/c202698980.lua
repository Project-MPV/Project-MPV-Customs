--Imaginary Force - Amire Wish
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x303,0x6789}
function s.filter(c)
	return c:IsSetCard(0x303) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.amire(c)
	return c:IsFaceup() and c:IsSetCard(0x6789) and c:IsMonster()
end
function s.rth(c)
	return c:IsAbleToDeck() and c:IsMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)~=0)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
	Duel.DisableShuffleCheck()
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if not tc then return end
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if (tc:IsMonster() and tc:IsAbleToGrave()) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	elseif (tc:IsSpellTrap()) and tc:IsAbleToHand() then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
		if Duel.IsExistingMatchingCard(s.amire,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,1))then
		local am=Duel.SelectMatchingCard(tp,s.rth,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		if am then 
			Duel.HintSelection(am)
			Duel.SendtoDeck(am,nil,1,REASON_EFFECT)	
end
end
end
end