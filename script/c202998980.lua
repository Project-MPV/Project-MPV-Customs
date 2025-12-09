--Enigmation Force - Disaster Hawk
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(s.ffilter),4,2,nil,nil,Xyz.InfiniteMats)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x303,0x344}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x303) or c:IsSetCard(0x344)
end
function s.banish(c)
	return c:IsAbleToRemove() 
end
function s.rfilter(c)
	return c:IsLocation(LOCATION_REMOVED)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banish,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,e:GetHandler())
	and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banish,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(s.banish,tp,LOCATION_GRAVE,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.banish,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,e:GetHandler())
	local tc=g:GetFirst()
	--
	if tc then
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(-800)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		Duel.RegisterEffect(e2,tp)
		if (tc:IsSetCard(0x303) or tc:IsSetCard(0x344)) then
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
		if sg then
		Duel.HintSelection(sg)
		if Duel.SendtoDeck(sg,nil,1,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
end
end
end
end
end
end
