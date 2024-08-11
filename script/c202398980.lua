--Imaginary Force Trident
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_GRAVE+LOCATION_DECK)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.c)
	e2:SetTarget(s.t)
	e2:SetOperation(s.o)
	c:RegisterEffect(e2)
end
s.listed_series={0x303}
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetOriginalLevel()>=8 and c:IsSetCard(0x303)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
	Duel.Draw(tp,1,REASON_EFFECT)
end
end
--
function s.rtfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) and c:IsReason(REASON_EFFECT)
end
function s.rvfilter(c)
	return c:IsSetCard(0x303)
end
function s.c(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rtfilter,1,nil,e,tp) and 
	Duel.IsExistingMatchingCard(s.rvfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
end
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x303) and c:IsAbleToGrave()
end
function s.t(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
end
function s.o(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,1,REASON_EFFECT) then
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	local sc=g:GetFirst()
	if sc then
	Duel.HintSelection(sc)
	if Duel.SendtoDeck(sc,nil,1,REASON_EFFECT)~=0 and sc:IsPreviousLocation(LOCATION_MZONE) then
	Duel.BreakEffect()
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
end
end
end
end
end