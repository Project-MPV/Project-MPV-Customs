--Nefarioit Manifestation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Ritual.AddProcGreater{handler=c,filter=s.ritualfil,extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg}
	--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
s.listed_series={0xfc12}
function s.ritualfil(c)
	return c:IsSetCard(0xfc12) and c:IsRitualMonster()
end
function s.mfilter(c)
	return c:HasLevel() and c:IsMonster() and c:IsAbleToDeck()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD):Filter(Card.IsType,nil,TYPE_MONSTER)
	Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
function s.costfilter(c)
	return c:IsSetCard(0xfc12) and c:IsType(TYPE_RITUAL) and c:IsMonster() and c:IsAbleToDeck()
end
function s.flipfilter(c)
	return c:IsMonster() and not c:IsType(TYPE_RITUAL) and c:IsType(TYPE_FLIP) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() and chkc:IsControler(tp)  and chkc~=e:GetHandler()  and Duel.IsPlayerCanDraw(tp,1)  end
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		and Duel.IsExistingTarget(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
			Duel.BreakEffect()
		local g=Duel.SelectMatchingCard(tp,s.flipfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
end
end
end
