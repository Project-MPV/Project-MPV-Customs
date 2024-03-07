--Nefarioit Crimson Specter
local s,id=GetID()
function s.initial_effect(c)
	--FLIP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.trtg)
	e1:SetOperation(s.trop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.c)
	e2:SetTarget(s.t)
	e2:SetOperation(s.o)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc12}
function s.fycon(c)
	return c:IsFaceup() and c:IsSetCard(0xfc12) and c:IsType(TYPE_RITUAL)
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsDestructable),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	local ck=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil,tp,POS_FACEUP)
		and Duel.IsExistingMatchingCard(s.fycon,tp,LOCATION_MZONE,0,1,nil)
	--
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsDestructable),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if #g>0 then
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
	if ck and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
	local vs=Duel.GetFieldGroup(tp,0,LOCATION_DECK):RandomSelect(tp,1)
	if #vs>0 then
	Duel.Remove(vs,POS_FACEUP,REASON_EFFECT)
end
end
end
end

function s.rtfilter(c)
	return c:IsAbleToDeck() and c:IsRitualMonster()
end
function s.rtfilter2(c)
	return c:IsRitualSpell() and c:IsAbleToHand()
end
function s.c(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsFacedown()
end
function s.t(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
end
function s.o(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(cg,nil,1,REASON_EFFECT)
	if c:IsRelateToEffect(e) then
	if Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)~=0 then
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rtfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
end
end
end
end
