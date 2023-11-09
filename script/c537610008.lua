--Dichroic Excess
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.con)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x391}
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x391),tp,LOCATION_MZONE,0,1,nil)
end
function s.fycon(c)
	return c:IsFaceup() and c:IsSetCard(0x391) and c:IsType(TYPE_FUSION)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ck=Duel.IsExistingMatchingCard(s.fycon,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil,e,tp,ck) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local ck=Duel.IsExistingMatchingCard(s.fycon,tp,LOCATION_MZONE,0,1,nil)
if ck and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
	--Decrease 1000 and cannot trigger
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
	e1:SetValue(-1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.mcond)
	e3:SetValue(s.mlimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	c:RegisterFlagEffect(0,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
else
	--Decrease 200
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
	e1:SetValue(-200)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e2,tp)
end
end
function s.mcond(e)
	return Duel.IsBattlePhase()
end
function s.mlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
--
function s.thfilter(c)
	return (c:GetReason()&0x40008)==0x40008 and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)	
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
end