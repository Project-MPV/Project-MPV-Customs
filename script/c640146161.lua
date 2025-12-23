--Droga The Phantasm Retriever
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Phantasm" Spell/Trap
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCost(s.scost)
	e0:SetTarget(s.stg)
	e0:SetOperation(s.sop)
	c:RegisterEffect(e0)
	--SP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={0x145,0x344}
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	and e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.filter(c)
	return c:IsSetCard(0x145) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.rumfilter(c)
	return c:IsSetCard(0x95) and c:IsSpell()
end
function s.ex(c)
	return (c:IsSetCard(0x145) or c:IsSetCard(0x344)) and c:IsMonster() and c:IsAbleToGrave()
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--Extra
		if Duel.IsExistingMatchingCard(s.rumfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local rm=Duel.SelectMatchingCard(tp,s.ex,tp,LOCATION_EXTRA,0,1,1,nil)
		if #rm>0 then
		Duel.SendtoGrave(rm,REASON_EFFECT)
end
end
end
end
function s.rfilter(c,e,tp)
	return (c:IsSetCard(0x344) or c:IsSetCard(0x145)) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp)
	and e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tp,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 then
	local sg=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	if #sg>0 then
	Duel.SpecialSummon(sg,0,tp,tp,true,true,POS_FACEUP)
	local tc=sg:GetFirst()
	if tc:IsType(TYPE_XYZ) then
	Duel.Overlay(tc,c)
end
end
end
end