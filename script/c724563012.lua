--Nefarioit Hollow Masquerade
local s,id=GetID()
function s.initial_effect(c)	
	--Negate Monster Activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})	
	e1:SetCondition(s.setup)
	e1:SetCost(Cost.SelfChangePosition(POS_FACEUP_DEFENSE))
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--You can reveal this card in your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfReveal)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_RELEASE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.trtg)
	e3:SetOperation(s.trop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfc12}
function s.setup(e,tp,eg,ep,ev,re)
	return e:GetHandler():IsFacedown() and ep==1-tp and re:IsMonsterEffect() 
	and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_MZONE|LOCATION_HAND>0 
	and Duel.IsChainNegatable(ev) 
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Release(eg,REASON_EFFECT)
	end
end
function s.release(c,e,tp)
	return c:IsReleasableByEffect() and c:IsSpecialSummoned()
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsReleasableByEffect() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.release,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.release,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g>0 then
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
		Duel.HintSelection(g)
		Duel.Release(g,REASON_EFFECT)		
	end
end
function s.thfilter(c)
	return c:IsSetCard(0xfc12) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
end