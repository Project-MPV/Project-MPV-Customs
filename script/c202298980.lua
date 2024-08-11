--Imaginary Force Wish
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCost(s.cost)
	e0:SetTarget(s.t)
	e0:SetOperation(s.a)
	c:RegisterEffect(e0)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={0x303}
s.check=false
function s.ifilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsSetCard(0x303) and c:IsMonster()
end
function s.tgfilter(c)
	return c:IsSetCard(0x303) and c:IsMonster() and c:IsAbleToDeckAsCost() 
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,1,REASON_COST)
	local atk=g:GetFirst():GetLevel()*200
	e:SetLabel(atk)
end
function s.t(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.ifilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.ifilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.a(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e0:SetRange(LOCATION_MZONE)
		e0:SetCode(EFFECT_UPDATE_ATTACK)
		e0:SetValue(e:GetLabel())
		e0:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e0)
	end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3101)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
end
function s.efilter(e,te)
	return te:IsMonsterEffect() and e:GetHandler()~=te:GetOwner()
end
function s.afilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsSetCard(0x303) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.afilter,1,nil,tp)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.thcon)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local c=e:GetHandler()
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
end
