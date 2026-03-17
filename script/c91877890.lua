--Alistair, Trickster of the Waxing Moon
--Scripted by fawwazzed
if not PROC_REBIRTH_LOADED then Duel.LoadScript("proc_rebirth.lua") end
if not MPV_CONSTANTS_IMPORTED then Duel.LoadScript("MPV_constant.lua") end
local s,id=GetID()
s.Rebirth=true
function s.initial_effect(c)
    c:EnableReviveLimit()   
    --REBIRTH SUMMON: 2 Level 4 Monsters= Grade 8
    Rebirth.AddProcedure(c,8,nil,2,2)
	--Set 1 Spell/Trap (With Coin Toss)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Coin Toss Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetSummonType()==SUMMON_TYPE_REBIRTH
end
function s.setfilter(c)
	return c.toss_coin and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,2)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res={Duel.TossCoin(tp,2)}
	local heads=0
	local tails=0
	for i=1,#res do
		if res[i]==1 then heads=heads+1 else tails=tails+1 end
	end	
	--HEADS
	if heads>0 then
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			e1:SetValue(heads*500)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			c:RegisterEffect(e2)
		end		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,heads,heads,c)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end	
	--TAILS
	if tails>0 then
		local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
		if #g2>0 then
			local tc=g2:GetFirst()
			while tc do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(tails*700)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e2)
				tc=g2:GetNext()
			end
		end
	end
end