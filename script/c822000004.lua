--Venom Pudde
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x50}
s.counter_place_list={0x1009}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and not c:IsLocation(LOCATION_DECK)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.filter(c)
	return c:IsRace(RACE_REPTILE) and c:HasLevel()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end 
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Group.CreateGroup()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end 
	local tc=g:GetFirst()  
	for i=1,e:GetLabel() do	
		local tc=g:Select(tp,1,1,nil)	
		local atk=tc:GetFirst():GetAttack()	
		tc:GetFirst():AddCounter(0x1009,1) 		   
  if atk>0 and tc:GetFirst():GetAttack()==0 then
 	 Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
end
end
end

