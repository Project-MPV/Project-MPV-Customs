--
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
function s.filter1(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x344) and c:HasLevel() and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,c,c:GetLevel())
end
function s.filter2(c,lv)
	return c:IsMonster() and c:IsSetCard(0x344) and c:HasLevel() and c:IsAbleToHand() and not c:IsLevel(lv) 
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,e,tp)
	and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetLevel())
	if #g1>0 and #g2>0 then
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1+g2)
	end
end
function s.stfilter(c)
	return c:IsCode(8855578) or (c:IsSetCard(0x95) and c:IsSpell()) and c:IsSSetable()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.stfilter),tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local nevermind=e:GetHandler()
	if Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)~=0 then
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
	local smash=g:GetFirst()
	if smash then
		Duel.SSet(tp,smash)
		local do_di_do=Effect.CreateEffect(nevermind)
		do_di_do:SetType(EFFECT_TYPE_SINGLE)
		do_di_do:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		do_di_do:SetCode(EFFECT_BECOME_QUICK)
		do_di_do:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		smash:RegisterEffect(do_di_do)
		local what_did_you_expect=Effect.CreateEffect(nevermind)
		what_did_you_expect:SetType(EFFECT_TYPE_SINGLE)
		what_did_you_expect:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		what_did_you_expect:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		what_did_you_expect:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		smash:RegisterEffect(what_did_you_expect)
end
end
end
