local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.tftg)
	e1:SetOperation(s.tfop)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e2)
end
s.listed_series={ox7970,0x7971,0x8}
function s.exfilter(c,tp)
	return c:IsSetCard(0x8) and c:IsMonster() and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.exfilter2,tp,LOCATION_DECK,0,1,nil,c)
end
function s.exfilter2(c,mc)
	return Card.ListsArchetype(c,0x7970,0x7971) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra() 
		and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SendtoExtraP(e:GetHandler(),tp,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,tp,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local mg=Duel.GetMatchingGroup(s.exfilter2,tp,LOCATION_DECK,0,nil,g:GetFirst())
		if #mg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			g:Merge(sg)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
end
end
end
