--Enigmation Oath
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--SET "RUM" or "DoD"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x344}
function s.filter1(c,tp)
	return c:IsMonster() and c:IsSetCard(0x344) and c:HasLevel() and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,c,c:GetLevel())
end
function s.filter2(c,lv)
	return c:IsMonster() and c:IsSetCard(0x344) and c:HasLevel() and c:IsAbleToHand() and not c:IsLevel(lv) 
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil,tp)
	if #g==0 then return end
	local g1=nil
	local g2=nil
	local cancelable=true	
	--LOOP SELECTION
	while true do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g1==0 then break end 		
		local tc1=g1:GetFirst()		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,0,1,tc1,tc1:GetLevel())		
		if #g2>0 then
			break
		else
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		end
	end
	if g1 and g2 and #g1>0 and #g2>0 then
		g1:Merge(g2)
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
	end
end
function s.stfilter(c)
	return c:IsCode(8855578) or (c:IsSetCard(0x95) and c:IsSpell()) and c:IsSSetable()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsAbleToDeck() 
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.stfilter),tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
		local smash=g:GetFirst()
		if smash and Duel.SSet(tp,smash)>0 then
			--Set as Quick Play
			local e1=Effect.CreateEffect(smash)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_BECOME_QUICK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			smash:RegisterEffect(e1)		
			local e2=Effect.CreateEffect(smash)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			smash:RegisterEffect(e2)
		end
	end
end