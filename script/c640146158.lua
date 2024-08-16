--Enigmation - Overlay Spider
local s,id=GetID()
function s.initial_effect(c)
	--REMOVE
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--Negate all face-up Spell/Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcond)
	e2:SetCost(s.negcost)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={0x344}
function s.tgfilter(c)
	return c:IsSetCard(0x344) and c:IsMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
		if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
end
end
end
function s.xyzfilter(c)
	return c:IsSetCard(0x344) and c:IsType(TYPE_XYZ)
end
function s.negcond(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
	and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.xyzfilter),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
	and Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSpellTrap),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)>0
end
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x344) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true) 
end
function s.attachfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
function s.xyz(c,mc,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Negate face-up spell/trap
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())
	for rc in aux.Next(g) do
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	rc:RegisterEffect(e1)
end
	if Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_GRAVE,0,1,nil,tp) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local mc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local xyzc=Duel.SelectMatchingCard(tp,s.xyz,tp,LOCATION_MZONE,0,1,1,nil,mc,tp):GetFirst()
	if not xyzc:IsImmuneToEffect(e) then
	Duel.BreakEffect()
	Duel.Overlay(xyzc,mc)
end
end
end
