--Enigmation - Infernal Chief
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.co)
	e2:SetTarget(s.tb)
	e2:SetOperation(s.tbo)
	c:RegisterEffect(e2)	
end
s.listed_series={0x344}
function s.filter(c)
	return c:IsSetCard(0x344) and c:IsAbleToDeck()
end
function s.atk(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) 
	and Duel.IsExistingMatchingCard(s.atk,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
	if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
	local sc=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #sc>0 then
	Duel.HintSelection(sc)
	sc:GetFirst():UpdateAttack(1000,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
end
end
end
end
function s.enigmation(c)
	return c:IsSetCard(0x344) and c:IsMonster()
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.co(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and
	Duel.IsExistingMatchingCard(aux.FaceupFilter(s.enigmation),tp,LOCATION_REMOVED,0,1,e:GetHandler())
end
function s.tb(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,0,0)
end
function s.tbo(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,c,e,tp)
	if #tc>0 then
		tc:AddCard(c)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
