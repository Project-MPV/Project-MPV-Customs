--Bahamut - Pendulum Genesis
local s,id=GetID()
function c200009316.initial_effect(c)
	--PendulumSummon
	Pendulum.AddProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atcost)
	e1:SetTarget(s.atg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)		  
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		tc:RegisterEffect(e1)
	end
end