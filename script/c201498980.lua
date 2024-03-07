--Imaginary Force Crescent Light
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=false
		s[1]=false
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE_STEP_END)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=false
			s[1]=false
		end)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsSetCard(0x303) then
		s[a:GetControler()]=true
	end
	if d and d:IsSetCard(0x303) then
		s[d:GetControler()]=true
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return s[tp]
end
function s.filter(c)
	return c:IsSetCard(0x303) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.pfilter(c,code)
	return c:IsSetCard(0x303) and c:IsAbleToHand() and c:IsCode(code)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--Add Copy
	if Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil,g:GetFirst():GetCode()) then
        local g2=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil,g:GetFirst():GetCode())
        if g2:GetCount()>0 then
          Duel.SendtoHand(g2,nil,REASON_EFFECT)
        end
        end
        end
        end       