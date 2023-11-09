--Dichroic Resistor
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.sscon)
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
end
s.listed_series={0x391}
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.filter(c,e,tp,ck)
	return c:IsSetCard(0x391) and c:IsMonster() and (c:IsAbleToHand() or (ck and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.fycon(c)
	return c:IsFaceup() and c:IsSetCard(0x391) and c:IsType(TYPE_FUSION)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ck=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.fycon,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,e:GetHandler(),e,tp,ck) end
	if ck then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ck=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.fycon,tp,LOCATION_MZONE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,e:GetHandler(),e,tp,ck):GetFirst()
	if tc then
		if ck and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and (not tc:IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		e:GetHandler():UpdateAttack(200,RESET_EVENT|RESETS_STANDARD)
	end
	end
	end
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=1000
end
function s.sfilter(c,ec)
	return c:IsSetCard(0x391) and c:IsSpellTrap()
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler())
	if #g>0 then
		Duel.SSet(tp,g)
end
end
end